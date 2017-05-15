//
//  ResultViewController.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/13.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController,OznerPairDelegate,UITextFieldDelegate {
    var currDeviceType:OZDeviceClass!
    var deviceArr:[String : (type: String, instance: Int)]!
    
    @IBOutlet var ssidText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var starORCancelButton: UIButton!
    @IBAction func StarORCancel(_ sender: UIButton) {
        if sender.titleLabel?.text=="StarPair" {
            starORCancelButton.setTitle("CancelPair", for: .normal)
            OznerManager.instance.starPair(deviceClass: currDeviceType, pairDelegate: self, ssid: ssidText.text!, password: passwordText.text!)
        }else{
            
            starORCancelButton.setTitle("StarPair", for: .normal)
            OznerManager.instance.canclePair()
        }
    }
    @IBAction func completeClick(_ sender: Any) {
        for (iden,value) in deviceArr {
            let device=OznerManager.instance.createDevice(identifier: iden, type: value.type, setting: nil)
            device.settings.name=nameText.text!
            OznerManager.instance.saveDevice(device: device)
            OznerManager.instance.currentDevice=device
            break
        }
        _=self.navigationController?.popToRootViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=false
        deviceArr=[String : (type: String, instance: Int)]()        
        OznerManager.instance.fetchCurrentSSID { (ssid) in
            self.ssidText.text=ssid
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func OznerPairSucceed(devices: [String : (type: String, instance: Int)]) {
        textView.text="找到设备\(devices)"
        deviceArr=devices
    }
    func OznerPairFailured(error: Error) {
        textView.text=error.localizedDescription
        starORCancelButton.setTitle("starPair", for: .normal)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
