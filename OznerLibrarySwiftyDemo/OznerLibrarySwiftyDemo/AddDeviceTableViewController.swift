//
//  AddDeviceTableViewController.swift
//  OznerLibrarySwiftyDemo
//
//  Created by 赵兵 on 2017/1/12.
//  Copyright © 2017年 net.ozner. All rights reserved.
//

import UIKit

class AddDeviceTableViewController: UITableViewController {

    var deviceArr:[(nameStr:String,type:OZDeviceClass)]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden=false
        deviceArr=[
            ("智能水杯---蓝牙连接",.Cup),
            ("水探头---蓝牙连接",.Tap),
            ("TDS笔---蓝牙连接",.Tap),
            ("台式空净---蓝牙连接",.AirPurifier_Blue),
            ("净水器---蓝牙连接",.WaterPurifier_Blue),
            ("补水仪---蓝牙连接",.WaterReplenish),
            ("立式空净---WIFI连接",.AirPurifier_Wifi),
            ("净水器---WIFI连接",.WaterPurifier_Wifi),
        ]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deviceArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddDeviceCell", for: indexPath)
        cell.textLabel?.text=deviceArr[indexPath.row].nameStr
        
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "pushPairID", sender: indexPath.row)
    }
    
    

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pair = segue.destination as! ResultViewController
        pair.currDeviceType = deviceArr[sender as! Int].type
    }
   

}
