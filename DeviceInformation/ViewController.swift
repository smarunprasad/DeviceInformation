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
    
    //Model
    let device = DeviceInfo()
    var cryptManager: CryptManager!
    var deviceData = Data()
    var logString = ""
    
    //Outlets
    @IBOutlet weak var deviceInfoImageView: UIImageView!
    
    @IBOutlet weak var encryptionImageView: UIImageView!
    
    @IBOutlet weak var apiImageView: UIImageView!
    @IBOutlet weak var logTextView: UITextView!
    
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
    
    //MARK: UIButton Action
    @IBAction func startButtonTapped(_ sender: Any) {
        
        //1
        //Get device information
        ///////////////
        let dictionary = getDeviceInfo()
        self.loadLogInTextView(value: dictionary)
        
        //2
        //Converting to data type
        //////////////
        guard let data = generateDataFrom(parameters: dictionary) else { return  }
        self.logString += "\nDevice info data\n"
        self.loadLogInTextView(value: data)
        self.deviceInfoImageView.isHighlighted = true
        
        //3
        //Encryption
        //////////////
        deviceData = encryptData(data: data)
        self.logString += "\nEncrypted device info data\n"
        self.loadLogInTextView(value: self.deviceData)
        self.encryptionImageView.isHighlighted = true
        
        //4
        //Sending the device data and static values to the API
        //////////////
        callCustomerAPI()
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        
        UIView.transition(with: self.view, duration: 0.1, options: .transitionCrossDissolve, animations: {
            
            self.logString = ""
            self.logTextView.text = ""
            self.deviceData = Data()
            
            self.deviceInfoImageView.isHighlighted = false
            self.encryptionImageView.isHighlighted = false
            self.apiImageView.isHighlighted = false
        }, completion: nil)
    }
}

//MARK:- Device Info Method
extension ViewController {
    
    func getDeviceInfo() -> [String: Any] {
        
        var param = [String: Any]()
        device.getDeviceInfo { (device) in
            
            param["name"] = device.name
            param["model"] = device.model
            param["systemName"] = device.systemName
            param["systemVersion"] = device.systemVersion
        }
        return param
    }
}

//MARK:- API Call & Formating URLRequest
extension ViewController {
    
    //MARK: HTTP Body
    func generateHTTPBody() -> Data{
        
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
        customObject[deviceInfo] = deviceData.base64EncodedString()
        
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
        urlRequest.httpBody = generateHTTPBody()
        urlRequest.httpMethod = "post"
        urlRequest.allHTTPHeaderFields = generateHTTPHeader()
        
        APIManager.dataRequest(request: urlRequest, completionHandler: { (data) in
            
            self.logString += "\n Response data\n"
            self.loadLogInTextView(value: data)
            
            self.logString += "\n Response String\n"
            self.loadLogInTextView(value: String.init(data: data, encoding: .utf8) as Any)
            
            DispatchQueue.main.async {
                self.apiImageView.isHighlighted = true
            }
            
        }) { (error) in
            
        }
    }
}

//MARK:- Helper
extension ViewController {
    
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
    
    //MARK: Support functions
    
    func loadLogInTextView(value: Any) {
        
        if value is [String: Any] {
            
            logString = "DeviceInfo\n"
            
            //To print the device info in log textview
            for (x, y) in value as! [String: Any] {
                logString += "(\(x): \(y))\n"
            }
        }
        else if value is Data {
            
            let data = value as! Data
            logString += "\(data.count)"
        }
        else {
            
            logString += value as! String
        }
        DispatchQueue.main.async {
            
            self.logTextView.text = self.logString
        }
    }
    
    
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


