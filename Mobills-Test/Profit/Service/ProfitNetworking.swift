import Foundation
import Firebase

class ProfitNetworking {
    private init() {}
    
    static func createProfit(userUID: String, profit: FirebaseProfit, completion: @escaping (GetProfitResponse) -> Void) {
        var documentErr: Error?
        let ref = userBalanceRef.document(userUID).collection("profits").addDocument(data: profit.dictionary, completion:{ (errorDocument) in
            documentErr = errorDocument
        })
        let imageData = profit.image ?? Data()
        userImagesRef.child(userUID).child("profits").child(ref.documentID).putData(imageData, metadata: nil) { (metadata, errorFoto) in
            let response = GetProfitResponse(errorDocmt: documentErr, errorImg: errorFoto)
            completion(response)
        }
    }
    
    static func getUserPrtofits(userUID: String, completion: @escaping (GetListProfitResponse) -> Void) {
        userBalanceRef.document(userUID).collection("profits").getDocuments(completion: {(data, errorDocument) in
            let response = GetListProfitResponse(data: data, error: errorDocument)
            completion(response)
        })
    }
    
    static func getProfitImage(userUID: String, documentID: String, completion: @escaping (Data?, String) -> Void){
        userImagesRef.child(userUID).child("profits").child(documentID).getData(maxSize: 4 * 1024 * 1024) { data, error in
            completion(data, "Erro ao carregar imagem" )
        }
    }
    
    static func updateProfit(userUID: String, profit: FirebaseProfit) {
        userBalanceRef.document(userUID).collection("profits").document(profit.documentID!).updateData(profit.dictionary)
    }
}
