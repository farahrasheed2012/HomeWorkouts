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
        VStack(spacing: HSTheme.spaceSection) {
            Text("Who's working out?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, HSTheme.spaceXL)
            
            VStack(spacing: HSTheme.spaceMD) {
                ForEach(UserStore.availableProfiles) { profile in
                    Button {
                        userStore.selectUser(profile)
                        onProfileSelected?()
                    } label: {
                        HStack(spacing: HSTheme.spaceMD) {
                            Image(systemName: profile.profileType.icon)
                                .font(.title)
                                .foregroundStyle(HSTheme.accent)
                                .frame(width: 44, height: 44)
                                .background(HSTheme.accentFill)
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: HSTheme.spaceXS) {
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
                        .padding(HSTheme.spaceMD)
                        .background(HSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: HSTheme.radiusLG))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HSTheme.contentPaddingH)
            .padding(.top, HSTheme.spaceSM)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HSTheme.pageBackground)
    }
}

#Preview {
    UserSelectionView()
        .environmentObject(UserStore())
}
