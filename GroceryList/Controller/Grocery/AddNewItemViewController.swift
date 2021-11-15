//
//  AddNewItemViewController.swift
//  GroceryList
//
//  Created by administrator on 11/11/2021.
//

import UIKit
import JGProgressHUD
import FirebaseStorage
import SDWebImage
class AddNewItemViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .light)

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNamelbl: UITextField!
    @IBOutlet weak var AddEditBtn: UIButton!
    @IBOutlet weak var mainStackView: UIStackView!
    var userName = UserDefaults.standard.string(forKey: "name")
    var isEdit = false
    var item = Item(id: "",
                    name: "",
                    isDone: false,
                    User: "",
                    urlImage: "")
    let DBojc = DatabaseManger()

    override func viewDidLoad() {
        super.viewDidLoad()
        if isEdit {
            itemNamelbl.text = item.name
            let theUrl = item.urlImage ?? " "
            if  let url = URL(string: theUrl) {
                DispatchQueue.main.async(){
                    self.itemImageView.sd_setImage(with: url, completed: nil)
                    self.spinner.dismiss()
                }
            }
        }else{
            self.navigationItem.rightBarButtonItem = nil
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapDetected))
                    singleTap.numberOfTapsRequired = 1
                    itemImageView.isUserInteractionEnabled = true
                    itemImageView.addGestureRecognizer(singleTap)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styles()
        DispatchQueue.main.async {
           
            if self.isEdit {
                self.AddEditBtn.setTitle("Edit", for: UIControl.State.normal)
            }
        }
       
    }
   
    @IBAction func deleteCliecked(_ sender: Any) {
        // ask if sure
        let alert = UIAlertController(title: "Delete Item", message: "Are Sure You Want To Delete This Item", preferredStyle: UIAlertController.Style.alert)
            alert.addAction((UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
                self.DBojc.deleteItem(id: self.item.id, completion: {isDeleted in
                    if !isDeleted {
                       
                        //failed to delete
                        self.Alert(title: "Some Error Occur", message: "Item Did Not Deleted Try Some Time")
                    }
                })
                self.navigationController!.popViewController(animated: true)
                alert.dismiss(animated: true, completion: nil)
            })))
        alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
            self.present(alert, animated: true, completion: nil)
          
       
    }
    @IBAction func AddEditCliecked(_ sender: Any) {
        if itemNamelbl.text!.isEmpty{
            // please fill fields
            Alert(title: "Can't Add New Item", message: "Please Fill All Fields")
        }else {
            spinner.show(in: self.view)
            if !isEdit {
                //add
                let iditem = UUID().uuidString
                self.settheImage(id:iditem ,completion: { image in
                    let newitem = Item(id: iditem, name: self.itemNamelbl.text!, isDone: false, User: self.userName!, urlImage: image)
                    self.DBojc.addItem(item: newitem, completion: { isSaved in
                    if !isSaved{
                        //some error occur
                        self.Alert(title: "Some Error Occur", message: "Item Did Not Saved Try Some Time")
                        return
                    }
                })
                    self.spinner.dismiss()
                    self.navigationController!.popViewController(animated: true)
                })
              
            
            }else {
                //edit
                DBojc.updateItemName(name: itemNamelbl.text!, id: item.id, completion: {isUpdted in
                    if !isUpdted {
                        // not able to update
                        self.Alert(title: "Some Error Occur", message: "Item Did Not Updated Try Some Time")

                    }
                })
                self.spinner.dismiss()
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    //Alert warining function
    func Alert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            })))

            self.present(alert, animated: true, completion: nil)
          }
    func styles(){
        //---btns--
        AddEditBtn.applyGradient()
        AddEditBtn.layer.cornerRadius = 10
        AddEditBtn.clipsToBounds = true
       


        
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
        itemNamelbl.layer.cornerRadius = itemNamelbl.frame.midX / 2
        itemNamelbl.layer.shadowColor =  UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1).cgColor
        itemNamelbl.layer.shadowOffset = CGSize(width: 0, height: 0)
        itemNamelbl.layer.shadowOpacity = 1.0
        itemNamelbl.layer.shadowRadius = 5.0
       
        //---view---
        self.view.backgroundColor = UIColor.init(red: 255/255, green: 222/255, blue: 43/255, alpha: 1)

        //---image---
        itemImageView.layer.cornerRadius =  itemImageView.frame.maxX / 2.7
        itemImageView.clipsToBounds = true
        itemImageView.layer.borderWidth = 4
        itemImageView.layer.borderColor = UIColor.black.cgColor
       
    }

    @objc func tapDetected() {
           presentPhotoActionSheet()
       }
    func settheImage(id:String ,completion: @escaping ((String) -> Void)) {
            var urlImage = ""
            if let image = itemImageView.image?.jpegData(compressionQuality: 0.5) {
                let storageRef = Storage.storage().reference().child("imagesItems/\(id)Image.png")
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
extension AddNewItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
        self.itemImageView.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
