//
//  CateringEditTVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/5/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit
import CoreData

class CateringEditTVC: FlavorTagTVC {
    
    var tempDataArray: [NSManagedObject] = []

    override func viewDidLoad() {
        self.entityID = "All"
        self.cellCoefficient = 15
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(CateringEditTVC.exit))
        
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tempDataArray = dat.fetchCoreData("Catering")
        //print(self.tempDataArray.map({ $0.value(forKey: "name") as! String }))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var name: String!
        var temptd: [String]!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            name = filteredData[indexPath.row].value(forKey: "name") as? String
            temptd = filteredData.map({ $0.value(forKey: "name") as! String })
        } else {
            name = tableData[indexPath.row].value(forKey: "name") as? String
            temptd = tableData.map({ $0.value(forKey: "name") as! String })
        }
        
        cell.textLabel?.text = name
        
        let temptemp = tempDataArray.map({ $0.value(forKey: "name") as! String })
        
        if temptemp.contains(temptd[indexPath.row]) {
            cell.imageView?.image = UIImage(named: "CheckMark.png")
        } else {
            cell.imageView?.image = UIImage()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected: NSManagedObject!
        let temptd: [String]!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selected = filteredData[indexPath.row]
            temptd = filteredData.map({ $0.value(forKey: "name") as! String })
        } else {
            selected = tableData[indexPath.row]
            temptd = tableData.map({ $0.value(forKey: "name") as! String })
        }
        
        let temptemp = tempDataArray.map({ $0.value(forKey: "name") as! String })
        
        if !temptemp.contains(temptd[indexPath.row]) {
            tempDataArray.append(selected)
        } else {
            let i = temptemp.firstIndex(of: selected.value(forKey: "name") as! String)!
            tempDataArray.remove(at: i)
        }
        
        //print(tempDataArray.map({ $0.value(forKey: "name") as! String }))
        
        self.tableView.reloadData()
    }
    
    @objc func exit() {
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        dat.saveFlavorEntity(entityName: "Catering", dataArray: tempDataArray)
        print("saving catering")
        //(segue.destination as! CateringTVC).tableData = dat.fetchCoreData("Catering")
    }
    

}
