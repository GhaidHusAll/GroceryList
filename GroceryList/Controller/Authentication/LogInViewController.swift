//
//  LogInViewController.swift
//  GroceryList
//
//  Created by administrator on 10/11/2021.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LogInViewController: UIViewController , GIDSignInUIDelegate  {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var MainStackView: UIStackView!
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var googleSignupBtn: UIButton!
    var loginobserver : NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        styles()
        // Do any additional setup after loading the view.
        loginobserver = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue:"LogInNotification"), object: nil, queue: .main, using:{ [weak self ]_ in
                    guard let strongSelf = self else {return}
                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                    //reload and enter the app after google sign in
                    self?.validateAuth()
                    
                })
       
    }
    // to remove and clear the notification when it's ends
       deinit {
           if let removeNotification = loginobserver {
               NotificationCenter.default.removeObserver(removeNotification)
               
           }
           print("after logg in")
       }
    func viewDidReceiveNotification(notification: Notification) -> Void
      {
          if (notification.name.rawValue == "LogInNotification")
          {
              print("Notification Received")
          }
      }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        validateAuth()
    }
   
    func styles(){
        //---btns--
        loginBtn.applyGradient()
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        signupBtn.applyGradient()
        signupBtn.layer.cornerRadius = 10
        signupBtn.clipsToBounds = true

        
        //---stackview---
        MainStackView.backgroundColor = UIColor.white
        MainStackView.layer.cornerRadius = MainStackView.frame.midX / 10
        MainStackView.layer.borderWidth = 1.0
        MainStackView.layer.borderColor = UIColor.init(red: 255/255, green: 152/255, blue: 210/255, alpha: 1).cgColor
        MainStackView.layer.shadowColor = UIColor.init(displayP3Red: 147/255, green: 255/255, blue: 96/255, alpha: 1).cgColor
        MainStackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        MainStackView.layer.shadowOpacity = 1.0
        MainStackView.layer.shadowRadius = 5.0
        
        //---lbls---
        passwordtxt.layer.cornerRadius = passwordtxt.frame.midX / 2
        passwordtxt.layer.shadowColor = UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1).cgColor
        passwordtxt.layer.shadowOffset = CGSize(width: 0, height: 0)
        passwordtxt.layer.shadowOpacity = 1.0
        passwordtxt.layer.shadowRadius = 5.0
        emailtxt.layer.cornerRadius = emailtxt.frame.midX / 2
        emailtxt.layer.shadowColor =  UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1).cgColor
        emailtxt.layer.shadowOffset = CGSize(width: 0, height: 0)
        emailtxt.layer.shadowOpacity = 1.0
        emailtxt.layer.shadowRadius = 5.0
        //---view---

        //---image---
        logoImage.layer.cornerRadius =  logoImage.frame.maxX / 2.7
        logoImage.clipsToBounds = true
       
    }

    @IBAction func toHome(_ sender: Any) {
        toLogIn()
    }
    
    @IBAction func toSignUp(_ sender: Any) {
        let addvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "register") as? SignUpViewController
                self.navigationController?.pushViewController(addvc!, animated: true)
    }
    
    @IBAction func googleSignUp(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // is user logged in
    private func validateAuth(){
            // current user is set automatically when you log a user in
            if FirebaseAuth.Auth.auth().currentUser != nil {
                let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "home") as? HomeListViewController
                self.navigationController?.pushViewController(mainvc!, animated: true)
            }
        }
    // function to log in
    func toLogIn(){
        if (emailtxt.text!.isEmpty || passwordtxt.text!.isEmpty){
            //alert
        }else {
            FirebaseAuth.Auth.auth().signIn(withEmail: self.emailtxt.text!, password: self.passwordtxt.text!, completion: { authResult, error in
                guard let result = authResult, error == nil else {
                    self.Alert(title: "Error Occur", message: "Failed to log in user with email \(String(describing: self.emailtxt.text))")
                    return
                }
                let user = result.user
                let defaults = UserDefaults.standard
                defaults.set(self.emailtxt.text, forKey: "Email")
                let mainvc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "home") as? HomeListViewController
                self.navigationController?.pushViewController(mainvc!, animated: true)
                print("logged in user: \(user)")
            })
        }
    }
    func Alert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            })))

            self.present(alert, animated: true, completion: nil)
          }
}
extension UIButton
{
    func applyGradient()
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1).cgColor,
            UIColor.init(red: 255/255, green: 152/255, blue: 210/255, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

