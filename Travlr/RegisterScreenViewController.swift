//
//  RegisterScreenViewController.swift
//  Travlr
//
//  Created by Ryan Ching on 5/21/17.
//  Copyright © 2017 Ryan Ching. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
class RegisterScreenViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //gestures to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterScreenViewController.dismissKeyboard))
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector (RegisterScreenViewController.dismissKeyboard))
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector (RegisterScreenViewController.dismissKeyboard))
     
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)  // Allows dismissal of keyboard on tap anywhere on screen besides the keyboard itself
        view.addGestureRecognizer(swipe)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func register(_ sender: Any) {
        var username = usernameTextField.text;
        let password = passwordTextField.text;
        let confirmPassword = confirmPasswordTextField.text;
        if username!.characters.count < 1 {
            let alert = UIAlertController(title: "Error", message: "Username must be at least 1 character", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if password!.characters.count < 6{
            let alert = UIAlertController(title: "Error", message: "Password must be at least 6 character", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if username!.range(of: "@") != nil{
            let alert = UIAlertController(title: "Error", message: "Username cannot contain the @ symbol", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if password != confirmPassword{
            let alert = UIAlertController(title: "Error", message: "Please ensure the password fields match", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            username = username! + "@email.com"
            
            Auth.auth().createUser(withEmail: username!, password: password!, completion: { (user, error) in
                if error != nil {
                    //error creating account
                    var errorMessage = error?.localizedDescription
                    if errorMessage == "The email address is already in use by another account." {
                        errorMessage = "This username is already in use by another account."
                    }
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    //success
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabs")
                    self.present(nextViewController, animated:true, completion:nil)
                }
                
            })
        }
        
    }

    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status and drop into background
        view.endEditing(true)
    }
    @IBAction func goToLogin() {

//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "login")
//       // self.present(nextViewController, animated:true, completion:nil)
//        
//        let transition = CATransition()
//        transition.duration = 0.3
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromLeft
//        view.window!.layer.add(transition, forKey: kCATransition)
//        self.present(nextViewController, animated: false, completion: nil)
//
    }
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
