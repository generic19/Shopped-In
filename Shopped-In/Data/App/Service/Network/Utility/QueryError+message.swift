//
//  QueryError+message.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 31/05/2025.
//

import Buy

extension Graph.QueryError? {
    func message(object: String) -> String {
        switch self {
            case .request(error: let error): 
                return error?.localizedDescription ?? "Error requesting \(object)."
                
            case .noData:
                return "Did not receive any data for \(object)."
                
            case .http(statusCode: let statusCode):
                if statusCode < 500 {
                    return "Server refused request to fetch \(object) data."
                } else {
                    return "Server could not send \(object) data."
                }
                
            case .jsonDeserializationFailed(data: let data):
                print("json deserialization failed \(String(describing: data))")
                return "Malformed response from server for \(object) data."
        
            case .invalidJson(json: let json):
                print("invalid json \(json)")
                return "Malformed response from server for \(object) data."
                
            case .invalidQuery(reasons: let reasons):
                print("invalid query \(reasons)")
                return "Requset format for \(object) no longer supported."
                
            case .schemaViolation(violation: let violation):
                print("schema violation \(violation)")
                return "Request format for \(object) no longer supported."
                
            default:
                return "Could not fetch \(object)."
        }
    }
}
