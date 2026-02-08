//
//  UserStore.swift
//  HomeStrength
//
//  Current user selection and persistence.
//

import Foundation
import SwiftUI

@MainActor
class UserStore: ObservableObject {
    private static let currentUserIdKey = "HomeStrength.currentUserId"
    
    @Published var currentUser: UserProfile?
    
    /// Predefined profiles: Mom, Middle School Daughter, 7-year-old, 5-year-old, Group Fitness Classes.
    static let availableProfiles: [UserProfile] = [
        UserProfile(profileType: .mom),
        UserProfile(profileType: .daughterMiddleSchool),
        UserProfile(profileType: .child7),
        UserProfile(profileType: .child5),
        UserProfile(profileType: .groupFitness),
    ]
    
    init() {
        loadCurrentUser()
    }
    
    func selectUser(_ profile: UserProfile) {
        currentUser = profile
        saveCurrentUser()
    }
    
    func signOut() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: Self.currentUserIdKey)
    }
    
    private func loadCurrentUser() {
        guard let raw = UserDefaults.standard.string(forKey: Self.currentUserIdKey) else { return }
        let type: UserProfileType? = UserProfileType(rawValue: raw) ?? (raw == "Daughter" ? .daughterMiddleSchool : nil)
        guard let type = type else { return }
        currentUser = UserProfile(profileType: type)
    }
    
    private func saveCurrentUser() {
        guard let user = currentUser else { return }
        UserDefaults.standard.set(user.profileType.rawValue, forKey: Self.currentUserIdKey)
    }
}
