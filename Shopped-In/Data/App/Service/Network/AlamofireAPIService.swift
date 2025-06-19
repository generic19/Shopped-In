//
//  AlamofireAPIService.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 17/06/2025.
//
import Alamofire
import Foundation

final class AlamofireAPIService {
    protocol GraphQLRequest {
        associatedtype ResponseType: Decodable
        var body: String { get }
    }
    
    private static let GRAPHQL_URL = "https://mad45-ios3-sv.myshopify.com/admin/api/2025-04/graphql.json"
    static let shared = AlamofireAPIService()
    private let session: Session
    
    private init() {
        let config = URLSessionConfiguration.default
        
        config.headers = ["X-Shopify-Access-Token": ADMIN_API_ACCESS_TOKEN]
        config.timeoutIntervalForRequest = 15
        
        session = .init(configuration: config)
    }
    
    func request<RequestType: GraphQLRequest>(graphQL: RequestType, completion: @escaping (Result<RequestType.ResponseType, AFError>) -> Void) {
        let parameters = ["query": graphQL.body]
        
        session.request(
            AlamofireAPIService.GRAPHQL_URL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
        .validate()
        .responseDecodable(of: RequestType.ResponseType.self) { response in
            if let data = response.data, let string = String(data: data, encoding: .utf8) {
                print(string)
            }
            completion(response.result)
        }
    }
}
