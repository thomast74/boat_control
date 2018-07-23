    //
//  SwinjectStoryboard.swift
//  Boat Control
//
//  Created by Thomas Trageser on 04/07/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard
    
    
extension SwinjectStoryboard {
    @objc class func setup() {
        print("SwinjectStoryboard.setup")

        defaultContainer.register(NMEAReceiverManager.self) { _ in NMEAReceiverManager() }
                        .inObjectScope(.container)

        defaultContainer.register(ModelManager.self) { _ in ModelManager() }
                        .inObjectScope(.container)

        defaultContainer.storyboardInitCompleted(OnTheWayViewController.self) { r, c in
            c.modelManager = r.resolve(ModelManager.self)
        }
        defaultContainer.storyboardInitCompleted(NavigationLogViewController.self) { r, c in
            c.modelManager = r.resolve(ModelManager.self)
        }
        defaultContainer.storyboardInitCompleted(WindHistoryViewController.self) { r, c in
            c.modelManager = r.resolve(ModelManager.self)
        }
        defaultContainer.storyboardInitCompleted(NmeaLogViewController.self) { r, c in
            c.modelManager = r.resolve(ModelManager.self)
        }
    }
}
    
