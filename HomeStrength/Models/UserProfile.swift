//
//  UserProfile.swift
//  HomeStrength
//
//  Five profiles: Mom, Middle School Daughter, 7-year-old, 5-year-old, Group Fitness Classes.
//

import Foundation

enum UserProfileType: String, Codable, CaseIterable, Hashable {
    case mom = "Mom"
    case daughterMiddleSchool = "DaughterMS"
    case child7 = "Child7"
    case child5 = "Child5"
    case groupFitness = "GroupFitness"
    
    var displayName: String {
        switch self {
        case .mom: return "Mom"
        case .daughterMiddleSchool: return "Middle School Daughter"
        case .child7: return "7-Year-Old"
        case .child5: return "5-Year-Old"
        case .groupFitness: return "Group Fitness Classes"
        }
    }
    
    var subtitle: String {
        switch self {
        case .mom: return "At-home strength · Beginner-friendly"
        case .daughterMiddleSchool: return "Volleyball · Jump & serve"
        case .child7: return "Fun movement & games"
        case .child5: return "Super fun moves & play"
        case .groupFitness: return "Lead bodyweight classes · No equipment"
        }
    }
    
    var icon: String {
        switch self {
        case .mom: return "figure.strengthtraining.traditional"
        case .daughterMiddleSchool: return "figure.volleyball"
        case .child7: return "figure.run"
        case .child5: return "figure.play"
        case .groupFitness: return "person.3.fill"
        }
    }
    
    /// Stable UUID for progress tracking (same device, same profile = same id).
    var stableId: UUID {
        switch self {
        case .mom: return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        case .daughterMiddleSchool: return UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        case .child7: return UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        case .child5: return UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        case .groupFitness: return UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
        }
    }
    
    var isYoungKid: Bool { self == .child7 || self == .child5 }
    var isAdultOrTeen: Bool { !isYoungKid }
    var isGroupFitness: Bool { self == .groupFitness }
}

struct UserProfile: Identifiable, Hashable, Codable {
    /// Use stableId from profileType for progress; this id is for display/equality.
    var id: UUID { profileType.stableId }
    var profileType: UserProfileType
    /// Optional custom name (e.g. daughter's first name).
    var customName: String?
    
    var displayName: String {
        customName ?? profileType.displayName
    }
    
    init(profileType: UserProfileType, customName: String? = nil) {
        self.profileType = profileType
        self.customName = customName
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(profileType) }
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool { lhs.profileType == rhs.profileType }
}
