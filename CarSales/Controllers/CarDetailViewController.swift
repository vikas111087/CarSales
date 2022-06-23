//
//  CarDetailViewController.swift
//  CarSales
//
//  Created by Vikas Bawa on 23/06/22.
//  Copyright © 2022 Vikas Bawa. All rights reserved.
//


import Foundation
import UIKit

class CarDetailViewController: UIViewController {
    @IBOutlet weak var otlImages            : CarsPhotoSliderView!
    
    @IBOutlet weak var otlTitle             : UILabel!
    @IBOutlet weak var otlLocation          : UILabel!
    @IBOutlet weak var otlPrice             : UILabel!
    @IBOutlet weak var otlSaleStatus        : UILabel!
    @IBOutlet weak var otlComments          : UITextView!
    
    @IBOutlet weak var otlImagesHeight      : NSLayoutConstraint!
        
    private let m_appModel                  = AppModel.sharedInstance
    private let m_appDelegate               = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dic = m_appModel.getSelectedCarObject()
        
        if let detailsUrl = dic.value(forKey: "DetailsUrl") as? String {
            getCarDetail(m_appModel.getBaseURL() + detailsUrl)
        }
        else {
            handleError("CarDetailViewController viewDidLoad: Unable to read DetailsUrl.")
        }
        
        registerAllNotications()
    }
    
    private func getCarDetail(_ url: String) {
        m_appDelegate.operationsQueue.async {
            let appWebServices = AppWebServices()
            appWebServices.sendServiceRequest(url)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        m_appDelegate.mainThread.async {
            self.updateUI()
        }
    }
    
    private func updateUI() {
        let dic  = m_appModel.getSelectedCarObject()
        if let Id = dic.value(forKey: "Id") as? String {
            self.restorationIdentifier = Id
        }
        else { handleError("Unable to read Id.") }
        
        if let title = dic.value(forKey: "Title") as? String {
            navigationItem.title = title
            otlTitle.text = title
        }
        else { handleError("Unable to read Title.") }
        
        if let saleStatus = dic.value(forKey: "SaleStatus") as? String {
            otlSaleStatus.text = saleStatus
        }
        else { handleError("Unable to read Title.") }
        
        if let comments = dic.value(forKey: "Comments") as? String {
            otlComments.text = comments
        }
        else { handleError("Unable to read Comments.") }
        
        if let dicOverview = dic.value(forKey: "Overview") as? NSDictionary {
            if let arrPhotos = dicOverview.value(forKey: "Photos") as? NSArray  {
                let scrollViewFrameHeight = getImagesHeight()
                otlImagesHeight.constant = scrollViewFrameHeight
                
                let scrollViewFrame = CGRect(x: 0,y: 0, width: otlImages.contentView.frame.size.width, height: scrollViewFrameHeight)
                otlImages.configure(arrPhotos, scrollViewFrame)
            }
            else { handleError("Unable to read Photos.") }
            
            if let location = dicOverview.value(forKey: "Location") as? String {
                otlLocation.text = location
            }
            else { handleError("Unable to read Location.") }
            
            if let price = dicOverview.value(forKey: "Price") as? String {
                otlPrice.text = price
            }
            else { handleError("Unable to read Price.") }
        }
        else { handleError("Unable to read Overview.") }
    }
    
    private func handleError(_ error: String) {
        print("HandleError : " + error)
        m_appDelegate.showAlertMessage(self, error)
    }
    
    private func getImagesHeight() -> CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                if UIDevice.current.orientation.isLandscape || 1366 <= self.view.frame.size.width {
                    return 750 //explicit set this one for because, its cove the whole screen, it can be fix but need more time and another approach.
                }
            case .unspecified: break
            case .phone: break
            case .tv: break
            case .carPlay: break
            case .mac: break
            @unknown default: break
        }
        
        return m_appDelegate.getRatioHeight(self.view.frame.size.width)
    }
    
    private func registerAllNotications() {
        NotificationCenter.default.addObserver(self,selector: #selector(listenNofications),name: NSNotification.Name(rawValue: _SUCCESS_TO_GET_CAR_DETAIL_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(listenNofications),name: NSNotification.Name(rawValue: _FAILED_TO_GET_CAR_DETAIL_NOTIFICATION), object: nil)
    }
    
    @objc private func listenNofications(_ notification:Notification) {
        let notificationName = notification.name.rawValue
        
        if(_SUCCESS_TO_GET_CAR_DETAIL_NOTIFICATION == notificationName) {
            m_appDelegate.mainThread.async {
                self.updateUI()
            }
            
            return
        }
        
        if(_FAILED_TO_GET_CAR_DETAIL_NOTIFICATION == notificationName) {
            m_appDelegate.showAlertMessage(self, "Something is wrong.")
            return
        }
    }
}


/*// MARK: UIScrollViewDelegate
extension CarDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        pageControl.currentPage = Int(currentPage)
    }
}*/
