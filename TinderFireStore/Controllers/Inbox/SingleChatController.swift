//
//  ChatLogController.swift
//  TinderFireStore
//
//  Created by wenlong qiu on 10/1/19.
//  Copyright © 2019 wenlong qiu. All rights reserved.
//

import UIKit
import Firebase


class MessageCell: ListCell<Message> {
    
    let textBoba = UIView(backgroundColor: #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1), opacity: 1)
    
    var anchoredConstraints: AnchoredConstraints!
    
    
    //uilabels are vertical center aligned.
    let textView : UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    override var item: Message! {
        didSet {
            textView.text =  item.text
            if item.isUserText {
                //stick to right
                self.anchoredConstraints.trailing?.isActive = true
                self.anchoredConstraints.leading?.isActive = false
                textBoba.backgroundColor = #colorLiteral(red: 0, green: 0.7427282333, blue: 1, alpha: 1)
                textView.textColor = .white
            } else {
                //stick to left
                self.anchoredConstraints.trailing?.isActive = false
                self.anchoredConstraints.leading?.isActive = true
                textBoba.backgroundColor = #colorLiteral(red: 0.8861967325, green: 0.8863244653, blue: 0.8861687779, alpha: 1)
                textView.textColor = .black
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        addSubview(textBoba)
        textBoba.layer.cornerRadius = 12
        self.anchoredConstraints = textBoba.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        self.anchoredConstraints.leading?.constant = 20 //padding 20 from left
        self.anchoredConstraints.trailing?.constant = -20// padding 20 from right
        
        
        self.textBoba.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true //return the max width the textView will use
        self.textBoba.addSubview(textView)
        self.textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))
    }
    
    
    
}

class SingleChatController: ListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout{
    
    
    fileprivate let navBarHeight:CGFloat = 120
    
    fileprivate let match: Match
        
    fileprivate lazy var singleChatNavBar = SingleChatNavBar(match: match)

    
    init(match: Match) {
        self.match = match //if there is a super class, in init, must initialize all instance variables before calling super.init()
        super.init()
        
    }
    
    
    lazy var kbInputView: ChatInputAccessView = {
        let kbi = ChatInputAccessView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        kbi.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return kbi
    }()
    
    fileprivate func saveToMatchesMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        let collection = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid)
        
        let data = ["text": kbInputView.textView.text ?? "", "fromId": currentUserId, "toId": match.uid, "timestamp": Timestamp(date:Date())] as [String: Any]
        
        //auto document id genereated when adddocument
        collection.addDocument(data: data) { (err) in
            if let err = err {
                print(err)
                return
            }
            self.kbInputView.textView.text = ""
            self.kbInputView.placeHolderLabel.isHidden = false
            
        }
        
        let toCollection = Firestore.firestore().collection("matches_messages").document(match.uid).collection(currentUserId)
        
        toCollection.addDocument(data: data) { (err) in
            if let err = err {
                print(err)
                return
            }
            self.kbInputView.textView.text = ""
            self.kbInputView.placeHolderLabel.isHidden = false
            
        }
    }
    
    @objc fileprivate func handleSend() {
        saveToMatchesMessages()
        saveToRecentMessages()
    }
    
    fileprivate func saveToRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        let data = ["text": kbInputView.textView.text ?? "", "name": match.name, "profileImageUrl": match.profileImageUrl, "timestamp": Timestamp(date: Date()), "uid": match.uid] as [String:Any]
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").document(match.uid).setData(data) { (err) in
            if let err = err {
                print(err)
                return
            }
        }
        
        guard let currentUser = self.currentUser else {return}
        
        let otherData =  ["text": kbInputView.textView.text ?? "", "name": currentUser.name, "profileImageUrl": currentUser.imageUrl, "timestamp": Timestamp(date: Date()), "uid": currentUserId] as [String:Any]
        Firestore.firestore().collection("matches_messages").document(match.uid).collection("recent_messages").document(currentUserId).setData(otherData) { (err) in
            if let err = err {
                print(err)
                return
            }
        }
        
    }
    
    //input accessory view
    override var inputAccessoryView: UIView? {
        get {
            return kbInputView
        }
    }
    
     //whenever user interact with ui element, that element become first responder, canBecomefirstresponder lets self.view can become first responders so from the documentation: When the receiver subsequently becomes the first responder, the responder infrastructure attaches the view to the appropriate input view before displaying it, ,if you set canbecomefirst reponder return false, accessroyr view wont show up, self.view instantly becomes the first responder when first switch to this view, then responder infrastructure attaches the redview to the input view (keyboard ?)
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    fileprivate func fetchMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {return}
        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid).order(by: "timestamp")
        
        query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ (change) in
                if change.type == .added {
                    let dictionary = change.document.data()
                    self.items.append(.init(dictionary: dictionary))
                }
            })
            self.collectionView.reloadData()
            //scroll to last message everytime add a message
            self.collectionView.scrollToItem(at: [0, self.items.count - 1], at: .bottom, animated: true)
        }
        
//        query.getDocuments { (querySnapshot, err) in
//            if let err  = err {
//                print(err)
//                return
//            }
//            querySnapshot?.documents.forEach({ (documentSnapshot) in
//                self.items.append(Message.init(dictionary: documentSnapshot.data()))
//            })
//
//            //can put this is becasue foreach dont have a completion block unlike getDocuments
//            self.collectionView.reloadData()
//        }
    }
    
    @objc fileprivate func handleKeyboardShow() {
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    var currentUser: User?
    
    fileprivate func fetchCurrentUser() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (snapshot, err) in
            let data = snapshot?.data() ?? [:]
            self.currentUser = User(dictionary: data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchCurrentUser() //since seted by matchespoolcontroller or homecontroller
        
        //everytiume keyboad shows scroll to the last message, need remove observer
        //NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        
        collectionView.keyboardDismissMode = .interactive
        
        fetchMessages()
        collectionView.alwaysBounceVertical = true //boucing animation when scroll down to end
        view.addSubview(singleChatNavBar)
        singleChatNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: navBarHeight))
        collectionView.contentInset.top = navBarHeight //move collection view's content down to leave space for messageNavBar
        collectionView.scrollIndicatorInsets.top = navBarHeight //shift scroll indicator down so it aligns with collection view content
        
        singleChatNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        //fix bug where view goes over and cover up status bar when scroll up
        let statusBarCover = UIView(backgroundColor: .white, opacity: 1)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    //so collectionview content below shadow
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let guessSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))
        guessSizeCell.item = items[indexPath.item]
        guessSizeCell.layoutIfNeeded() //layout the setupviews in message cells, refresh cell
        
        let guessSize = guessSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        
        return .init(width: view.frame.width, height: guessSize.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
