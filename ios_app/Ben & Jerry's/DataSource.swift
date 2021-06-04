//
//  JSON.swift
//  Jiri's Homework
//
//  Created by John Cunniff on 12/29/16.
//  Copyright © 2016 JohnCunniff. All rights reserved.
//

import Foundation
import UIKit.UIImage
import CoreData

let dat = DataSource()

class DataSource {
    let version         = "2.3.1"
    var host            : String?
    var progress        : Float = 0.0
    var report          : String?
    var processID       : String!
    var appDelegate     : AppDelegate
    var managedContext  : NSManagedObjectContext
    
    init() {
        appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        managedContext = appDelegate.persistentContainer.viewContext
        host = self.getHost()
    }
    
    //--------------------------------------------------------------------
    // main methods
    

    func flavorData() -> [String:[String]] {
        guard let NSObj: NSManagedObject = self.fetchCoreData("FlavorData").first else { return [:] }
        return self.convertJSON(NSObj.value(forKey: "json") as! String) as! [String:[String]]
    }
    
    func getHost() -> String {
        return self.fetchCoreData("Data_Source_Data").first?.value(forKey: "host") as? String ?? "http://jcmbp.local:8010"
    }
    
    func sendHTTPRequest(url: String, path: String, completionHanler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        // https://stackoverflow.com/questions/38292793/http-requests-in-swift-3
        //print("GET " + path)
        let task = URLSession.shared.dataTask(with: URL(string: (url + "/" + path).replacingOccurrences(of: " ", with: "%20"))!, completionHandler: completionHanler)
        task.resume()
    }
    
    func convertJSON(_ jsonStr: String) -> Any {
        do {
            return try JSONSerialization.jsonObject(with: jsonStr.data(using: String.Encoding.ascii)!, options: .mutableContainers)
        } catch {
            print(error)
        }
        return (Any).self
    }
    
    func filterData(for key: String) -> [NSManagedObject] {
        print(key)
        guard let nsdataobj = self.fetchCoreData("FlavorData").first else {
            return []
        }
        let targetArray = self.convertJSON(nsdataobj.value(forKey: "json") as! String) as! [String:[String]]
        return self.fetchCoreData("All").filter({ targetArray[key]!.contains($0.value(forKey: "name") as! String) })
    }
    
    func fetchCoreData(_ entityName: String, key: String = "name") -> [NSManagedObject] {
        processID = "Fetching \(entityName)"
        progress = 0
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            progress = 1
            return self.alphabetizeCoreDataArray(try managedContext.fetch(fetchRequest), key: key)
        } catch {
            print("1 \(error)")
            self.progress = -1
        }
        return []
    }
    
    func saveFlavor(entityName: String, name: String, tag: UIImage, info: UIImage) {
        //processID = "Saving: \(name)"
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        let objToSave = NSManagedObject(entity: entity, insertInto: managedContext)
        
        objToSave.setValue(name, forKeyPath: "name")
        objToSave.setValue(info.pngData()!, forKey: "info")
        objToSave.setValue(tag.pngData()!, forKey: "tag")
    }
    
    func saveFlavor(entityName: String, obj: NSManagedObject) {
        let name: String = obj.value(forKey: "name") as! String
        let tag = UIImage(data: obj.value(forKey: "tag") as! Data)!
        let info = UIImage(data: obj.value(forKey: "info") as! Data)!
        self.saveFlavor(entityName: entityName, name: name, tag: tag, info: info)
    }
    
    func deleteAllData(entity: String) {
        progress = 0
        processID = "Deleting All Data in \(entity)"
        print(processID ?? "nill")
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        do {
            let results = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            var i: Int = 1
            for managedObject in results {
                progress = Float(i) / Float(results.count)
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
                i+=1
            }
            self.progress = 1
        } catch let error as NSError {
            self.progress = -1
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
        self.processID = "Deleted All Data in \(entity)"
        //try? managedContext.save()
    }
    
    func deleteAllData() {
        progress = 0
        processID = "Deleting All Data"
        
        for i in ["All", "Catering", "Vegan", "Gluten", "FlavorData"] {
            deleteAllData(entity: i)
        }
        
        self.processID = "Deleted All Data"
        
        progress = 1
    }
    
    func saveFlavorEntity(entityName: String, dataArray: [NSManagedObject]) {
        struct Flavor {
            var name: String!
            var tag: UIImage!
            var info: UIImage!
        }
        let arr = dataArray.map({
            Flavor(
                name: $0.value(forKey: "name") as? String,
                tag: UIImage(data: $0.value(forKey: "tag") as! Data)!,
                info: UIImage(data: $0.value(forKey: "info") as! Data)!
            )
        })
        deleteAllData(entity: entityName)
        print("SAVE \(entityName) \(arr.map({ $0.name! }))")
        for obj in arr {
            self.saveFlavor(entityName: entityName, name: obj.name, tag: obj.tag, info: obj.info)
        }
        if managedContext.hasChanges {
            try? managedContext.save()
        }
    }
    
    func requestFlavors(_ array: [String], _ url: String) {
        var flavorCount = 0
        let count = array.count
        
        for flavorName in array {
//            print("GET: \(flavorName)")
            
            self.sendHTTPRequest(url: url, path: "images/" + flavorName + ".jpeg", completionHanler: {(info, response, error) in
                guard let info : Data = info else { return }
                
                
                self.sendHTTPRequest(url: url, path: "images/" + flavorName + "Icon.jpeg", completionHanler: {(tag, response, error) in
                    guard let tag : Data = tag else { return }
                    if let _ : Error = error { return }
                    
                    print(flavorName)
                    self.saveFlavor(entityName: "All", name: flavorName, tag: UIImage(data: tag)!, info: UIImage(data: info)!)
                    flavorCount += 1
                    
                    self.progress = Float(flavorCount) / Float(count)
                    
                    self.processID = "Fetching New Image Data"
                })
            })
        }
    }
    
    func getAllergyInfo(_ flavorData: [String:[String]],_ data: Data?,_ url: String) {
        // deal with allergy data
        func singleAllergyRequest(_ key: String) {
            self.deleteData(self.fetchCoreData(key))
            self.sendHTTPRequest(url: url, path: "images/\(key).jpeg", completionHanler: {(data, response, error) in
                guard let data : Data = data else { return }
                let entity = NSEntityDescription.entity(forEntityName: "\(key)", in: self.managedContext)!
                let objToSave = NSManagedObject(entity: entity, insertInto: self.managedContext)
                objToSave.setValue(data, forKey: "info")
            })
        }
        
        singleAllergyRequest("Gluten")
        singleAllergyRequest("Vegan")
        
        self.deleteData(self.fetchCoreData("Allergy"))
        let allergyentity = NSEntityDescription.entity(forEntityName: "Allergy", in: self.managedContext)!
        for i in flavorData["Allergy"]! {
            let objToSave = NSManagedObject(entity: allergyentity, insertInto: self.managedContext)
            objToSave.setValue(i, forKeyPath: "name")
        }

        
    }
    
    func deleteData(_ arr: [NSManagedObject]) {
        if arr == [] { return }
        for i in arr { self.managedContext.delete(i) }
    }
    
    func saveFlavorData(data: Data) {
        self.deleteData(self.fetchCoreData("FlavorData"))
        let entity = NSEntityDescription.entity(forEntityName: "FlavorData", in: self.managedContext)!
        let objToSave = NSManagedObject(entity: entity, insertInto: self.managedContext)
        objToSave.setValue(NSString(data: data, encoding: String.Encoding.ascii.rawValue), forKey: "json")
    }
    
    func fetchNewDataFromServer(url: String) {
        progress = 0
        processID = "Fetching Data Map"
        sendHTTPRequest(url: url, path: "FlavorData.json", completionHanler: {(data, response, error) in
            if let _ : Error = error {
                print("Fail")
                self.progress = -1
                return
            }
            guard let flavorData = (dat.convertJSON(NSString(data: data!, encoding: String.Encoding.ascii.rawValue)! as String) as? [String : [String]]) else {
                print("Fail")
                self.progress = -1
                return
            }
            
            self.progress = 0
            self.processID = "Fetching New Image Data"
            
            try? self.managedContext.save()
            
            let gets: [String]
            
            let currmapjson: String? = self.fetchCoreData("FlavorData").first?.value(forKey: "json") as? String
            guard let jsonstr: String = currmapjson else {
                gets = flavorData["All"]!
                self.report = "DEL : nil \n GET : \(gets)"
                self.requestFlavors(gets, url)
                self.getAllergyInfo(flavorData, data, url)
                self.saveFlavorData(data: data!)
                return
            }
            
            // optimization from data map
            let currentmap: [String] = (self.convertJSON(jsonstr) as! [String:[String]])["All"]!
            let newmap = flavorData["All"]!
            
            gets = self.antiUnion(newmap, currentmap)
            let dels = self.antiUnion(currentmap, newmap)
            
            self.del_get(gets, dels, data: data, url: url, flavorData: flavorData)
        })
    }
    
    func del_get(_ gets: [String],_ dels: [String], data: Data?, url: String, flavorData: [String:[String]]) {
        print("dels : \(dels)")
        print("gets : \(gets)")
        self.report = "DEL : \(dels) \n GET : \(gets)"
        
        print("saving flavor data map to database...")
        self.saveFlavorData(data: data!)
        
        print("deleting necessary flavors \(dels)")
        self.deleteData(self.fetchCoreData("All").filter({ dels.contains($0.value(forKey: "name") as! String) }))
        
        print("fetching new allergy data...")
        self.getAllergyInfo(flavorData, data, url)
        
        self.processID = "Fetching New Image Data"
        print("getting new flavor data\(gets)")
        self.requestFlavors(gets, url)
    }

    
    //--------------------------------------------------------------------
    // utility methods
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0) { _ in
            closure()
        }
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
    }
    
    func alphabetizeArray(_ data: [String]) -> [String] {
        return data.sorted{ $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
    }
    
    func alphabetizeCoreDataArray(_ data: [NSManagedObject], key: String) -> [NSManagedObject] {
        return data.sorted(by: { ($0.value(forKey: key) as! String).localizedCaseInsensitiveCompare($1.value(forKey: key) as! String) == ComparisonResult.orderedAscending })
    }
    
    func negArray(_ array: [NSManagedObject], key: String) -> [NSManagedObject] {
        let arrStr = array.map({$0.value(forKey: "name") as! String})
        return self.alphabetizeCoreDataArray(self.fetchCoreData("All").filter({ !arrStr.contains($0.value(forKey: "name") as! String) }), key: key)
    }
    
    func antiUnion(_ array1: [String], _ array2: [String]) -> [String] {
        return array1.filter({ !array2.contains($0) }) as [String]
    }
 }
