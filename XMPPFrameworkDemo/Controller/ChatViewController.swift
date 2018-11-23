//
//  ChatViewController.swift
//  XMPPFrameworkDemo
//
//  Created by Zubair.Nagori on 23/11/18.
//  Copyright © 2018 applligent. All rights reserved.
//

import UIKit
import XMPPFramework

class ChatViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var arrMessages = [Message]()
    
    @IBOutlet weak var txtNewMessage: UITextField!
    @IBOutlet weak var tblMessages: UITableView!
    
    var senderJabberId: XMPPJID!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Register xib
        tblMessages.register(UINib(nibName: "ChatCell", bundle: Bundle.main), forCellReuseIdentifier: "ChatCell")
        appDelegate.messagingDelegate = self

    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let xmppMessage = XMPPMessage(type: "chat", to: senderJabberId)
        xmppMessage.addBody(txtNewMessage.text!)
        self.appDelegate.xmppStream.send(xmppMessage)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        if arrMessages.count > 0 {
            let message = arrMessages[indexPath.row]
            cell.lblMessage.text = message.strMessage
            
            switch message.state {
            case .sent:
                cell.lblMessageLeadingConstraint.constant = 10
                cell.lblMessageTrailingConstraint.constant = 200
            case .received:
                cell.lblMessageLeadingConstraint.constant = 200
                cell.lblMessageTrailingConstraint.constant = 10

            }
        }
        return cell
    }
}

extension ChatViewController: MessagingDelegate {
    func messageReceived(message: XMPPMessage) {
        //Append the new message to messages array
        let msg = Message(strMessage: message.body!, state: .received)
        arrMessages.append(msg)
        tblMessages.reloadData()

    }
    func messageSent(message: XMPPMessage) {
        //Append the new message to messages array
        let msg = Message(strMessage: message.body!, state: .sent)
        arrMessages.append(msg)
        tblMessages.reloadData()

    }
}
