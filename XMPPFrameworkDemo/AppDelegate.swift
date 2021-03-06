//
//  AppDelegate.swift
//  XMPPFrameworkDemo
//
//  Created by Zubair.Nagori on 23/11/18.
//  Copyright © 2018 applligent. All rights reserved.
//

import UIKit
import CoreData
import XMPPFramework

protocol PresenceDelegate {
    func buddyWentOnline(name: String)
    func buddyWentOffline(name: String)
    func didDisconnect()
}

protocol MessagingDelegate {
    func messageReceived(message: XMPPMessage)
    func messageSent(message: XMPPMessage)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //MARK: XMPP Properties
    var presenceDelegate: PresenceDelegate!
    var messagingDelegate: MessagingDelegate?
    
    let xmppStream = XMPPStream()
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster

    override init() {
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupStream()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        disconnect()
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
        
        connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "XMPPFrameworkDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: Custom XMPP Methods
    private func setupStream() {
        xmppRoster.activate(xmppStream)
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    private func goOnline() {
        let presence = XMPPPresence()
        let domain = xmppStream.myJID!.domain
        
        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
            let priority = DDXMLElement.element(withName: "priority", stringValue: "24") as! DDXMLElement
            presence.addChild(priority)
        }
        xmppStream.send(presence)
    }
    
    private func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.send(presence)
    }

    func connect() -> Bool {
        if !xmppStream.isConnected {
            guard let jabberID = UserDefaults.standard.string(forKey: "userID"), let _ = UserDefaults.standard.string(forKey: "userPassword") else {
                return false
            }
            
            if !xmppStream.isDisconnected {
                return true
            }
            
            xmppStream.myJID = XMPPJID(string: jabberID)
            
            do {
                try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
                print("Connection success")
                return true
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
    }
    
    func disconnect() {
        goOffline()
        xmppStream.disconnect()
    }
}

extension AppDelegate: XMPPStreamDelegate {
    func xmppStreamDidConnect(_ sender: XMPPStream) {
        do {
            guard let password = UserDefaults.standard.string(forKey: "userPassword") else {
                print("Password not available.")
                return
            }
            try xmppStream.authenticate(withPassword: password )
        } catch {
            print("Could not authenticate")
        }
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("Stream did authenticate")
        goOnline()
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive iq: XMPPIQ) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive message: XMPPMessage) {
        print("Did receive message \(message)")
        messagingDelegate?.messageReceived(message: message)
    }
    
    func xmppStream(_ sender: XMPPStream, didSend message: XMPPMessage) {
        print("Did send message \(message)")
        messagingDelegate?.messageSent(message: message)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive presence: XMPPPresence) {
        let presenceType = presence.type!
        let myUsername = sender.myJID!.user!
        
        let presenceFromUser = presence.from!.user!
        
        if presenceFromUser != myUsername {
            print("Did receive presence from \(presenceFromUser)")
            if presenceType == "available" {
                presenceDelegate.buddyWentOnline(name: presenceFromUser)
            } else if presenceType == "unavailable" {
                presenceDelegate.buddyWentOffline(name: presenceFromUser)
            }
        }
    }
    
    func xmppRoster(_ sender: XMPPRoster, didReceiveRosterItem item: DDXMLElement) {
        print("Did receive Roster item")
    }
    
}

extension AppDelegate: XMPPRosterDelegate {
    
}
