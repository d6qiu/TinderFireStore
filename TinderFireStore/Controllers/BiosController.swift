//
//  SettingsController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/7/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class BiosController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    


    var delegate: SettingsControllerDelegate?
    
    lazy var header: UIView = {
        let header = UIView()
        header.layer.opacity = 1
        header.backgroundColor = UIColor(white: 0.95, alpha: 1)
        header.addSubview(imageButtonLeft)
        let padding: CGFloat = 16
        imageButtonLeft.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        imageButtonLeft.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [imageButtonRightTop, imageButtonRightBot])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: imageButtonLeft.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
   
    lazy var imageButtonLeft = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButtonRightTop = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButtonRightBot = createButton(selector: #selector(handleSelectPhoto))
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }
    
    @objc func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        //picker doesnt know which button is which, thats why u dont set the image using like imageButtonLeft.setImage
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else {return}
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "uploading image..."
        hud.show(in: view)
        ref.putData(uploadData, metadata: nil) { (nil, err) in
            if let err = err {
                hud.dismiss()
                print(err)
                return
            }
            ref.downloadURL(completion: { (url, err) in
                hud.dismiss()
                if let err = err {
                    print(err)
                }
                
                if imageButton == self.imageButtonLeft {
                    self.user?.imageUrl = url?.absoluteString //gets data into cache then upload cache to firestore, ui is already updated for this once from the above code, user need save data by tapping save button
                } else if imageButton == self.imageButtonRightTop {
                    self.user?.imageUrl2 = url?.absoluteString
                } else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
                
            })
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView() //list of item view
        tableView.keyboardDismissMode = .interactive //when scrolls down in tableview, keyboard also scrolls down
        
        fetchCurrentUser()
    }
    
    var user: User?
    
    fileprivate func fetchCurrentUser() {
        //theres get documents and get document
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print(err)
                return
            }
            self.user = user
            self.loadUserPhotos()
            self.tableView.reloadData()
        }
        
    }
    
    fileprivate func loadUserPhotos() {
        if let imageUrl = user?.imageUrl, let url = URL(string: imageUrl) {
            //load image into cache known as the shared manager object
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.imageButtonLeft.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.imageButtonRightTop.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.imageButtonRightBot.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
    }
    
    
    //one section = one header + its tablerows
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { //
            return header
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking Age Range"
        }
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return headerLabel
    }
    //shrift label to left by 16
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300 //only want header for the photos dont want rows
        }
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return 1
    }
    
    static let defaultMinSeekingAge = 18
    static let defaultMaxSeekingAge = 50
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChanged), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChanged), for: .valueChanged)
            let minAge = user?.minSeekingAge ?? BiosController.defaultMinSeekingAge
            let maxAge = user?.maxSeekingAge ?? BiosController.defaultMaxSeekingAge
            ageRangeCell.minLabel.text = "Min \(minAge)"
            ageRangeCell.minSlider.value = Float(minAge)
            ageRangeCell.maxLabel.text = "Max \(maxAge)"
            ageRangeCell.maxSlider.value = Float(maxAge)
            return ageRangeCell
        }
        
        let cell = BioCell(style: .default, reuseIdentifier: nil) //not going to reuse any
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Enter Age"
            if let age = user?.age { //wont set the text is the age is nil
                cell.textField.text = String(age)
            }
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
        default:
            cell.textField.placeholder = "Enter Bio"
//            cell.textField.text = user?
        }
        return cell
    }
    
    @objc fileprivate func handleMinAgeChanged(slider: UISlider) {
        let indexpath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexpath) as! AgeRangeCell
        let minAge = slider.value
        let maxAge = ageRangeCell.maxSlider.value
        if minAge > maxAge {
            ageRangeCell.maxSlider.setValue(minAge, animated: true)
            ageRangeCell.maxLabel.text = "Max \(Int(minAge))"
            self.user?.maxSeekingAge = Int(minAge)
        }
        ageRangeCell.minLabel.text = "Min \(Int(slider.value))"
        self.user?.minSeekingAge = Int(slider.value)
        //evaluateMinMax()
    }
    
    @objc fileprivate func handleMaxAgeChanged(slider: UISlider) {
        let indexpath = IndexPath(row: 0, section: 5)
        let ageRangeCell = tableView.cellForRow(at: indexpath) as! AgeRangeCell
        let maxAge = slider.value
        let minAge = ageRangeCell.minSlider.value
        if maxAge < minAge {
            ageRangeCell.minSlider.setValue(maxAge, animated: true)
            ageRangeCell.minLabel.text = "Min \(Int(maxAge))"
            self.user?.minSeekingAge = Int(maxAge)
        }
        ageRangeCell.maxLabel.text = "Max \(Int(slider.value))"
        self.user?.maxSeekingAge = Int(slider.value)
//        evaluateMinMax()
    }
    
    //not using
    fileprivate func evaluateMinMax() {
        let ageRangeCell = tableView.cellForRow(at: [5,0]) as! AgeRangeCell
        let minAge = Int(ageRangeCell.minSlider.value)
        var maxAge = Int(ageRangeCell.maxSlider.value)
        maxAge = max(minAge, maxAge)
        ageRangeCell.maxSlider.value = Float(maxAge)
        ageRangeCell.minLabel.text = "Min \(minAge)"
        ageRangeCell.maxLabel.text = "Max \(maxAge)"
        user?.minSeekingAge = minAge
        user?.maxSeekingAge = maxAge
    }
    
    @objc fileprivate func handleNameChange(textField: UITextField) {
        self.user?.name = textField.text
    }
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "") //Int("") return nil
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain
            , target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        ]
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleSave() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData: [String: Any] = [
            "uid": uid,
            "fullName" : user?.name ?? "",
            "imageUrl": user?.imageUrl,
            "imageUrl2": user?.imageUrl2,
            "imageUrl3": user?.imageUrl3,
            "age": user?.age,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge,
            "maxSeekingAge": user?.maxSeekingAge
            
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving bio"
        hud.show(in: view) //show hud when click save
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            hud.dismiss() //dismiss hud when saved
            if let err = err {
                print(err)
                return
            }
            self.dismiss(animated: true, completion: {
                self.delegate?.didSaveSettings()
            })
        }
    }
    
    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut() //dont need try catch block if use try?
        dismiss(animated: true)
    }
    

    deinit {
        print("bioscontroller destroyed itself, no retain cycle")
    }

}
