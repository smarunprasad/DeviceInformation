//
//  ViewController.swift
//  DeviceInformation
//
//  Created by Arunprasat Selvaraj on 24/06/2019.
//  Copyright © 2019 Arunprasat Selvaraj. All rights reserved.
//

import UIKit
import EncryptedDeviceKit
import EncryptedAPIManager

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
    
    let device = EncryptedDeviceInfo()
    var encryptAPIManager: EncryptedAPIManager!
    var deviceData = Data()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpModel()
    }

    
    func setUpModel() {
        
       callAPIWithEncryptDeviceData()
    }

    private func callAPIWithEncryptDeviceData() {
        
        do {
            encryptAPIManager = try EncryptedAPIManager.init(key: "FiugQTgPNwCWUY,VhfmM4cKXTLVFvHFe")
            encryptAPIManager.getEncryptedData(data: generateHTTPBody(), completionBlock: { (encryptedData) in
                
                var request = URLRequest.init(url: URL.init(string: "https://api-staging.ravelin.com/v2/customer")!)
                request.httpMethod = "post"
                request.allHTTPHeaderFields = generateHTTPHeader()
                request.httpBody = encryptedData

                encryptAPIManager.encryptedAPIRequest(request: request, completionHandler: { (handler) in

                    if handler.error == nil {

                        if let data = handler.data {

                            self.encryptAPIManager.getDecryptedData(encrptedData: data, completionBlock: { (decrptedData) in

                                do {
                                    let object = try JSONSerialization.jsonObject(with: decrptedData, options: [.allowFragments])
                                    print(object)
                                }
                                catch {

                                }

                            }, errorBlock: { (error) in

                            })
                        }
                    }
                    else {
                        print(handler.error)
                    }
                })
            }) { (error) in
                
            }
        }
        catch {
            print(error)
        }
    }

    private func generateHTTPBody() -> Data{
        
        /*{
         "timestamp": 1512828988826,
         "customer": {
         "customerId": "smarun16@gmail.com",
         "email": "smarun16@gmail.com",
         "name": "Arun"
         },
         "device": {
         "deviceId": "65fc5ac0-2ba3-4a3b-aa5e-f5a77b845260",
         "custom": {
         "deviceInfo": {}
         }
         }*/
        
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
        customObject[deviceInfo] = getDeviceInfo()

        //Device object
        deviceObject[deviceId] = "65fc5ac0-2ba3-4a3b-aa5e-f5a77b845260"
        deviceObject[custom] = customObject
        
        //customBody Object
        customBodyObject[timestamp] = 1512828988826
        customBodyObject[customer] = customerObject
        customBodyObject[deviceBody] = deviceObject
        
        
        guard let data = self.deviceInfoDictGenerator(parameters: customBodyObject) else {
            return Data()
        }
        return data
    }
    private func generateHTTPHeader() -> [String: String] {
    
        return ["Authorization":"token secret_key_live_1Od41KPkFXqn9gR4KB8s5l3hvOaGAYqs",
                "Content-Type":"application/json"]
    }
    private func getDeviceInfo() -> [String: Any] {
        
        var param = [String: Any]()
        device.getDeviceInfo { (device) in
            
            param["name"] = device.name
            param["model"] = device.model
            param["systemName"] = device.systemName
            param["systemVersion"] = device.systemVersion
        }
        return param
    }
    
    private func deviceInfoDictGenerator(parameters: [String: Any]) -> Data? {
        
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            return postData
        }
        catch {
            fatalError("HTTP body json serialization problem")
        }
    }
}

