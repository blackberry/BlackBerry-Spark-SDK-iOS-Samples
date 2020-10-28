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

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var sdkVersionLabel: UILabel!
    @IBOutlet weak var uploadStatus: UILabel!
    @IBOutlet weak var minimumOSText: UITextField!
    
    let picker = UIPickerView()
    
    let myPickerData = ["11", "12", "13", "14"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sdkVersionLabel.text = PFApp.shared.getVersion()
        minimumOSText.inputView = picker
        minimumOSText.text = PFApp.shared.getMinimumOSVersion()
        picker.delegate = self
    }
    
    @IBAction func uploadLogs(_ sender: Any) {
        PFApp.shared.uploadLogs { (status) in
            DispatchQueue.main.async {
                self.uploadStatus.text = status
            }
        }
    }
    
    @IBAction func displayThreatStatus(_ sender: Any) {
        let threatStatusVC = self.storyboard?.instantiateViewController(identifier: "ThreatStatusVC")
        self.navigationController?.pushViewController(threatStatusVC!, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return myPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        minimumOSText.text = myPickerData[row]
        PFApp.shared.setMinimumOSVersion(OSVersion: myPickerData[row])
    }
}
