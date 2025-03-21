//
//  UserPreference.swift
//  Gauntlet Gauge
//
//  Created by Aryan Prodduturi on 3/20/25.
//

class UserPreference {
    static let shared = UserPreference()
    var batteryPreference = BatteryPreference()
    
    init(batteryPreference: BatteryPreference = .init()) {
        self.batteryPreference = batteryPreference
    }
    
    class BatteryPreference {
        var batteryLevel: Int
        
        init(batteryLevel: Int = 20) {
            self.batteryLevel = batteryLevel
        }
        
        func updateBatteryLevel(_ newLevel: Int) {
            self.batteryLevel = newLevel
        }
    }
    
    func updateBatteryLevel(_ newLevel: Int) {
        batteryPreference.updateBatteryLevel(newLevel)
    }
}
