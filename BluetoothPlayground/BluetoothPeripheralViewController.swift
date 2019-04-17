//
//  BluetoothPeripheralViewController.swift
//  BluetoothPlayground
//
//  Created by Felipe Ricieri on 14/04/19.
//  Copyright © 2019 TAB (super.init). All rights reserved.
//

import UIKit
import CoreBluetooth

// LESSON II: Set a Peripheral Manager

// HAS the Data (peripheral device, like heart beat measuring device)
final class BluetoothPeripheralViewController: UIViewController {
    
    // 1) Use the CLI uuidgen to generate a random UUID
    private let serviceUUID = CBUUID(string: "F38EEBFE-BC74-42A5-B874-59E53AA6A097")
    private let readableCharacteristicUUID = CBUUID(string: "548CCB32-92EC-4DEA-9B72-B7A563A1A06E")
    private let writeableCharacteristicUUID = CBUUID(string: "EEE73588-64C8-4C4E-9EE1-76AF5BD93122")
    
    // 2) After setting your UUID you can create your Service & Characteristic properties
    
    // 3) CHARACTERISTICS:
    // 3.1) If you want a characteristic to be READABLE, you MUST set its initial value
    private lazy var readableCharacteristic: CBMutableCharacteristic = {
        return CBMutableCharacteristic(
            type: readableCharacteristicUUID,
            properties: CBCharacteristicProperties.read,
            value: "hello world".data(using: .utf8),
            permissions: CBAttributePermissions.readable
        )
    }()
    
    // 3.2) If you want a characteristic to be writeable, you MUST set its value as nil
    private lazy var writeableCharacteristic: CBMutableCharacteristic = {
        return CBMutableCharacteristic(
            type: writeableCharacteristicUUID,
            properties: CBCharacteristicProperties.write, // if you don't want notifications, you can set it as .writeWithoutResponse
            value: nil,
            permissions: CBAttributePermissions.writeable
        )
    }()
    
    // 4) SERVICES:
    // 4.1) A PRIMARY service describes the primary functionality of a device
    private lazy var primaryReadableService: CBMutableService = {
        let service = CBMutableService(type: serviceUUID, primary: true) // primary is TRUE
        service.characteristics = [writeableCharacteristic] // adding our characteristics
        return service
    }()
    
    // 4.2) A SECONDARY service describes a service that is relevant only in the context of another service that has referenced it.
    private lazy var secondaryReadableService: CBMutableService = {
        let service = CBMutableService(type: serviceUUID, primary: false) // primary is FALSE
        service.characteristics = [readableCharacteristic] // adding our characteristics
        return service
    }()
    
    // 5) Last but not least, we need the Manager to coordinate our Peripgerals
    private var peripheralManager: CBPeripheralManager!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
}

extension BluetoothPeripheralViewController: CBPeripheralManagerDelegate {
    
    // 6) When you create a peripheral manager, the peripheral manager calls this method
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // 6.1) Now we can add our services to our manager
        peripheralManager.add(primaryReadableService)
        peripheralManager.add(secondaryReadableService)
        // 6.2) ... and advertising our services thoughout the bluetooth network!
        peripheralManager.startAdvertising([
            // Only two of the keys are supported for peripheral manager objects:  [CBAdvertisementDataLocalNameKey](https://developer.apple.com/documentation/corebluetooth/cbadvertisementdatalocalnamekey)  and  [CBAdvertisementDataServiceUUIDsKey](https://developer.apple.com/documentation/corebluetooth/cbadvertisementdataserviceuuidskey) .
            CBAdvertisementDataServiceUUIDsKey: [
                primaryReadableService.uuid,
                secondaryReadableService.uuid
            ]
        ])
    }
    
    // 7) When you call the method to publish your services, the peripheral manager will call this method
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        // 7.1) you have the change to handle any errors right away
        if  let error = error {
            print("Oops... Peripheral Manager error out: \(error.localizedDescription)")
            return
        }
        // ⚠️ NOTE: After you publish a service and any of its associated characteristics to the peripheral’s database, the service is cached and you can NO LONGER make changes to it
    }
    
    // 8) When you start advertising some of the data on your local peripheral, the peripheral manager calls this method
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        // 8.1) you have the change to handle any errors right away
        if  let error = error {
            print("Oops... Peripheral Manager error out while advertising: \(error.localizedDescription)")
            return
        }
    }
}
