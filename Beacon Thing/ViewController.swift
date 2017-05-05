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
import UserNotifications
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate {

  @IBOutlet weak var logTextView: UITextView!
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var bluetoothStatusLabel: UILabel!
  @IBOutlet weak var monitorRegionSwitch: UISwitch!
  @IBOutlet weak var rangeBeaconsInRegionSwitch: UISwitch!
  @IBOutlet weak var localNotificationsSwitch: UISwitch!
  @IBOutlet weak var regionStatusLabel: UILabel!
  
  var bluetoothManager = CBCentralManager()
  
  var locationManager = CLLocationManager()
  let regionUUIDString = "2F234454-CF6D-4A0F-ADF2-F4911BA9CAFE"
  var regionUUID: UUID!
  var beaconRegion: CLBeaconRegion!
  var enterBeaconRegion: CLBeaconRegion!
  var exitBeaconRegion: CLBeaconRegion!

  var playLogSound = true
  let logSoundID: SystemSoundID = 1123
  
  let logBorderWidth = CGFloat(2.0)
  let logBorderColor = UIColor.black.cgColor
  
  let dateFormatter = DateFormatter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initializeLogging()
    initializeBluetooth()
    enableControlsForState(bluetoothState: bluetoothManager.state, locationState: CLLocationManager.authorizationStatus())
    initializeCoreLocation()
    checkAuthorization()
    initializeBeaconData()
    initializeNotifications()
    decorateViews()
  }
  
  func initializeLogging() {
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .medium
  }
  
  func initializeBluetooth() {
    bluetoothManager.delegate = self
  }
  
  func initializeCoreLocation() {
    locationManager.delegate = self
    locationManager.allowsBackgroundLocationUpdates = true
  }
  
  func checkAuthorization() {
    if (CLLocationManager.authorizationStatus() != .authorizedAlways) {
      locationManager.requestAlwaysAuthorization()
    }
  }
  
  func initializeBeaconData() {
    uuidLabel.text = regionUUIDString
    regionUUID = UUID(uuidString: regionUUIDString)
    beaconRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: "Beacon Region")
    enterBeaconRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: "Enter Beacon Region")
    enterBeaconRegion.notifyOnExit = false
    exitBeaconRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: "Exit Beacon Region")
    exitBeaconRegion.notifyOnEntry = false
  }
  
  func initializeNotifications() {
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]
    center.requestAuthorization(options: options) {
      (granted, error) in
      if !granted {
        self.logMessage("C'mon, man!")
      }
    }
  }
  
  func createLocalNotifications() {
    let center = UNUserNotificationCenter.current()

    let enterTrigger = UNLocationNotificationTrigger(region:enterBeaconRegion, repeats:true)
    let enterContent = UNMutableNotificationContent()
    enterContent.title = "Beacon Region"
    enterContent.body = "Entered"
    enterContent.sound = UNNotificationSound.default()

    let request = UNNotificationRequest(identifier: "enter region", content: enterContent, trigger: enterTrigger)
    center.add(request, withCompletionHandler: { (error) in
      if let error = error {
        self.logMessage("Error adding local notification for entry: \(error.localizedDescription)")
      }
    })

    let exitTrigger = UNLocationNotificationTrigger(region:exitBeaconRegion, repeats:true)
    let exitContent = UNMutableNotificationContent()
    exitContent.title = "Beacon Region"
    exitContent.body = "Exited"
    exitContent.sound = UNNotificationSound.default()
    
    let exitRequest = UNNotificationRequest(identifier: "exit region", content: exitContent, trigger: exitTrigger)
    center.add(exitRequest, withCompletionHandler: { (error) in
      if let error = error {
        self.logMessage("Error adding local notification for exit: \(error.localizedDescription)")
      }
    })
  }
  
  func cancelLocalNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
 }
  
  func decorateViews() {
    logTextView.drawBorder(width: logBorderWidth, color: logBorderColor)
  }
  
  func updateBluetoothStatus() {
    bluetoothStatusLabel.text = "Bluetooth is \(bluetoothManager.stateDescription())"
  }
  
  func enableControlsForState(bluetoothState: CBManagerState, locationState: CLAuthorizationStatus) {
    setControlsEnabled(enabled: bluetoothState == .poweredOn && locationState == .authorizedAlways)
  }
  
  func setControlsEnabled(enabled: Bool) {
    monitorRegionSwitch.isEnabled = enabled
    rangeBeaconsInRegionSwitch.isEnabled = enabled
    localNotificationsSwitch.isEnabled = enabled
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
  
  @IBAction func localNotificationsAction(_ sender: UISwitch) {
    let shouldUseLocalNotifications = sender.isOn
    if shouldUseLocalNotifications {
      createLocalNotifications()
    }
    else {
      cancelLocalNotifications()
    }
  }
  
  @IBAction func soundAction(_ sender: UISwitch) {
    playLogSound = sender.isOn
  }
  
  @IBAction func clearLogAction() {
    logTextView.text = ""
  }
  
  func cancelAllBeaconMonitoring() {
    locationManager.stopMonitoring(for: beaconRegion)
    locationManager.stopRangingBeacons(in: beaconRegion)
  }
  
  func logMessage(_ message: String) {
    logTextView.text = logTextView.text + dateFormatter.string(from: Date()) + ": " + message + "\n"
    let textLength = logTextView.text.lengthOfBytes(using: .utf8)
    let bottom = NSMakeRange(textLength - 1, 1)
    logTextView.scrollRangeToVisible(bottom)
    if playLogSound {
      AudioServicesPlaySystemSound(logSoundID)
    }
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    updateBluetoothStatus()
    enableControlsForState(bluetoothState: central.state, locationState: CLLocationManager.authorizationStatus())
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    enableControlsForState(bluetoothState: bluetoothManager.state, locationState: status)
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

