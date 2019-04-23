import UIKit
import SwiftSpinner

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTF{
            self.passwordTF.becomeFirstResponder()
        }else{
            self.loginAction(self.loginBtn)
        }
        return true
    }
    
    private func validateForm() -> String?{
        if let email = self.emailTF.text, let password = self.passwordTF.text{
            if !email.isValidEmail(){
                return "E-mail inválido!"
            }else if password.count == 0 || password.count < 6 {
                return "Senha inválida!"
            }
            return nil
        }else{
            return "Email e senha são necessários."
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        let validate = self.validateForm()
        if validate == nil{
            SwiftSpinner.show("Entrando...")
            UserNetworking.loginUser(email: self.emailTF.text!, password: self.passwordTF.text!, completion:{ (response) in
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
