//
//  FlavorTagTVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/1/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

extension FlavorTagTVC: UISearchResultsUpdating, UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? FlavorTagCell else {
            return nil
        }
        
        guard let detailView = storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as? ContentViewController else {
            return nil
        }
        
        previewingContext.sourceRect = cell.frame
        detailView.image = cell.infoImage
        detailView.preferredContentSize = CGSize(width: 0, height: 500)
        
        return detailView
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

    private func touchedView(view: UIView, location: CGPoint) -> Bool {
        let locationInView = view.convert(location, from: tableView)
        return view.bounds.contains(locationInView)
    }

    func createUIImageViewController(image: UIImage) -> UIViewController {
        let viewController = UIViewController()
        let imageView = UIImageView()
        imageView.image = image
        viewController.view.addSubview(imageView)
        viewController.view.frame = imageView.frame
        return viewController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchBar.returnKeyType = .search
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchBar.text!, scope: scope)
    }
}

class FlavorTagTVC: UITableViewController {
    
    var tableData: [NSManagedObject] = []
    var entityID: String = ""
    var filteredData: [NSManagedObject] = []
    var scopeButtonTitles: [String] = [""]
    var cellCoefficient = 7
    var navTitle: String = ""
    let searchController = UISearchController(searchResultsController: nil)
    var activeTableData: () -> [NSManagedObject]? = { return [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = (self.view.frame.height / CGFloat(self.cellCoefficient))
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.title = self.navTitle
        
        self.tableData = dat.filterData(for: self.entityID)
        
        activeTableData = {() -> [NSManagedObject] in
            if self.searchController.isActive && self.searchController.searchBar.text != "" {
                return self.filteredData
            }
            return self.tableData
        }
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableData = dat.filterData(for: self.entityID)
        self.tableView.reloadData()
        //print("view did appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.activeTableData()!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FlavorTagCell
        
        let activeTD = self.activeTableData()!
        
        cell.cellImage.image = UIImage(data: activeTD[indexPath.row].value(forKey: "tag") as! Data)
        cell.infoImage = UIImage(data: activeTD[indexPath.row].value(forKey: "info") as! Data)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected: NSManagedObject!
        
        selected = activeTableData()![indexPath.row]
        
        performSegue(withIdentifier: "segueToCVC", sender: UIImage(data: selected.value(forKey: "info") as! Data))
    }
    
    /*
     fiters tableData based on scope and searchText
     */
    func filterContentForSearchText(_ searchText: String, scope: String) {
        if scope != "" {
             self.tableData = dat.filterData(for: scope)
        } else {
             self.tableData = dat.filterData(for: self.entityID)
        }
       
        self.filteredData = self.tableData.filter({ (tableDataObj: NSManagedObject) -> Bool in
            return (tableDataObj.value(forKey: "name") as! String).lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableData.remove(at: indexPath.row)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let temp = tableData[fromIndexPath.row]
        tableData[fromIndexPath.row] = tableData[to.row]
        tableData[to.row] = temp
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
        }
    }
}
