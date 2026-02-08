//
//  UserSelectionView.swift
//  HomeStrength
//
//  User selection at app startup: Mom, Middle School Daughter, 7-Year-Old, 5-Year-Old, or Group Fitness Classes.
//

import SwiftUI

struct UserSelectionView: View {
    @EnvironmentObject var userStore: UserStore
    /// When set (e.g. when presented as a sheet), called after a profile is selected so the presenter can dismiss.
    var onProfileSelected: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Who's working out?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                ForEach(UserStore.availableProfiles) { profile in
                    Button {
                        userStore.selectUser(profile)
                        onProfileSelected?()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: profile.profileType.icon)
                                .font(.title)
                                .foregroundStyle(.orange)
                                .frame(width: 44, height: 44)
                                .background(Color.orange.opacity(0.2))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(profile.profileType.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    UserSelectionView()
        .environmentObject(UserStore())
}
