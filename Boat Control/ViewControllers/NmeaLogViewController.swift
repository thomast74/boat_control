//
//  NmeaLogViewController.swift
//  Boat Control
//
//  Created by Thomas Trageser on 24/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

class NmeaLogViewController: UIViewController {
    
    @IBOutlet weak var txtErrorMessage: UILabel!
    @IBOutlet weak var txtSentences: UITextView!
    
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(newNMEASentenceReceived), name: NotificationNames.NMEA_NEW_SENTENCE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newNMEAErrorReceived), name: NotificationNames.NMEA_CONNECTION_ERROR, object: nil)
        txtSentences.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("NmeaLogViewController: viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func btnSettingsTownDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    @objc func newNMEASentenceReceived(notificaiton: Notification) {
        DispatchQueue.global(qos: .default).async {
            if notificaiton.object != nil {
                let nmeaObj = notificaiton.object! as? NMEA_BASE
                if nmeaObj != nil {
                    DispatchQueue.main.async {
                        var oldText = self.txtSentences.text ?? ""
                        DispatchQueue.global(qos: .default).async {
                            oldText.append(nmeaObj!.raw + "\n")
                            
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
            }
        }
    }

    @objc func newNMEAErrorReceived(notificaiton: Notification) {
        DispatchQueue.main.async {
            if notificaiton.object != nil {
                if notificaiton.object is String {
                    print((notificaiton.object as! String))
                } else if notificaiton.object is Error {
                    print((notificaiton.object as! Error).localizedDescription)
                }
            }
        }
    }
}
