//
//  BluetoothCentralViewController.swift
//  BluetoothPlayground
//
//  Created by Felipe Ricieri on 14/04/19.
//  Copyright © 2019 TAB (super.init). All rights reserved.
//

import UIKit
import CoreBluetooth

// LESSON I: Set a Central Manager

// WANTS the data, like your app
final class BluetoothCentralViewController: UIViewController {
    
    private lazy var centralManager: CBCentralManager = {
        // Creates the Central Manager
        return CBCentralManager(delegate: self, queue: nil, options: nil)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Starts to scan for Peripherals
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
}

extension BluetoothCentralViewController: CBCentralManagerDelegate {
    
    // 1) When central manager starts, this is the first method it calls (its required to implement)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("🔵 centralManagerDidUpdateState: \(central)")
    }
    
    // 2) When Central discover a peripheral, this is the method it triggers
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("- didDiscover: 📱\(peripheral.name ?? "(untitled)"), advertisementData: \(advertisementData), rssi: \(RSSI)")
        // 2.1) After discovering a peripheral, you can store it reference (optional)
        //self.discoveredPeripheral = peripheral
        // 2.2) ... or just connect to it
        centralManager.connect(peripheral, options: nil)
        // 2.3) After discovering the peripherals you want, stop to scaring in order to save power
        //centralManager.stopScan()
    }
    
    // 3) If central connected with Peripheral, it will trigger this method
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("- didConnect: 📱\(peripheral.name ?? "(untitled)")")
        // 3.1) Now you can set the peripheral delegate
        peripheral.delegate = self
        // 3.2) After you have established a connection, you can explore data
        peripheral.discoverServices(nil) // CBServices UUIDs
        // See #4 in the 2nd extension below
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("🔵 willRestoreState: \(dict)")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("- didDisconnectPeripheral: \(peripheral), error: \(String(describing: error))")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("- didFailToConnect: 📱\(peripheral.name ?? "(untitled)"), error: \(String(describing: error))")
    }
}

extension BluetoothCentralViewController: CBPeripheralDelegate {
    
    // 4) When the peripheral disconvered the peripheral services, this method is triggered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // 4.1) the peripheral discovered might have more than one service.
        // 4.2) one of them is primary service, while the others are secondaries services
        peripheral.services?.forEach { service in
            print("Hey! I'm a Service! \(service)")
            // 4.3) now you can discover the characteristics of each service
            peripheral.discoverCharacteristics(nil, for: service) // Characteristics UUIDs
        }
    }
    
    // 5) When the peripheral discovered the service's characteristics, this method is triggered
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // 5.1) the peripheral discovered might have more than one service.
        service.characteristics?.forEach { (characteristic) in
            print("Yo! I'm a Characteristic! \(characteristic)")
            // 5.2) A characteristic contains a single value that represents information about a peripheral’s service.
            peripheral.readValue(for: characteristic)
            // 5.3) Though reading the value of a characteristic using the  [readValueForCharacteristic:] method can be effective for static values, it is not the most efficient way to retrieve a dynamic value.
            // You subscribe to the value of a characteristic that you are interested
            peripheral.setNotifyValue(true, for: characteristic)
            
            /// NOTE: Not all characteristics offer subscription. You can determine if a characteristic offers subscription by checking if its properties attribute includes either of the  [CBCharacteristicPropertyNotify] or [CBCharacteristicPropertyIndicate] constants.
        }
    }
    
    // 6) When you attempt to read the value of a characteristic, the peripheral calls this method
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // 6.1 & 7.2) Cool! Now that you subscribed to a characteristic this is your entry point to updates on it
        guard let data = characteristic.value else { return } // Parse the data as you need
        
        // 8) If a characteristic’s value is writeable, you can write its value with data (an instance of NSData
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        // 8.1) CBCharacteristicWriteType.withResponse: which instructs the peripheral to let your app know whether or not the write succeeds
        // 8.2) CBCharacteristicWriteType.withoutResponse: the write operation is performed as best-effort, and delivery is neither guaranteed nor reported. The peripheral does not call any delegate method.
        
        /// NOTE: Characteristics may support only certain types of writes, or none at all. You determine what type of writes, if any, a characteristic supports by checking its properties attribute for one of the  [CBCharacteristicPropertyWriteWithoutResponse] or  [CBCharacteristicPropertyWrite] constants.
    }
    
    // 7) When you subscribe to (or unsubscribe from) a characteristic’s value, the peripheral calls this method
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // 7.1) Here you got the change to handle any errors while updating notification state
        if  let error = error {
            print("Oops... an updating notification state error ocurred: \(error.localizedDescription)")
            return
        }
    }
    
    // 8.3) When you choose to get responses from writing data, this is the method that will be called
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // 8.3.1) Here you got the change to handle any errors while writing data
        if  let error = error {
            print("Oops... an writing data error ocurred: \(error.localizedDescription)")
            return
        }
    }
}
