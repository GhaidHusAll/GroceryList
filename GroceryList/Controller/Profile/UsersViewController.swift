//
//  UserViewController.swift
//  GroceryList
//
//  Created by administrator on 14/11/2021.
//

import UIKit
import JGProgressHUD
class UsersViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .light)

    @IBOutlet weak var usersTable: UITableView!
    var usersArray = [User]()
    let DB = DatabaseManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usersTable.dataSource = self
        self.usersTable.delegate = self
        //style
        style()
        
        DispatchQueue.main.async {
            self.spinner.show(in: self.view)
            self.getUsers()
        }
    }
  
    //for set the styles
    func style(){
        self.view.backgroundColor = UIColor(displayP3Red: 255/255, green: 152/255, blue: 210/255, alpha: 1)
        
        //NavBar
        self.title = "Family Grocery Users"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
               
    }
    func getUsers(){
        DB.getUsers(completion: {users in
            if users.count != 0 {
                DispatchQueue.main.async {
                self.usersArray = users
                self.usersTable.reloadData()
            }
        }
            self.spinner.dismiss()
        })
    }
}
extension UsersViewController :  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 1
      }
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 7
       }
       
       func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let headerView = UIView()
           headerView.backgroundColor = UIColor.clear
           return headerView
       }
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.usersArray.count
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usercell", for: indexPath)
        cell.textLabel?.text = usersArray[indexPath.section].userName
        //styles --cell--
        cell.textLabel!.font = UIFont(name:"Avenir", size:25)
        if usersArray[indexPath.section].isOnline {
            cell.backgroundColor =  UIColor(displayP3Red: 147/255, green: 255/255, blue: 96/255, alpha: 1)
            cell.textLabel?.tintColor = UIColor.black
        }else {
            cell.backgroundColor = UIColor.lightGray
            cell.textLabel?.tintColor = UIColor.gray
        }
        cell.layer.cornerRadius = cell.layer.frame.width / 13
        cell.clipsToBounds = true
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = cell.layer.frame.width / 13
        cell.clipsToBounds = true
       
     return cell
    }
}
