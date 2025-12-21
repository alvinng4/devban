import SwiftUI

/// Sheet view for displaying and managing team members.
///
/// This view displays a list of team members with their roles and allows admins to:
/// - View all team members in a sorted list (Admin first, current user second, then alphabetically)
/// - Transfer admin privileges to another member
/// - Remove members from the team (if they are an admin)
///
/// The view automatically loads team data from Firestore and maintains real-time synchronization
/// through a callback mechanism when admin privileges are transferred.
struct TeamMembersSheetView: View
{
    // MARK: - Environment & Dismissal

    /// Environment variable to dismiss this sheet
    @Environment(\.dismiss) var dismiss

    // MARK: - State Variables

    /// Array of team members with their uid, display name, and role
    @State private var teamMembers: [(uid: String, name: String, role: String)] = []

    /// Loading state for async operations
    @State private var isLoading: Bool = false

    /// Error message to display if an operation fails
    @State private var errorMessage: String?

    /// Tracks which member is selected for an action (remove or transfer admin)
    @State private var selectedMemberForAction: String?

    /// Controls visibility of the remove confirmation alert
    @State private var showRemoveConfirmation: Bool = false

    /// Controls visibility of the transfer admin confirmation alert
    @State private var showTransferAdminConfirmation: Bool = false

    // MARK: - Input Parameters

    /// The current user's unique identifier
    let currentUserUID: String?

    /// The current user's role in the team ("admin" or "member")
    let currentUserRole: String?

    /// The team's unique identifier
    let teamId: String?

    /// Optional callback that fires when admin privileges are successfully transferred
    /// Used to notify parent view to refresh team data
    let onAdminTransferred: (() -> Void)?

    // MARK: - Computed Properties

    /// Determines if the current user has admin privileges
    var isCurrentUserAdmin: Bool
    {
        currentUserRole == "admin"
    }

    // MARK: - View Body

    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()

                if isLoading
                {
                    // Show loading spinner during async operations
                    ProgressView()
                }
                else if let errorMessage
                {
                    // Show error state with retry button
                    VStack(spacing: 16)
                    {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .multilineTextAlignment(.center)

                        Button("Retry")
                        {
                            loadTeamMembers()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
                else
                {
                    // Main content: list of team members
                    List
                    {
                        ForEach(teamMembers, id: \.uid)
                        { member in
                            TeamMemberManagementView(
                                member: member,
                                currentUserUID: currentUserUID,
                                isCurrentUserAdmin: isCurrentUserAdmin,
                                onRemove: { removeMember(uid: member.uid) },
                                onTransferAdmin: { transferAdmin(to: member.uid) },
                            )
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Team Members (\(teamMembers.count))")
            .navigationBarTitleDisplayMode(.inline)
            // Confirmation alert for removing a member
            .alert("Confirm Remove", isPresented: $showRemoveConfirmation)
            {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive)
                {
                    confirmRemoveMember()
                }
            } message: {
                Text("Are you sure you want to remove this member?")
            }

            // Confirmation alert for transferring admin privileges
            .alert("Transfer Admin", isPresented: $showTransferAdminConfirmation)
            {
                Button("Cancel", role: .cancel) {}
                Button("Transfer", role: .destructive)
                {
                    confirmTransferAdmin()
                }
            } message: {
                Text("Are you sure you want to transfer admin privileges?")
            }

            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button("Close")
                    {
                        dismiss()
                    }
                }
            }
            .onAppear
            {
                loadTeamMembers()
            }
        }
    }

    // MARK: - Sorting Helper

    /// Sorts team members according to a priority system:
    /// 1. Admin role always appears first
    /// 2. Current user (if not admin) appears second among their role group
    /// 3. Remaining members within the same role are sorted alphabetically by displayName (or uid as fallback)
    ///
    /// This ensures a stable, predictable member list order that doesn't change unexpectedly.
    ///
    /// - Parameter members: The unsorted array of team members
    /// - Returns: A sorted array of team members following the priority rules
    private func sortedTeamMembers(_ members: [(uid: String, name: String, role: String)]) -> [(
        uid: String,
        name: String,
        role: String,
    )]
    {
        members.sorted
        { memberA, memberB in
            // Priority 1: Admin always comes first
            // If one is admin and the other isn't, admin comes first
            if memberA.role == "admin", memberB.role != "admin"
            {
                return true
            }
            if memberA.role != "admin", memberB.role == "admin"
            {
                return false
            }

            // At this point, both members have the same role
            // Priority 2: If current user is not admin, prioritize them second
            // This ensures current user appears right after admin (or first if current user is admin)
            if !isCurrentUserAdmin
            {
                let memberAIsCurrentUser = memberA.uid == currentUserUID
                let memberBIsCurrentUser = memberB.uid == currentUserUID

                if memberAIsCurrentUser, !memberBIsCurrentUser
                {
                    return true
                }
                if !memberAIsCurrentUser, memberBIsCurrentUser
                {
                    return false
                }
            }

            // Priority 3: Sort by displayName alphabetically (case-insensitive)
            // If displayName is empty, use uid as fallback for stable sorting
            let memberAName = memberA.name.isEmpty ? memberA.uid : memberA.name
            let memberBName = memberB.name.isEmpty ? memberB.uid : memberB.name

            return memberAName.localizedCaseInsensitiveCompare(memberBName) == .orderedAscending
        }
    }

    // MARK: - Data Loading

    /// Fetches team members from Firestore and populates the teamMembers list.
    ///
    /// This function:
    /// 1. Retrieves the team document from Firestore
    /// 2. For each member, fetches their display name from the users collection
    /// 3. Falls back to using the uid if the user document cannot be fetched
    /// 4. Sorts the members according to the priority rules
    /// 5. Updates the UI on the main thread
    ///
    /// If any error occurs, it's displayed in an error state with a retry option.
    private func loadTeamMembers()
    {
        isLoading = true
        errorMessage = nil

        Task
        {
            do
            {
                // Validate that we have a team ID
                guard let teamId
                else
                {
                    throw NSError(domain: "TeamMembers", code: 400,
                                  userInfo: [NSLocalizedDescriptionKey: "Team ID is nil"])
                }

                // Fetch the team document from Firestore
                let team = try await DevbanTeam.getTeam(teamId)

                // Build member list with display names
                var members: [(uid: String, name: String, role: String)] = []

                for (uid, role) in team.members
                {
                    do
                    {
                        // Try to fetch the user's display name
                        let user = try await DevbanUser.getUser(uid)
                        let displayName = user.displayName.isEmpty ? uid : user.displayName
                        members.append((
                            uid: uid,
                            name: displayName,
                            role: role.rawValue,
                        ))
                    }
                    catch
                    {
                        // If user fetch fails, use uid as the display name
                        members.append((uid: uid, name: uid, role: role.rawValue))
                    }
                }

                // Sort members before displaying
                let sortedMembers = sortedTeamMembers(members)

                // Update UI on main thread
                await MainActor.run
                {
                    self.teamMembers = sortedMembers
                    self.isLoading = false
                }
            }
            catch
            {
                await MainActor.run
                {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Member Removal

    /// Initiates the member removal flow by showing a confirmation alert.
    ///
    /// - Parameter uid: The unique identifier of the member to remove
    private func removeMember(uid: String)
    {
        selectedMemberForAction = uid
        showRemoveConfirmation = true
    }

    /// Confirms and executes the removal of a member from the team.
    ///
    /// This function:
    /// 1. Removes the member from the team in Firestore
    /// 2. Refreshes the team data in the user container
    /// 3. Updates the local UI by removing the member from the list
    /// 4. Displays error message if operation fails
    private func confirmRemoveMember()
    {
        guard let uid = selectedMemberForAction, let teamId else { return }

        isLoading = true

        Task
        {
            do
            {
                // Remove member from team in Firestore
                try await DevbanTeam.deleteUser(teamId: teamId, uid: uid)

                // Refresh the team data in the global container
                try await DevbanUserContainer.shared.setTeam(id: teamId)

                await MainActor.run
                {
                    // Remove from local list
                    teamMembers.removeAll { $0.uid == uid }
                    isLoading = false
                    showRemoveConfirmation = false
                }
            }
            catch
            {
                await MainActor.run
                {
                    errorMessage = "Failed to remove member: \(error.localizedDescription)"
                    isLoading = false
                    showRemoveConfirmation = false
                }
            }
        }
    }

    // MARK: - Admin Transfer

    /// Initiates the admin transfer flow by showing a confirmation alert.
    ///
    /// - Parameter uid: The unique identifier of the member to promote to admin
    private func transferAdmin(to uid: String)
    {
        selectedMemberForAction = uid
        showTransferAdminConfirmation = true
    }

    /// Confirms and executes the transfer of admin privileges to another member.
    ///
    /// This function:
    /// 1. Calls the backend to transfer admin privileges (using Firestore transaction)
    /// 2. Updates the team data in the global container
    /// 3. Updates local member roles and re-sorts the list
    /// 4. Triggers the onAdminTransferred callback to notify parent view
    /// 5. Displays error message if operation fails
    private func confirmTransferAdmin()
    {
        guard let newAdminUid = selectedMemberForAction,
              let currentUserUID,
              let teamId else { return }

        isLoading = true

        Task
        {
            do
            {
                // Execute the admin transfer in Firestore (uses transaction for consistency)
                try await DevbanTeam.transferAdmin(
                    teamId: teamId,
                    fromUid: currentUserUID,
                    toUid: newAdminUid,
                )

                // Refresh team data in the global container
                try await DevbanUserContainer.shared.setTeam(id: teamId)

                await MainActor.run
                {
                    // Update local member roles
                    if let index = teamMembers.firstIndex(where: { $0.uid == newAdminUid })
                    {
                        teamMembers[index].role = "admin"
                    }
                    if let index = teamMembers.firstIndex(where: { $0.uid == currentUserUID })
                    {
                        teamMembers[index].role = "member"
                    }

                    // Re-apply sorting to reflect role changes
                    teamMembers = sortedTeamMembers(teamMembers)

                    isLoading = false
                    showTransferAdminConfirmation = false

                    // Notify parent view to refresh (for Profile page)
                    onAdminTransferred?()
                }
            }
            catch
            {
                await MainActor.run
                {
                    errorMessage = "Failed to transfer admin: \(error.localizedDescription)"
                    isLoading = false
                    showTransferAdminConfirmation = false
                }
            }
        }
    }
}

#Preview
{
    TeamMembersSheetView(
        currentUserUID: "user1",
        currentUserRole: "admin",
        teamId: "team1",
        onAdminTransferred: nil,
    )
}
