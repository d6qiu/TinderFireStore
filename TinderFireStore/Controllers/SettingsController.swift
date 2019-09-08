//
//  SettingsController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 9/7/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

   
    lazy var imageButtonLeft = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButtonRightTop = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButtonRightBot = createButton(selector: #selector(handleSelectPhoto))
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
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
        let picker = picker as? CustomImagePickerController
        //picker doesnt know which button is which, thats why u dont set the image using like imageButtonLeft.setImage
        picker?.imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        tableView.sectionIndexBackgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView() //list of item view
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
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
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 300
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc fileprivate func handleSave() {
        
    }
    
    @objc fileprivate func handleLogout() {
        
    }


}
