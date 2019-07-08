//
//  AuthViewController.swift
//  FireBase Demo
//
//  Created by mahmoud mohamed on 7/7/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class AuthViewController: UIViewController {
    
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    var verificationId:String!
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        configViews()
    }
    
    func configViews(){
        verificationCodeTextField.delegate = self
        phoneNumberTextField.layer.cornerRadius = 5
        verificationCodeTextField.layer.cornerRadius = 5
        verifyButton.layer.cornerRadius = 5
        setupNavBar()
    }
    
    func setupNavBar(){
        navigationItem.title = "Enter your Phone"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberTextField.text!, uiDelegate: nil) {[unowned self] (verificationId, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            print(verificationId!,"🚨")
            DispatchQueue.main.async {
                self.verificationId = verificationId
                self.verificationCodeTextField.isEnabled = true
            }
        }
    }
    
    func authenticate(verificationId:String,verificationCode:String){
        print(verificationCode)
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { (dataResult, error) in
            if error != nil{
                print("Error: ",error!.localizedDescription)
                self.ref.child("messages").childByAutoId().setValue("not Authenticated")
                return
            }
            self.ref.child("messages").childByAutoId().setValue("Authenticated")
            UserDefaults.standard.set(self.phoneNumberTextField.text!, forKey: "phoneNumber")
            DispatchQueue.main.async {
                let friendsListVC = FriendsViewController()
                self.navigationController?.pushViewController(friendsListVC, animated: true)
            }
            print("Authenticated 🌕")
        }
    }
    
}

extension AuthViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("entered")
        if string == " " || string == ""{
            return false
        }
        if textField.text!.count + string.count == 6 {
            print("Authenticating")
            let verificationCode = textField.text! + string
            authenticate(verificationId: self.verificationId, verificationCode: verificationCode)
        }
        return true
    }
}
