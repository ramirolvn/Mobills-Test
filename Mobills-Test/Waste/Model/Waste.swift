import Foundation
import Firebase
import RealmSwift

struct FirebaseWaste {
    public let valor: NSNumber?
    public let descricao: String?
    public let data: Timestamp?
    public let pago: Bool?
    public var image: Data? = nil
    public var documentID: String? = ""
    var dictionary: [String: Any] {
        return ["valor": valor ?? nil,
                "descricao": descricao ?? nil,
                "data": data ?? nil,
                "pago": pago ?? nil]
    }
    
    init?(_ firebaseWaste: [String: Any]) {
        guard let valor = firebaseWaste["valor"] as? NSNumber else { return nil }
        guard let descricao = firebaseWaste["descricao"] as? String else { return nil }
        guard let data = firebaseWaste["data"] as? Date else { return nil }
        guard let pago = firebaseWaste["pago"] as? Bool else { return nil }
        guard let image = firebaseWaste["image"] as? Data else { return nil }
        self.valor = valor
        self.descricao = descricao
        self.data = Timestamp(date: data)
        self.pago = pago
        self.image = image
        self.documentID = firebaseWaste["documentID"] as? String ?? ""
    }
    
    init?(_ firebaseWaste: QueryDocumentSnapshot, documentID: String) {
        guard let valor = firebaseWaste.data()["valor"] as? NSNumber else { return nil }
        guard let descricao = firebaseWaste.data()["descricao"] as? String else { return nil }
        guard let data = firebaseWaste.data()["data"] as? Timestamp else { return nil }
        guard let pago = firebaseWaste.data()["pago"] as? Bool else { return nil }
        self.valor = valor
        self.descricao = descricao
        self.data = data
        self.documentID = documentID
        self.pago = pago
    }
}
