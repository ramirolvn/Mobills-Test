import Foundation
import Firebase

class UserNetworking {
    private init() {}
    
    static func registerUser(email: String, password: String, completion: @escaping (GetUserResponse) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (data, error) in
            let response =  GetUserResponse(data: data, error: error)
            completion(response)
        }
    }
    static func loginUser(email: String, password: String, completion: @escaping (GetUserResponse) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (data, error) in
            let response = GetUserResponse(data: data, error: error)
            completion(response)
        })
    }
    
    static func logoutUser(_ user : FirebaseUser, completion: @escaping (GetLogoutResponse) -> Void) {
        let firebaseAuth = Auth.auth()
        let response = GetLogoutResponse(firebaseAuth: firebaseAuth, firebaseUser: user)
        completion(response)
    }
}
