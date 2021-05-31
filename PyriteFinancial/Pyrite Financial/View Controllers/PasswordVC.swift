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
import BlackBerrySecurity

class PasswordVC: UIViewController {
    
    var biometricsInvalidated = false
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var firstDot: UIImageView!
    @IBOutlet weak var secondDot: UIImageView!
    @IBOutlet weak var thirdDot: UIImageView!
    @IBOutlet weak var fourthDot: UIImageView!
    @IBOutlet weak var fifthDot: UIImageView!
    

    @IBOutlet weak var one: UIImageView!
    @IBOutlet weak var two: UIImageView!
    @IBOutlet weak var three: UIImageView!
    @IBOutlet weak var four: UIImageView!
    @IBOutlet weak var five: UIImageView!
    @IBOutlet weak var six: UIImageView!
    @IBOutlet weak var seven: UIImageView!
    @IBOutlet weak var eight: UIImageView!
    @IBOutlet weak var nine: UIImageView!
    @IBOutlet weak var zero: UIImageView!
    @IBOutlet weak var back: UIImageView!
    
    var passcode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SecurityControl.shared.state == .authenticationSetupRequired {
            titleLabel.text = "Create a new PIN"
        } else {
            titleLabel.text = "Enter Previous PIN"
        }
        
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        zero.isUserInteractionEnabled = true
        zero.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        one.isUserInteractionEnabled = true
        one.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))

        two.isUserInteractionEnabled = true
        two.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        three.isUserInteractionEnabled = true
        three.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        four.isUserInteractionEnabled = true
        four.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        five.isUserInteractionEnabled = true
        five.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        six.isUserInteractionEnabled = true
        six.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        seven.isUserInteractionEnabled = true
        seven.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        eight.isUserInteractionEnabled = true
        eight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
        
        nine.isUserInteractionEnabled = true
        nine.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PasswordVC.numberTapped)))
    }
    
    @objc func numberTapped(sender: UITapGestureRecognizer) {
        if sender.view!.tag < 10 {
            passcode = passcode + String(sender.view!.tag)
        } else {
            passcode = String(passcode.dropLast())
        }
        updateDots()
        processTap()
    }
    
    func updateDots() {
        switch passcode.count {
        case 0:
            firstDot.image = UIImage.init(named: "pin_not_entered_circle")
            secondDot.image = UIImage.init(named: "pin_not_entered_circle")
            thirdDot.image = UIImage.init(named: "pin_not_entered_circle")
            fourthDot.image = UIImage.init(named: "pin_not_entered_circle")
            fifthDot.image = UIImage.init(named: "pin_not_entered_circle")
            break
        case 1:
            firstDot.image = UIImage.init(named: "pin_entered_circle")
            secondDot.image = UIImage.init(named: "pin_not_entered_circle")
            thirdDot.image = UIImage.init(named: "pin_not_entered_circle")
            fourthDot.image = UIImage.init(named: "pin_not_entered_circle")
            fifthDot.image = UIImage.init(named: "pin_not_entered_circle")
            break
        case 2:
            firstDot.image = UIImage.init(named: "pin_entered_circle")
            secondDot.image = UIImage.init(named: "pin_entered_circle")
            thirdDot.image = UIImage.init(named: "pin_not_entered_circle")
            fourthDot.image = UIImage.init(named: "pin_not_entered_circle")
            fifthDot.image = UIImage.init(named: "pin_not_entered_circle")
            break
        case 3:
            firstDot.image = UIImage.init(named: "pin_entered_circle")
            secondDot.image = UIImage.init(named: "pin_entered_circle")
            thirdDot.image = UIImage.init(named: "pin_entered_circle")
            fourthDot.image = UIImage.init(named: "pin_not_entered_circle")
            fifthDot.image = UIImage.init(named: "pin_not_entered_circle")
            break
        case 4:
            firstDot.image = UIImage.init(named: "pin_entered_circle")
            secondDot.image = UIImage.init(named: "pin_entered_circle")
            thirdDot.image = UIImage.init(named: "pin_entered_circle")
            fourthDot.image = UIImage.init(named: "pin_entered_circle")
            fifthDot.image = UIImage.init(named: "pin_not_entered_circle")
            break
        case 5:
            firstDot.image = UIImage.init(named: "pin_entered_circle")
            secondDot.image = UIImage.init(named: "pin_entered_circle")
            thirdDot.image = UIImage.init(named: "pin_entered_circle")
            fourthDot.image = UIImage.init(named: "pin_entered_circle")
            fifthDot.image = UIImage.init(named: "pin_entered_circle")
            break
        default:
            break
        }
    }
    
    func processTap() {
        if passcode.count == 5 {
            if SecurityControl.shared.state == .authenticationSetupRequired {
                let result = AppAuthentication.shared.setPassword(passcode)
                if result {
                    if PFApp.shared.isBiometricsAvailable() {
                        self.showAlertWithCancel(title: "Biometric", message: "Do you want to use Biometric to unlock the app?", confirm: "Yes", dismiss: "No") { (confirmed) in
                            PFApp.shared.biometricPreference(enable: confirmed)
                            self.dismiss(animated: true, completion: {
                                PFApp.shared.handleStateChange(newState: PFApp.shared.currentInitializationState())
                            })
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    passcode = ""
                    updateDots()
                    self.showAlert(title: "Error", message: "Something went wrong. Try Again!", callback: {})
                }
                
            }
            if SecurityControl.shared.state == .authenticationRequired {
                AppAuthentication.shared.enterPassword(passcode)
                if biometricsInvalidated {
                    self.showAlertWithCancel(title: "Biometric profile changed", message: "Confirm only your face or fingerprint is enrolled on this device before re-enabling biometric authentication.", confirm: "Enable Biometrics", dismiss: "Dismiss") { (confirmed) in
                        PFApp.shared.biometricPreference(enable: confirmed)
                        self.dismiss(animated: true, completion: {
                            PFApp.shared.handleStateChange(newState: PFApp.shared.currentInitializationState())
                        })
                    }
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
