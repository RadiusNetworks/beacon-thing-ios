//
//  ViewController.swift
//  Beacon Thing
//
//  Created by Michael Harper on 4/20/17.
//  Copyright © 2017 Radius Networks, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate {

  @IBOutlet weak var logTextView: UITextView!
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var bluetoothStatusLabel: UILabel!
  @IBOutlet weak var monitorRegionSwitch: UISwitch!
  @IBOutlet weak var rangeBeaconsInRegionSwitch: UISwitch!
  @IBOutlet weak var regionStatusLabel: UILabel!
  
  var bluetoothManager = CBCentralManager()
  
  var locationManager = CLLocationManager()
  let regionUUIDString = "2F234454-CF6D-4A0F-ADF2-F4911BA9CAFE"
  var regionUUID: UUID!
  var beaconRegion: CLBeaconRegion!

  let logBorderWidth = CGFloat(2.0)
  let logBorderColor = UIColor.black.cgColor
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeBluetooth()
    enableControlsForState(bluetoothState: bluetoothManager.state)
    initializeCoreLocation()
    initializeBeaconData()
    decorateViews()
  }
  
  func initializeBluetooth() {
    bluetoothManager.delegate = self
  }
  
  func initializeCoreLocation() {
    locationManager.delegate = self
    locationManager.allowsBackgroundLocationUpdates = true
  }
  
  func initializeBeaconData() {
    uuidLabel.text = regionUUIDString
    regionUUID = UUID(uuidString: regionUUIDString)
    beaconRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: "Beacon Region")
  }
  
  func decorateViews() {
    logTextView.drawBorder(width: logBorderWidth, color: logBorderColor)
  }
  
  func updateBluetoothStatus() {
    bluetoothStatusLabel.text = "Bluetooth is \(bluetoothManager.stateDescription())"
  }
  
  func enableControlsForState(bluetoothState: CBManagerState) {
    setControlsEnabled(enabled: bluetoothState == .poweredOn)
  }
  
  func setControlsEnabled(enabled: Bool) {
    monitorRegionSwitch.isEnabled = enabled
    rangeBeaconsInRegionSwitch.isEnabled = enabled
  }
  
  func updateRegionStatus(forState state: CLRegionState) {
    regionStatusLabel.text = "I believe I am \(CLRegion.descriptionForState(state: state)) of the region"
  }
  
  @IBAction func monitorAction(_ sender: UISwitch) {
    let shouldMonitor = sender.isOn
    if shouldMonitor {
      locationManager.startMonitoring(for: beaconRegion)
    }
    else {
      locationManager.stopMonitoring(for: beaconRegion)
    }
  }
  
  @IBAction func rangeAction(_ sender: UISwitch) {
    let shouldRange = sender.isOn
    if shouldRange {
      locationManager.startRangingBeacons(in: beaconRegion)
    }
    else {
      locationManager.stopRangingBeacons(in: beaconRegion)
    }
  }
  
  @IBAction func clearLogAction() {
    logTextView.text = ""
  }
  
  func cancelAllBeaconMonitoring() {
    locationManager.stopMonitoring(for: beaconRegion)
    locationManager.stopRangingBeacons(in: beaconRegion)
  }
  
  func logMessage(_ message: String) {
    logTextView.text = logTextView.text + message + "\n"
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    updateBluetoothStatus()
    enableControlsForState(bluetoothState: central.state)
  }
  
  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    logMessage("didDetermineState \(CLRegion.descriptionForState(state: state)) forRegion \(region.identifier)")
    updateRegionStatus(forState: state)
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    logMessage("didEnterRegion \(region.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    logMessage("didExitRegion \(region.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    logMessage("didRangeBeacons \(region.identifier). Beacon count is \(beacons.count)")
  }
}

