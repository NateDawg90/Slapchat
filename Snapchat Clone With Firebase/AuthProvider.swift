//
//  AuthProvider.swift
//  Snapchat Clone With Firebase
//
//  Created by Nathan Johnson on 2/1/17.
//  Copyright © 2017 Nathan Johnson. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ errMSG: String?) -> Void;

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid Email address, please provide real email address."
    static let WRONG_PASSWORD = "Wrong password, please enter the correct password";
    static let PROBLEM_CONNECTING = "Problem connecting to database, please try again later.";
    static let USER_NOT_FOUND = "User not found. Please Register";
    static let EMAIL_ALREADY_IN_USE = "Email already in use";
    static let WEAK_PASSWORD = "Password should be at least 6 characters";
    
    
}

class AuthProvider {
    private static let _instance = AuthProvider();
    
    static var instance: AuthProvider {
        return _instance;
    }
    
    func isLoggedIn() -> Bool {
        if FIRAuth.auth()?.currentUser != nil {
            return true;
        }
        return false;
    }
    
    func logOut() -> Bool {
        
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut();
                return true;
            } catch {
                return false;
            }
        }
        return true;
    }
    
    func logIn(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error != nil {
                // user not signed in we have a problem
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
                
            } else {
                //user is signed in
                loginHandler?(nil);
                
            }
            
        });

    }
    
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        FIRAuth.auth()?.createUser(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil {
                
                self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
                
            } else {
                
                // uid is user id
                if user?.uid != nil {
                    
                    // save to database
                    DBProvider.instance.saveUser(withId: user!.uid, email: withEmail, password: password);
                    
                    // signin user
                    FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: { (user, error) in
                        
                        if error != nil {
                            self.handleErrors(err: error as! NSError, loginHandler: loginHandler);
                        } else {
                            loginHandler?(nil);
                        }
                    })
                    
                }
                
            }
            
        })
        
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        
        if let errCode = FIRAuthErrorCode(rawValue: err.code) {
            
            switch errCode {
                
            case .errorCodeWrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD);
                break;
                
            case .errorCodeInvalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL);
                break;
                
            case .errorCodeUserNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND);
                break;
                
            case .errorCodeEmailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE);
                break;
                
            case .errorCodeWeakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD);
                break;
                
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING);
                break;
                
            }
            
        }
        
    }
    
}
















































