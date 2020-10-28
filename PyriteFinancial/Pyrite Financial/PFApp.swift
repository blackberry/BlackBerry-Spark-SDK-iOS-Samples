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


import Foundation
import FirebaseAuth
import BlackBerrySecurity

protocol PFAppState {
    func sparkSDKActive()
}

class PFApp {
    
    static let shared = PFApp()
    
    private init(){}
    
    private var currentUser : User!
    
    var delegate: PFAppState!
    
    func alreadySignedIn() -> Bool {
        if let currentUser = Auth.auth().currentUser {
            self.currentUser = currentUser
            getToken()
            return true
        } else {
            return false
        }
    }
    
    func setCurrentUser(loggedInUser: User) {
        self.currentUser = loggedInUser
    }
    
    func getToken() {
        currentUser.getIDTokenForcingRefresh(true) { (token, error) in
            if error !=  nil {
                print("error getting token")
            } else {
                self.initSparkSDKWith(token: token!)
            }
        }
    }
    
    func initSparkSDKWith(token: String) {
        SecurityControl.shared.provideToken(token: token.data(using: .utf8)!)
        SecurityControl.shared.onStateChange = handleStateChange
        handleStateChange(newState: SecurityControl.shared.state)
    }
    
    //This method listens to the state changes of the Spark SDK and when the token expires, gets a new token from Firebase Auth and provies it to the SDK.
    //When the states becomes active, Spark SDK APIs can be used to get get the threat status and manage rules
    func handleStateChange(newState: SecurityControl.InitializationState) {
        switch newState {
        case .tokenExpired:
            getToken()
            break
        case .active:
            configureDeviceSecurityRules()
            if delegate != nil {
                delegate.sparkSDKActive()
            }
            break
        default:
            break
        }
    }
    
    func configureDeviceSecurityRules() {
        var deviceSecurityRule = DeviceSecurityRules.init(featureStatus: .disabled)
        deviceSecurityRule = deviceSecurityRule.enableCheck(check: .jailbreakDetection).enableCheck(check: .deviceLockScreen)
        
        ManageRules.setDeviceSecurityRules(rules: deviceSecurityRule)
    }
    
    func checkUrl(url : String, completion: @escaping (Bool) -> Void) {
        _ = ContentChecker.checkUrl(url: url as NSString) { (int, result) in
            switch result {
            case .safe:
                completion(true)
                break
            case .unsafe:
                completion(false)
                break
            case .unavailable:
                completion(false)
                break
            default:
                break
            }
        }
    }
    
    func isDeviceOSRestricted() -> Bool {
        let deviceOSThreat = ThreatStatus().getThreat(by: .deviceSoftware) as! ThreatDeviceSoftware
        return deviceOSThreat.isDeviceOSRestricted()
    }
    
    func isScreenLockEnabled() -> Bool {
        let deviceSecurity = ThreatStatus().getThreat(by: .deviceSecurity) as! ThreatDeviceSecurity
        return deviceSecurity.isScreenLockEnabled()
    }
    
    func isDeviceCompromised() -> Bool {
        let deviceSecurity = ThreatStatus().getThreat(by: .deviceSecurity) as! ThreatDeviceSecurity
        return deviceSecurity.isDeviceCompromised()
    }
    
    func setMinimumOSVersion(OSVersion: String) {
        let deviceSoftwareRule = try! DeviceSoftwareRules.init(minimumOSVersion: OSVersion, enableDeviceOSCheck: true)
        ManageRules.setDeviceSoftwareRules(rules: deviceSoftwareRule)
    }
    
    func getMinimumOSVersion() -> String {
        return try! ManageRules.getDeviceSoftwareRules().getMinimumOSVersion()
    }
    
    func updateThreatStatus() {
        DeviceChecker.checkDeviceSecurity()
    }
    
    func getVersion() -> String {
        return Diagnostics.getRuntimeVersion();
    }
    
    func uploadLogs(callback: @escaping (String) -> Void) {
        Diagnostics.uploadLogs(reason: "Uploading Logs from Settings") { (status) in
            switch status {
            case .busy:
                callback("Busy")
                break
            case .completed:
                callback("Completed")
                break
            case .failed:
                callback("Failed")
                break
            @unknown default:
                callback("Unknown")
                break
            }
        }
    }
    
    func enableDataCollection() {
        ManageRules.setDataCollectionRules(rules: DataCollectionRules.init().enableDataCollection())
    }
    
    func checkIfExists(fileName : String, create: Bool, initialValue: String?) -> Bool {
        let filePath = getDocumentsDirectory(fileName: fileName)
        
        if (!BBSFileManager.default!.fileExistsAt(path: filePath)) {
            if create {
                return BBSFileManager.default!.createFileAt(path: filePath, contents: initialValue!.data(using: .utf8), attributes: nil)
            } else {
                return false
            }
        }
        return true
    }
    
    func contentsOfFile(fileName : String) -> Data? {
        let filePath = getDocumentsDirectory(fileName: fileName)
        
        if (!(BBSFileManager.default!.fileExistsAt(path: filePath))) {
            return nil
        } else {
            return BBSFileManager.default!.contentsAtPath(path: filePath)
        }
    }
    
    func saveInFile(fileName: String, value : String) {
        let filePath = getDocumentsDirectory(fileName: fileName)
        
        _ = BBSFileManager.default!.createFileAt(path: filePath, contents: value.data(using: .utf8), attributes: nil)
    }
    
    func getDocumentsDirectory(fileName : String) -> String {
        let paths = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.path + fileName
    }
}
