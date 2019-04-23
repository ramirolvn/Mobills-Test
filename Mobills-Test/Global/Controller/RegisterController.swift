import UIKit
import SwiftSpinner

class RegisterController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTF{
            self.passwordTF.becomeFirstResponder()
        }else{
            self.registerBtn(self.registerButton)
        }
        return true
    }
    
    private func validateForm() -> String?{
        if let email = self.emailTF.text, let password = self.passwordTF.text{
            if !email.isValidEmail(){
                return "E-mail inválido!"
            }else if password.count == 0{
                return "Senha necessária!"
            }else if password.count < 6{
                return "Senha precisa de ter pelo menos 6 letras!"
            }
            return nil
        }else{
            return "Email e senha são necessários."
        }
    }
    
    @IBAction func registerBtn(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        let validate = self.validateForm()
        if validate == nil{
            SwiftSpinner.show("Registrando...")
            UserNetworking.registerUser(email: self.emailTF.text!, password: self.passwordTF.text!, completion:{ (response) in
                SwiftSpinner.hide()
                if let e = response.err{
                    self.simpleAlert(title: "Erro", msg: e)
                }else if let u = response.user{
                    let storyboard = UIStoryboard(name: "User", bundle: nil)
                    if let mainNavcntrl = storyboard.instantiateViewController(withIdentifier: "userNavigation") as? UINavigationController, let userFinanceCntrl = mainNavcntrl.children[0] as? UserFinanceController{
                        userFinanceCntrl.user = u
                        DispatchQueue.main.async {
                            self.present(mainNavcntrl, animated: true, completion: nil)
                        }
                    }
                }
            })
        }else{
            SwiftSpinner.hide()
            simpleAlert(title: "Atenção", msg: validate!)
        }
    }
    
}
