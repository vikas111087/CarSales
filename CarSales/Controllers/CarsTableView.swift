//
//  CarsTableView.swift
//  CarSales
//
//  Created by Vikas Bawa on 23/06/22.
//  Copyright © 2022 Vikas Bawa. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var otlTitle             : UILabel!
    @IBOutlet weak var otlPrice             : UILabel!
    @IBOutlet weak var otlLocation          : UILabel!
    @IBOutlet weak var otlThumbnail         : UIImageView!
    
    @IBOutlet weak var otlThumbnailHeight   : NSLayoutConstraint!
}

class CarsTableView: UIViewController {
    @IBOutlet var otlSearchBar              : UISearchBar!
    @IBOutlet var otlTableView              : UITableView!
    @IBOutlet var otlButton                 : UIButton!
        
    private let m_appModel                  = AppModel.sharedInstance
    private let m_appDelegate               = UIApplication.shared.delegate as! AppDelegate
    
    private var m_searchedCar               = [String]()
    private var m_isSearching               = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCarsData(m_appModel.getBaseURL() + m_appModel.getCarsDataURL())
        registerAllNotications()
        
        otlTableView.delegate = self
        otlTableView.dataSource = self
        
        otlTableView.rowHeight = m_appDelegate.getRatioHeight(self.view.frame.size.width) + 80
        
        otlSearchBar.delegate = self
        otlSearchBar.showsCancelButton = true
        
        otlButton.addTarget(self, action: #selector(sortByName), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        reloadDataAdjustTableRowHightLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        reloadDataAdjustTableRowHightLoad()
    }
    
    private func reloadDataAdjustTableRowHightLoad() {
        m_appDelegate.mainThread.async {
            self.otlTableView.rowHeight = self.m_appDelegate.getRatioHeight(self.view.frame.size.width) + 80
            self.otlTableView.reloadData()
        }
    }
    
    private func getCarsData(_ url: String) {
        m_appDelegate.operationsQueue.async {
            let appWebServices = AppWebServices()
            appWebServices.sendServiceRequest(url)
        }
    }
    
    @objc func sortByName(sender: UIButton!) {
        let arrSortedCarsData = m_appModel.getSortedCarsData(m_appModel.getCarsData())
        m_appModel.setSortedCarsData(arrSortedCarsData)
        
        m_appDelegate.mainThread.async {
            self.otlTableView.reloadData()
        }
    }
    
    private func registerAllNotications() {
        NotificationCenter.default.addObserver(self,selector: #selector(listenNofications),name: NSNotification.Name(rawValue: _SUCCESS_TO_GET_CARS_DATA_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(listenNofications),name: NSNotification.Name(rawValue: _FAILED_TO_GET_CARS_DATA_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(listenNofications),name: NSNotification.Name(rawValue: _FINISHED_TO_GET_CARS_DATA_NOTIFICATION), object: nil)
    }
    
    @objc private func listenNofications(_ notification:Notification) {
        let notificationName = notification.name.rawValue
        
        if(_SUCCESS_TO_GET_CARS_DATA_NOTIFICATION == notificationName) {
            m_appDelegate.mainThread.async {
                self.otlTableView.reloadData()
            }
            
            return
        }
        
        if(_FAILED_TO_GET_CARS_DATA_NOTIFICATION == notificationName) {
            m_appDelegate.showAlertMessage(self, "Something is wrong.")
            return
        }
        
        if(_FINISHED_TO_GET_CARS_DATA_NOTIFICATION == notificationName) {
            m_appDelegate.mainThread.async {
                self.otlTableView.reloadData()
            }
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CarDetailViewControllerSegue" {
            _ = segue.destination as! CarDetailViewController
        }
    }
}

extension CarsTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(m_isSearching) {
            return m_searchedCar.count
        } else {
            return m_appModel.getCarsData().count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell") as! CustomTableViewCell
        
        var dic             = NSDictionary()
        if(m_isSearching) {
            let title = m_searchedCar[indexPath.row]
            dic = m_appModel.getCarDetailFromName(title)
            
        } else {
            dic = m_appModel.getCarsData()[indexPath.row] as! NSDictionary
        }
        
        if let Id = dic.value(forKey: "Id") as? String {
            customTableViewCell.restorationIdentifier = Id
        }
        else { print("tableView cellForRowAt: Unable to read Id.") }
        
        if let title = dic.value(forKey: "Title") as? String {
            customTableViewCell.otlTitle?.text = title
        }
        else { print("tableView cellForRowAt: Unable to read Title.") }
        
        if let price = dic.value(forKey: "Price") as? String {
            customTableViewCell.otlPrice?.text = price
        }
        else { print("tableView cellForRowAt: Unable to read Price.") }
        
        if let location = dic.value(forKey: "Location") as? String {
            customTableViewCell.otlLocation?.text = location
        }
        else { print("tableView cellForRowAt: Unable to read Location.") }
        
        if let mainPhoto = dic.value(forKey: "MainPhoto") as? String {
            customTableViewCell.otlThumbnail?.setImageFromUrl(ImageURL: mainPhoto)
            customTableViewCell.otlThumbnailHeight.constant = m_appDelegate.getRatioHeight(self.view.frame.size.width)
        }
        else { print("tableView cellForRowAt: Unable to read MainPhoto.") }
        
        return customTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dic  = NSDictionary()
        
        if(m_isSearching) {
            let name = m_searchedCar[indexPath.row]
            dic = m_appModel.getCarDetailFromName(name)
        } else {
            dic = m_appModel.getCarsData()[indexPath.row] as! NSDictionary
        }
        
        m_appModel.setSelectedCarObject(dic)
        
        performSegue(withIdentifier: "CarDetailViewControllerSegue", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        otlSearchBar.searchTextField.endEditing(true)
    }
    
    /*private func setTableViewRowHeight() {
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
            if UIDevice.current.orientation.isLandscape || 1366 <= self.view.frame.size.width {
                    otlTableView.rowHeight = 910 + 80 //getRatioHeight(self.view.frame.size.width) + 50
                    return
                }
                
                otlTableView.rowHeight = 682 + 80
                return
            
            case .unspecified: break
            case .phone: break
            case .tv: break
            case .carPlay: break
            case .mac: break
            @unknown default: break
        }
        
        otlTableView.rowHeight = 370
    }
    
    private func getThumbnailHeight() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                if UIDevice.current.orientation.isLandscape || 1366 <= self.view.frame.size.width {
                    return 910
                }
            
                return 682
            
            case .unspecified: break
            case .phone: break
            case .tv: break
            case .carPlay: break
            case .mac: break
            @unknown default: break
        }
        
        return 283
    }*/
}

extension CarsTableView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {        
        m_searchedCar = m_appModel.getCarsName().filter { $0.lowercased().prefix(searchText.count) == searchText.lowercased() }
        m_isSearching = true
        otlTableView.reloadData()
        
        if(searchText.isEmpty) {
            resetSearch()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearch()
    }
    
    func resetSearch() {
        m_isSearching = false
        otlSearchBar.text = ""
        otlTableView.reloadData()
    }
}
