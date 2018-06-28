//
//  SettingsViewController.swift
//  Boat Control
//
//  Created by Thomas Trageser on 24/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var fldConnectionType: UISegmentedControl!
    @IBOutlet weak var fldIPAddress: UITextField!
    @IBOutlet weak var fldPort: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let connectionType = UserDefaults.standard.value(forKey: "nmea_connection_type") as? String
        
        fldConnectionType.selectedSegmentIndex = Int(connectionType ?? "0")!
        fldIPAddress.text = UserDefaults.standard.value(forKey: "nmea_ip_address") as? String
        fldPort.text = UserDefaults.standard.value(forKey: "nmea_port") as? String
        
        setStateOfFldIpAddress()
    }
    
    @IBAction func connectionTypeValueChanged(_ sender: Any) {
        setStateOfFldIpAddress()
    }
    
    func setStateOfFldIpAddress() {
        let connectionType = fldConnectionType.titleForSegment(at: fldConnectionType.selectedSegmentIndex)
        
        if connectionType == "UDP" {
            fldIPAddress.text = "0.0.0.0"
            fldIPAddress.isEnabled = false
        }
        else {
            fldIPAddress.isEnabled = true
        }
    }
    
    @IBAction func btnSaveTouchDown(_ sender: Any) {
        print("Save pressed, check and store entered values,close if successful")
        
        if verifyIpAddressEntry() == false {
            print("Entered IP Address not correct, show error message")
            return
        }
        
        if verifyPort() == false {
            print("Port is not correct, show error message")
            return
        }
        
        UserDefaults.standard.set(String(fldConnectionType.selectedSegmentIndex), forKey: "nmea_connection_type")
        UserDefaults.standard.set(fldIPAddress.text!, forKey: "nmea_ip_address")
        UserDefaults.standard.set(fldPort.text!, forKey: "nmea_port")

        NotificationCenter.default.post(name: NotificationNames.SETTINGS_UPDATED, object: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    func verifyIpAddressEntry() -> Bool {
        if fldConnectionType.selectedSegmentIndex == 0 {
            let validIpAddressRegex = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
            if (fldIPAddress.text!.range(of: validIpAddressRegex, options: NSString.CompareOptions.regularExpression) == nil) {
                return false
            }
        }

        return true
    }
    
    func verifyPort() -> Bool {
        let port:Int? = Int(fldPort.text!)
        if port == nil || port! < 1024 || port! >= 65535 {
            return false
        }
        
        return true
    }
    
}
