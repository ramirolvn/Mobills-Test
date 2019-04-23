import Foundation
import Firebase
import RealmSwift

struct FirebaseProfit {
    public let valor: NSNumber?
    public let descricao: String?
    public let data: Timestamp?
    public let recebido: Bool?
    public var image: Data?
    public var documentID: String? = ""
    var dictionary: [String: Any] {
        return ["valor": valor ?? nil,
                "descricao": descricao ?? nil,
                "data": data ?? nil,
                "recebido": recebido ?? nil]
    }
    
    init?(_ firebaseWaste: [String: Any]) {
        guard let valor = firebaseWaste["valor"] as? NSNumber else { return nil }
        guard let descricao = firebaseWaste["descricao"] as? String else { return nil }
        guard let data = firebaseWaste["data"] as? Date else { return nil }
        guard let recebido = firebaseWaste["recebido"] as? Bool else { return nil }
        guard let image = firebaseWaste["image"] as? Data else { return nil }
        self.valor = valor
        self.descricao = descricao
        self.data = Timestamp(date: data)
        self.recebido = recebido
        self.image = image
        self.documentID = firebaseWaste["documentID"] as? String ?? ""
    }
    
    init?(_ firebaseWaste: QueryDocumentSnapshot, documentID: String) {
        
        guard let valor = firebaseWaste.data()["valor"] as? NSNumber else { return nil }
        guard let descricao = firebaseWaste.data()["descricao"] as? String else { return nil }
        guard let data = firebaseWaste.data()["data"] as? Timestamp else { return nil }
        guard let recebido = firebaseWaste.data()["recebido"] as? Bool else { return nil }
        self.valor = valor
        self.descricao = descricao
        self.data = data
        self.documentID = documentID
        self.recebido = recebido
    }
}
