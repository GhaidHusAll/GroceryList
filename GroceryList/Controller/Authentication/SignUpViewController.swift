//
//  SignUpViewController.swift
//  GroceryList
//
//  Created by administrator on 10/11/2021.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import FirebaseStorage
import JGProgressHUD

class SignUpViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .light)
    @IBOutlet weak var MainStackView: UIStackView!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    let DBojc = DatabaseManger()
    override func viewDidLoad() {
        super.viewDidLoad()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
                singleTap.numberOfTapsRequired = 1
                profileImage.isUserInteractionEnabled = true
                profileImage.addGestureRecognizer(singleTap)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styles()
    }
    func styles(){
        //---btns--
        loginBtn.applyGradient()
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        signUpBtn.applyGradient()
        signUpBtn.layer.cornerRadius = 10
        signUpBtn.clipsToBounds = true

        
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
        fullNameTxt.layer.cornerRadius = fullNameTxt.frame.midX / 2
        fullNameTxt.layer.shadowColor =  UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1).cgColor
        fullNameTxt.layer.shadowOffset = CGSize(width: 0, height: 0)
        fullNameTxt.layer.shadowOpacity = 1.0
        fullNameTxt.layer.shadowRadius = 5.0
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
        profileImage.layer.cornerRadius =  profileImage.frame.maxX / 2.7
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 2
       
    }

    @IBAction func newAccount(_ sender: Any) {
        creatNewAcount()
    }
    
   
    @IBAction func backToLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // function to create new user account and check if all field are fill
    func creatNewAcount(){
        if (emailtxt.text!.isEmpty || passwordtxt.text!.isEmpty || fullNameTxt.text!.isEmpty){
            // please fill
            self.Alert(title: "Warning", message: "Please fill all the fields")

        }else {
            // check if the email already exist
            DBojc.userExists(with: emailtxt.text!, completion: {isExist in
                if isExist {
                    // email address exist
                    self.Alert(title: "Warning", message: "this Email Address already Exist")

                }else { //  creat
                    self.spinner.show(in: self.view)
                    FirebaseAuth.Auth.auth().createUser(withEmail: self.emailtxt.text! , password: self.passwordtxt.text!, completion: { authResult , error  in
                        guard let result = authResult, error == nil else {
                            self.Alert(title: "Error Occur", message: "\(error!.localizedDescription)")
                            return
                            }
                        print("created \(result)")
                        self.settheImage{ image in
                                               print(image)
                        let newUser = User(userName: self.fullNameTxt.text!,
                                           emailAddress: self.emailtxt.text!,
                                           isOnline: true, imageProfile: image)
                        self.DBojc.insertUser(with: newUser, completion: {isCreated in
                            if isCreated {
                                // to home
                                let defaults = UserDefaults.standard
                                defaults.set(self.emailtxt.text, forKey: "Email")
                                self.navigationController?.popViewController(animated: true)
                                self.spinner.dismiss()
                            }else {
                                //some error happiend
                                self.Alert(title: "Error Occur", message: "some error occur while creating you acount")
                                self.spinner.dismiss()
                                
                            }
                        })
                    }
                    })
                  
                }
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
    @objc func tapDetected() {
           presentPhotoActionSheet()
       }
    func settheImage(completion: @escaping ((String) -> Void)) {
            var urlImage = ""
            if let image = profileImage.image?.jpegData(compressionQuality: 0.5) {
                let storageRef = Storage.storage().reference().child("imagesProfile/\(fullNameTxt.text!)Image.png")
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

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
        self.profileImage.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
