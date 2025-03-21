//
//  Gauntlet_GaugeApp.swift
//  Gauntlet Gauge
//
//  Created by Aryan Prodduturi on 3/14/25.
//

import SwiftUI
import UserNotifications
import CoreBluetooth

@main
struct Gauntlet_GaugeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance = AppDelegate()
    lazy var statusBarItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength)
    let menu = NSMenu()
    let BM = BluetoothManager.shared
    let NM = NotificationManager.shared
    
    var leftPercent: Int = -1
    var rightPercent: Int = -1

    lazy var contentView: MenuView = MenuView(
        left: leftPercent,
        right: rightPercent
    )


    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        startRefreshTimer()
        refreshMenu()
        requestNotificationPermissions()
    }
    
    func createMenu() {
        menu.removeAllItems()

        let contentView: MenuView = MenuView(
            left: leftPercent,
            right: rightPercent,
            title: BM.selectedPeripheral?.name
        )
        let topView = NSHostingController(rootView: contentView)
        topView.view.frame.size = CGSize(width: 225, height: 145)

        let customMenuItem = NSMenuItem()
        customMenuItem.view = topView.view

        menu.addItem(customMenuItem)
        menu.addItem(NSMenuItem.separator())

        let refreshMenuItem = NSMenuItem(
            title: "Refresh",
            action: #selector(refreshMenu),
            keyEquivalent: "r"
        )
        refreshMenuItem.target = self
        menu.addItem(refreshMenuItem)

        let quitMenuItem = NSMenuItem(
            title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let desMenuItem = NSMenuItem(
                title: "Deselect Peripheral",
                action: #selector(deselectPeripheral),
                keyEquivalent: "0"
            )
        desMenuItem.target = self
        menu.addItem(desMenuItem)
        
        BM.discoveredPeripherals.enumerated().forEach {
            index, peripheral in
            addPeripheralToMenu(peripheral, index: index)
        }

    }

    private func startRefreshTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(
            timeInterval: 60.0,
            target: self,
            selector: #selector(refreshMenu),
            userInfo: nil,
            repeats: true
        )
    }

    private func requestNotificationPermissions() {
        NM.requestAuthorization()
    }

    @objc func refreshMenu() {
        // print("Refreshing Battery Data")

        BM.reConnect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // print("updating Menu Bar Item")
            
            self.updateBatteryPercents()
            self.createMenu()
            
            self.NM.pushNotification(bluetoothManager: self.BM)

            self.statusBarItem.button?.subviews.forEach { $0.removeFromSuperview() }

            let handView = HandView(
                left: self.leftPercent,
                right: self.rightPercent)
            let nsHandView = NSHostingView(rootView: handView)
            nsHandView.frame = NSRect(x: 0, y: 1, width: 50, height: 20)

            self.statusBarItem.button?.addSubview(nsHandView)
            self.statusBarItem.button?.frame = nsHandView.frame

            self.statusBarItem.menu = self.menu
        }

    }

    @objc func deselectPeripheral() {
        BM.changeSelectedPeripheral(nil)
        refreshMenu()
    }

    func updateBatteryPercents() {
        if BM.selectedPeripheral != nil {
            leftPercent = BM.batteryLevels[0]
            rightPercent = BM.batteryLevels[1]
        } else {
            leftPercent = -1
            rightPercent = -1
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func addPeripheralToMenu(_ peripheral: CBPeripheral, index: Int) {
        let peripheralItem = NSMenuItem(
            title: peripheral.name ?? "Unknown Peripheral",
            action: #selector(peripheralSelected(_:)),
            keyEquivalent: index < 10 ? String((index + 1) % 10) : "")
        peripheralItem.target = self
        peripheralItem.representedObject = peripheral
        menu.addItem(peripheralItem)
    }

    @objc func peripheralSelected(_ sender: NSMenuItem) {
        if let peripheral = sender.representedObject as? CBPeripheral {
            // print("Selected peripheral: \(peripheral.name ?? "Unknown")")

            BM.changeSelectedPeripheral(peripheral)
            refreshMenu()
        }
    }
}

