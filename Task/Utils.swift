//
//  Utils.swift
//  Task
//
//  Created by Łukasz Sypniewski on 05/03/2018.
//  Copyright © 2018 Łukasz Sypniewski. All rights reserved.
//

import UIKit
import SystemConfiguration

class Utils {
    
    // MARK: Networking
    // Taken from https://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
    static func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    // MARK: Displaying alerts
    static func showAlert(_ vc: UIViewController, title: String, message: String, buttonText: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(buttonText, comment: "Default action"), style: .`default`, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        //alert.present(vc, animated: true, completion: nil)
    }
    
    static func showNoConnectionAlert(_ vc: UIViewController) {
        showAlert(vc, title: "No internet connection", message: "There is no internet connection, data cannot be downloaded now.", buttonText: "OK")
    }
    
    static func showNoDataAlert(_ vc: UIViewController) {
        showAlert(vc, title: "No data has been downloaded", message: "No data has been downloaded. Check your internet connection and connection parameters!", buttonText: "OK")
    }
    
    static func showInvalidDataFormat(_ vc: UIViewController) {
        showAlert(vc, title: "Downloaded data is in wrong format", message: "Downloaded data is in wrong format " +
            "therefore cannot be parsed! Check if correct JSON file has been downloaded.", buttonText: "OK")
    }
}
