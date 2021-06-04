//
//  FetchNewDataVC.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 7/3/17.
//  Copyright © 2017 JohnCunniff. All rights reserved.
//

import UIKit

class ProgressVC: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    var finishID: String!
    
    var exacutable = {() -> Void in }

    override func viewDidLoad() {
        super.viewDidLoad()
        dat.progress = 0
        dat.report = nil
        
        updateProgress()
        
        dat.delay(0.0, closure: { self.exacutable() })
    }
    
    func processFinAlert() {
        let alert : UIAlertController!
        
        if let rep: String = dat.report {
            alert = UIAlertController(title: "Process FIN",  message: "Task has successfully completed. \n \(rep)", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Process FIN",  message: "Task has successfully completed.", preferredStyle: .alert)
        }
        
        let setAction = UIAlertAction(title: "Done", style: .default) { (action) in
            self.performSegue(withIdentifier: "exit", sender: nil)
        }
        
        alert.addAction(setAction)
        
        present(alert, animated: true)
        
        //try? dat.managedContext.save()
    }
    
    func processFailAlert() {
        let alert = UIAlertController(title: "Process Failed",  message: "Task has failed. Please send a photo of error report to John Cunniff (914) 602-9446 \n\nError Report: \nprogress: \(dat.progress) \nfinishID: \(finishID!) \nerror process: \(dat.processID!)", preferredStyle: .alert)
        
        let setAction = UIAlertAction(title: "Done", style: .default) { (action) in
            self.performSegue(withIdentifier: "exit", sender: nil)
        }
        
        alert.addAction(setAction)
        
        present(alert, animated: true)
    }

    func updateProgress() {
        dat.delay(0.1, closure: {
            if dat.processID == self.finishID && dat.progress == 1 { // if target process complete
                //print("FIN")
                self.finishID = ""
                self.label.text = "FIN"
                self.processFinAlert()
                
                dat.appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                // managed context should be saved while no threads touch core data
                try? dat.managedContext.save()
            } else if dat.progress <= 1 && dat.progress >= 0 { // if process not finished
                self.progressView.progress = dat.progress
                self.label.text = "\(dat.processID!)"
                self.progressLabel.text = "\(Int(dat.progress * 100)) %"
                self.updateProgress()
            } else if dat.progress == -1 { // if process fail detected
                print("Failed")
                self.label.text = "Task Failed"
                self.processFailAlert()
            }
        })
    }
}
