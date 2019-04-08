//
//  AppDelegate.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 08/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import NotificationCenter
import FBSDKCoreKit
import UserNotifications
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate, SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate {

    
    var _client: SINClient!
    var push: SINManagedPush!

    var window: UIWindow?

    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        
        if let launchOptions = launchOptions {
            
            if let notificationDictionary = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? [NSObject : AnyObject] {
                
                self.application(application, didReceiveRemoteNotification: notificationDictionary)
            }
            
        }

        
        //sinch push
        
        self.push = Sinch.managedPush(with: .development)
        self.push.delegate = self
        self.push.setDesiredPushTypeAutomatically()
        
        
        func onUserDidLogin(userId: String) {

            self.push.registerUserNotificationSettings()
            self.initSinchWithUserId(userId: userId)
            self.startOneSignal()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserDidLoginNotification"), object: nil, queue: nil, using: {
            note in
            
            let userId = note.userInfo!["userId"] as! String
            UserDefaults.standard.set(userId, forKey: "userId")
            UserDefaults.standard.synchronize()
            
            onUserDidLogin(userId: userId)
        })
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        

        
        //ios 10 check
        
        if #available(iOS 10.0, *) {
            
            let ceter = UNUserNotificationCenter.current()
            
            ceter.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (granted, error) in
                
                
            })
            
            application.registerForRemoteNotifications()
            
        } else {
            
            let types: UIUserNotificationType = [.alert, .badge, .sound]
            
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            
        }
        
        
        
        
        //oneSignal
        OneSignal.initWithLaunchOptions(launchOptions, appId: kONESIGNALAPPID, handleNotificationReceived: nil, handleNotificationAction: nil, settings: [kOSSettingsKeyInAppAlerts : false])
        


        OneSignal.setLogLevel(ONE_S_LOG_LEVEL.LL_NONE, visualLevel: ONE_S_LOG_LEVEL.LL_NONE)

        

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")

        locationMangerStop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")

        locationManagerStart()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationDidBecomeActive")

    }
    
    //MARK: OneSignal
    
    func startOneSignal() {

        OneSignal.idsAvailable { (userId, token) in
            
            if token != nil {
                UserDefaults.standard.setValue(userId!, forKey: "OneSignalId")
            } else {
                UserDefaults.standard.removeObject(forKey: "OneSignalId")
            }
            
            updateOneSignalId()
        }

    }
    

    
    //MARK: Location Manager
    
    func locationManagerStart() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
    }
    
    func locationMangerStop() {
        
        locationManager!.stopUpdatingLocation()
    }
    
    
    //MARK: Location ManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            locationManager = nil
            print("denied location")
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinates = locations.last!.coordinate
    }
    
    
    //MARK: Facebook login
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

        let result = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return result
    }
    

    //MARK: PushNotification functions
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        self.push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        self.push.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("did fail to register for remote notif\(error)")
    }
    
    //MARK: Sinch Init
    
    func initSinchWithUserId(userId: String) {
        
        
        if _client == nil {
            
            _client = Sinch.client(withApplicationKey: kSINCHKEY, applicationSecret: kSINCHSECRET, environmentHost: "sandbox.sinch.com", userId: userId)
            
            _client.delegate = self
            _client.call().delegate = self
            
            _client.setSupportCalling(true)
            _client.enableManagedPushNotifications()
            _client.start()
            _client.startListeningOnActiveConnection()
            
        }
        
        
    }
    
    func handleRemoteNotification(userInfo: NSDictionary) {
        
        
        if _client != nil {
            
            let userId = UserDefaults.standard.object(forKey: "userId")
            
            if userId != nil {
                
                self.initSinchWithUserId(userId: userId as! String)
            }
            
        }
        
        self._client.relayRemotePushNotification(userInfo as! [AnyHashable : Any])
        
    }
    
    //MARK: SinManagedPushDelegate
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        

        if pushType == "PKPushTypeVoIP" {

            self.handleRemoteNotification(userInfo: payload as NSDictionary)
        } else {
            
            let userId = UserDefaults.standard.object(forKey: "userId")
            
            if userId != nil {
                
                self.initSinchWithUserId(userId: userId as! String)
            }

        }
    }
    
    
    //MARK: SINCallClientDelegate
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        
        var top = self.window?.rootViewController
        
        while (top?.presentedViewController != nil) {
            top = top?.presentedViewController
        }
        
        let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CallVC") as! CallViewController
        
        callVC._call = call
        
        top?.present(callVC, animated: true, completion: nil)
    }
    
    func client(_ client: SINCallClient!, localNotificationForIncomingCall call: SINCall!) -> SINLocalNotification! {
        
        
        let notification = SINLocalNotification()
        notification.alertAction = "Answer"
        notification.alertBody = "Incoming Call"
        
        return notification
    }
    
    //MARK: SINClientDelegate
    
    func clientDidStart(_ client: SINClient!) {
        print("Sinch client started")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("Sinch client failed")
    }
    
    func client(_ client: SINClient!, logMessage message: String!, area: String!, severity: SINLogSeverity, timestamp: Date!) {
        
        if severity == SINLogSeverity.critical {
            
            print("Message: \(message)")
        }
        
    }
    

    


    
    
    




}

