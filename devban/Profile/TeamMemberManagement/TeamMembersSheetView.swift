import SwiftUI

struct TeamMembersSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var teamMembers: [(uid: String, name: String, role: String)] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var selectedMemberForAction: String?
    @State private var showRemoveConfirmation: Bool = false
    @State private var showTransferAdminConfirmation: Bool = false
    
    let currentUserUID: String?
    let currentUserRole: String?
    let teamId: String?
    
    var isCurrentUserAdmin: Bool {
        currentUserRole == "admin"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        Text("Error")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            loadTeamMembers()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(teamMembers, id: \.uid) { member in
                            TeamMemberManagementView(
                                member: member,
                                currentUserUID: currentUserUID,
                                isCurrentUserAdmin: isCurrentUserAdmin,
                                onRemove: { removeMember(uid: member.uid) },
                                onTransferAdmin: { transferAdmin(to: member.uid) }
                            )
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Team Members (\(teamMembers.count))")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Confirm Remove", isPresented: $showRemoveConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    confirmRemoveMember()
                }
            } message: {
                Text("Are you sure you want to remove this member?")
            }

            .alert("Transfer Admin", isPresented: $showTransferAdminConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Transfer", role: .destructive) {
                    confirmTransferAdmin()
                }
            } message: {
                Text("Are you sure you want to transfer admin privileges?")
            }

            .toolbar {

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadTeamMembers()
            }
        }
    }
    
    private func loadTeamMembers() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // get team members
                guard let teamId = teamId else {
                    throw NSError(domain: "TeamMembers", code: 400,
                                userInfo: [NSLocalizedDescriptionKey: "Team ID is nil"])
                }
                
                let team = try await DevbanTeam.getTeam(teamId)
                
                // get user details for each member
                var members: [(uid: String, name: String, role: String)] = []
                
                for (uid, role) in team.members {
                    do {
                        let user = try await DevbanUser.getUser(uid)
                        members.append((
                            uid: uid,
                            name: user.displayName ?? "Unknown",
                            role: role.rawValue
                        ))
                    } catch {
                        // user fetch failed, use uid as name fallback
                        members.append((uid: uid, name: uid, role: role.rawValue))
                    }
                }
                
                await MainActor.run {
                    self.teamMembers = members
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func removeMember(uid: String) {
        selectedMemberForAction = uid
        showRemoveConfirmation = true
    }
    
    private func confirmRemoveMember() {
        guard let uid = selectedMemberForAction, let teamId = teamId else { return }
        
        isLoading = true
        
        Task {
            do {
                try await DevbanTeam.deleteUser(teamId: teamId, uid: uid)
                try await DevbanUserContainer.shared.setTeam(id: teamId)
                
                await MainActor.run {
                    teamMembers.removeAll { $0.uid == uid }
                    isLoading = false
                    showRemoveConfirmation = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to remove member: \(error.localizedDescription)"
                    isLoading = false
                    showRemoveConfirmation = false
                }
            }
        }
    }
    
    private func transferAdmin(to uid: String) {
        selectedMemberForAction = uid
        showTransferAdminConfirmation = true
    }
    
    private func confirmTransferAdmin() {
        guard let newAdminUid = selectedMemberForAction,
              let currentUserUID = currentUserUID,
              let teamId = teamId else { return }
        
        isLoading = true
        
        Task {
            do {
                try await DevbanTeam.transferAdmin(
                    teamId: teamId,
                    fromUid: currentUserUID,
                    toUid: newAdminUid
                )
                try await DevbanUserContainer.shared.setTeam(id: teamId)
                await MainActor.run {
                    // update local state
                    if let index = teamMembers.firstIndex(where: { $0.uid == newAdminUid }) {
                        teamMembers[index].role = "admin"
                    }
                    if let index = teamMembers.firstIndex(where: { $0.uid == currentUserUID }) {
                        teamMembers[index].role = "member"
                    }
                    
                    isLoading = false
                    showTransferAdminConfirmation = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to transfer admin: \(error.localizedDescription)"
                    isLoading = false
                    showTransferAdminConfirmation = false
                }
            }
        }
    }
}

#Preview {
    TeamMembersSheetView(
        currentUserUID: "user1",
        currentUserRole: "admin",
        teamId: "team1"
    )
}
