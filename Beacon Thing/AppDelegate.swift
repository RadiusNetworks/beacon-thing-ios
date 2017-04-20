//
//  AppDelegate.swift
//  Beacon Thing
//
//  Created by Michael Harper on 4/20/17.
//  Copyright © 2017 Radius Networks, Inc. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

  var window: UIWindow?
  var locationManager = CLLocationManager()

  let regionUUIDString = "2F234454-CF6D-4A0F-ADF2-F4911BA9CAFE"
  var regionUUID: UUID!
  var beaconRegion: CLBeaconRegion!
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    locationManager.delegate = self
    checkAuthorization()
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

  func checkAuthorization() {
    if (CLLocationManager.authorizationStatus() != .authorizedAlways) {
      locationManager.requestAlwaysAuthorization()
    }
    else {
      if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        startMonitoringRegion()
      }
    }
  }
  
  func startMonitoringRegion() {
    regionUUID = UUID(uuidString: regionUUIDString)
    beaconRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: "Beacon Region")
    locationManager.startMonitoring(for: beaconRegion)
//    locationManager.startRangingBeacons(in: beaconRegion)
    locationManager.allowsBackgroundLocationUpdates = true
  }
  
  func stopMonitoringRegion() {
    locationManager.stopMonitoring(for: beaconRegion)
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if (status == .authorizedAlways) {
      startMonitoringRegion()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    NSLog("didEnterRegion \(region.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    NSLog("didExitRegion \(region.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    NSLog("didRangeBeacons \(region.identifier). Beacon count is \(beacons.count)")
  }
}

