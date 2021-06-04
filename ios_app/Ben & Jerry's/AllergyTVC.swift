//
//  AllergyTVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/4/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit
import CoreData

class AllergyTVC: UITableViewController {
    
    var tableData = { () -> [String] in
        guard let jsonstr: String = dat.fetchCoreData("FlavorData").first?.value(forKey: "json") as? String else {
            return []
        }
        return (dat.convertJSON(jsonstr) as!  [String:[String]])["Allergy"]!
    }()
    let bypassCells = ["Gluten", "Vegan"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = (self.view.frame.height / 10)
        //print((dat.convertJSON(dat.fetchCoreData("FlavorData").first?.value(forKey: "json") as! String) as!  [String:[String]])["Allergy"]!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        
        tableData = { () -> [String] in
            guard let jsonstr: String = dat.fetchCoreData("FlavorData").first?.value(forKey: "json") as? String else {
                return []
            }
            return (dat.convertJSON(jsonstr) as!  [String:[String]])["Allergy"]!
        }()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = tableData[indexPath.row]
        print(selected)
        
        if self.bypassCells.contains(selected) {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: selected) as NSFetchRequest
            let image = UIImage(data: (try? dat.managedContext.fetch(fetchRequest))?.first?.value(forKey: "info") as! Data)!
            performSegue(withIdentifier: "segToContentVC", sender: image)
            return
        }
        
        performSegue(withIdentifier: "segToAllergy2", sender: selected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier!
        //print(sender as! String)
        
        if segueID == "segToAllergy2" {
            let dest = segue.destination as! Allergy2TVC
            dest.entityID = (sender as! String).replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "-",with: "_")
            dest.navTitle = sender as! String
        } else if segueID == "segToContentVC" {
            let dest = segue.destination as! ContentViewController
            dest.image = sender as? UIImage
            
        }
    }
}
