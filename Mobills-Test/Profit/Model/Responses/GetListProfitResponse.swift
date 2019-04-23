import Foundation
import Firebase

struct GetListProfitResponse {
    var err: String?
    var userProfits: [FirebaseProfit]?
    
    init(data: QuerySnapshot?,error: Error?) {
        if let err = error, let errMsg = FirestoreErrorCode(rawValue: err._code)?.errorMessage{
            self.err = errMsg
        }
        if let data = data{
            var userProfitsAux = [FirebaseProfit]()
            for d in data.documents{
                
                if let firebaseProfit = FirebaseProfit(d, documentID: d.documentID){
                    userProfitsAux.append(firebaseProfit)
                }
            }
            self.userProfits = userProfitsAux
        }
    }
}


