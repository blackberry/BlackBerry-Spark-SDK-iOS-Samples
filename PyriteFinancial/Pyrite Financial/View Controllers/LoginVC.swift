/* Copyright (c) 2020 BlackBerry Limited.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
*/


import UIKit
import FirebaseAuth
import BlackBerrySecurity

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }

    @IBAction func login(_ sender: Any) {
        let username = emailTextField.text!
        let password = passwordTextField.text!
        if validate(username: username, password: password) {
            login(username: username, password: password)
        } else {
            self.showAlert(title: "Alert!", message: "Values cannot be nil") {}
        }
    }
    
    func login(username: String, password: String) {
        self.showSpinner(onView: self.view)
        Auth.auth().signIn(withEmail: username, password: password) {authResult, error in
            self.removeSpinner()
            if error != nil {
                self.showAlert(title: "Alert!", message: "Values are incorrect") {}
            } else {
                authResult?.user.getIDToken(completion: { (token, error) in
                    PFApp.shared.initSparkSDKWith(token: token!)
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    func validate(username : String, password: String) -> Bool {
        if username.count == 0 || password.count == 0 {
            return false
        }
        return true
    }
    
}
