import Foundation
import Firebase

struct GetLogoutResponse {
    
    var err: String?
    
    init(firebaseAuth: Auth?, firebaseUser: FirebaseUser) {
        do {
            try firebaseAuth?.signOut()
            RealmUser().removeUser(firebaseUser)
        } catch let signOutError{
            if let errMsg = AuthErrorCode(rawValue: signOutError._code)?.errorMessage{
                self.err = errMsg
            }
        }
    }
}


