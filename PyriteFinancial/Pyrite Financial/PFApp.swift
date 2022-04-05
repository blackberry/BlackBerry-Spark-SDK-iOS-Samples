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
    func sparkAuthRequired(biometricsInvalidated: Bool)
    func loginRequired(error: String?)
    func promptBiometricPreference()
}

class PFApp {
    
    static let shared = PFApp()
    
    private init(){}
    
    private var currentUser : User!
    
    var delegate: PFAppState!
    
    var showingThreatStatus: Bool = false
    
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
                self.provideToken(token: token!)
            }
        }
    }
    
    func listenToStateChanges() {
        SecurityControl.shared.onStateChange = handleStateChange
        handleStateChange(newState: SecurityControl.shared.state)
    }
    
    func provideToken(token: String) {
        SecurityControl.shared.provideToken(token.data(using: .utf8)!)
    }
    
    func biometricPreference(enable: Bool) {
        setUserBiometricSetting(value: enable)
        if enable {
            _ = AppAuthentication.shared.setupBiometrics()
        } else {
            _ = AppAuthentication.shared.disableBiometrics()
        }
        checkLogin()
    }
    
    func checkLogin() {
        if alreadySignedIn() {
            getToken()
        } else {
            if delegate != nil {
                delegate.loginRequired(error: nil)
            }
        }
    }
    
    //This method listens to the state changes of the Spark SDK and when the token expires, gets a new token from Firebase Auth and provies it to the SDK.
    //When the states becomes active, Spark SDK APIs can be used to get get the threat status and manage rules
    func handleStateChange(newState: SecurityControl.InitializationState) {
        switch newState {
        case .tokenExpired:
            getToken()
            break
        case .authenticationSetupRequired:
            if delegate != nil {
                delegate.sparkAuthRequired(biometricsInvalidated: false)
            }
            break
        case .authenticationRequired:
            if AppAuthentication.shared.isBiometricsAvailable() && AppAuthentication.shared.isBiometricsSetup() {
                AppAuthentication.shared.promptBiometrics("Unlock App") { (unlocked, err) in
                    if unlocked {
                        self.checkLogin()
                    }
                    if let error = err {
                        switch (error as NSError).code {
                        case BiometricAuthenticationErrorCode.invalidated.rawValue:
                            if self.delegate != nil {
                                self.delegate.sparkAuthRequired(biometricsInvalidated: true)
                            }
                            break
                        default:
                            if self.delegate != nil {
                                self.delegate.sparkAuthRequired(biometricsInvalidated: false)
                            }
                        }
                    }
                }
            } else {
                if delegate != nil {
                    delegate.sparkAuthRequired(biometricsInvalidated: false)
                }
            }
            break
        case .registration:
            checkLogin()
            break
        case .active:
            if delegate != nil {
                delegate.sparkSDKActive()
            }
            NotificationCenter.default.addObserver(self, selector: #selector(threatStatusChanged), name: ThreatStatus.threatStatusChangedNotification, object: nil)
            break
        case .error:
            if delegate != nil {
                delegate.loginRequired(error: "An error occurred initializing BlackBerry Security.")
            }
        default:
            break
        }
    }
    
    func currentInitializationState() -> SecurityControl.InitializationState {
        return SecurityControl.shared.state
    }
    
    @objc func threatStatusChanged(notification: NSNotification) {
        if !showingThreatStatus {
            let threatStatusVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "ThreatStatusVC")
            UIApplication.shared.windows.last?.rootViewController?.present(threatStatusVC, animated: true, completion: nil)
        }
    }
    
    func checkUrl(url : String, completion: @escaping (Bool) -> Void) {
        do {
            _ = try ContentChecker.checkURL(url) { (int, result) in
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
        catch {
            print("Failed to check URL: \(error)")
        }
    }
    
    func isDeviceOSRestricted() -> Bool {
        do {
            let deviceOSThreat = try ThreatStatus().threat(ofType: .deviceSoftware) as! ThreatDeviceSoftware
            return try deviceOSThreat.isDeviceOSRestricted.get()
            
        }
        catch {
            print("An Error Occured getting Threat Status: \(error)")
            return true
        }
    }
    
    func isScreenLockEnabled() -> Bool {
        let deviceSecurity = try! ThreatStatus().threat(ofType: .deviceSecurity) as! ThreatDeviceSecurity
        return try! deviceSecurity.isScreenLockEnabled.get()
    }
    
    func isDeviceCompromised() -> Bool {
        let deviceSecurity = try! ThreatStatus().threat(ofType: .deviceSecurity) as! ThreatDeviceSecurity
        return try! deviceSecurity.isDeviceCompromised.get()
    }
    
    func updateThreatStatus() {
        do {
            try DeviceChecker.checkDeviceSecurity()
        }
        catch {
            print("Error updating threat status: \(error)")
        }
    }
    
    func getVersion() -> String {
        do {
            let value = try Diagnostics.runtimeVersion.get()
            print("The value is \(value).")
            return value
        } catch {
            print("Error retrieving the value: \(error)")
            return "error"
        }
    }
    
    func getContainerId() -> String {
        do {
            let appContainerId = try Diagnostics.appContainerID.get()
            return appContainerId
        } catch {
            print("Error retrieving the ContainerID: \(error)")
            return "error"
        }
    }
    
    func getInstanceIdentifier() -> String {
        do {
            let instanceId = try AppIdentity.init().appInstanceIdentifier.get()
            return instanceId
        } catch {
            print("Error retrieving the InstanceId: \(error)")
            return "error"
        }
    }
    
    func getAuthenticityID() -> String {
        do {
            let dict = try AppIdentity().authenticityIdentifiers.get()
            let authenticity = dict[.authenticity]!
            return authenticity
        } catch {
            print("Error retrieving the AuthenticityId: \(error)")
            return "error"
        }
    }
    
    func uploadLogs(callback: @escaping (String) -> Void) {
        do {
            try Diagnostics.uploadLogs(reason: "Uploading Logs from Settings") { status in
                switch status {
                case .busy:
                    print("Busy uploading logs: unknown: \(status)")
                    callback("Busy")
                    break
                case .completed:
                    callback("Completed")
                    break
                case .failed:
                    print("Failed to upload logs: \(status)")
                    callback("Failed")
                    break
                @unknown default:
                    print("Failed to upload logs: unknown: \(status)")
                    callback("Unknown")
                    break
                }
            }
        }
        catch {
            print("Failed to upload logs with error: \(error)")
        }
    }
    
    
    func checkIfExists(fileName : String, create: Bool, initialValue: String?) -> Bool {
        let filePath = getDocumentsDirectory(fileName: fileName)
        
        guard case .success(let fileManager) = BBSFileManager.default, let manager = fileManager else {
            print("Failed to get BBSFileManager instance")
            return false
        }
    
        do {
            let fileExists = try manager.fileExists(atPath: filePath)
            if (!fileExists) {
                if create { 
                    let result = try manager.createFile(atPath: filePath, contents: initialValue!.data(using: .utf8), attributes: nil)
                    return result
                } else { 
                    return false
                }
            } else {
                return true
            } 
        }
        catch {
            print("Error Checking if file exists/creating non-existing file: \(error)")
            return false
        }
    
    }
    
    func contentsOfFile(fileName : String) -> Data? {
        let filePath = getDocumentsDirectory(fileName: fileName)
        
        guard case .success(let fileManager) = BBSFileManager.default, let manager = fileManager else {
            print("Failed to get BBSFileManager instance")
            return nil
        }
        
        do {
            let fileExists =  try manager.fileExists(atPath: filePath)

            if (!fileExists) {
                return nil
            } else {
                return try manager.contents(atPath: filePath)
            }
        }
        catch {
            print("Error Occurred checking contents of file: \(error)")
            return nil
        }
    }
    
    func saveInFile(fileName: String, value : String) {
        let filePath = getDocumentsDirectory(fileName: fileName)
        guard case .success(let fileManager) = BBSFileManager.default, let manager = fileManager else {
            print("Failed to get BBSFileManager instance")
            return
        }
        do {
            _ = try manager.createFile(atPath: filePath, contents: value.data(using: .utf8), attributes: nil)
        }
        catch {
            print("Error Occurred checking contents of file: \(error)")
            return
        }

    }
    
    func getDocumentsDirectory(fileName : String) -> String {
        let paths = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.path + fileName
    }
    
    func isBiometricsAvailable() -> Bool {
        return AppAuthentication.shared.isBiometricsAvailable()
    }
    
    func isBiometricsSetup() -> Bool {
        return AppAuthentication.shared.isBiometricsSetup()
    }
    
    func getUserBiometricSetting() -> Bool {
        return UserDefaults.standard.bool(forKey: "biometricSetting")
    }
    
    func setUserBiometricSetting(value: Bool) {
        UserDefaults.standard.set(value, forKey: "biometricSetting")
    }
}
