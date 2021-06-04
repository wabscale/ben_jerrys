//
//  Allergy2TVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/12/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit

class Allergy2TVC: FlavorTagTVC {
    
    var segControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segControl = UISegmentedControl(items: ["C","DNC"])
        segControl.addTarget(self, action: #selector(segControlDidChange), for: .valueChanged)
        segControl.selectedSegmentIndex = 0
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: segControl)
    }
    
    @objc func segControlDidChange() {
        let index = self.segControl.selectedSegmentIndex
        switch index { 
        case 0:
            self.tableData = dat.filterData(for: self.entityID)
            self.tableView.reloadData()
            break
        case 1:
            self.tableData = dat.negArray(self.tableData, key: "name")
            self.tableView.reloadData()
            break
        default:
            print("")
        }
    }

}
