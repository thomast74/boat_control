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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func btnSettingsTownDown(_ sender: Any) {
        print("Settings page requested")
        let settingsVC = self.storyboard!.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        self.present(settingsVC, animated: true, completion: nil)
    }
    
}
