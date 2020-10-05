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

class AccountVC: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var newBalanceField: UITextField!
    
    let fileName = "Account_Balance.txt"
    
    var currentBalance: Int = 0

    //BBSFileManager APIs should only be called when the Spark SDK state is active. 
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFApp.shared.checkIfExists(fileName: fileName, create: true, initialValue: "\(currentBalance)") {
            print("File Created or Exists")
            if let balanceData = PFApp.shared.contentsOfFile(fileName: fileName) {
                self.currentBalance = Int(String(decoding: balanceData, as: UTF8.self))!
                updateText()
            }
        } else {
            print("File could not be created")
        }
    }
    
    func updateText() {
        DispatchQueue.main.async {
            self.balanceLabel.text = "Account Balance: \(self.currentBalance)"
        }
    }
    
    @IBAction func deposit(_ sender: Any) {
        let updateBalance = newBalanceField.text!
        if (validate(text: updateBalance)) {
            currentBalance += Int(updateBalance)!
            PFApp.shared.saveInFile(fileName: fileName, value: "\(currentBalance)")
            self.updateText()
        } else {
            self.showAlert(title: "Error", message: "Enter an Integer", callback: {})
        }
    }
    
    @IBAction func withdraw(_ sender: Any) {
        let updateBalance = newBalanceField.text!
        if (validate(text: updateBalance)) {
            currentBalance -= Int(updateBalance)!
            PFApp.shared.saveInFile(fileName: fileName, value: "\(currentBalance)")
            self.updateText()
        } else {
            self.showAlert(title: "Error", message: "Enter an Integer", callback: {})
        }
    }
    
    func validate(text: String) -> Bool {
        let textInt:Int? = Int(text)
        return (textInt != nil)
    }
}
