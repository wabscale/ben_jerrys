//
//  MoreTVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/2/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit
import CoreData

struct Exe {
    var executable: () -> Void
    var title: String
    var finishID: String
}

class MoreTVC: UITableViewController, UITextFieldDelegate {
    
    let password: String = "red911"
    //var action: () -> Void
    //var currentAlert: UIAlertController
    
    override func viewDidLoad() {
        self.tableView.rowHeight = CGFloat(self.view.frame.height / 7.0)
        self.navigationItem.title = "\(dat.version)"
    }
    
    @IBAction func unwindToMore(_ segue: UIStoryboardSegue) {}
    @IBAction func fetchNewData() {
        self.createAlert(title: "Fetch New Data", finishID: "Fetching New Image Data", e: { dat.fetchNewDataFromServer(url: dat.getHost()) })
    }

    @IBAction func deleteAllData() {
        self.createAlert(title: "Delete All Data", finishID: "Deleted All Data", e: { dat.deleteAllData() })
    }

    @IBAction func resetCateringData(_ sender: Any) {
        self.createAlert(title: "Reset Catring Data", finishID: "Deleted All Data in Catering", requirePassword: false, enabled: true, e: { dat.deleteAllData(entity: "Catering") })
    }
    
    @IBAction func setHost(_ sender: Any) {
        let alert = UIAlertController(title: "Set Host",  message: "", preferredStyle: .alert)
        
        let setAction = UIAlertAction(title: "Set", style: .destructive) { (action) in
            let hostTextField     = alert.textFields?[0]
            let passwordTextField = alert.textFields?[1]
            
            if passwordTextField?.text == self.password {
                dat.deleteAllData(entity: "Data_Source_Data")
                let entity = NSEntityDescription.entity(forEntityName: "Data_Source_Data", in: dat.managedContext)!
                let objToSave = NSManagedObject(entity: entity, insertInto: dat.managedContext)
                objToSave.setValue(hostTextField?.text, forKeyPath: "host")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        setAction.isEnabled = false
        
        alert.addTextField(configurationHandler: {(textField) in
            textField.text = dat.getHost()
        })
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter Admin Password"
            textField.isSecureTextEntry = true
        })
        
        let isEnabledExe: () -> Void = {() in setAction.isEnabled = alert.textFields?[0].text! != "" && alert.textFields?[1].text! != ""}
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?[0], queue: OperationQueue.main) { notification in isEnabledExe() }
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?[1], queue: OperationQueue.main) { notification in isEnabledExe() }
        
        alert.addAction(setAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction func about(_ sender: Any) {
        let alert = UIAlertController(title: "About", message: "Maintained by John Cunniff \n+1 (914) 602-9446 \njohncunniff1248@gmail.com", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        present(alert, animated: true)
    }
    
    func createAlert(title: String, segID: String? = "segToProgressVC", finishID: String = "", requirePassword: Bool = true, message: String = "", enabled: Bool = false, e: @escaping () -> Void) {
        let alert = UIAlertController(title: title,  message: message, preferredStyle: .alert)
        
        let runAction = UIAlertAction(title: "Run", style: .destructive) { (action) in
            if requirePassword && alert.textFields?[0].text == self.password {
                guard let segID = segID else { e(); return }
                self.performSegue(withIdentifier: segID, sender: Exe(
                    executable: e,
                    title: alert.title!,
                    finishID: finishID
                ))
            } else if !requirePassword {
                guard let segID = segID else { e(); return }
                self.performSegue(withIdentifier: segID, sender: Exe(
                    executable: e,
                    title: alert.title!,
                    finishID: finishID
                ))
            }
        }
        runAction.isEnabled = enabled
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        if requirePassword {
            alert.addTextField(configurationHandler: {(textField) in
                textField.placeholder = "Enter Admin Password"
                textField.isSecureTextEntry = true
                textField.delegate = textdel(a: {})
                
                NotificationCenter.default.addObserver(
                    forName: UITextField.textDidChangeNotification,
                    object: textField,
                    queue: OperationQueue.main
                ) { notification in
                    runAction.isEnabled = textField.text != ""
                }
            })
        }
        
        alert.addAction(runAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    class textdel: NSObject, UITextFieldDelegate {
        init(a: @escaping () -> Void) {
            self.action = a
        }
        
        var action: () -> Void
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            //textField.resignFirstResponder()
            print("text field should return")
            self.action()
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segToProgressVC" {
            let VC = segue.destination as! ProgressVC
            let e = sender as! Exe
            VC.exacutable = e.executable
            VC.finishID = e.finishID
            VC.navigationItem.title = e.title
        }
    }
}
