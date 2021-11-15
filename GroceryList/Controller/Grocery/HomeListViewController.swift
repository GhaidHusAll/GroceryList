//
//  HomeListViewController.swift
//  GroceryList
//
//  Created by administrator on 10/11/2021.
//

import UIKit
import SideMenu
import JGProgressHUD
import FirebaseAuth
import GoogleSignIn
import Network

import FirebaseDatabase
class HomeListViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .light)
    var menu : SideMenuNavigationController?
    @IBOutlet weak var groceryTable: UITableView!
    var email = UserDefaults.standard.string(forKey: "Email")
    var ItemArray = [Item]()
    var userOnlineCount = 0
    let DBojc = DatabaseManger()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        menu = SideMenuNavigationController(rootViewController: MenuTableView())
        menuSetUp()
        DispatchQueue.main.async {
            self.updateList()
            self.updateUsersCount()
        }
      //table delegate and source
        self.groceryTable.delegate = self
        self.groceryTable.dataSource = self
        
        //
        validateAuth()
        style()
        // network connection
        NetConnection()
    }
   
    // is user logged in
    private func validateAuth(){
            // current user is set automatically when you log a user in
            if FirebaseAuth.Auth.auth().currentUser == nil {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    // internet connection
    func NetConnection(){
       let moniter = NWPathMonitor()
        moniter.pathUpdateHandler = {path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    //connected
                    self.DBojc.connectionUpdateIsOnline(email: self.email!, status: true)
                }
            }else{
                DispatchQueue.main.async {
                    //not connected
                    self.DBojc.connectionUpdateIsOnline(email: self.email!, status: false)
                }
            }
        }
        let queue = DispatchQueue(label: "Network")
        moniter.start(queue: queue)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        validateAuth()
        DispatchQueue.main.async {
            self.spinner.show(in: self.view)
            self.spinner.textLabel.text = "Loading"
            self.fetchData()
            self.fetchAllItem()
        }
    }
   
    //for set the styles
    func style(){
        self.view.backgroundColor = UIColor(displayP3Red: 255/255, green: 152/255, blue: 210/255, alpha: 1)
        
        //NavBar
        self.title = "Family Grocery List"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
               
               changeCount()
           
    }
    func changeCount() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: " \(userOnlineCount)", style: .plain, target: nil,
                                                            action: #selector(self.ToUsersViewController))
    }
    @objc func ToUsersViewController() {
        let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "users") as? UsersViewController
        self.navigationController?.pushViewController(mainvc!, animated: true)
         
    }
    func updateUsersCount(){
        DBojc.updateUsers(completion: { [weak self] usersOnline in
            guard let strongSelf = self else {return}
            if  usersOnline.count != 0 {
                strongSelf.userOnlineCount = 0
                for user in usersOnline {
                    if user.isOnline{
                        strongSelf.userOnlineCount += 1
                    }
                }
                DispatchQueue.main.async {
                    strongSelf.changeCount()
            }
            }
        })
    }
    // set the menu
    func menuSetUp(){
        menu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
    }
    @IBAction func didTapMenu(){
        present(menu!, animated: true)
           }
}
extension HomeListViewController :  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 1
      }
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 10
       }
       
       func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let headerView = UIView()
           headerView.backgroundColor = UIColor.clear
           return headerView
       }
    func numberOfSections(in tableView: UITableView) -> Int {
           return self.ItemArray.count
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GroceryItemTableViewCell
         let theurl = ItemArray[indexPath.section].urlImage ?? " "
        cell.setCellValues(ItemName: ItemArray[indexPath.section].name, UserName: ItemArray[indexPath.section].User , url: theurl)
        //styles --cell--
        //cell.backgroundColor = UIColor.clear
        
        cell.contentView.layer.cornerRadius = cell.contentView.layer.frame.width / 15
        cell.contentView.clipsToBounds = true
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = cell.layer.frame.width / 15
        cell.clipsToBounds = true
       
     return cell
    }
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }
   
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let checkAction = UIContextualAction(style: .normal, title:  nil, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            //my check method
//            self.DBojc.updateItemIsDone(isDone: self.ItemArray[indexPath.section].isDone,
//                                        id: self.ItemArray[indexPath.section].id
//                                        , completion: { isDone in
//                                            if !isDone {
//                                                let alert = UIAlertController(title: "Some Error Occur", message: "Could not CheckMark The Item", preferredStyle: UIAlertController.Style.alert)
//                                                    alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
//                                                        alert.dismiss(animated: true, completion: nil)
//                                                    })))
//
//                                                    self.present(alert, animated: true, completion: nil)
//
//                                            }
//                                        })
//                success(true)
//            })
//        if self.ItemArray[indexPath.section].isDone  {
//            checkAction.image = UIImage(named: "checkmark")?.withTintColor(UIColor.green)
//                debugPrint("marked")
//                self.groceryTable.reloadData()
//               } else {
//                debugPrint("unMarked")
//                checkAction.image = UIImage(named: "checkmark")?.withTintColor(UIColor.gray)
//                self.groceryTable.reloadData()
//               }
//        print("++++ \(ItemArray[indexPath.section].name)")
//        checkAction.backgroundColor =  UIColor(displayP3Red: 255/255, green: 152/255, blue: 210/255, alpha: 1)
//        let configuration = UISwipeActionsConfiguration(actions: [checkAction])
//        configuration.performsFirstActionWithFullSwipe = true
//        return configuration
//    }
    func swipeCellButtons(color:Bool) -> UIImage
     {
        

         UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, UIScreen.main.scale)
         let context = UIGraphicsGetCurrentContext()
         context!.setFillColor(UIColor(displayP3Red: 255/255, green: 152/255, blue: 210/255, alpha: 1).cgColor)
        context!.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        if color {
            let img: UIImage = UIImage(named: "checkmark")!.withTintColor(UIColor.green)
            img.draw(in: CGRect(x: 5, y: 15, width: 60, height: 60))
        }else{
        let img: UIImage = UIImage(named: "checkmark")!.withTintColor(UIColor.gray)
            img.draw(in: CGRect(x: 5, y: 15, width: 60, height: 60))
        }
        
         let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
         UIGraphicsEndImageContext()

         return newImage
     }


    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let myButton = UITableViewRowAction(style: .normal, title: "") {
            action, index in
            //my check method
            self.DBojc.updateItemIsDone(isDone: self.ItemArray[indexPath.section].isDone,
                                        id: self.ItemArray[indexPath.section].id
                                        , completion: { isDone in
                                            if !isDone {
                                                let alert = UIAlertController(title: "Some Error Occur", message: "Could not CheckMark The Item", preferredStyle: UIAlertController.Style.alert)
                                                    alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                                        alert.dismiss(animated: true, completion: nil)
                                                    })))

                                                    self.present(alert, animated: true, completion: nil)

                                            }
                                        })
        }

        if self.ItemArray[indexPath.section].isDone  {
        let patternImg = swipeCellButtons(color: true)
        myButton.backgroundColor = UIColor(patternImage: patternImg)
        }else {
            let patternImg = swipeCellButtons(color: false)
            myButton.backgroundColor = UIColor(patternImage: patternImg)
        }
        return [myButton]
    }
   

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "addItem") as? AddNewItemViewController
        addvc?.isEdit = true
        addvc?.item = self.ItemArray[indexPath.section]
        self.navigationController?.pushViewController(addvc!, animated: true)
               
           
    }
    func fetchAllItem(){
        DBojc.getAllItem(completion: { items in
            self.ItemArray = items
            self.groceryTable.reloadData()
            self.spinner.dismiss()
        })
    }
    // fetch user data
    func fetchData(){
        DBojc.getUser(email: email!, completion: {user in
            let defaults = UserDefaults.standard
            defaults.set(user.userName, forKey: "name")
            defaults.set(user.isOnline, forKey: "isOnline")
            defaults.set(user.imageProfile, forKey: "url")

        })
        
    }
    // update the grocery list realtime
    func updateList(){
        DBojc.updateItems(completion: { [weak self] newItem in
            guard let strongSelf = self else {return}
            print(newItem.count)
            if  newItem.count != 0 {

                DispatchQueue.main.async {
                strongSelf.ItemArray = newItem
                print("------- in update func \(newItem)")
                strongSelf.groceryTable.reloadData()
            }
            }
        })
    }
    func logOutFromHome(){
        if let navController = self.navigationController {
                        navController.popToRootViewController(animated: true)
                    }
    }
}
// class to set the menu items in table view
class  MenuTableView : UITableViewController  {
    var MenuItems = ["Profile","Users" , "Add Grocery" , "Exit"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")
       
    }
     func popMainVc() {
        print("in will disapper1")
        if let homevc = presentingViewController as? HomeListViewController {
                        print("in will disapper")
                       homevc.viewDidLoad()
                      
                }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.textLabel?.text = MenuItems[indexPath.row]
        
        //styles --cell--
        cell.backgroundColor = UIColor.clear
     return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "profile") as? ProfileViewController
            self.navigationController?.pushViewController(mainvc!, animated: true)
        } else if indexPath.row == 1 {
            let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "users") as? UsersViewController
            self.navigationController?.pushViewController(mainvc!, animated: true)
              
        }
        else if indexPath.row == 2 {
            print("in add")
            let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "addItem") as? AddNewItemViewController
            self.navigationController?.pushViewController(mainvc!, animated: true)
        } else if indexPath.row == 3 {
            // ask if sure
            let alert = UIAlertController(title: "Sign Out", message: "Are Sure You Want ToSign Out from this account", preferredStyle: UIAlertController.Style.alert)
                alert.addAction((UIAlertAction(title: "Sign Out", style: .default, handler: { (action) -> Void in
                    //google sign out from account
                        GIDSignIn.sharedInstance().signOut()
                    do {
                        try FirebaseAuth.Auth.auth().signOut()
                        let defaults = UserDefaults.standard
                        defaults.set("", forKey: "Email")
                        self.dismiss(animated: true, completion: {
                            self.popMainVc()
                        })
                        
                       
                    }
                    catch {
                    }
                    alert.dismiss(animated: true, completion: nil)
                })))
            alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            })))
                self.present(alert, animated: true, completion: nil)
        }
    }
}

