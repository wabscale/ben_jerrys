//
//  Plist.swift
//  Ben & Jerry's
//
//  Created by John Cunniff on 11/17/16.
//  Copyright © 2016 JohnCunniff. All rights reserved.
//

import Foundation

class Plist {
    
    /*
     writes a String array to a plist. Note that
     the file being writen on needs to already exist.
     */
    func writePlist(fileName: String, key: String, value: [String]) {
        let path = Bundle.main.path(forResource: fileName, ofType: "plist")!
        let data : NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
        data.setValue(value, forKey: key)
        data.write(toFile: path, atomically: true)
        print("writePlist(fileName: \(fileName), key: \(key), value: \(value))")
    }
    
    /* 
     this method reads and returns a [String] from a plist
     */
    func readPlist(fileName: String, key: String) -> [String] {
        var propList:[String:[String]] = {
            var format = PropertyListSerialization.PropertyListFormat.xml
            let plistPath:String? = Bundle.main.path(forResource: fileName, ofType: "plist")!
            let plistXML = FileManager.default.contents(atPath: plistPath!)!
            do {
                return try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &format) as! [String:[String]]
            } catch {
                print("Error reading plist: \(error), format: \(format)")
            }
            return [key:[]]
        }()
        
        print("readPlist(fileName: \(fileName), key: \(key))")
        
        return propList[key]!
    }
    
    /*
     the code below would alphabetize the array read from the plist.
     comment out this return statement to make the alphabetizeing work
     */
    
    /*
     let unfilteredTableData:[String] = propList[key]!
     
     let tableData:[String] = {
        let sortedArray = unfilteredTableData.sorted{ $0.localizedCaseInsensitiveCompare($1 ) == ComparisonResult.orderedAscending }
        return sortedArray
     }()
     
     return tableData
     */
}
