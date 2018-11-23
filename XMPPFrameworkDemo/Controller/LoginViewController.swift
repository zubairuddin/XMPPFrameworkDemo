//
//  LoginViewController.swift
//  XMPPFrameworkDemo
//
//  Created by Zubair.Nagori on 23/11/18.
//  Copyright © 2018 applligent. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtUsername.text = "user1@localhost"
        txtPassword.text = "123456"
    }

    @IBAction func loginAction(_ sender: UIButton) {
        //Set username and password in user defaults
        UserDefaults.standard.set(txtUsername.text!, forKey: "userID")
        UserDefaults.standard.set(txtPassword.text!, forKey: "userPassword")
        
        //Navigate to buddies list screen
        let vc = storyboard?.instantiateViewController(withIdentifier: "BuddiesListViewController") as! BuddiesListViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}
