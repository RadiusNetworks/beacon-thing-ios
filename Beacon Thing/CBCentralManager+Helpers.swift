//
//  CBCentralManager+Helpers.swift
//  Beacon Thing
//
//  Created by Michael Harper on 4/24/17.
//  Copyright © 2017 Radius Networks, Inc. All rights reserved.
//

import CoreBluetooth

extension CBCentralManager {
  func stateDescription() -> String {
    var description: String = "unknown"
    
    switch state {
      
    case .resetting:
      description = "resetting"
      
    case .unsupported:
      description = "unsupported"
      
    case .unauthorized:
      description = "unauthorized"
      
    case .poweredOff:
      description = "OFF"
      
    case .poweredOn:
      description = "ON"
      
    default:
      break
    }
    
    return description
  }
}
