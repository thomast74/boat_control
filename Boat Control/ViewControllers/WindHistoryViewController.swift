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
    
    @IBOutlet weak var aparentWindAngle: NumberView!
    @IBOutlet weak var aparentWindSpeed: NumberView!
    @IBOutlet weak var aparentWindDirection: NumberView!
    @IBOutlet weak var trueWindAngle: NumberView!
    @IBOutlet weak var trueWindSpeed: NumberView!
    @IBOutlet weak var trueWindDirection: NumberView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WindHistoryViewController: viewDidLoad")
        aparentWindAngle.type.text = "AWA"
        aparentWindAngle.measurement.text = "°"
        aparentWindSpeed.type.text = "AWS"
        aparentWindSpeed.measurement.text = "kn"
        aparentWindDirection.type.text = "AWD"
        aparentWindDirection.measurement.text = "°T"
        trueWindAngle.type.text = "TWA"
        trueWindAngle.measurement.text = "°"
        trueWindSpeed.type.text = "TWS"
        trueWindSpeed.measurement.text = "kn"
        trueWindDirection.type.text = "TWD"
        trueWindDirection.measurement.text = "°T"
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
        DispatchQueue.main.async {
            self.aparentWindAngle.number.text = "\(wind.AWA)"
            self.aparentWindSpeed.number.text = "\(wind.AWS)"
            self.aparentWindDirection.number.text = "\(wind.AWD)"
            self.trueWindAngle.number.text = "\(wind.TWA)"
            self.trueWindSpeed.number.text = "\(wind.TWS)"
            self.trueWindDirection.number.text = "\(wind.TWD)"
        }
    }
    
    func modelManager(didReceiveWindHistory windHistory: [Wind]) {
    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
    }
}
