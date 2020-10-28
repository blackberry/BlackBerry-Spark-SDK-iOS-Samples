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
import LocalAuthentication

class ThreatStatusVC: UIViewController {

    @IBOutlet weak var deviceSoftwareLabel: UILabel!
    @IBOutlet weak var deviceSecurityLabel: UILabel!
    @IBOutlet weak var deviceCompromisedLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !self.isBeingPresented {
            self.dismissButton.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(threatStatusChanged), name: ThreatStatus.threatStatusChangedNotification, object: nil)
        updateLabels()
        
    }
    
    @objc func threatStatusChanged(notification: NSNotification) {
        updateLabels()
    }
    
    func updateLabels() {
        let deviceOSRestricted = PFApp.shared.isDeviceOSRestricted()
        let screenLock = PFApp.shared.isScreenLockEnabled()
        let isDeviceCompromised = PFApp.shared.isDeviceCompromised()
        
        deviceSoftwareLabel.text = deviceOSRestricted ? "Device OS Restricted" : "Device OS not Restricted"
        deviceSecurityLabel.text = screenLock ? "Screen Lock enabled" : "Screen Lock disabled"
        deviceCompromisedLabel.text = isDeviceCompromised ? "Device is Compromised" : "Device is not Compromised"
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshStatus(_ sender: Any) {
        PFApp.shared.updateThreatStatus()
    }
}
