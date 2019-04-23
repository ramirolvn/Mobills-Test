import Foundation
import Firebase

let dbRef = Firestore.firestore()
let storageRef = Storage.storage().reference()

//DbCollections
let profitTypeRef = dbRef.collection("profitType")
let wasteTypeRef = dbRef.collection("wasteType")
let userBalanceRef = dbRef.collection("userBalance")


//StorageCollections
let userImagesRef = storageRef.child("userImages")



let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
