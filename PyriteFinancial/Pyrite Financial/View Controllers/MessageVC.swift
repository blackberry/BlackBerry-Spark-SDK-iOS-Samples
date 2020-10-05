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

class MessageVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var messageView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toLabel.text = "Pyrite Investor"
        fromLabel.text = "Pyrite Investment Team"
        subjectLabel.text = "Golden Opportunity, Act Now!"
        let message = NSMutableAttributedString.init(string: "Dear VIP Investore: \nPyriteFinancial has selected you to join our Golden VIP Club to get top investments not available to the public. Click on the link below to sign up. Act now,  limited spaces available. \nClick Here \nPyrite Investment Team")
        
        message.addAttribute(.link, value: "https://blackberry.com/safe_browsing_test_fake_bad_url", range: NSRange(location: 207, length: 10))
        message.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: 207))
        message.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 217, length: 24))
        
        message.addAttribute(.font, value: UIFont.init(name: "Times New Roman", size: CGFloat.init(18))!, range: NSRange(location: 0, length: 241))
        
        messageView.attributedText = message
        messageView.delegate = self
        
        messageView.isEditable = false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.showSpinner(onView: self.view)
        PFApp.shared.checkUrl(url: URL.absoluteString) { (safe) in
            self.removeSpinner()
            if safe {
                UIApplication.shared.open(URL)
            } else {
                self.showAlert(title: "Alert!", message: "The URL is not Safe", callback: {})
            }
        }
        return false
    }
}
