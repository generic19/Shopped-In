//
//  FirebaseUser.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 26/06/2025.
//
import FirebaseAuth


protocol FirebaseUser {
  var email: String? { get }
  var displayName: String? { get }
  var isEmailVerified: Bool { get }
}

extension FirebaseAuth.User: FirebaseUser {}
