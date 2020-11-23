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
            var contectChecker = ContentCheckerRules.init()
            
            if let allowedDomainUrls = contentCheckerRules["AllowedDomainURLs"] {
                contectChecker = contectChecker.setCheckList(listType: .allowlist, listCategory: .domainURLs, checkList: allowedDomainUrls as! [String])
            }
            if let disallowedDomainURLs = contentCheckerRules["DisallowedDomainURLs"] {
                contectChecker = contectChecker.setCheckList(listType: .denylist, listCategory: .domainURLs, checkList: disallowedDomainURLs as! [String])
            }
            if let allowedIPs = contentCheckerRules["AllowedIPs"] {
                contectChecker = contectChecker.setCheckList(listType: .allowlist, listCategory: .ip, checkList: allowedIPs as! [String])
            }
            if let disallowedIPs = contentCheckerRules["DisallowedIPs"] {
                contectChecker = contectChecker.setCheckList(listType: .denylist, listCategory: .ip, checkList: disallowedIPs as! [String])
            }
            
            if let safeBrowsing = contentCheckerRules["SafeBrowsing_CheckType"] as? String {
                let checkType = convertStringToCheckType(input: safeBrowsing)
                contectChecker = contectChecker.setCheckType(threatType: .safeBrowsing, checkType: checkType)
            }
            
            if let safeMessaging = contentCheckerRules["SafeMessaging_CheckType"] as? String {
                let checkType = convertStringToCheckType(input: safeMessaging)
                contectChecker = contectChecker.setCheckType(threatType: .safeMessaging, checkType: checkType)
            }
            if let deviceSecurity = contentCheckerRules["DeviceSecurity_CheckType"] as? String {
                let checkType = convertStringToCheckType(input: deviceSecurity)
                contectChecker = contectChecker.setCheckType(threatType: .deviceSecurity, checkType: checkType)
            }
            if let deviceSoftware = contentCheckerRules["DeviceSoftware_CheckType"] as? String {
                let checkType = convertStringToCheckType(input: deviceSoftware)
                contectChecker = contectChecker.setCheckType(threatType: .deviceSoftware, checkType: checkType)
            }
            _ = ManageRules.setContentCheckerRules(rules: contectChecker)
        }
        
        if let deviceSecurityRules = newRules["DeviceSecurityRules"] {
            let deviceSecurityRule = DeviceSecurityRules.init()
            
            if let lockScreen = deviceSecurityRules["DeviceLockScreen_Check"] as? String {
                if lockScreen == "Enabled" {
                    deviceSecurityRule.enableCheck(check: .deviceLockScreen)
                } else {
                    deviceSecurityRule.disableCheck(check: .deviceLockScreen)
                }
            }
            
            if let debugDetection = deviceSecurityRules["DebugDetection_Check"] as? String {
                if debugDetection == "Enabled" {
                    deviceSecurityRule.enableCheck(check: .debugDetection)
                } else {
                    deviceSecurityRule.disableCheck(check: .debugDetection)
                }
            }
            
            if let debugAction = deviceSecurityRules["DebugDetection_EnforcementAction"] as? String {
                let action = convertStringToAction(input: debugAction)
                deviceSecurityRule.setEnforcementAction(check: .debugDetection, action: action)
            }
            
            if let jaibreakDetection = deviceSecurityRules["JailbreakDetection_Check"] as? String {
                if jaibreakDetection == "Enabled" {
                    deviceSecurityRule.enableCheck(check: .jailbreakDetection)
                } else {
                    deviceSecurityRule.disableCheck(check: .jailbreakDetection)
                }
            }
            
            if let hookDetection = deviceSecurityRules["HookDetection_Check"] as? String {
                if hookDetection == "Enabled" {
                    deviceSecurityRule.enableCheck(check: .hookDetection)
                } else {
                    deviceSecurityRule.disableCheck(check: .hookDetection)
                }
            }
            
            ManageRules.setDeviceSecurityRules(rules: deviceSecurityRule)
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
                deviceSoftwareRule = try! deviceSoftwareRule.setMinimumOSVersion(version: minimumOSVersion)
            }
            
            ManageRules.setDeviceSoftwareRules(rules: deviceSoftwareRule)
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
                dataCollectionRule.setUploadType(uploadType: upload)
            }
            
            if let uploadLimit = deviceCollectionRules["UploadMonthlyLimit"] as? String {
                let upload = convertStringToUploadLimit(input: uploadLimit)
                dataCollectionRule.setUploadMonthlyLimit(uploadMonthlyLimit: upload)
            }
            
            ManageRules.setDataCollectionRules(rules: dataCollectionRule)
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
