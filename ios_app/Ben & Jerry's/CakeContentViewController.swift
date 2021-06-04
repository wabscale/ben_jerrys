//
//  CakeContentViewController.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 11/22/16.
//  Copyright © 2016 JohnCunniff. All rights reserved.
//

import UIKit

// https://developer.apple.com/reference/swift/dictionary

class CakeContentViewController: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var sizeText: UITextField!
    @IBOutlet weak var employeeText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var flavor1Text: UITextField!
    @IBOutlet weak var flavor2Text: UITextField!
    @IBOutlet weak var decorationText: UITextField!
    @IBOutlet weak var dateOrderedText: UITextField!
    @IBOutlet weak var dateOfPickupText: UITextField!
    @IBOutlet weak var timeOfPickupText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var name = String()
    
    @IBAction func saveDidTouch(_ sender: Any) {
        let cakeForStorage = [nameText.text, sizeText.text, employeeText.text, phoneNumberText.text, flavor1Text.text, flavor2Text.text, decorationText.text, dateOrderedText.text, dateOfPickupText.text, timeOfPickupText.text]
        Plist().writePlist(fileName: "CakeInfo", key: name, value: cakeForStorage as! [String])
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.titleLabel?.text = "Save"
        displayKnownCake(name: name)
        // Do any additional setup after loading the view.
    }
    
    func displayKnownCake(name: String) {
        let cake: [String] = Plist().readPlist(fileName: "CakeInfo", key: name)
        print("cake: " + String(describing: cake))
        nameText.text = cake[6]
        sizeText.text = cake[8]
        employeeText.text = cake[3]
        phoneNumberText.text = cake[7]
        flavor1Text.text = cake[4]
        flavor2Text.text = cake[5]
        decorationText.text = cake[2]
        dateOrderedText.text = cake[1]
        dateOfPickupText.text = cake[0]
        timeOfPickupText.text = cake[9]
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            let moo = segue.destination as! CakesTableViewController
            moo.newName = name
        }
    }
}
