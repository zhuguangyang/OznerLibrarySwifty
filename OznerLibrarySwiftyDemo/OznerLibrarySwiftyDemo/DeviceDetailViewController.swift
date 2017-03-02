//
//  DeviceDetailViewController.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/12.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class DeviceDetailViewController: UIViewController,OznerBaseDeviceDelegate {

    
    @IBOutlet var textView: UITextView!
    @IBAction func powerClick(_ sender: Any) {
        switch true {
        case currDevice.isKind(of: AirPurifier_Bluetooth.classForCoder()):
            let tmpdevice = currDevice as! AirPurifier_Bluetooth
            tmpdevice.setPower(power: !(tmpdevice.sensor.Power), callBack: { (error) in
                
            })
        case currDevice.isKind(of: WaterPurifier_Wifi.classForCoder()):
            let deviceTmp = currDevice as! WaterPurifier_Wifi
            deviceTmp.setPower(Power: !deviceTmp.status.Power, callBack: { (_) in
                
            })
            break
        case currDevice.isKind(of: AirPurifier_Wifi.classForCoder()):
            let deviceTmp = currDevice as! AirPurifier_Wifi
            print("单机了")
            deviceTmp.setPower(power: !deviceTmp.status.Power, callBack: { (error) in
                print(error ?? "")
            })
        default:
            break
        }
    }
    @IBAction func ValueChange(_ sender: UISlider) {
        if currDevice.isKind(of: AirPurifier_Bluetooth.classForCoder()) {
            (currDevice as! AirPurifier_Bluetooth).setSpeed(speed: Int(sender.value), callBack: { (error) in
            })
        }
    }
    var speedInt = 0
    
    @IBAction func speedClick(_ sender: Any) {
        speedInt=(speedInt+1)%3
        switch true {
        case currDevice.isKind(of: WaterPurifier_Wifi.classForCoder()):
            let deviceTmp = currDevice as! WaterPurifier_Wifi
            deviceTmp.setHot(Hot: !deviceTmp.status.Hot, callBack: { (_) in
                
            })
            break
        case currDevice.isKind(of: AirPurifier_Wifi.classForCoder()):
            let deviceTmp = currDevice as! AirPurifier_Wifi
            deviceTmp.setSpeed(speed: [0,4,5][speedInt], callBack: { (_) in
            })
        default:
            break
        }
    }
    @IBAction func lockClick(_ sender: Any) {
        switch true {
        case currDevice.isKind(of: WaterPurifier_Wifi.classForCoder()):
            let deviceTmp = currDevice as! WaterPurifier_Wifi
            deviceTmp.setCool(Cool: !deviceTmp.status.Cool, callBack: { (_) in
                
            })
            break
        case currDevice.isKind(of: AirPurifier_Wifi.classForCoder()):
            let deviceTmp = currDevice as! AirPurifier_Wifi
            deviceTmp.setLock(lock: !deviceTmp.status.Lock, callBack: { (_) in
                
            })
        default:
            break
        }
    }
    private var currDevice:OznerBaseDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden=false
        currDevice=OznerManager.instance.currentDevice
        currDevice.delegate=self
        textView.text=currDevice.describe()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ////OznerBaseDeviceDelegate
    func OznerDeviceSensorUpdate(identifier: String) {
        DispatchQueue.main.async {
            self.textView.text=self.currDevice.describe()
        }
        
        
    }
    func OznerDeviceStatusUpdate(identifier: String) {
        DispatchQueue.main.async {
            self.textView.text=self.currDevice.describe()
        }
    }
    func OznerDevicefilterUpdate(identifier: String) {
        DispatchQueue.main.async {
            self.textView.text=self.currDevice.describe()
        }
        
    }
    func OznerDeviceRecordUpdate(identifier: String) {
        DispatchQueue.main.async {
            self.textView.text=self.currDevice.describe()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
