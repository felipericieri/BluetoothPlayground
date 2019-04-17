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
    
    private var peripheralManager: CBPeripheralManager!
    
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
        return CBMutableService(type: serviceUUID, primary: true)
    }()
    
    // 4.2) A SECONDARY service describes a service that is relevant only in the context of another service that has referenced it.
    private lazy var secondaryReadableService: CBMutableService = {
        return CBMutableService(type: serviceUUID, primary: true)
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Creates and starts the Peripheral Manager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
}

extension BluetoothPeripheralViewController: CBPeripheralManagerDelegate {
    
    // 2) When you create a peripheral manager, the peripheral manager calls this method
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
}
