//
//  WindHistoryViewController.swift
//  Boat Control
//
//  Created by Thomas Trageser on 04/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

class WindHistoryViewController: UIViewController, ModelManagerDelegate {
    
    var modelManager: ModelManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WindHistoryViewController: viewDidLoad")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("WindHistoryViewController: viewWillAppear")
        
        modelManager?.setDelegate(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("WindHistoryViewController: viewWillDisappear")
    }
    
    @IBAction func btnSettingsTownDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func modelManager(didReceiveSentence nmeaObj: NMEA_BASE) {
    }
    
    func modelManager(didReceiveSystemMessage message: String, of type: MessageType) {
        // TODO: Need to find a way to show error
    }
    
    func modelManager(didReceiveWind wind: Wind) {
    }
    
    func modelManager(didReceiveWindHistory windHistory: [Wind]) {
    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
    }
}
