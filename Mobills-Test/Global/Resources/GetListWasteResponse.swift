import Foundation
import Firebase

struct GetListWasteResponse {
    var err: String?
    var userWastes: [FirebaseWaste]?
    
    init(data: QuerySnapshot?,error: Error?) {
        if let err = error, let errMsg = FirestoreErrorCode(rawValue: err._code)?.errorMessage{
            self.err = errMsg
        }
        if let data = data{
            var userWastesAux = [FirebaseWaste]()
            for d in data.documents{
                if let firebaseWaste = FirebaseWaste(d, documentID: d.documentID){
                    userWastesAux.append(firebaseWaste)
                }
            }
            self.userWastes = userWastesAux
        }
    }
}


