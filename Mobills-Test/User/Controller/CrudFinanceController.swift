import UIKit
import SwiftSpinner
import Firebase
import Photos


class CrudFinanceController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    @IBOutlet weak var checkButton: CheckBox!
    @IBOutlet weak var labelRadio: UILabel! {
        didSet {
            if labelRadio != nil{
                labelRadio.text = labelText
            }
        }
    }
    @IBOutlet weak var valorTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var ObsTV: UITextView!
    @IBOutlet weak var selectedIV: UIImageView!
    
    private var imagePicker = UIImagePickerController()
    private let datePicker = UIDatePicker()
    private let textViewPlaceholder = "Digite aqui uma observação até 140 letras"
    private let formatter = DateFormatter()
    
    var user: FirebaseUser!
    var labelText = ""
    var dataType: DataType!
    var userProfit: FirebaseProfit?
    var userWaste: FirebaseWaste?
    
    
    enum AttachmentType: String{
        case camera, photoLibrary
    }
    
    enum DataType {
        case NewProfit
        case NewWaste
        case EditProfit
        case EditWaste
    }
    
    func setup(for dataType: DataType) {
        switch dataType {
        case .NewProfit:
            break
        case .NewWaste:
            break
        case .EditProfit:
            let userProfit = self.userProfit
            DispatchQueue.main.async {
                self.imageSpinner.isHidden = false
                self.dateTF.text = userProfit?.data?.dateValue().getStringDate() ?? ""
                self.valorTF.text = userProfit?.valor?.stringValue.currencyInputFormatting() ?? ""
                self.ObsTV.textColor = .darkGray
                self.ObsTV.text = userProfit?.descricao ?? ""
                self.checkButton.isChecked = userProfit?.recebido ?? false
            }
            ProfitNetworking.getProfitImage(userUID: self.user.uid, documentID: userProfit?.documentID ?? "", completion: {(imgData, err) in
                DispatchQueue.main.async {
                    self.imageSpinner.isHidden = true
                    if let data = imgData, let img = UIImage(data: data){
                        self.selectedIV.image  = img
                    }else{
                        self.simpleAlert(title: "Atenção", msg: err)
                    }
                }
            })
        case .EditWaste:
            let wasteProfit = self.userWaste
            DispatchQueue.main.async {
                self.imageSpinner.isHidden = false
                self.dateTF.text = wasteProfit?.data?.dateValue().getStringDate() ?? ""
                self.valorTF.text = wasteProfit?.valor?.stringValue.currencyInputFormatting() ?? ""
                self.ObsTV.textColor = .darkGray
                self.ObsTV.text = wasteProfit?.descricao ?? ""
                self.checkButton.isChecked = wasteProfit?.pago ?? false
            }
            WasteNetworking.getWasteImage(userUID: self.user.uid, documentID: wasteProfit?.documentID ?? "", completion: {(imgData, err) in
                DispatchQueue.main.async {
                    self.imageSpinner.isHidden = true
                    if let data = imgData, let img = UIImage(data: data){
                        self.selectedIV.image  = img
                    }else{
                        self.simpleAlert(title: "Atenção", msg: err)
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        self.ObsTV.delegate = self
        formatter.dateFormat = "dd/MM/yyyy"
        showDatePicker()
        ObsTV.text = textViewPlaceholder
        ObsTV.textColor = .lightGray
    }
    
    private func validateForm() -> String?{
        if let valor = self.valorTF.text, let date = self.dateTF.text, let obs = self.ObsTV.text{
            if valor.count == 0 || valor == "R$ 0,00"{
                return "Valor necessário"
            }else if date.count == 0{
                return "Data necessária"
            }else if obs.count == 0 || obs == textViewPlaceholder{
                return "Observação necessária"
            }else if self.selectedIV.image == nil{
                return "Foto necessária"
            }
            return nil
        }else{
            return "Todos os campos são necessários."
        }
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        SwiftSpinner.show("Salvando...")
        let validate = validateForm()
        if validate == nil{
            switch self.dataType {
            case .some(.NewProfit):
                if let UserUID = RealmUser().retriveUser()?.uid, let date = formatter.date(from: self.dateTF.text!), let valor = self.valorTF.text?.getNumberRepresentation(), let firebaseProfit = FirebaseProfit(["valor" : valor, "data": date, "descricao" : self.ObsTV.text!, "recebido" : self.checkButton.isChecked ? true : false, "image" : self.selectedIV.image?.pngData() as Any]){
                    ProfitNetworking.createProfit(userUID: UserUID, profit: firebaseProfit, completion: {
                        (response) in
                        SwiftSpinner.hide()
                        if let error = response.errDocument{
                            self.simpleAlert(title: "Atenção", msg: error)
                        }else if let errorMsg = response.errImage{
                            self.simpleAlert(title: "Atenção", msg: errorMsg)
                        }else{
                            self.simpleAlert(title: "Sucesso", msg: "Dados cadastrados")
                        }
                    })
                }else{
                    SwiftSpinner.hide()
                    simpleAlert(title: "Atenção", msg: "Erro nos dados!")
                }
            case .some(.NewWaste):
                if let userUID = RealmUser().retriveUser()?.uid, let date = formatter.date(from: self.dateTF.text!), let valor = self.valorTF.text?.getNumberRepresentation(), let firebaseWaste = FirebaseWaste(["valor" : valor, "data": date, "descricao" : self.ObsTV.text!, "pago" : self.checkButton.isChecked ? true : false, "image" : self.selectedIV.image?.pngData() as Any]){
                    WasteNetworking.createWaste(userUID: userUID, waste: firebaseWaste, completion: {
                        (response) in
                        SwiftSpinner.hide()
                        if let error = response.errDocument{
                            self.simpleAlert(title: "Atenção", msg: error)
                        }else if let errorMsg = response.errImage{
                            self.simpleAlert(title: "Atenção", msg: errorMsg)
                        }else{
                            self.simpleAlert(title: "Sucesso", msg: "Dados cadastrados")
                        }
                    })
                }else{
                    SwiftSpinner.hide()
                    simpleAlert(title: "Atenção", msg: "Erro nos dados!")
                }
            case .some(.EditProfit):
                if let userUID = RealmUser().retriveUser()?.uid, let date = formatter.date(from: self.dateTF.text!), let valor = self.valorTF.text?.getNumberRepresentation(), let firebaseProfit = FirebaseProfit(["documentID" : self.userProfit?.documentID ?? "","valor" : valor, "data": date, "descricao" : self.ObsTV.text!, "recebido" : self.checkButton.isChecked ? true : false, "image" : self.selectedIV.image?.pngData() as Any]){
                    ProfitNetworking.updateProfit(userUID: userUID, profit: firebaseProfit, completion: {
                        (response) in
                        DispatchQueue.main.async {
                            SwiftSpinner.hide()
                            if let err = response.errImage{
                                self.simpleAlert(title: "Erro", msg: err)
                            }else{
                                self.simpleAlert(title: "Sucesso", msg: "Dados editados com sucesso!")
                            }
                        }
                    })
                    
                }else{
                    SwiftSpinner.hide()
                    simpleAlert(title: "Atenção", msg: "Erro nos dados!")
                }
            case .some(.EditWaste):
                if let userUID = RealmUser().retriveUser()?.uid, let date = formatter.date(from: self.dateTF.text!), let valor = self.valorTF.text?.getNumberRepresentation(), let firebaseWaste = FirebaseWaste(["documentID" : self.userWaste?.documentID ?? "", "valor" : valor, "data": date, "descricao" : self.ObsTV.text!, "pago" : self.checkButton.isChecked ? true : false, "image" : self.selectedIV.image?.pngData() as Any]){
                    WasteNetworking.updateWaste(userUID: userUID, waste: firebaseWaste, completion: {
                        (response) in
                        DispatchQueue.main.async {
                            SwiftSpinner.hide()
                            if let err = response.errImage{
                                self.simpleAlert(title: "Erro", msg: err)
                            }else{
                                self.simpleAlert(title: "Sucesso", msg: "Dados editados com sucesso!")
                            }
                        }
                        
                    })
                    
                }else{
                    SwiftSpinner.hide()
                    simpleAlert(title: "Atenção", msg: "Erro nos dados!")
                }
            default:
                print("Default")
            }
        }else{
            SwiftSpinner.hide()
            simpleAlert(title: "Atenção", msg: validate!)
        }
    }
    
    //Mark:-- Buttons Actions
    
    @IBAction func addAttachment(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Escolha uma câmera", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Câmera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = self.checkButton
            alert.popoverPresentationController?.sourceRect = self.checkButton.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openImage(_ sender: UIButton) {
        if let image = self.selectedIV.image{
            let newImageView = UIImageView(image: image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.selectedIV.image = selectedImage
            }
        })
    }
    
    
    //Mark:-- TexViewDelegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .darkGray
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = textViewPlaceholder
            textView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 140
    }
    
    
    //Mark: -- PrivateFuncs
    
    private func openCamera(){
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            self.simpleAlert(title: "Atenção", msg: "Você não possui câmera!")
        }
    }
    
    private func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    private func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        self.dateTF.inputAccessoryView = toolbar
        self.dateTF.inputView = datePicker
        
    }
    
    //Mark:-- Objc Funcs
    
    @objc func donedatePicker(){
        
        self.dateTF.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
}
