import Foundation
import Firebase
import RealmSwift

struct FirebaseUser: Codable {
    public let uid: String
    public let email: String?
    public let refreshToken: String?
    
    init(_ firebaseUser: User) {
        self.uid = firebaseUser.uid
        self.email = firebaseUser.email
        self.refreshToken = firebaseUser.refreshToken
    }
}

class RealmUser : Object {
    
    @objc private dynamic var structData:Data? = nil
    var myStruct : FirebaseUser? {
        get {
            if let data = structData {
                return try? JSONDecoder().decode(FirebaseUser.self, from: data)
            }
            return nil
        }
        set {
            structData = try? JSONEncoder().encode(newValue)
        }
    }
    
    func saveUser(_ firebaseUser : FirebaseUser){
        let realm = try! Realm()
        try! realm.write {
            let myRealm = RealmUser()
            myRealm.myStruct = firebaseUser
            realm.add(myRealm)
        }
    }
    
    func retriveUser() -> FirebaseUser?{
        let realm = try! Realm()
        let results = realm.objects(RealmUser.self)
        if let firebaseUser = results.first?.myStruct{
            return firebaseUser
        }
        return nil
    }
    
    func removeUser(_ firebaseUser : FirebaseUser){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(RealmUser.self))
        }
    }
}
