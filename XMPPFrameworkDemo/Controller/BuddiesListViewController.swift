//
//  BuddiesListViewController.swift
//  XMPPFrameworkDemo
//
//  Created by Zubair.Nagori on 23/11/18.
//  Copyright © 2018 applligent. All rights reserved.
//

import UIKit
import XMPPFramework
class BuddiesListViewController: UIViewController {
    @IBOutlet weak var tblBuddies: UITableView!
    
    var arrOnlineBuddies = [String]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Since we are not getting buddies, just add the user which is configured on Adium client
        arrOnlineBuddies.append("user2@localhost")
        
        //Register the custom cell
        tblBuddies.register(UINib(nibName: "BuddiesCell", bundle: Bundle.main), forCellReuseIdentifier: "BuddiesCell")
        
        //Subscribe for receiving presence events
        appDelegate.presenceDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Check if userID is not nil
        guard let _ = UserDefaults.standard.string(forKey: "userID") else {
            return
        }
        
        //
        if appDelegate.connect() {
            title = appDelegate.xmppStream.myJID?.bare
            appDelegate.xmppRoster.fetch()
        }
        else {
            print("User not logged-in. Please login first.")
        }
    }
    
}

extension BuddiesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOnlineBuddies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BuddiesCell", for: indexPath) as! BuddiesCell
        cell.lblBuddyName.text = arrOnlineBuddies[indexPath.row]
        
        return cell
    }
}

extension BuddiesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let senderJID = XMPPJID(string: arrOnlineBuddies[indexPath.row]) else {
            return
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.senderJabberId = senderJID
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension BuddiesListViewController: PresenceDelegate {
    func buddyWentOnline(name: String) {
        if !arrOnlineBuddies.contains(name) {
            arrOnlineBuddies.append(name)
            tblBuddies.reloadData()
        }
    }
    
    func buddyWentOffline(name: String) {
        //TODO: Add code to remove buddy from array
        /*
         arrOnlineBuddies.remove(name)
         tblBuddies.reloadData()
 */
    }
    
    func didDisconnect() {
        arrOnlineBuddies.removeAll()
        tblBuddies.reloadData()
    }
}
