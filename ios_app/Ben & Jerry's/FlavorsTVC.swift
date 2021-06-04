//
//  TestTVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/1/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit

class FlavorsTVC: FlavorTagTVC {
    
    override func viewDidLoad() {
        self.entityID = "All"
        self.scopeButtonTitles = ["All", "Ice Cream", "Sorbet", "Non-Dairy", "Fro-Yo"]
        
        super.viewDidLoad()
    }
    
}
