//
//  DBProvider.swift
//  Snapchat Clone With Firebase
//
//  Created by Nathan Johnson on 2/23/17.
//  Copyright © 2017 Nathan Johnson. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class DBProvider {
    private static let _instance = DBProvider();
    
    private let USERS = "users";
    private let CHILD_MESSAGE = "message";
    private let EMAIL = "email";
    private let PASSWORD = "password";
    private let DATA = "data";
    private let STORAGE_URL = "gs://slapchat-559e7.appspot.com";
    private let IMAGE_STORAGE = "images";
    private let VIDEO_STORAGE = "videos";
    
    let SENDER_ID = "senderID";
    let RECEIVER = "receiver";
    let MEDIA_URL = "mediaURL";
    let MESSAGE = "message";
    
    var imageURL: URL?;
    var videoURL: URL?;
    
    static var instance: DBProvider {
        return _instance;
    }
    
    var dbRef: FIRDatabaseReference {
        return FIRDatabase.database().reference();
    }
    
    var usersRef: FIRDatabaseReference {
        return dbRef.child(USERS);
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference(forURL: STORAGE_URL);
    }
    
    var messageRef: FIRDatabaseReference {
        return dbRef.child(CHILD_MESSAGE);
    }
    
    var imagesStorage: FIRStorageReference {
        return storageRef.child(IMAGE_STORAGE);
    }
    
    var videoStorage: FIRStorageReference {
        return storageRef.child(VIDEO_STORAGE);
    }
    
    func saveImage(data: Data, name: String) {
        let ref = imagesStorage.child(name);
        
        ref.put(data, metadata: nil, completion: { (metadata: FIRStorageMetadata?, err: Error?) in
            
            if err != nil {
                print("Problem uploading image");
            } else {
                self.imageURL = metadata!.downloadURL();
            }
            
        });
    }
    
    func saveVideo(url: URL, name: String) {
        let ref = videoStorage.child(name);
        ref.putFile(url, metadata: nil, completion: { (metadata: FIRStorageMetadata?, err: Error?) in
           
            if err != nil {
                print("Inform the user with handlers that we have a problem uploading video");
            } else {
                self.videoURL = metadata!.downloadURL();
            }
            
        });
    }
    
    func setMessageAndMedia(senderId: String, sendingTo: String, mediaURL: String, message: String) {
        
        let msg: Dictionary<String, String> = [SENDER_ID: senderId, RECEIVER: sendingTo, MEDIA_URL: mediaURL, MESSAGE: message];
        
        dbRef.child(CHILD_MESSAGE).childByAutoId().setValue(msg);
        
    }
    
    func saveUser(withId: String, email: String, password: String) {
        let data: Dictionary<String, String> = [EMAIL: email, PASSWORD: password];
        usersRef.child(withId).child(DATA).setValue(data);
    }
}
