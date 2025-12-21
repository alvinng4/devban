import SwiftUI

struct TeamMemberManagementView: View
{
    let member: (uid: String, name: String, role: String)
    let currentUserUID: String?
    let isCurrentUserAdmin: Bool
    let onRemove: () -> Void
    let onTransferAdmin: () -> Void

    var isCurrentUser: Bool
    {
        member.uid == currentUserUID
    }

    var isAdmin: Bool
    {
        member.role == "admin"
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 12)
        {
            HStack(spacing: 12)
            {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4)
                {
                    HStack(spacing: 8)
                    {
                        Text(member.name)
                            .font(.system(.body, design: .default))
                            .fontWeight(isCurrentUser || isAdmin ? .bold : .regular)

                        if isCurrentUser
                        {
                            Text("(You)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                        }

                        if isAdmin
                        {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    Text(isAdmin ? "Admin" : "Member")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // management actions (only for Admins)
            if isCurrentUserAdmin, !isCurrentUser
            {
                HStack(spacing: 12)
                {
                    /*
                     Button(role: .destructive) {
                         onRemove()
                     } label: {
                         Label("Remove", systemImage: "xmark.circle.fill")
                             .font(.caption)
                     }
                     .buttonStyle(.bordered)
                     */
                    Button
                    {
                        onTransferAdmin()
                    } label: {
                        Label("Transfer Admin", systemImage: "crown")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)

                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview
{
    List
    {
        TeamMemberManagementView(
            member: (uid: "1", name: "Alvin Ng", role: "admin"),
            currentUserUID: "1",
            isCurrentUserAdmin: true,
            onRemove: {},
            onTransferAdmin: {},
        )

        TeamMemberManagementView(
            member: (uid: "2", name: "User B", role: "member"),
            currentUserUID: "1",
            isCurrentUserAdmin: true,
            onRemove: {},
            onTransferAdmin: {},
        )

        TeamMemberManagementView(
            member: (uid: "3", name: "User C", role: "member"),
            currentUserUID: "1",
            isCurrentUserAdmin: false,
            onRemove: {},
            onTransferAdmin: {},
        )
    }
}
