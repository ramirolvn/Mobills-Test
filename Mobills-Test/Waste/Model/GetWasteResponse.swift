import Foundation
import Firebase

struct GetWasteResponse {
    var errDocument: String?
    var errImage: String?
    
    init(errorDocmt: Error?, errorImg: Error?) {
        if let err = errorDocmt, let errMsg = FirestoreErrorCode(rawValue: err._code)?.errorMessage{
            self.errDocument = errMsg
        }
        if errorImg != nil{
            self.errImage = "Erro ao salvar imagem."
        }
    }
}


