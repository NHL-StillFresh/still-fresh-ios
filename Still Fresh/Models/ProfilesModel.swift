//
//  ProfilesModel.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 21/05/2025.
//

struct ProfileModel: Encodable, Decodable {
    let user_id: String
    let profile_first_name: String
    let profile_last_name: String
    let created_at: String?
    let updated_at: String?
}
