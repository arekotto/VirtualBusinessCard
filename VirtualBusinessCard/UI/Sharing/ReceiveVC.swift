//
//  ReceiveVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 06/04/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//
/*
import UIKit
import CoreBluetooth
import CoreLocation
import Firebase

class ReceiveVC: UIViewController {

    let SERVICE_UUID: CBUUID = CBUUID(string: "b30358c2-7720-11ea-bc55-0242ac130003")
    let RX_UUID: CBUUID = CBUUID(string: "b79d5496-7720-11ea-bc55-0242ac130003")
    let RX_PROPERTIES: CBCharacteristicProperties = .read
    let RX_PERMISSIONS: CBAttributePermissions = .readable
    
    let label = UILabel()
    let button = UIButton(type: .system)
    
    var iBeaconPeripheralManager: CBPeripheralManager!
    var bluetoothPeripheralManager: CBPeripheralManager!

    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem.image = UIImage(systemName: "square.and.pencil")!
        title = "Receive"
        view.backgroundColor = UIColor.systemBackground

        iBeaconPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)

        view.addSubview(label)
        label.text = "No msg"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(button)
        button.setTitle("scan", for: .normal)
        button.addTarget(self, action: #selector(startScan), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
    }
    
    @objc func startScan() {
        
        print("start tapped")
        advertiseBeacon()
    }
    
    func advertiseBeacon() {
        let proximityUUID = UUID(uuidString: "39ED98FF-2900-441A-802F-9C398FC199D2")!
        let major: CLBeaconMajorValue = UInt16.random(in: UInt16.min..<UInt16.max)
        let minor: CLBeaconMinorValue = UInt16.random(in: UInt16.min..<UInt16.max)
        let beaconID = "com.example.myBeaconRegion"

        let region = CLBeaconRegion(beaconIdentityConstraint: CLBeaconIdentityConstraint(uuid: proximityUUID, major: major, minor: minor), identifier: beaconID)

        let peripheralData = region.peripheralData(withMeasuredPower: nil)

        peripheralData[CBAdvertisementDataLocalNameKey] = Auth.auth().currentUser!.email

        
        
        let serialService = CBMutableService(type: SERVICE_UUID, primary: true)
        let writeCharacteristics = CBMutableCharacteristic(type: RX_UUID, properties: RX_PROPERTIES, value: "testinggg".data(using: .utf8)!, permissions: RX_PERMISSIONS)
        serialService.characteristics = [writeCharacteristics]
        bluetoothPeripheralManager.add(serialService)

        let advertisementData = "\(major)-\(minor)"
        bluetoothPeripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[SERVICE_UUID], CBAdvertisementDataLocalNameKey: advertisementData])


        debugPrint("Sending broadcast messages.")
        
//                iBeaconPeripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
//        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
//            self.iBeaconPeripheralManager.stopAdvertising()
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                self.iBeaconPeripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
//            }
//        })
    }
}



extension ReceiveVC: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("peripheral on ")
        default:
            print("peripheral other")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("connected to char")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("disconnected from char")
    }
}
*/
