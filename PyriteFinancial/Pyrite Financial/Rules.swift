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
            do {
                let contectChecker = try ManageRules.getContentCheckerRules()
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
                    contectChecker.setSafeBrowsingCheckType(checkType)
                }
                
                if let safeMessaging = contentCheckerRules["SafeMessaging_CheckType"] as? String {
                    let checkType = convertStringToCheckType(input: safeMessaging)
                    contectChecker.setSafeMessagingCheckType(checkType)
                }
                _ = try ManageRules.setContentCheckerRules(contectChecker)
            }
            catch {
                print("Error, failed to get Content Rules \(error)")
            }
        }
        
        if let deviceSecurityRules = newRules["DeviceSecurityRules"] {
            
            do {
                let deviceSecurityRule = DeviceSecurityRules.init()
                
                if let lockScreen = deviceSecurityRules["DeviceLockScreen_Check"] as? String {
                    if lockScreen.lowercased() == "enabled" {
                        try deviceSecurityRule.enableCheck(.deviceLockScreen)
                    } else {
                        try deviceSecurityRule.disableCheck(.deviceLockScreen)
                    }
                }
                
                if let debugDetection = deviceSecurityRules["DebugDetection_Check"] as? String {
                    if debugDetection.lowercased() == "enabled" {
                        try deviceSecurityRule.enableCheck(.debugDetection)
                    } else {
                        try deviceSecurityRule.disableCheck(.debugDetection)
                    }
                }
                
                if let debugAction = deviceSecurityRules["DebugDetection_EnforcementAction"] as? String {
                    let action = convertStringToAction(input: debugAction)
                    try deviceSecurityRule.setEnforcementAction(action, for: .debugDetection)
                }
                
                if let jaibreakDetection = deviceSecurityRules["JailbreakDetection_Check"] as? String {
                    if jaibreakDetection.lowercased() == "enabled" {
                        try deviceSecurityRule.enableCheck(.jailbreakDetection)
                    } else {
                        try deviceSecurityRule.disableCheck(.jailbreakDetection)
                    }
                }
                
                if let hookDetection = deviceSecurityRules["HookDetection_Check"] as? String {
                    if hookDetection.lowercased() == "enabled" {
                        try deviceSecurityRule.enableCheck(.hookDetection)
                    } else {
                        try deviceSecurityRule.disableCheck(.hookDetection)
                    }
                }
                
                _ = try ManageRules.setDeviceSecurityRules(deviceSecurityRule)
            }
            catch {
                print("Unable to set Device Security Rules: \(error)")
            }
        }
        
        if let deviceSoftwareRules = newRules["iOSDeviceSoftwareRules"] {
            do {
                var deviceSoftwareRule = DeviceSoftwareRules.init()
                
                if let deviceOSCheck = deviceSoftwareRules["DeviceOSSoftware_Check"] as? String {
                    if deviceOSCheck.lowercased() == "enabled" {
                        try deviceSoftwareRule.enableCheck()
                    } else {
                        try deviceSoftwareRule.disableCheck()
                    }
                }
                
                if let minimumOSVersion = deviceSoftwareRules["MinimumOSVersion"] as? String {
                    deviceSoftwareRule = try! deviceSoftwareRule.setMinimumOSVersion(minimumOSVersion)
                }
                
                _ = try ManageRules.setDeviceSoftwareRules(deviceSoftwareRule)
            }
            catch {
                print("Unable to set Device OS Check: \(error)")
            }
        }
        
        
        if let deviceOfflineRules = newRules["DeviceOfflineRules"] {
            if let minutesToMedium = deviceOfflineRules["MinutesToMedium"] as? String, let minutesToHigh = deviceOfflineRules["MinutesToHigh"] as? String {
                let deviceOfflineRule = try! DeviceOfflineRules.init(minutesToMediumThreatLevel: Int(minutesToMedium)!, minutesToHighThreatLevel: Int(minutesToHigh)!)
                do {
                    _ = try ManageRules.setDeviceOfflineRules(deviceOfflineRule)
                }
                catch {
                    print("Failed to set Device Offline Rules: \(error)")
                }
            }
        }
        
        if let features = newRules["Features"] {
            do {
                if let deviceSecurity = features["DeviceSecurity_Enabled"] as? String {
                    if (deviceSecurity.lowercased() == "enabled") {
                        _ = try ManageFeatures.enableFeature(.deviceSecurity)
                    } else {
                        _ = try ManageFeatures.disableFeature(.deviceSecurity)
                    }
                }
                
                if let deviceSoftware = features["DeviceSoftware_Enabled"] as? String {
                    if (deviceSoftware.lowercased() == "enabled") {
                        _ = try ManageFeatures.enableFeature(.deviceSoftware)
                    } else {
                        _ = try ManageFeatures.disableFeature(.deviceSoftware)
                    }
                }
                
                if let safeBrowsing = features["SafeBrowsing_Enabled"] as? String {
                    if (safeBrowsing.lowercased() == "enabled") {
                        _ = try ManageFeatures.enableFeature(.safeBrowsing)
                    } else {
                        _ = try ManageFeatures.disableFeature(.safeBrowsing)
                    }
                }
                
                if let safeMessaging = features["SafeMessaging_Enabled"] as? String {
                    if (safeMessaging.lowercased() == "enabled") {
                        _ = try ManageFeatures.enableFeature(.safeMessaging)
                    } else {
                        _ = try ManageFeatures.disableFeature(.safeMessaging)
                    }
                }
                
                if let deviceOffline = features["DeviceOffline_Enabled"] as? String {
                    if (deviceOffline.lowercased() == "enabled") {
                        _ = try ManageFeatures.enableFeature(.deviceOffline)
                    } else {
                        _ = try ManageFeatures.disableFeature(.deviceOffline)
                    }
                }
            }
            catch {
                print("Failed to set Device Feature Rules: \(error)")
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
    
}
