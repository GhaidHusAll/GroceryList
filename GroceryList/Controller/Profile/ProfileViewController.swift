//
//  ProfileViewController.swift
//  GroceryList
//
//  Created by administrator on 12/11/2021.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import SDWebImage
import JGProgressHUD
import FirebaseStorage
class ProfileViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .light)
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var signoutBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNamelbl: UILabel!
    @IBOutlet weak var emaillbl: UILabel!
    let email =  UserDefaults.standard.string(forKey: "Email")
    let userName =  UserDefaults.standard.string(forKey: "name")
    let url =  UserDefaults.standard.string(forKey: "url")
    let DB = DatabaseManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUserInformation()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
                singleTap.numberOfTapsRequired = 1
                profileImageView.isUserInteractionEnabled = true
                profileImageView.addGestureRecognizer(singleTap)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styles()
    }
    func setUserInformation(){
        spinner.show(in: view)
        userNamelbl.text = userName
        emaillbl.text = email
        if !url!.isEmpty {
                    if  let url = URL(string: url!) {
                        DispatchQueue.main.async(){
                            self.profileImageView.sd_setImage(with: url, completed: nil)
                            self.spinner.dismiss()
                        }
                    }
                }else{
                    self.spinner.dismiss()
                    return
                }
    }
    @IBAction func signOut(_ sender: Any) {
        let alert = UIAlertController(title: "Sign Out", message: "Are Sure You Want ToSign Out from this account", preferredStyle: UIAlertController.Style.alert)
            alert.addAction((UIAlertAction(title: "Sign Out", style: .default, handler: { (action) -> Void in
                //google sign out from account
                    GIDSignIn.sharedInstance().signOut()
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    let defaults = UserDefaults.standard
                    defaults.set("", forKey: "Email")
                    if let navController = self.navigationController {
                                    navController.popToRootViewController(animated: true)
                                }
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
    
    func styles(){
        //---btns--
        signoutBtn.applyGradient()
        signoutBtn.layer.cornerRadius = 10
        signoutBtn.clipsToBounds = true
        

        
        //---stackview---
        mainStackView.backgroundColor = UIColor.white
        mainStackView.layer.cornerRadius = mainStackView.frame.midX / 10
        mainStackView.layer.borderWidth = 1.0
        mainStackView.layer.borderColor = UIColor.init(red: 255/255, green: 152/255, blue: 210/255, alpha: 1).cgColor
        mainStackView.layer.shadowColor = UIColor.init(displayP3Red: 147/255, green: 255/255, blue: 96/255, alpha: 1).cgColor
        mainStackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        mainStackView.layer.shadowOpacity = 1.0
        mainStackView.layer.shadowRadius = 5.0
        
        //---lbls---
        userNamelbl.layer.cornerRadius = userNamelbl.frame.midX / 2
        userNamelbl.layer.shadowColor =  UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1).cgColor
        userNamelbl.layer.shadowOffset = CGSize(width: 0, height: 0)
        userNamelbl.layer.shadowOpacity = 1.0
        userNamelbl.layer.shadowRadius = 5.0
        emaillbl.layer.cornerRadius = emaillbl.frame.midX / 2
        emaillbl.layer.shadowColor =  UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1).cgColor
        emaillbl.layer.shadowOffset = CGSize(width: 0, height: 0)
        emaillbl.layer.shadowOpacity = 1.0
        emaillbl.layer.shadowRadius = 5.0
       
        //---view---
        self.view.backgroundColor = UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1)

        //---image---
        profileImageView.layer.cornerRadius =  profileImageView.frame.maxX / 2.7
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.black.cgColor
       
    }
    
    func Alert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            })))

            self.present(alert, animated: true, completion: nil)
          }
@objc func tapDetected() {
     presentPhotoActionSheet()
 }
func settheImage(completion: @escaping ((String) -> Void)) {
      var urlImage = ""
      if let image = profileImageView.image?.jpegData(compressionQuality: 0.5) {
          let storageRef = Storage.storage().reference().child("imagesProfile/\(userName!)Image.png")
          storageRef.putData(image, metadata: nil, completion: {(matedata , error) in
              if error != nil {
                  print("errpr  \(String(describing: error?.localizedDescription))")
                  self.Alert(title: "Some Error Accur", message:  "Profile Image could not be uploaded")
              }else {
                  storageRef.downloadURL(completion: { (url, error) in
                      DispatchQueue.main.async(){ urlImage = url!.absoluteString
                          completion(urlImage)}
                  })
              }
          })
      }else {completion(urlImage)}
  }

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take a photo or select a photo
        
        // action sheet - take photo or choose photo
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.profileImageView.image = selectedImage
        self.settheImage{ image in
            self.spinner.show(in: self.view)
            if let guardemail = self.email {
                self.DB.updateUserImage(image: image, email: guardemail){ isDone in
                    if isDone {
                        return
                    }else {
                        self.Alert(title: "Some Error Accur", message:  "Profile Image could not be uploaded")
                    }
                }
                self.spinner.dismiss()
            }
            
        }
        
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
