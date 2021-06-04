//
//  CakesTableViewController.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 11/22/16.
//  Copyright © 2016 JohnCunniff. All rights reserved.
//

import UIKit



class CakesTableViewController: UITableViewController {
    
    var name = String()
    var newName = String()
    var tableData = [String]()
    
    @IBAction func unwindToCakes(_ segue: UIStoryboardSegue) {
        if !tableData.contains(newName) {
            tableData.append(newName)
        }
        print("New tableData: \(tableData)")
        Plist().writePlist(fileName: "CakeInfo", key: "Name List", value: tableData)
        tableView.reloadData()
    }

    @IBAction func plus(_ sender: Any) {
        tableData.append("New Cake")
        Plist().writePlist(fileName: "CakeInfo", key: "Name List", value: tableData)
        name = "New Cake"
        performSegue(withIdentifier: "click", sender: self)
        
        /*
        create new value in name array and blank cake in cake dictionary
        segue to cake content view controller
         */
    }
    
    @IBAction func button(_ sender: Any) {
        let testArray: [String] = ["test"]
        Plist().writePlist(fileName: "CakeInfo", key: "Name List", value: testArray)
        tableData = Plist().readPlist(fileName: "CakeInfo", key: "Name List")
        print(tableData)
        if tableData.contains("test") {
            print("wrote \(testArray) to plist")
        } else {
            print("Failed")
        }
        tableView.reloadData()
    }
    
    func loadNamesAtStartup() {
        tableData = Plist().readPlist(fileName: "CakeInfo", key: "Name List")
        tableView.reloadData()
        
        /* 
         load up name list saved on Names.plist when cake table view is open
         */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "<- Don't touch that button"
        loadNamesAtStartup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableData[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        name = tableData[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "click", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "click" {
            let moo = segue.destination as! CakeContentViewController
            moo.name = name
        }
    }
}
