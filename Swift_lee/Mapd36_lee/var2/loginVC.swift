//
//  loginVC.swift
//  Mapd36_lee
//
//  Created by student on 2022/3/10.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import GoogleSignIn
import JGProgressHUD

class loginVC: UIViewController , UITextFieldDelegate{

    
    @IBOutlet weak var LoginAccountTextField: UITextField!
    @IBOutlet weak var LoginPasswordTextField: UITextField!
    
    @IBOutlet weak var loginErrorLabel: UILabel!
    var confirmPw = ""
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        varifyUser()


    }
    
    func varifyUser(){
        hud.textLabel.text = "驗證中.."
        hud.show(in: self.view)
        if let accessToken = AccessToken.current {
            print("\(accessToken.userID) login")
            if let next = storyboard?.instantiateViewController(withIdentifier: "CalendarPage"){
                next.modalPresentationStyle = .fullScreen
                
                self.present(next, animated: true,completion: nil)
                hud.dismiss(animated: true)
            }
        } else {
            print("not login")
            hud.dismiss(animated: true)
        }
        
        if let user = Auth.auth().currentUser{
            print("\(user.uid) login suscess")
            if let next = storyboard?.instantiateViewController(withIdentifier: "CalendarPage"){
                next.modalPresentationStyle = .fullScreen
                self.present(next, animated: true,completion: nil )
            }
        }else{
            print("login field")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "login"{
            return false
        }
        else{
            return true
        }
    }
    
    @IBAction func FBLoginPressedBtb(_ sender: Any) {
        let manager = LoginManager()
        manager.logIn(permissions: [.publicProfile, .email]) { (result) in
            if case LoginResult.success(granted: _, declined: _, token: let token) = result {
                self.hud.textLabel.text = "驗證中.."
                self.hud.show(in: self.view)
                print("login ok")
                let credential =  FacebookAuthProvider.credential(withAccessToken: token!.tokenString)
                Auth.auth().signIn(with: credential) { (result, error) in
                    if let next = self.storyboard?.instantiateViewController(withIdentifier: "CalendarPage"){
                        next.modalPresentationStyle = .fullScreen
                        self.present(next, animated: true,completion: nil )
                    }
                    self.hud.dismiss(animated: true)
                }
                guard let accessToken = AccessToken.current else {
                         print("Failed to get access token")
                         return
                     }
 
            } else {
                print("login fail")
                self.hud.dismiss(animated: true)
            }
        }
    }
    
    
    
    
    @IBAction func LoginPressedBtn(_ sender: Any) {
        if let loginAccount = LoginAccountTextField.text,
           let loginPassword = LoginPasswordTextField.text{
            
            Auth.auth().signIn(withEmail: loginAccount, password: loginPassword){
                result , error in
                if error == nil {
                    self.hud.textLabel.text = "驗證中.."
                    self.hud.show(in: self.view)
                    self.performSegue(withIdentifier: "login", sender: self)
                    self.hud.dismiss(animated: true)
                }else{
                    self.loginErrorLabel.text = "登入失敗，請確認帳密是否正確"
                    print("登入錯誤\(error?.localizedDescription)")
                    self.hud.dismiss(animated: true)
                    return
                }
            }
        }
    }
    let signIN = GIDSignIn.sharedInstance
    let clientID = "122250777417-79of5bmmmmkkj2jm96puaidbc8maaet2.apps.googleusercontent.com"
    @IBAction func GoogleLoginPressedBtn(_ sender: Any) {
        let config = GIDConfiguration(clientID: clientID)
        signIN.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print("Auth Fail:\(error)")
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                    if let next = self.storyboard?.instantiateViewController(withIdentifier: "CalendarPage"){
                        self.hud.textLabel.text = "驗證中.."
                        self.hud.show(in: self.view)
                        next.modalPresentationStyle = .fullScreen
                        self.present(next, animated: true,completion: nil )
                        self.hud.dismiss(animated: true)
                }
            }
        }
    }
}
// MARK: - 字串類別延伸
extension String {
    // 是否含有注音
    func isContainsPhoneticCharacters() -> Bool {
        for scalar in self.unicodeScalars {
            if (scalar.value >= 12549 && scalar.value <= 12582) || (scalar.value == 12584 || scalar.value == 12585 || scalar.value == 19968) {
                return true
            }
        }
        return false
    }
    
    // 是否含有中文字元
    func isContainsChineseCharacters() -> Bool {
        for scalar in self.unicodeScalars {
            if scalar.value >= 19968 && scalar.value <= 171941 {
                return true
            }
        }
        return false
    }
    
    // 是否含有空白字元
    func isContainsSpaceCharacters() -> Bool {
        for scalar in self.unicodeScalars {
            if scalar.value == 32 {
                return true
            }
        }
        return false
    }
    


}
