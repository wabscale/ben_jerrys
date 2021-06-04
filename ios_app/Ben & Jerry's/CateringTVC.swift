//
//  CateringTVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/5/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit
import CoreData

class CateringTVC: FlavorTagTVC {
    
    @IBAction func unwindToCatering(_ segue: UIStoryboardSegue) {}

    override func viewDidLoad() {
        self.entityID = "Catering"
        
        self.tableView.rowHeight = (self.view.frame.height / CGFloat(self.cellCoefficient))
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.title = self.navTitle
        
        activeTableData = {() -> [NSManagedObject] in
            if self.searchController.isActive && self.searchController.searchBar.text != "" {
                return self.filteredData
            }
            return self.tableData
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
        self.tableData = dat.fetchCoreData(self.entityID)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(CateringTVC.segToEdit))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableData = dat.fetchCoreData(self.entityID)
        self.tableView.reloadData()
        //print("view did appear")
    }
    
    func reset() {
        dat.deleteAllData(entity: "Catering")
        self.tableView.reloadData()
    }
    
    @objc func segToEdit() {
        self.performSegue(withIdentifier: "segToCateringEditTVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        if segue.identifier! == "segueToCVC" {
            let moo = segue.destination as! ContentViewController
            let image = sender as? UIImage
            moo.image = image
            dat.delay(5.0, closure: {() in
                print("exit to catering")
                moo.performSegue(withIdentifier: "exitToCatering", sender: nil)
            })
        }
    }
 

}
