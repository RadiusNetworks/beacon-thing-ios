//
//  CLRegion+Helpers.swift
//  Beacon Thing
//
//  Created by Michael Harper on 4/24/17.
//  Copyright © 2017 Radius Networks, Inc. All rights reserved.
//

import CoreLocation

extension CLRegion {
  class func descriptionForState(state: CLRegionState) -> String {
    var description: String = "unknown"
    
    switch state {
      
    case .inside:
      description = "inside"
      
    case .outside:
      description = "outside"
      
    default:
      break
    }
    
    return description
  }
}
