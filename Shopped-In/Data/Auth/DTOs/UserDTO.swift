//
//  UserDTO.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//
import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserDTO {
    let firebaseUser: FirebaseUser
    let randomToken: String
}
