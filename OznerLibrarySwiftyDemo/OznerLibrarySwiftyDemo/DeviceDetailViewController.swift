//
//  DeviceDetailViewController.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/12.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class DeviceDetailViewController: UIViewController,OznerBaseDeviceDelegate,UITextFieldDelegate {

    @IBOutlet weak var powerBtn: UIButton!
    
    @IBOutlet weak var coldBtn: UIButton!
    @IBOutlet weak var hotBtn: UIButton!
    @IBOutlet var textView: UITextView!
    @IBAction func powerClick(_ sender: Any) {
        switch true {

        case currDevice.isKind(of: WaterPurifier_Wifi.classForCoder()):
            break
            
            
        default:
            break
        }
    }
    @IBAction func ValueChange(_ sender: UISlider) {

    }
    var speedInt = 0
    
    @IBAction func speedClick(_ sender: Any) {
        speedInt=(speedInt+1)%3
        switch true {
        case currDevice.isKind(of: WaterPurifier_Wifi.classForCoder()):

            break

        default:
            break
        }
    }
    @IBAction func lockClick(_ sender: Any) {
        switch true {
        case currDevice.isKind(of: WaterPurifier_Wifi.classForCoder()):
            break

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

    @IBAction func otaAction(_ sender: UIButton) {
        
    }
    
    
    @IBAction func LASTAction(_ sender: Any) {
        
        

        
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
