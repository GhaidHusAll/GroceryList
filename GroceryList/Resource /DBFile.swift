//
//  File.swift
//  GroceryList
//
//  Created by administrator on 10/11/2021.
//

import Foundation
import FirebaseDatabase

class DatabaseManger{
    
    static let shared = DatabaseManger()
    private let database = Database.database().reference()
    
    
    


}
extension DatabaseManger {
    
    func safeEmail (email : String)-> String{
           
           var safeEmail = email.replacingOccurrences(of: ".", with: "-")
           safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
           return safeEmail
       }
   
    //function to autheraization
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
           
           let safeEmail = safeEmail(email: email)
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.database.child("users").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
                       if snapshot.exists() {
                           completion(true)
                           return
                       }else { completion(false) }
                   }
               }else {  completion(false)}
           }
       }
    
   
    // Insert new user profile to database
       public func insertUser(with user: User ,completion: @escaping ((Bool) -> Void)) {
        let safeEmail = safeEmail(email: user.emailAddress)
        guard let guardUrl = user.imageProfile else {return}
        self.database.child("users").child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
                   if var users = snapshot.value as?[[String : Any]]{
                       // add to existing db child
                       let newuser: [String:Any] = [
                           
                        "name" : user.userName ,
                        "email" : safeEmail,
                        "imageUrl" : guardUrl,
                        "isOnline" : user.isOnline
                        
                       ]
                       
                       users.append(newuser)
                    self.database.child("users").child(safeEmail).setValue(users, withCompletionBlock: {error,  _ in
                           guard  error != nil else {
                               completion(true)
                               return
                           }
                           completion(false)
                       })
                   }else{
                       //create new collection for database if it does not exist
                       let newUsers : [[String:Any]]=[
                           [
                            "name" : user.userName ,
                            "email" : safeEmail,
                            "imageUrl" : guardUrl,
                            "isOnline" : user.isOnline
                           ]
                       ]
                    self.database.child("users").child(safeEmail).setValue(newUsers, withCompletionBlock: {error,  _ in
                           guard  error != nil else {
                               completion(true)
                               return
                           }
                        print("----error \(String(describing: error))")
                           completion(false)
                       })
                   }
               })
           
       }
    // fetch user's data
       public func getUser(email: String  ,completion: @escaping ((User) -> Void)) {
        var user = User(userName: "", emailAddress: "", isOnline: false, imageProfile: "")
        let safeEmail = safeEmail(email: email)
        self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            if !snapshot.exists() {
                DispatchQueue.main.async {completion(user)}
            }else {
            for snap in snapshot.children {
                let Snap = snap as! DataSnapshot
                if Snap.key == safeEmail{
                let UsersValues = Snap.value as! [[String:Any]]
                let userValue = UsersValues[0]
                guard let theemail = userValue["email"] as? String,
                let name = userValue["name"] as? String,
                let isonline = userValue["isOnline"] as? Bool,
                let url = userValue["imageUrl"] as? String else {return}
                
                let oneUser = User(userName: name,
                                   emailAddress: theemail,
                                   isOnline: isonline,
                                   imageProfile: url)
                    user = oneUser
                }// if key
            }//for loop
            }//else
            DispatchQueue.main.async {print(user)
                completion(user)}
        })
    }
    //update user's image profile
        public func updateUserImage(image: String, email: String,completion: @escaping ((Bool) -> Void)) {
            let safeEmail = safeEmail(email: email)
            self.database.child("users/\(safeEmail)/0").updateChildValues(["imageUrl" : image])
            DispatchQueue.main.async(){
                completion(true)
                return
            }
            completion(false)
        }
    //fetch  all users
       public func getUsers( completion: @escaping (([User]) -> Void)) {
           var returnUsers = [User]()
        self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            if !snapshot.exists() {
                DispatchQueue.main.async {completion(returnUsers)}
            }else {
            for snap in snapshot.children {
                let Snap = snap as! DataSnapshot
                
                let Values = Snap.value as! [[String:Any]]
                let itemValue = Values[0]
                guard let email = itemValue["email"] as? String,
                let name = itemValue["name"] as? String,
                let isOnline = itemValue["isOnline"] as? Bool,
                let url = itemValue["imageUrl"] as? String else {return}
                
                let oneUser = User(userName: name,
                                   emailAddress: email,
                                   isOnline: isOnline,
                                   imageProfile: url)
                
                returnUsers.append(oneUser)
               
            }//for loop
            }//else
            DispatchQueue.main.async { completion(returnUsers)}
        })
       }
    //function to obverv and update user status realtime
    func updateUsers(completion: @escaping (([User]) -> Void)){
        var returnUsers : [User] = []
        
        self.database.child("users/").observe(.value, with: { snapshot in
            if !snapshot.exists() {
                returnUsers = []
                completion(returnUsers)
            }else {
                returnUsers = []
                for snap in snapshot.children {
                    let Snap = snap as! DataSnapshot
                    
                    let Values = Snap.value as! [[String:Any]]
                    let itemValue = Values[0]
                    guard let email = itemValue["email"] as? String,
                    let name = itemValue["name"] as? String,
                    let isOnline = itemValue["isOnline"] as? Bool,
                    let url = itemValue["imageUrl"] as? String else {return}
                    
                    let oneUser = User(userName: name,
                                       emailAddress: email,
                                       isOnline: isOnline,
                                       imageProfile: url)
                    
                    returnUsers.append(oneUser)
                   
                } //inner for
               
            }//else
            DispatchQueue.main.async {completion(returnUsers)}
            
        })
        
    }
    // MARK: Connection
    // function to check the user connection and update status
    
    func connectionUpdateIsOnline(email: String , status:Bool){
        let safeEmail = self.safeEmail(email: email)
        if status {
                print("Connected")
                self.database.child("users/\(safeEmail)/0").updateChildValues(["isOnline" : true])
            } else {
                print("Not connected")
                self.database.child("users/\(safeEmail)/0").onDisconnectUpdateChildValues(["isOnline" : false])
            }
    
    }
   
    // MARK: Grocery database
    
    //function to add item
    func addItem(item : Item, completion: @escaping ((Bool) -> Void)){
        guard let guardUrl = item.urlImage else {return}
        self.database.child("items").observeSingleEvent(of: .value, with: {snapshot in
                   if var items = snapshot.value as?[[String : Any]]{
                       // add to existing db child
                       let newitem: [String:Any] = [
                           
                        "name" : item.name ,
                        "id" : item.id,
                        "imageUrl" : guardUrl,
                        "isDone" : item.isDone,
                        "user" : item.User
                        
                       ]
                       
                       items.append(newitem)
                    self.database.child("items").child(item.id).setValue(items, withCompletionBlock: {error,  _ in
                           guard  error != nil else {
                            completion(true)
                              return
                           }
                           completion(false)
                       })
                   }else{
                       //create new collection for database if it does not exist
                       let newItem : [[String:Any]]=[
                           [
                            "name" : item.name ,
                            "id" : item.id,
                            "imageUrl" : guardUrl,
                            "isDone" : item.isDone,
                            "user" : item.User
                           ]
                       ]
                    self.database.child("items").child(item.id).setValue(newItem, withCompletionBlock: {error,  _ in
                        guard  error != nil else {
                           completion(true)
                           return
                        }
                           completion(false)
                       })
                   }
               })
        
    }
    // function to fetch all items
    func getAllItem( completion: @escaping (([Item]) -> Void)){
        var items = [Item]()
        self.database.child("items").observeSingleEvent(of: .value, with: {snapshot in
            if !snapshot.exists() {
                DispatchQueue.main.async {completion(items)}
            }else {
            for snap in snapshot.children {
                let Snap = snap as! DataSnapshot
                if Snap.key != "lastItem" {
                let itemsValues = Snap.value as! [[String:Any]]
                let itemValue = itemsValues[0]
                guard let id = itemValue["id"] as? String,
                let name = itemValue["name"] as? String,
                let isDone = itemValue["isDone"] as? Bool,
                let user = itemValue["user"] as? String,
                let url = itemValue["imageUrl"] as? String else {return}
                
                let oneItem = Item(id: id ,
                                   name: name,
                                   isDone: isDone,
                                   User: user,
                                   urlImage: url)
                items.append(oneItem)
                }//if
            }//for loop
            }//else
            DispatchQueue.main.async { completion(items)}
        })
    }
    //update item's name
         func updateItemName(name: String, id: String,completion: @escaping ((Bool) -> Void)) {
            self.database.child("items/\(id)/0/name").setValue(name , withCompletionBlock: {error , _ in
                if error == nil{
                    completion(true)
                    return
                }
                completion(false)
            })
           
        }
    // function to toggle the check mark
    func updateItemIsDone(isDone: Bool,id: String,completion: @escaping ((Bool) -> Void)){
        self.database.child("items/\(id)/0/isDone").setValue(!isDone , withCompletionBlock: {error , _ in
            if error == nil{
                completion(true)
                return
            }
            completion(false)
        })
    }
    // delete one item
    func deleteItem(id: String,completion: @escaping ((Bool) -> Void)) {
        self.database.child("items/\(id)").removeValue(completionBlock: {error,_  in
            if error != nil {
                completion(false)
               }
            DispatchQueue.main.async(){
                completion(true)
            }
        })
    }
    
    //function to obverv and update list items realtime
    func updateItems(completion: @escaping (([Item]) -> Void)){
        var returnItem : [Item] = []
        
        self.database.child("items/").observe(.value, with: { snapshot in
            if !snapshot.exists() {
                returnItem = []
                completion(returnItem)
            }else {
                returnItem = []
                for subSnap in snapshot.children {
                    let innerSnap = subSnap as! DataSnapshot
                        let itemsValues = innerSnap.value as! [[String:Any]]
                        let itemValue = itemsValues[0]
                        guard let id = itemValue["id"] as? String,
                              let name = itemValue["name"] as? String,
                              let isDone = itemValue["isDone"] as? Bool,
                              let user = itemValue["user"] as? String,
                              let url = itemValue["imageUrl"] as? String else {return}
                        
                        let oneItem = Item(id: id ,
                                           name: name,
                                           isDone: isDone,
                                           User: user,
                                           urlImage: url)
                        returnItem.append(oneItem)
                } //inner for
               
            }//else
            DispatchQueue.main.async {print("ghghg \(returnItem)")
                completion(returnItem)}
            
        })
        
    }
}

