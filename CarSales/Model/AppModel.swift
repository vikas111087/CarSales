//
//  AppModel.swift
//  CarSales
//
//  Created by Vikas Bawa on 23/06/22.
//  Copyright © 2022 Vikas Bawa. All rights reserved.
//

import UIKit

class AppModel: NSObject {
    private var m_arrCars                   = NSMutableArray()
    private var m_arrCarsName               = NSMutableArray()
    private var m_arrCarDetail              = NSMutableArray()
    
    private var m_dicSearchedCar            = NSMutableDictionary()
    private var m_dicSelectedCar            = NSDictionary()
    
    //MARK: Singleton Objects
    static let sharedInstance : AppModel = {
        let instance = AppModel()
        return instance
    }()
    
    func getBaseURL() -> String {
        return _BASE_URL
    }
    
    func getCarsDataURL() -> String {
        return _CARS_DATA_URL
    }
    
    func parseCarsData(_ dic: NSMutableDictionary) {
        if (0 == dic.count)  {
            print("parseCarsData : Unable to read dic.")
            NotificationCenter.default.post(name: Notification.Name(rawValue: _FAILED_TO_GET_CARS_DATA_NOTIFICATION), object: nil)
            return
        }
        
        if(nil != dic.value(forKey: "Result")) {
            if let results = dic.value(forKey: "Result") as? NSArray {
                setCarsData(results)
            }
            else { print("parseCarsData : Unable to read results.") }
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: _SUCCESS_TO_GET_CARS_DATA_NOTIFICATION), object: nil)
    }
    
    func setCarsData(_ arrCars: NSArray) {
        for value in arrCars {
            if let dicObject = value as? NSDictionary {
                m_arrCars.add(dicObject)
                setCarsName(dicObject)
            }
            else { print("setCarsData : Unable to read value.") }
        }
    }
    
    func getSortedCarsData(_ arrUnsorted: NSMutableArray) ->NSMutableArray {
        let sortedResults = arrUnsorted.sorted {(obj1, obj2) -> Bool in
            let dic1 = obj1 as! NSDictionary
            let dic2 = obj2 as! NSDictionary
            
            if(0 == dic1.count || 0 == dic2.count) {
                return false
            }
            
            if(nil == dic1.value(forKey: "Title") || nil == dic2.value(forKey: "Title")) {
                return false
            }
            
            let name1 = dic1.value(forKey: "Title") as! String
            let name2 = dic2.value(forKey: "Title") as! String
            
            if(name1.isEmpty || name2.isEmpty) {
                return false
            }
            
            return name1 < name2
        }
        
        if(sortedResults.count == 0) {
            return arrUnsorted
        }
        
        if(sortedResults.count > arrUnsorted.count) {
            return arrUnsorted
        }
        
        let arrSorted = NSMutableArray()
        arrSorted.addObjects(from: sortedResults)
        return arrSorted
    }
    
    func setSortedCarsData(_ arrSortedCars: NSMutableArray) {
        m_arrCars = arrSortedCars
    }
    
    func getCarsData() -> NSMutableArray {
        return m_arrCars
    }
    
    func setSearchedCarsData(_ dicSearchedCar: NSMutableDictionary) {
        m_dicSearchedCar = dicSearchedCar
    }
    
    func getSearchedCarsData() -> NSMutableDictionary {
        return m_dicSearchedCar
    }
    
    func setCarsName(_ dic: NSDictionary) {
        if let title = dic.value(forKey: "Title") as? String {
            let carYear = title.prefix(5)
            let carName = title.replacingOccurrences(of: carYear, with: "")
            m_arrCarsName.add(carName)
        }
        else { print("setCarsName : Unable to read Title.") }
    }
    
    func getCarsName() -> [String] {
        let carsNames : [String] = m_arrCarsName as! [String]
        return carsNames
    }
    
    func setSelectedCarObject(_ dicSelectedCar: NSDictionary) {
        m_dicSelectedCar = dicSelectedCar
    }
    
    func getSelectedCarObject() -> NSDictionary {
        return m_dicSelectedCar
    }
    
    func getCarDetailFromName(_ name: String) -> NSDictionary {
        for value in getCarsData() {
            if let dic = value as? NSDictionary {
                if let title = dic.value(forKey: "Title") as? String {
                    let carYear = title.prefix(5)
                    let carName = title.replacingOccurrences(of: carYear, with: "")
                    if(name == carName) {
                        return dic
                    }
                }
                else { print("getCarDetailFromName : Unable to read value.") }
            }
            else { print("getCarDetailFromName : Unable to read value.") }
        }
        
        return m_dicSelectedCar
    }
    
    func parseCarDetail(_ dic: NSDictionary) {
        if (0 == dic.count)  {
            print("parseCarDetail : Unable to read dic.")
            NotificationCenter.default.post(name: Notification.Name(rawValue: _FAILED_TO_GET_CAR_DETAIL_NOTIFICATION), object: nil)
            return
        }
        
        m_dicSelectedCar = dic
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: _SUCCESS_TO_GET_CAR_DETAIL_NOTIFICATION), object: nil)
    }
    
    func getCarDetail() -> NSDictionary {
        return m_dicSearchedCar 
    }
}
