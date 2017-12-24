//
//  LoginScreenViewController.swift
//  Travlr
//
//  Created by Ryan Ching on 5/21/17.
//  Copyright © 2017 Ryan Ching. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginScreenViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func goToRegisterScreen(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "register")
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tryAutoLogin()
        //gestures to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterScreenViewController.dismissKeyboard))
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector (RegisterScreenViewController.dismissKeyboard))
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector (RegisterScreenViewController.dismissKeyboard))
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)  // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        view.addGestureRecognizer(swipe)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tryAutoLogin(){
        let defaults = UserDefaults.standard
        if(defaults.object(forKey: "username") != nil && defaults.object(forKey: "password") != nil){
            let username = defaults.object(forKey: "username")!
            let password = defaults.object(forKey: "password")!
            Auth.auth().signIn(withEmail: username as! String, password: password as! String) { (user, error) in
                if error != nil {
                    //error logging in
                    let alert = UIAlertController(title: "Error", message: "Incorrect username or password", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    //success
                    let defaults = UserDefaults.standard
                    defaults.set(username, forKey: "username")
                    defaults.set(password, forKey: "password")
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabs")
                    self.present(nextViewController, animated:true, completion:nil)
                    
                }
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        var username = usernameTextField.text;
        username = username! + "@email.com"
        let password = passwordTextField.text;
        Auth.auth().signIn(withEmail: username!, password: password!) { (user, error) in
            if error != nil {
                //error logging in
                let alert = UIAlertController(title: "Error", message: "Incorrect username or password", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                //success
                let defaults = UserDefaults.standard
                defaults.set(username, forKey: "username")
                defaults.set(password, forKey: "password")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabs")
                self.present(nextViewController, animated:true, completion:nil)
                
            }
        }
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
        view.endEditing(true)
    }

}
