//
//  OnTheWayViewController.swift
//  Boat Control
//
//  Created by Thomas Trageser on 14/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

class OnTheWayViewController: UIViewController, ModelManagerDelegate {

    var modelManager: ModelManager?

    @IBOutlet weak var awa: NumberView!
    @IBOutlet weak var aws: NumberView!
    @IBOutlet weak var twa: NumberView!
    @IBOutlet weak var tws: NumberView!
    @IBOutlet weak var twd: NumberView!
    @IBOutlet weak var compass: CompassView!
    @IBOutlet weak var position: PositionView!
    @IBOutlet weak var sog: NumberView!
    @IBOutlet weak var stw: NumberView!
    @IBOutlet weak var cog: NumberView!
    @IBOutlet weak var depth: NumberView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OnTheWayViewController: viewDidLoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("OnTheWayViewController: viewWillAppear")
        
        modelManager?.setDelegate(self)
        modelManager?.sendCurrentData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("OnTheWayViewController: viewWillDisappear")
    }
    
    @IBAction func btnSettingsTouchDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func modelManager(didReceiveWind wind: Wind) {
        let geomagneticField = self.modelManager?.geomagneticField
        let twdMag = (geomagneticField?.trueToMagnetic(trueDegree: wind.TWD) ?? wind.TWD).rounded(toPlaces: 0)

        DispatchQueue.main.async {
            self.awa.value = wind.AWA
            self.aws.value = wind.AWS
            self.twa.value = wind.TWA
            self.tws.value = wind.TWS
            self.twd.value = twdMag
            self.compass.awa = wind.AWA
            self.compass.twd = twdMag
        }
    }
    
    func modelManager(didReceiveWindHistory windHistory: [WindAggregate]) {

    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
        DispatchQueue.main.async {
            self.position.set(latitude: navigation.latitude, direction: navigation.latitudeDirection)
            self.position.set(longitude: navigation.longitude, direction: navigation.longitudeDirection)
            
            self.sog.value = navigation.speedOverGround
            self.stw.value = navigation.speedThroughWater
            self.cog.value = navigation.courseOverGroundMagnetic
            self.depth.value = -1.0
            self.compass.headingMagnetic = navigation.headingMagnetic
            self.compass.cogMagnetic = navigation.courseOverGroundMagnetic
        }
    }
    
    func modelManager(didReceiveNavigationHistory navigationHistory: [NavigationAggregate]) {

    }
    
    func modelManager(didReceiveSentence nmeaObj: NMEA_BASE) {

    }
    
    func modelManager(didReceiveSystemMessage message: String, of type: MessageType) {

    }

}
