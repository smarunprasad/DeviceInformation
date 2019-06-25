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

    let device = EncryptedDeviceInfo()
    var encryptAPIManager: EncryptedAPIManager!
    var deviceData = Data()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUpModel()
    }

    
    func setUpModel() {
        
       encryptTheDeviceData()
    }

    func getDeviceInfo() {
        
        device.getDeviceInfo { (device) in
            
            var param = [String: Any]()
            param["name"] = device.name
            param["model"] = device.model
            param["systemName"] = device.systemName
            param["systemVersion"] = device.systemVersion

            if let data = self.deviceInfoDictGenerator(parameters: param) {
                self.deviceData = data
            }
        }
    }
    
    
    func encryptTheDeviceData() {
        
        getDeviceInfo()
        
        do {

            encryptAPIManager = try EncryptedAPIManager.init(key: "FiugQTgPNwCWUY,VhfmM4cKXTLVFvHFe")
            
            encryptAPIManager.getEncryptedData(data: self.deviceData, completionBlock: { (encryptedData) in
                
                var request = URLRequest.init(url: URL.init(string: "https://api.github.com/gists/ac57abaea4faba3e3cb6bf45e733c670")!)
                request.httpMethod = "get"

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

