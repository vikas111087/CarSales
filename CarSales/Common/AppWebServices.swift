//
//  AppWebServices.swift
//  CarSales
//
//  Created by Vikas Bawa on 23/06/22.
//  Copyright © 2022 Vikas Bawa. All rights reserved.
//

import Foundation

class AppWebServices {
    
    private let _SERVICE_TIMEOUT_INTERVAL               = 30.0
    private let m_appModel                              = AppModel.sharedInstance
    
    func sendServiceRequest(_ service: String) {
        let request     = NSMutableURLRequest(url: URL(string: service)!)
        request.httpMethod = "GET"
                
        request.timeoutInterval = _SERVICE_TIMEOUT_INTERVAL
        sendRequest(request as URLRequest, service)
    }
    
    private func sendRequest(_ request: URLRequest, _ service: String) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleErrorAndResponse(service, data, response, error)
        }
        task.resume()
    }
    
    private func handleErrorAndResponse(_ service: String, _ responseData: Data?, _ response: URLResponse?, _ error: Error?) {
        if(nil == response) {
            failedServiceRequest(service, 500)
            return
        }
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        if (0 == responseData?.count) {
            failedServiceRequest(service, statusCode)
            return
        }
        
        do {
            let dicResponse = try JSONSerialization.jsonObject(with: responseData!, options: []) as! [String:AnyObject] as AnyObject
            if(0 == dicResponse.count) {
                failedServiceRequest(service, statusCode)
                return
            }
            
            if (200 != statusCode && 204 != statusCode) {
                failedServiceRequest(service, statusCode)
                return
            }
            
            successResponse(service, dicResponse as! NSDictionary, statusCode)
            
        } catch _ as NSError {
            failedServiceRequest(service, statusCode)
            return
        }
    }
    
    private func successResponse(_ service: String, _ dicResponse: NSDictionary, _ statusCode: Int) {
        if(service.contains(m_appModel.getCarsDataURL())) {
            parseCarsDataResponse(dicResponse, statusCode)
            return
        }
        
        parseCarDetailResponse(dicResponse, statusCode)
    }
    
    private func parseCarsDataResponse(_ responseData: NSDictionary, _ statusCode: Int) {
        if (nil == responseData["Result"])  {
            failedServiceRequest(m_appModel.getBaseURL(), statusCode)
            return
        }
        
        m_appModel.parseCarsData(NSMutableDictionary.init(dictionary: responseData))
    }
    
    private func parseCarDetailResponse(_ responseData: NSDictionary, _ statusCode: Int) {
        if (nil == responseData["Id"] || nil == responseData["SaleStatus"] || nil == responseData["Title"] || nil == responseData["Overview"])  {
            failedServiceRequest(m_appModel.getBaseURL(), statusCode)
            return
        }
        
        m_appModel.parseCarDetail(responseData)
    }
    
    private func failedServiceRequest(_ service: String, _ statusCode: Int) {        
        if(m_appModel.getBaseURL() == service) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: _FAILED_TO_GET_CARS_DATA_NOTIFICATION), object: nil)
            return
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: _FAILED_TO_GET_CAR_DETAIL_NOTIFICATION), object: nil)
    }
}
