//
//  BluetoothManager.swift
//  Gauntlet Gauge
//
//  Created by Aryan Prodduturi on 3/15/25.
//

import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = BluetoothManager()
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral? = nil

    let batteryServiceUUID = CBUUID(string: "0x180F")
    let batteryLevelCharacteristicUUID = CBUUID(string: "0x2A19")

    var batteryLevels: [Int] = [0, 0]
    var isNextUpdateForRight: Bool = false

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func reConnect() {
        retrievePeripherals()

        guard selectedPeripheral != nil else { return }
        // print("Reconnecting to Peripheral \(selectedPeripheral?.name ?? "Unknown")")

        centralManager.connect(selectedPeripheral!)
    }
    
    func changeSelectedPeripheral(_ peripheral: CBPeripheral?) {
        if peripheral?.identifier == selectedPeripheral?.identifier { return }
        
        selectedPeripheral = peripheral
        batteryLevels = [-1, -1]
    }

    func retrievePeripherals() {
        // print("Scanning for Peripherals")
        discoveredPeripherals =
            centralManager
            .retrieveConnectedPeripherals(withServices: [batteryServiceUUID]
            )

        if selectedPeripheral != nil
            && !discoveredPeripherals
                .contains(selectedPeripheral!) {
            changeSelectedPeripheral(nil)
        }

//        if discoveredPeripherals.count == 1 {
//            changeSelectedPeripheral(discoveredPeripherals.first)
//            centralManager.connect(selectedPeripheral!)
//        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            retrievePeripherals()
        } else {
            // print("Bluetooth not powered on")
            discoveredPeripherals = []
            changeSelectedPeripheral(nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // print("connected to \(peripheral.name ?? "Unknown")")

        peripheral.delegate = self
        peripheral.discoverServices([batteryServiceUUID])
    }

    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverServices error: Error?
    ) {
        if let services = peripheral.services {
            for service in services {
                peripheral
                    .discoverCharacteristics(
                        [batteryLevelCharacteristicUUID],
                        for: service
                    )
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            if characteristic.uuid == batteryLevelCharacteristicUUID {
                peripheral.readValue(for: characteristic)
            }
        }

    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic, error: Error?
    ) {
        guard let data = characteristic.value else { return }

        if characteristic.uuid == batteryLevelCharacteristicUUID {
            let batteryLevel = data.first ?? 0
            // print("received battery level: \(batteryLevel) for side \(isNextUpdateForRight ? "right" : "left")")

            if batteryLevel != 0 {
                if isNextUpdateForRight {
                    batteryLevels[1] = Int(batteryLevel)
                } else {
                    batteryLevels[0] = Int(batteryLevel)
                }
            }

            isNextUpdateForRight.toggle()
        }
    }
}
