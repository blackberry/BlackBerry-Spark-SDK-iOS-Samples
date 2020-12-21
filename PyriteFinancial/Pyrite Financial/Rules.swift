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
import BlackBerrySecurity

class Rules {
    func updateRules(newRules: Dictionary<String, AnyObject>) {
        
        if let contentCheckerRules = newRules["ContentCheckerRules"] {
            let contectChecker = ManageRules.getContentCheckerRules()
            
            if let allowedDomainUrls = contentCheckerRules["AllowedDomainURLs"] as? [String] {
                
                contectChecker.allowURLs = allowedDomainUrls
            }
            if let disallowedDomainURLs = contentCheckerRules["DisallowedDomainURLs"] as? [String] {
                contectChecker.denyURLs = disallowedDomainURLs
            }
            if let allowedIPs = contentCheckerRules["AllowedIPs"] as? [String] {
                contectChecker.allowIPs = allowedIPs
            }
            if let disallowedIPs = contentCheckerRules["DisallowedIPs"] as? [String] {
                contectChecker.denyURLs = disallowedIPs
            }
            
            if let safeBrowsing = contentCheckerRules["SafeBrowsing_CheckType"] as? String {
                let checkType = convertStringToCheckType(input: safeBrowsing)
                contectChecker.setCheckType(checkType, for: .safeBrowsing)
            }
            
            if let safeMessaging = contentCheckerRules["SafeMessaging_CheckType"] as? String {
                let checkType = convertStringToCheckType(input: safeMessaging)
                contectChecker.setCheckType(checkType, for: .safeMessaging)
            }
            _ = ManageRules.setContentCheckerRules(contectChecker)
        }
        
        if let deviceSecurityRules = newRules["DeviceSecurityRules"] {
            let deviceSecurityRule = DeviceSecurityRules.init()
            
            if let lockScreen = deviceSecurityRules["DeviceLockScreen_Check"] as? String {
                if lockScreen == "Enabled" {
                    deviceSecurityRule.enableCheck(.deviceLockScreen)
                } else {
                    deviceSecurityRule.disableCheck(.deviceLockScreen)
                }
            }
            
            if let debugDetection = deviceSecurityRules["DebugDetection_Check"] as? String {
                if debugDetection == "Enabled" {
                    deviceSecurityRule.enableCheck(.debugDetection)
                } else {
                    deviceSecurityRule.disableCheck(.debugDetection)
                }
            }
            
            if let debugAction = deviceSecurityRules["DebugDetection_EnforcementAction"] as? String {
                let action = convertStringToAction(input: debugAction)
                deviceSecurityRule.setEnforcementAction(action, for: .debugDetection)
            }
            
            if let jaibreakDetection = deviceSecurityRules["JailbreakDetection_Check"] as? String {
                if jaibreakDetection == "Enabled" {
                    deviceSecurityRule.enableCheck(.jailbreakDetection)
                } else {
                    deviceSecurityRule.disableCheck(.jailbreakDetection)
                }
            }
            
            if let hookDetection = deviceSecurityRules["HookDetection_Check"] as? String {
                if hookDetection == "Enabled" {
                    deviceSecurityRule.enableCheck(.hookDetection)
                } else {
                    deviceSecurityRule.disableCheck(.hookDetection)
                }
            }
            
            ManageRules.setDeviceSecurityRules(deviceSecurityRule)
        }
        
        if let deviceSoftwareRules = newRules["iOSDeviceSoftwareRules"] {
            var deviceSoftwareRule = DeviceSoftwareRules.init()
            
            if let deviceOSCheck = deviceSoftwareRules["DeviceOSSoftware_Check"] as? String {
                if deviceOSCheck == "Enabled" {
                    deviceSoftwareRule.enableDeviceOSCheck()
                } else {
                    deviceSoftwareRule.disableDeviceOSCheck()
                }
            }
            
            if let minimumOSVersion = deviceSoftwareRules["MinimumOSVersion"] as? String {
                deviceSoftwareRule = try! deviceSoftwareRule.setMinimumOSVersion(minimumOSVersion)
            }
            
            ManageRules.setDeviceSoftwareRules(deviceSoftwareRule)
        }
        
        if let deviceCollectionRules = newRules["DataCollectionRules"] {
            let dataCollectionRule = DataCollectionRules.init()
            
            if let dataCollectionEnabled = deviceCollectionRules["DataCollectionEnabled"] as? String {
                if dataCollectionEnabled == "Enabled" {
                    dataCollectionRule.enableDataCollection()
                } else {
                    dataCollectionRule.disableDataCollection()
                }
            }
            
            if let uploadType = deviceCollectionRules["UploadType"] as? String {
                let upload = convertStringToUploadType(input: uploadType)
                dataCollectionRule.setUploadType(upload)
            }
            
            if let uploadLimit = deviceCollectionRules["UploadMonthlyLimit"] as? String {
                let upload = convertStringToUploadLimit(input: uploadLimit)
                dataCollectionRule.setUploadMonthlyLimit(upload)
            }
            
            ManageRules.setDataCollectionRules(dataCollectionRule)
        }
        
        if let deviceOfflineRules = newRules["DeviceOfflineRules"] {
            let deviceOffilenRule = DeviceOfflineRules.init()

            if let minutesToMedium = deviceOfflineRules["MinutesToMedium"] as? String  {
                deviceOffilenRule.minutesToMediumRule = Int(minutesToMedium)!
            }

            if let minutesToHigh = deviceOfflineRules["MinutesToHigh"] as? String  {
                deviceOffilenRule.minutesToHighRule = Int(minutesToHigh)!
            }

            ManageRules.setDeviceOfflineRules(deviceOffilenRule)
        }
        
        if let features = newRules["Features"] {
            
            if let deviceSecurity = features["DeviceSecurity_Enabled"] as? String {
                if (deviceSecurity == "ENABLED") {
                    _ = ManageFeatures.enableFeature(.deviceSecurity)
                } else {
                    _ = ManageFeatures.disableFeature(.deviceSecurity)
                }
            }
            
            if let deviceSoftware = features["DeviceSoftware_Enabled"] as? String {
                if (deviceSoftware == "ENABLED") {
                    _ = ManageFeatures.enableFeature(.deviceSoftware)
                } else {
                    _ = ManageFeatures.disableFeature(.deviceSoftware)
                }
            }
            
            if let safeBrowsing = features["SafeBrowsing_Enabled"] as? String {
                if (safeBrowsing == "ENABLED") {
                    _ = ManageFeatures.enableFeature(.safeBrowsing)
                } else {
                    _ = ManageFeatures.disableFeature(.safeBrowsing)
                }
            }
            
            if let safeMessaging = features["SafeMessaging_Enabled"] as? String {
                if (safeMessaging == "ENABLED") {
                    _ = ManageFeatures.enableFeature(.safeMessaging)
                } else {
                    _ = ManageFeatures.disableFeature(.safeMessaging)
                }
            }
            
            if let deviceOffline = features["DeviceOffline_Enabled"] as? String {
                if (deviceOffline == "ENABLED") {
                    _ = ManageFeatures.enableFeature(.deviceOffline)
                } else {
                    _ = ManageFeatures.disableFeature(.deviceOffline)
                }
            }
        }
    }
    
    func convertStringToCheckType(input: String) -> BlackBerrySecurity.CheckType {
        var checkType : BlackBerrySecurity.CheckType
        switch input {
        case "CLOUD":
            checkType = BlackBerrySecurity.CheckType.cloud
        case "CHECK_LIST_ONLY":
            checkType = BlackBerrySecurity.CheckType.checklistOnly
        case "ON_DEVICE":
            checkType = BlackBerrySecurity.CheckType.onDevice
        default:
            checkType = BlackBerrySecurity.CheckType.cloud
        }
        return checkType
    }
    
    func convertStringToAction(input: String) -> BlackBerrySecurity.DeviceSecurityEnforcementAction {
        var action : BlackBerrySecurity.DeviceSecurityEnforcementAction
        switch input {
        case "NOTIFY":
            action = .notify
        case "TERMINATE":
            action = .terminateProcess
        default:
            action = .notify
        }
        return action
    }
    
    func convertStringToUploadType(input: String) -> BlackBerrySecurity.UploadType {
        var uploadType : BlackBerrySecurity.UploadType
        switch input {
        case "WIFI_WHILE_CHARGING":
            uploadType = .wifiWhileCharging
        case "WIFI":
            uploadType = .wifi
        case "WIFI_AND_MOBILE":
            uploadType = .wifiAndMobile
        default:
            uploadType = .wifi
        }
        return uploadType
    }
    
    func convertStringToUploadLimit(input: String) -> BlackBerrySecurity.UploadMonthlyLimit {
        var uploadLimit : BlackBerrySecurity.UploadMonthlyLimit
        switch input {
        case "LIMIT_100MB":
            uploadLimit = .limit100MB
        case "LIMIT_50MB":
            uploadLimit = .limit50MB
        case "LIMIT_10MB":
            uploadLimit = .limit10MB
        default:
            uploadLimit = .limit10MB
        }
        return uploadLimit
    }
}
