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

class MainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PFAppState {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var firstRun = true
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        switch indexPath.row {
        case 0:
            cell.imageView.image = UIImage.init(named: "account_balance.png")
            cell.label.text = "Account Balance"
        case 1:
            cell.imageView.image = UIImage.init(named: "investments.png")
            cell.label.text = "Investments"
        case 2:
            cell.imageView.image = UIImage.init(named: "mortgage.png")
            cell.label.text = "Mortgage"
        case 3:
            cell.imageView.image = UIImage.init(named: "messages.png")
            cell.label.text = "1 New Message"
        case 4:
            cell.imageView.image = UIImage.init(named: "send_pyrite.png")
            cell.label.text = "Send Money"
        case 5:
            cell.imageView.image = UIImage.init(named: "purchase.png")
            cell.label.text = "Purchase"
        default:
            cell.label.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let AccountVC = self.storyboard?.instantiateViewController(identifier: "AccountVC")
            self.navigationController?.pushViewController(AccountVC!, animated: true)
            break
        case 3:
            let messageVC = self.storyboard?.instantiateViewController(identifier: "MessagesVC")
            self.navigationController?.pushViewController(messageVC!, animated: true)
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PFApp.shared.delegate = self
        if PFApp.shared.alreadySignedIn() {
            self.showSpinner(onView: self.view)
            if SecurityControl.shared.state != .active {
                PFApp.shared.getToken()
            } else {
                self.removeSpinner()
                self.startApp()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 4, height: width / 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    func startApp() {
        self.showThreatStatus()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !PFApp.shared.alreadySignedIn() {
            let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginVC")
            loginVC!.isModalInPresentation = true
            self.present(loginVC!, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        let settingVC = self.storyboard?.instantiateViewController(identifier: "settingVC")
        self.navigationController?.pushViewController(settingVC!, animated: true)
    }
    
    func showThreatStatus() {
        let threatStatusVC = self.storyboard?.instantiateViewController(identifier: "ThreatStatusVC")
        self.present(threatStatusVC!, animated: true, completion: nil)
    }
    
    func sparkSDKActive() {
        if firstRun {
            firstRun = false
            self.removeSpinner()
            self.startApp()
        }
    }
    
}
