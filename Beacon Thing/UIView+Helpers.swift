//
//  UIView+Helpers.swift
//  Beacon Thing
//
//  Created by Michael Harper on 4/24/17.
//  Copyright © 2017 Radius Networks, Inc. All rights reserved.
//

import UIKit

extension UIView {
  func drawBorder(width: CGFloat, color: CGColor) {
    self.layer.borderWidth = width
    self.layer.borderColor = color
  }
}
