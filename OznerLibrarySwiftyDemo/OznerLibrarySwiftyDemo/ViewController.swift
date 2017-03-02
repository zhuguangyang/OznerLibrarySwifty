//
//  ViewController.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2016/12/22.
//  Copyright © 2016年 net.ozner. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
   
    var deviceArray:[OznerBaseDevice]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceArray=[OznerBaseDevice]()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=true
        deviceArray = OznerManager.instance.getAllDevices()
        self.tableView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden=false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
extension ViewController:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceArray.count
    }
    //delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let device = deviceArray[indexPath.row]
            deviceArray.remove(at: indexPath.row)
            OznerManager.instance.deleteDevice(device: device)
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "DeviceListCell")!
        let device = deviceArray[indexPath.row]
        cell.textLabel?.numberOfLines=0
        cell.textLabel?.text="name:\(device.settings.name!),connectStatus:\(device.connectStatus),type:\(device.type!),isCurrentDevice:\(device.isCurrentDevice)"
        return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        OznerManager.instance.currentDevice=deviceArray[indexPath.row]
    }
}
