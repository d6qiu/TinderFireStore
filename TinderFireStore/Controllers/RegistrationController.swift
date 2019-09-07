//
//  RegistrationController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 8/30/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class RegistrationController: UIViewController {

    //Size classes don’t cover the difference between iPad Portrait and Landscape: they both have Regular Width and Regular Height.
    override public var traitCollection: UITraitCollection {
        
        if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isPortrait {
            return UITraitCollection(traitsFrom:[UITraitCollection(verticalSizeClass: .regular), UITraitCollection(horizontalSizeClass: .compact)])
        } else if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape {
            return UITraitCollection(traitsFrom:[UITraitCollection(verticalSizeClass: .compact), UITraitCollection(horizontalSizeClass: .regular)])
        }
        return super.traitCollection
    }
    
    let selectPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 275).isActive = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()
    
    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    let fullNameTextField: UITextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter full name"
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = CustomTextField(padding: 16)
        tf.placeholder = "Enter Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    //captures sender as parameter
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == fullNameTextField {
            registrationViewModel.fullName = textField.text
        } else if textField == emailTextField {
            registrationViewModel.email = textField.text
        } else {
            registrationViewModel.password = textField.text //changes model properties triggers check validity and update in UI
        }
 
    }
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.gray, for: .disabled) //disable means the drawing looks disabled
        button.isEnabled = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .lightGray
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()
    
    
    let registeringHUD = JGProgressHUD(style: .dark)
    
    @objc fileprivate func handleRegister() {
        self.handleTapDismiss()
        

        registrationViewModel.performRegistration { [weak self](err) in //unown is fine also
            if let err = err {
                print(err)
                self?.showHUDWithError(error: err)
                return
            }
            print("registering user complete ")
        }
    }
    
    fileprivate func showHUDWithError(error: Error) {
        registeringHUD.dismiss()
        let errorHud = JGProgressHUD(style: .dark)
        errorHud.textLabel.text = "Failed registration"
        errorHud.detailTextLabel.text = error.localizedDescription
        errorHud.show(in: self.view)
        errorHud.dismiss(afterDelay: 4) //dimiss after 4 seconds
        
    }
    
    
    lazy var verticalStackView: UIStackView = {
       let sv = UIStackView(arrangedSubviews: [
        fullNameTextField,
        emailTextField,
        passwordTextField,
        registerButton
        ])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    lazy var overallStackView = UIStackView(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
        ])
    
    let gradientLayer = CAGradientLayer()

    
    override func viewDidLoad() { //self existed when viewDidLoad is called
        super.viewDidLoad()
        
        setupGradientLayer()
        
        setupLayout()
        setupNotificationObservers()
        setupTapGesture()
        
        setupRegistrationViewModelObserver()
    }
    
    
    // MARK:- Pirvate
    
    let registrationViewModel = RegistrationViewModel()
    //set up reactors to viewmodel value changes 
    fileprivate func setupRegistrationViewModelObserver() {
        registrationViewModel.bindableIsFormValid.observer = { [unowned self](isFormValid) in //self is never nil in this closure because needs self to trigger change of value in model in the first place
            guard let isFormValid = isFormValid else {return}
            if isFormValid {
                self.registerButton.isEnabled = true
                self.registerButton.backgroundColor = #colorLiteral(red: 0.8202926517, green: 0.1025385633, blue: 0.3201393485, alpha: 1)
                self.registerButton.setTitleColor(.white, for: .normal)
            } else {
                self.registerButton.isEnabled = false
                self.registerButton.backgroundColor = .lightGray
                self.registerButton.setTitleColor(.gray, for: .normal)
            }
        }
        registrationViewModel.bindableImage.observer = { [unowned self](image) in
            self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        registrationViewModel.binadableIsRegistering.observer = { [unowned self](isRegistering) in
            guard let isRegistering = isRegistering else {return}
            if isRegistering {
                self.registeringHUD.textLabel.text = "Register"
                self.registeringHUD.show(in: self.view)
            } else {
                self.registeringHUD.dismiss() //dismiss when complete register
            }
        }
    }
    
    fileprivate func setupTapGesture() {
        //add recignizer on view, wont trigger on ui elements such as buttons and textfields
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }
    //dismiss keyboard
    @objc fileprivate func handleTapDismiss() {
        view.endEditing(true)
        //scroll view back down
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil) //object refers to sender of the notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyBoardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self) //avoid retain cycles
    }
    //not sure why this is needed
    @objc fileprivate func handleKeyBoardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    @objc fileprivate func handleKeyBoardShow(notification: Notification) {
        //print(notification.userInfo)
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = value.cgRectValue
        
        let bottomSpace = view.frame.height - overallStackView.frame.origin.y - overallStackView.frame.height //origin is top left corner coodinate
        
        let difference = keyboardFrame.height - bottomSpace
        self.view.transform = CGAffineTransform(translationX: 0, y: -difference - 8) // goal is to have keyboard to be right below register button, keyboard frame will overlap with bottom space+
        
        
    }
    
    fileprivate func setupLayout() {
        
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        selectPhotoButton.widthAnchor.constraint(equalToConstant: 275).isActive = true
        overallStackView.spacing = 8
        overallStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        overallStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9791890979, green: 0.3768676519, blue: 0.3662195504, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8867455125, green: 0.1123541966, blue: 0.4557753205, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor] //has to be cgcolor
        gradientLayer.locations = [0,1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds //gradientLayer superview is view.layer, so gradient's coordiante is the same as view's own coordinate
    }
    //calls this when view changes bounds ie when change land scape
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds //reset frame when change land scape, change gradient frame to horizotal rectangle
    }
    
    //when changes landscape, both works, traitcollection dont work with ipad, but fixed with overrriding traitcollection
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.verticalSizeClass == .compact { //portrait verticalsize class is regular, landscape verticalsize class is compact, ipad is always regular regardless of orientation
            overallStackView.axis = .horizontal
        } else {
            overallStackView.axis = .vertical
        }
    }
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransition(to: size, with: coordinator)
    //        if UIDevice.current.orientation.isLandscape {
    //            overallStackView.axis = .horizontal
    //        } else if UIDevice.current.orientation.isPortrait {
    //            overallStackView.axis = .vertical
    //        } else {
    //            overallStackView.axis = .vertical
    //        }
    //    }
    

}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        //needs renderingmode when image is blue template
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
