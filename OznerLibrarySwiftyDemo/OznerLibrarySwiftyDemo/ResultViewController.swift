//
//  ResultViewController.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/13.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit
import OznerLib

class ResultViewController: UIViewController,OznerPairDelegate,UITextFieldDelegate {
    var currDeviceType:OZDeviceClass!
    var scanDeviceInfo:OznerDeviceInfo!
    
    @IBOutlet var ssidText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var nameText: UITextField!
    @IBOutlet var starORCancelButton: UIButton!
    var starDate:Date!
    
    @IBAction func StarORCancel(_ sender: UIButton) {
        if sender.titleLabel?.text=="StarPair" {
            starDate=Date()
            textView.text="开始配网(<60s):\(Date())"
            starORCancelButton.setTitle("CancelPair", for: .normal)
            OznerManager.instance.starPair(deviceClass: currDeviceType, pairDelegate: self, ssid: ssidText.text!, password: passwordText.text!)
        }else{
            starORCancelButton.setTitle("StarPair", for: .normal)
            OznerManager.instance.canclePair()
        }
    }
    @IBAction func completeClick(_ sender: Any) {
        if scanDeviceInfo.deviceID == "" {
            return
        }
        let device=OznerManager.instance.createDevice(scanDeviceInfo: scanDeviceInfo, setting: nil)
        device.settings.name=nameText.text!
        OznerManager.instance.saveDevice(device: device)
        OznerManager.instance.currentDevice=device
        _=self.navigationController?.popToRootViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=false
        scanDeviceInfo=OznerDeviceInfo()
        OznerManager.instance.fetchCurrentSSID { (ssid) in
            self.ssidText.text=ssid
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        OznerManager.instance.canclePair()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func OznerPairSucceed(deviceInfo: OznerDeviceInfo) {
        textView.text.append("\n发现设备:\n"+deviceInfo.des())
        textView.text.append("\n结束时间:\(Date())")
        textView.text.append("\n配网用时:\(0-starDate.timeIntervalSinceNow)s")
        scanDeviceInfo=deviceInfo
    }
    func OznerPairFailured(error: Error) {
        textView.text.append("\n配网失败:"+error.localizedDescription)
        starORCancelButton.setTitle("starPair", for: .normal)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
