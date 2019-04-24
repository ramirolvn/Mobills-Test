import Foundation
import Firebase

class WasteNetworking {
    private init() {}
    
    static func createWaste(userUID: String, waste: FirebaseWaste, completion: @escaping (GetWasteResponse) -> Void) {
        var documentErr: Error?
        let ref = userBalanceRef.document(userUID).collection("wastes").addDocument(data: waste.dictionary, completion:{ (errorDocument) in
            documentErr = errorDocument
        })
        let imageData = waste.image ?? Data()
        userImagesRef.child(userUID).child("wastes").child(ref.documentID).putData(imageData, metadata: nil) { (metadata, errorFoto) in
            let response = GetWasteResponse(errorDocmt: documentErr, errorImg: errorFoto)
            completion(response)
        }
        
    }
    
    static func getUserWastes(userUID: String, completion: @escaping (GetListWasteResponse) -> Void) {
        userBalanceRef.document(userUID).collection("wastes").getDocuments(completion: {(data, errorDocument) in
            let response = GetListWasteResponse(data: data, error: errorDocument)
            completion(response)
        })
    }
    
    static func getWasteImage(userUID: String, documentID: String, completion: @escaping (Data?, String) -> Void){
        userImagesRef.child(userUID).child("wastes").child(documentID).getData(maxSize: 4 * 1024 * 1024) { data, error in
            completion(data, "Erro ao carregar imagem" )
        }
    }
    
    static func updateWaste(userUID: String, waste: FirebaseWaste, completion: @escaping (GetWasteResponse) -> Void) {
        userBalanceRef.document(userUID).collection("wastes").document(waste.documentID!).updateData(waste.dictionary){ errDocument in
            let imageData = waste.image ?? Data()
            userImagesRef.child(userUID).child("wastes").child(waste.documentID!).putData(imageData, metadata: nil) { (metadata, errorFoto) in
                let response = GetWasteResponse(errorDocmt: errDocument, errorImg: errorFoto)
                completion(response)
            }
        }
    }
    
    static func deleteWaste(userUID: String, waste: FirebaseWaste, completion: @escaping (GetWasteResponse) -> Void) {
        userBalanceRef.document(userUID).collection("wastes").document(waste.documentID!).delete(){ errDocument in
            userImagesRef.child(userUID).child("wastes").child(waste.documentID!).delete(completion: {
                (errorPhoto) in
                let response = GetWasteResponse(errorDocmt: errDocument, errorImg: errorPhoto)
                completion(response)
            })
        }
    }
}
