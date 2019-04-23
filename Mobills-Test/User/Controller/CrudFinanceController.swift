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
    
    fileprivate var didFetchData = false
    func setup(for dataType: DataType) {
        didFetchData = true
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
                self.ObsTV.textColor = .black
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
            print(self.userWaste)
            print("edit waste")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        formatter.dateFormat = "dd/MM/yyyy"
        showDatePicker()
        self.ObsTV.delegate = self
        ObsTV.text = textViewPlaceholder
        ObsTV.textColor = .lightGray
        // make default API call
        
        // Do any additional setup after loading the view.
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
                if let UserUID = RealmUser().retriveUser()?.uid, let date = formatter.date(from: self.dateTF.text!), let valor = self.valorTF.text?.getNumberRepresentation(), let firebaseProfit = FirebaseProfit(["valor" : valor, "data": date, "descricao" : self.ObsTV.text!, "recebido" : self.checkButton.isChecked ? true : false, "image" : self.selectedIV.image?.pngData()]){
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
                if let userUID = RealmUser().retriveUser()?.uid, let date = formatter.date(from: self.dateTF.text!), let valor = self.valorTF.text?.getNumberRepresentation(), let firebaseWaste = FirebaseWaste(["valor" : valor, "data": date, "descricao" : self.ObsTV.text!, "pago" : self.checkButton.isChecked ? true : false, "image" : self.selectedIV.image?.pngData()]){
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
                if let userUID = RealmUser().retriveUser()?.uid, let date = formatter.date(from: self.dateTF.text!), let valor = self.valorTF.text?.getNumberRepresentation(), let firebaseProfit = FirebaseProfit(["documentID" : self.userProfit?.documentID ?? "","valor" : valor, "data": date, "descricao" : self.ObsTV.text!, "recebido" : self.checkButton.isChecked ? true : false, "image" : self.selectedIV.image?.pngData()]){
                    ProfitNetworking.updateProfit(userUID: userUID, profit: firebaseProfit)
                    DispatchQueue.main.async {
                        self.simpleAlert(title: "Sucesso", msg: "Dados editados com sucesso!")
                    }
                }else{
                    SwiftSpinner.hide()
                    simpleAlert(title: "Atenção", msg: "Erro nos dados!")
                }
            case .some(.EditWaste):
                print("new profit")
            default:
                print("Default")
            }
        }else{
            SwiftSpinner.hide()
            simpleAlert(title: "Atenção", msg: validate!)
        }
    }
    
    @IBAction func addAttachment(_ sender: UIButton) {
        
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
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            self.simpleAlert(title: "Atenção", msg: "Você não possui câmera!")
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
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
            textView.textColor = .black
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
    
    
    
    private func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
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
}
