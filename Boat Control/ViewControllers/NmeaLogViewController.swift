//
//  NmeaLogViewController.swift
//  Boat Control
//
//  Created by Thomas Trageser on 24/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

class NmeaLogViewController: UIViewController, ModelManagerDelegate {
    
    @IBOutlet weak var txtErrorMessage: UILabel!
    @IBOutlet weak var txtSentences: UITextView!
    
    var modelManager: ModelManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("NmeaLogViewController: viewDidLoad")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("NmeaLogViewController: viewWillAppear")
        
        modelManager?.setDelegate(self)
        txtSentences.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("NmeaLogViewController: viewWillDisappear")
        
        modelManager?.removeDelegate()
    }
    
    @IBAction func btnSettingsTownDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func modelManager(didReceiveSentence nmeaObj: NMEA_BASE) {
        DispatchQueue.main.async {
            var oldText = self.txtSentences.text ?? ""
            DispatchQueue.global(qos: .userInitiated).async {
                oldText.append(nmeaObj.raw + "\n")
                
                var lines = oldText.split(separator: "\n")
                if lines.count > 100 {
                    lines.removeFirst(lines.count - 100)
                }
                
                DispatchQueue.main.async {
                    let newText = lines.joined(separator: "\n") + "\n"
                    self.txtSentences.text = newText
                    let bottom = NSMakeRange(self.txtSentences.text.count-1,1)
                    self.txtSentences.scrollRangeToVisible(bottom)
                }
            }
        }
    }
    
    func modelManager(didReceiveWind wind: Wind) {
    }
    
    func modelManager(didReceiveWindHistory windHistory: [Wind]) {
    }
    
    func modelManager(didReceiveNavigation navigation: Navigation) {
    }
}
