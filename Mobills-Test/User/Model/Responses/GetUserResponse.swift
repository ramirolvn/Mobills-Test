import Foundation
import Firebase

struct GetUserResponse {
    
    var user: FirebaseUser?
    var err: String?
    
    init(data: AuthDataResult?, error: Error?) {
        if let err = error, let errMsg = AuthErrorCode(rawValue: err._code)?.errorMessage{
            self.err = errMsg
        }
        if  let user = data?.user{
            self.user = FirebaseUser(user)
            let realmUser = RealmUser()
            realmUser.saveUser(FirebaseUser(user))
        }
    }
    
}


