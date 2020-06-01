//
//  ContentView.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 14/02/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//

import SwiftUI
import Firebase
import CoreNFC
import UIKit
import PassKit
import CoreBluetooth
import CoreLocation

class SendVC: UIViewController {

    let SERVICE_UUID: CBUUID = CBUUID(string: "b30358c2-7720-11ea-bc55-0242ac130003")
    let RX_UUID: CBUUID = CBUUID(string: "b79d5496-7720-11ea-bc55-0242ac130003")
    let RX_PROPERTIES: CBCharacteristicProperties = .read
    let RX_PERMISSIONS: CBAttributePermissions = .readable
    
    let disatanceLabel = UILabel()
    let connectionLabel = UILabel()
    let button = UIButton(type: .system)

    var peripherals: [UUID: CBPeripheral] = [:]
    
    var locationManager: CLLocationManager = CLLocationManager()
    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarItem.image = UIImage(systemName: "square.and.pencil")!
        title = "Send"
        view.backgroundColor = UIColor.systemBackground
        
        locationManager.delegate = self
        centralManager = CBCentralManager(delegate: self, queue: nil)

        disatanceLabel.text = "No distance"
        disatanceLabel.translatesAutoresizingMaskIntoConstraints = false

        connectionLabel.text = "No conenction"
        connectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("scan", for: .normal)
        button.addTarget(self, action: #selector(startScan), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [button, disatanceLabel, connectionLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        view.addSubview(stack)
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func startScan() {
        print("start tapped")
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
        monitorBeacons()
    }
    
    func monitorBeacons() {
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            // Match all beacons with the specified UUID
            let proximityUUID = UUID(uuidString: "39ED98FF-2900-441A-802F-9C398FC199D2")!
            let beaconID = "com.example.myDeviceRegion"

            // Create the region and begin monitoring it.
            let region = CLBeaconRegion(uuid: proximityUUID, identifier: beaconID)
            locationManager.requestAlwaysAuthorization()
            locationManager.startRangingBeacons(in: region)

        }
//        locationManager.requestAlwaysAuthorization()
//        locationManager.distanceFilter = kCLDistanceFilterNone
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestLocation()
    }
    
}

extension SendVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
//    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
//        manager.requestState(for: region)
//    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            print("did enter region")
            // Start ranging only if the devices supports this service.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)

                // Store the beacon so that ranging can be stopped on demand.
//                beaconsToRange.append(region as! CLBeaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        print("WOOOOOOO")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            DispatchQueue.main.async {
                let nearestBeacon = beacons.first!
                switch nearestBeacon.proximity {
                case .near: self.disatanceLabel.text = "near"
                case .immediate: self.disatanceLabel.text = "super near"
                case .far : self.disatanceLabel.text = "far"
                case .unknown: self.disatanceLabel.text = "dont know tbh"
                }
            }
        }
    }
}

extension SendVC: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown: print("central.state is .unknown")
          case .resetting: print("central.state is .resetting")
          case .unsupported: print("central.state is .unsupported")
          case .unauthorized: print("central.state is .unauthorized")
          case .poweredOff: print("central.state is .poweredOff")
          case .poweredOn: print("central.state is .poweredOn")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("did discover peripheral:", peripheral.name ?? "nn", peripheral.identifier)
        if peripherals[peripheral.identifier] == nil {
            print("connecting....")
            peripherals[peripheral.identifier] = peripheral
            central.connect(peripheral)
        }

        
        
//        if let power = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Double{
//            print("Distance is ", pow(10, ((power - Double(truncating: RSSI))/20)))
//            print(advertisementData)
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected: \(peripheral.identifier)", peripheral.name ?? "")
        connectionLabel.text = "\(peripheral.identifier) \(peripheral.name ?? "")"
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected: \(peripheral.identifier)", peripheral.name ?? "")
        print(error?.localizedDescription ?? "No error")
        peripherals.removeValue(forKey: peripheral.identifier)
        connectionLabel.text = "disconnectedd"
    }
}

extension SendVC: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
         guard let services = peripheral.services else { return }
         
         for service in services {
             debugPrint("Service found: \(service)")
             peripheral.discoverCharacteristics([RX_UUID], for: service)
         }
     }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            debugPrint("Characteristic found: \(characteristic)")
            if characteristic.properties.contains(.read) {
                print("reading..")
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let val = characteristic.value else { return }
        print(String(data: val, encoding: .utf8))

    }
}

class TestVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "logout", style: .done, target: self, action: #selector(logout))
    }
    
    @objc func logout() {
        try! Auth.auth().signOut()
    }
    
}
