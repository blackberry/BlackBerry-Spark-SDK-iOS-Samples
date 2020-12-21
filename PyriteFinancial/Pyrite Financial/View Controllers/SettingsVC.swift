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

class SettingsVC: UIViewController {
    
    @IBOutlet weak var sdkVersionLabel: UILabel!
    @IBOutlet weak var uploadStatus: UILabel!
    @IBOutlet weak var instanceIdentifierLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sdkVersionLabel.text = PFApp.shared.getVersion()
        instanceIdentifierLabel.text = PFApp.shared.getInstanceIdentifier()
    }
    
    @IBAction func getNewRules(_ sender: Any) {
        let gitHuburl = "https://raw.githubusercontent.com/gghangura/rules/master/rules.json"
        let url = "http://localhost:3000/rules?appAuthenticityID=" + PFApp.shared.getAuthenticityID() + "&appInstanceID=" + PFApp.shared.getInstanceIdentifier()
        var request = URLRequest(url: URL(string: gitHuburl)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        self.showSpinner(onView: self.view)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            self.removeSpinner()
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                Rules.init().updateRules(newRules: json)
            } catch {
                self.showAlert(title: "Error", message: "The file could not fetched. Check the URL", callback: {})
            }
        })

        task.resume()
    }
    
    @IBAction func uploadLogs(_ sender: Any) {
        PFApp.shared.uploadLogs { (status) in
            DispatchQueue.main.async {
                self.uploadStatus.text = status
                
                if status == "Completed" {
                    self.showAlert(title: "Upload Successful", message: "Logs uploaded with ContainerID - " + PFApp.shared.getContainerId(), callback: {})
                }
                
            }
        }
    }
    
    @IBAction func displayThreatStatus(_ sender: Any) {
        let threatStatusVC = self.storyboard?.instantiateViewController(identifier: "ThreatStatusVC")
        self.navigationController?.pushViewController(threatStatusVC!, animated: true)
    }
}
