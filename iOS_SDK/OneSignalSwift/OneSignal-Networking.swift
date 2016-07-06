//
//  OneSignal-Networking.swift
//  OneSignalSwift
//
//  Created by Joseph Kalash on 6/22/16.
//  Copyright © 2016 OneSignal. All rights reserved.
//

import Foundation

extension OneSignal {
    
    public static func postNotification(jsonData : NSDictionary) {
        self.postNotification(jsonData, onSuccess: nil, onFailure: nil)
    }
    
    public static func postNotification(jsonData : NSDictionary, onSuccess successBlock : OneSignalResultSuccessBlock?, onFailure failureBlock : OneSignalFailureBlock?) {
        let request = self.httpClient.requestWithMethod("POST", path: "notifications")
        
        let dataDic = NSMutableDictionary(dictionary: jsonData)
        
        dataDic["app_id"] = self.app_id
        
        var postData : NSData? = nil
        do {
            postData = try NSJSONSerialization.dataWithJSONObject(dataDic, options: NSJSONWritingOptions(rawValue: UInt(0)))
        }
        catch _ { }
        
        request.HTTPBody = postData
        
        self.enqueueRequest(request, onSuccess: { (results) in
            var jsonData : NSData? = nil
            do { jsonData = try NSJSONSerialization.dataWithJSONObject(results, options: NSJSONWritingOptions(rawValue: UInt(0))) }
            catch _ {}
            
            let resultsString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding)
            
            OneSignal.onesignal_Log(.DBG, message: "HTTP Create Notification Success \(resultsString!)")
            
            if successBlock != nil {successBlock!(results)}
            
            }) { (error) in
                OneSignal.onesignal_Log(.ERROR, message: "Create Notification Failed")
                OneSignal.onesignal_Log(.INFO, message: "\(error)")
                if failureBlock != nil { failureBlock!(error) }
        }
    }
    
    static func postNotificationWithJsonString(jsonString : NSString, onSuccess successBlock : OneSignalResultSuccessBlock?, onFailure failureBlock : OneSignalFailureBlock?) {
        
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        var jsonData : NSDictionary? = nil
        do { jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: UInt(0))) as? NSDictionary }
        catch let error as NSError {
            OneSignal.onesignal_Log(.WARN, message: "postNotification JSON Parse Error: \(error)")
            OneSignal.onesignal_Log(.WARN, message: "postNotification JSON Parse Error, JSON: \(jsonString)")
            return
        }
        
        self.postNotification(jsonData!, onSuccess: successBlock, onFailure: failureBlock)
    }
    
    static func enqueueRequest(request : NSURLRequest, onSuccess successBlock : OneSignalResultSuccessBlock?, onFailure failureBlock : OneSignalFailureBlock?) {
        self.enqueueRequest(request, onSuccess: successBlock, onFailure: failureBlock, isSynchronous: false)
    }
    
    static func enqueueRequest(request : NSURLRequest, onSuccess successBlock : OneSignalResultSuccessBlock?, onFailure failureBlock : OneSignalFailureBlock?, isSynchronous : Bool) {
        
            var response : NSURLResponse?
            var err : NSError?
            do {
                if isSynchronous { try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) }
                else {
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { (response, data, error) in
                        self.handleJSONNSURLResponse(response, data: data, error: error, onSuccess: successBlock, onFailure: failureBlock)
                    })
                }
            }
            catch let error as NSError {
                err = error
            }
        
        if isSynchronous { handleJSONNSURLResponse(response, data: nil, error: err, onSuccess: successBlock, onFailure: failureBlock) }
        
    }
    
    static func handleJSONNSURLResponse(response : NSURLResponse?, data : NSData?, error : NSError?, onSuccess successBlock : OneSignalResultSuccessBlock?, onFailure failureBlock : OneSignalFailureBlock?) {
        
        let httpResponse = response as? NSHTTPURLResponse
        let statusCode = httpResponse?.statusCode
        var innerJson : NSMutableDictionary? = nil
        
        if data != nil && data?.length > 0 {
            do { innerJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: UInt(0))) as? NSMutableDictionary }
            catch let jsonError as NSError {
                if failureBlock != nil {
                    failureBlock!(NSError(domain: "OneSignalError", code: statusCode!, userInfo: ["returned" : jsonError]))
                }
                return
            }
            
            if 200 == statusCode && error == nil {
                if successBlock != nil {
                    if innerJson != nil { successBlock!(innerJson!) }
                    else { successBlock!([:]) }
                }
            }
            else if failureBlock != nil {
                if innerJson != nil && error == nil {
                    failureBlock!(NSError(domain: "OneSignalError", code: statusCode!, userInfo: ["returned" : innerJson!]))
                }
                else if error != nil {
                    failureBlock!(NSError(domain: "OneSignalError", code: statusCode!, userInfo: ["error" : error!]))
                }
                else {
                    failureBlock!(NSError(domain: "OneSignalError", code: statusCode!, userInfo: nil))
                }
            }
            
        }
    }
    
}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    