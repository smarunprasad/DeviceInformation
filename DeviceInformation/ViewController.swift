//
//  ViewController.swift
//  DeviceInformation
//
//  Created by Arunprasat Selvaraj on 24/06/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import UIKit
import DeviceKit
import CryptKit

class ViewController: UIViewController {

    
    let timestamp = "timestamp"
    let customer = "customer"
    let customerId = "customerId"
    let email = "email"
    let name = "name"
    let deviceBody = "device"
    let deviceId = "deviceId"
    let custom = "custom"
    let deviceInfo = "deviceInfo"
    
    let device = DeviceInfo()
    var cryptManager: CryptManager!
    var deviceData = Data()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModel()
        // Do any additional setup after loading the view.
    }
    
    func setupModel() {
        
        do {
            cryptManager = try CryptManager.init(key: "FiugQTgPNwCWUY,VhfmM4cKXTLVFvHFe")
        }
        catch {
        }
    }
    
    //MARK: Encryption Methode call
    func encryptData(data: Data) -> Data {
        
        var cryptData = Data()
        cryptManager.getEncryptedData(data: data, completionBlock: { (data) in
           
            if let encrptedData = data {
                cryptData = encrptedData
            }
        }) { (error) in
            
        }
        return cryptData
    }
    
    //MARK: Decryption Methode call
    func decryptData(data: Data) -> Data {
        
        var cryptData = Data()
        cryptManager.getDecryptedData(encrptedData: data, completionBlock: { (data) in
            if let decrptedData = data {
                cryptData = decrptedData
            }
        }) { (error) in
            
        }
        return cryptData
    }
}

//MARK:- Encryption Device Info
extension ViewController {
    
    func getEncryptedDeviceInfo() -> Data {
        
        var param = [String: Any]()
        device.getDeviceInfo { (device) in
            
            param["name"] = device.name
            param["model"] = device.model
            param["systemName"] = device.systemName
            param["systemVersion"] = device.systemVersion
        }
        guard let data = generateDataFrom(parameters: param) else { return Data() }
        return data
    }
}

//MARK:- API Call & Formating URLRequest
extension ViewController {
    
    //MARK: HTTP Body
    func generateHTTPBody(deviceData: Data) -> Data{
        
        //Variables
        var customBodyObject = [String: Any]()
        var customerObject = [String: Any]()
        var deviceObject = [String: Any]()
        var customObject = [String: Any]()
        
        //Custom Object
        customerObject[customerId] = "smarun16@gmail.com"
        customerObject[email] = "smarun16@gmail.com"
        customerObject[name] = "Arun"
        
        //Custom Object
        customObject[deviceInfo] = deviceData
        
        //Device object
        deviceObject[deviceId] = "65fc5ac0-2ba3-4a3b-aa5e-f5a77b845260"
        deviceObject[custom] = customObject
        
        //customBody Object
        customBodyObject[timestamp] = 1512828988826
        customBodyObject[customer] = customerObject
        customBodyObject[deviceBody] = deviceObject
        
        guard let data = generateDataFrom(parameters: customBodyObject) else { return Data() }
        return data
    }
    
    //MARK: HTTP Header
    func generateHTTPHeader() -> [String: String] {
        
        return ["Authorization":"token secret_key_live_1Od41KPkFXqn9gR4KB8s5l3hvOaGAYqs",
                "Content-Type":"application/json"]
    }
    
    func callCustomerAPI() {
        
        if !(APIManager.isConnectedToNetwork()) {
            
            return
        }
        var urlRequest = URLRequest.init(url: URL.init(string: "https://api-staging.ravelin.com/v2/customer")!)
        urlRequest.httpBody = generateHTTPBody(deviceData: encryptData(data: getEncryptedDeviceInfo()))
        urlRequest.httpMethod = "post"
        urlRequest.allHTTPHeaderFields = generateHTTPHeader()
        
        APIManager.dataRequest(request: urlRequest, completionHandler: { (data) in
            
            
        }) { (error) in
            
        }
    }
}

//MARK:- Helper
extension ViewController {
    
    func generateDataFrom(parameters: [String: Any]) -> Data? {
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            return postData
        }
        catch {
            fatalError("HTTP body json serialization problem")
        }
    }
}


