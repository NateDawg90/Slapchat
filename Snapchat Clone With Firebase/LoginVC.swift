//
//  ViewController.swift
//  Snapchat Clone With Firebase
//
//  Created by Nathan Johnson on 1/30/17.
//  Copyright © 2017 Nathan Johnson. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    private let CONTACTS_SEGUE_ID = "ContactsVC";

    @IBOutlet weak var emailTextField: CustomTextField!
    
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AuthProvider.instance.isLoggedIn() {
            performSegue(withIdentifier: CONTACTS_SEGUE_ID, sender: nil);
        }
    }

    @IBAction func logIn(_ sender: AnyObject) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.instance.logIn(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.showAlertMessage(title: "Problem with Authentication", message: message!);
                } else {
                    self.emailTextField.text = "";
                    self.passwordTextField.text = "";
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE_ID, sender: nil);
                }
                
            });
            
        } else {
            showAlertMessage(title: "Email and Password are required", message: "Please enter email and password in text fields");
        }
        
    }

    @IBAction func SignUp(_ sender: AnyObject) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.showAlertMessage(title: "Problem with signing up", message: message!)
                } else {
                    self.passwordTextField.text = "";
                    self.emailTextField.text = "";
                    self.performSegue(withIdentifier: self.CONTACTS_SEGUE_ID, sender: nil);
                }
            });
            
        } else {
            showAlertMessage(title: "Email and Password are required", message: "Please enter email and password in text fields");
        }
        
    }
        
    private func showAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil);
        alert.addAction(ok);
        self.present(alert, animated: true, completion: nil);
            
    }
    
    func login(withEmail: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil {
                print("we have a problem logging in");
            } else {
               
            }
            
        });

    }

} //class

