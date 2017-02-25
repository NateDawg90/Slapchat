//
//  ContactsVC.swift
//  Snapchat Clone With Firebase
//
//  Created by Nathan Johnson on 1/31/17.
//  Copyright © 2017 Nathan Johnson. All rights reserved.
//

import UIKit
import MobileCoreServices
import FirebaseDatabase
import FirebaseAuth


class ContactsVC: UIViewController, UITableViewDataSource,
    UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var users = [User]();
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    private var index = -1;
    
    private let SHOW_MESSAGE_VC = "ShowMessageVC";

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsers();
        checkForMessages();

        // Do any additional setup after loading the view.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imgData = UIImageJPEGRepresentation(pickedImage, 0.9)! as Data
            let imgName = "\(NSUUID().uuidString).jpg";
            DBProvider.instance.saveImage(data: imgData, name: imgName);
            
            dismiss(animated: true, completion: nil);
            
        } else if let pickedVideoURL = info[UIImagePickerControllerMediaURL] as? URL {
            let videoName = "\(NSUUID().uuidString)\(pickedVideoURL)";
            DBProvider.instance.saveVideo(url: pickedVideoURL, name: videoName);
            
            dismiss(animated: true, completion: nil);
        }
    }
    
    private func checkForMessages() {
        
        DBProvider.instance.messageRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot: FIRDataSnapshot) in
            
            if let receivedMessage = snapshot.value as? Dictionary<String, AnyObject> {
                
                for (_, value) in receivedMessage {
                    
                    if let message = value as? Dictionary<String, String> {
                        
                        let mediaURL = message[DBProvider.instance.MEDIA_URL];
                        let msg = message[DBProvider.instance.MESSAGE];
                        let receiverId = message[DBProvider.instance.RECEIVER];
                        let senderId = message[DBProvider.instance.SENDER_ID];
                        
                        if receiverId == FIRAuth.auth()!.currentUser!.uid {
                            
                            self.messageReceived(title: "You received a message from User \(senderId!)", message: msg!, mediaURL: mediaURL!);
                            
                        }
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    private func getUsers() {
        DBProvider.instance.usersRef.observeSingleEvent(of: FIRDataEventType.value) { (snapshot: FIRDataSnapshot) in
            
            if let myUsers = snapshot.value as? Dictionary<String, AnyObject> {
                
                for (key, value) in myUsers {
                    
                    if let userData = value as? Dictionary<String, AnyObject> {
                        
                        if let data = userData["data"] as? Dictionary<String, AnyObject> {
                            
                            if let email = data["email"] as? String {
                                
                                let id = key;
                                let newUser = User(id: id, email: email);
                                self.users.append(newUser);
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            self.contactsTableView.reloadData();
            
        }
        
            
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath);
        
        cell.textLabel?.text = users[indexPath.row].email;
        
        return cell;
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row;
    }

    @IBAction func logOut(_ sender: Any) {
        if AuthProvider.instance.logOut() {
            dismiss(animated: true, completion: nil);
        } else {
            showAlertMessage(title: "Could not log out", message: "Problems connecting to database. Please try again");
        }
    }
    
    @IBAction func openGallery(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController();
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = false;
            self.present(imagePicker, animated: true, completion: nil);
        }
        
    }
    
    @IBAction func takePicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController();
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false;
            self.present(imagePicker, animated: true, completion: nil);
        }
    }
    
    @IBAction func sendImageOrVideo(_ sender: Any) {
        if index != -1 {
            if DBProvider.instance.imageURL != nil {
                
                DBProvider.instance.setMessageAndMedia(senderId: FIRAuth.auth()!.currentUser!.uid, sendingTo: users[index].id, mediaURL: DBProvider.instance.imageURL!.absoluteString, message: "Hey dude, this is my cool image");
                
                index = -1;
                
            } else if DBProvider.instance.videoURL != nil {
                
                
                DBProvider.instance.setMessageAndMedia(senderId: FIRAuth.auth()!.currentUser!.uid, sendingTo: users[index].id, mediaURL: DBProvider.instance.videoURL!.absoluteString, message: "Hey dude, this is my even more cool video");
                
                index = -1;
                
                
            } else {
                showAlertMessage(title: "No data to send", message: "Please select either an image or video to send");
            }
            
        } else {
            showAlertMessage(title: "Select a User", message: "Please select a user to send a message to");
        }
    }
    
    @IBAction func takeVideo(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController();
            imagePicker.sourceType = .camera;
            imagePicker.mediaTypes = [kUTTypeMovie as String];
            imagePicker.allowsEditing = false;
            imagePicker.delegate = self;
            present(imagePicker, animated: true, completion: nil);
            
        }
    }
    
    private func showAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil);
        alert.addAction(ok);
        self.present(alert, animated: true, completion: nil);
        
    }
    
    private func messageReceived(title: String, message: String, mediaURL: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let yes = UIAlertAction(title: "yes", style: .default) {
            (alertAction: UIAlertAction) in
            self.performSegue(withIdentifier: self.SHOW_MESSAGE_VC, sender: mediaURL);
            
            
        }
        let no = UIAlertAction(title: "no", style: .cancel, handler: nil);
        alert.addAction(no);
        self.present(alert, animated: true, completion: nil);
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ShowMessageVC {
            
            if let mediaURL = sender as? String {
                
                destination.mediaURL = mediaURL;
                
            }
            
        }
        
    }
    
} // class
