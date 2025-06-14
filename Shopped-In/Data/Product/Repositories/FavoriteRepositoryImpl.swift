//
//  FavoriteRepositoryImpl.swift
//  Shopped-In
//
//  Created by Ayatullah Salah on 08/06/2025.
//
import FirebaseFirestore
import FirebaseAuth
class FavoriteRepositoryImpl: FavoriteRepository {
   
    
    private let db=Firestore.firestore()
    private var userID: String? {
           return Auth.auth().currentUser?.uid
       }
    func isFavorite(productID: String, completion: @escaping (Bool) -> Void) {
        guard let uid = userID else {
            completion(false)
            return
        }
        let docRef = db.collection("users").document(uid).collection("favorites").document(productID)
        docRef.getDocument { doc, error in
            if let doc = doc, doc.exists {
                completion(true)
            } else {
                completion(false)
            }
        }

    }
    
    func addToFavorite(product: Product, completion: @escaping ((any Error)?) -> Void) {
        guard let uid = userID else {
                 completion(NSError(domain: "No user", code: 401, userInfo: nil))
                 return
             }
             let favRef = db.collection("users").document(uid).collection("favorites").document(product.title) 
             let data: [String: Any] = [
                "id": product.id,
                 "title": product.title,
                 "price": product.price,
                 "images": product.images,
                 "description": product.description
             ]
             favRef.setData(data) { error in
                 completion(error)
             }    }
    
    func removeFromFavorite(productID: String, completion: @escaping ((any Error)?) -> Void) {
        guard let uid = userID else {
                   completion(NSError(domain: "No user", code: 401, userInfo: nil))
                   return
               }
               let favRef = db.collection("users").document(uid).collection("favorites").document(productID)
               favRef.delete { error in
                   completion(error)
               }
           }
    }
    


