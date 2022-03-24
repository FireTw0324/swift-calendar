//
//  loginVC.swift
//  Mapd36_lee
//
//  Created by student on 2022/3/10.
//

import UIKit
import FirebaseAuth



class createUserVC: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var CreateLabel: UILabel!
    var confirmAccount = true
    var confirmPassword = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginPressedBtn(_ sender: Any) {
        confirmAccount = true
        confirmPassword = true
        varifyAccount()
        varifyPassword()
        if confirmAccount == false{
           CreateLabel.text = "輸入錯誤"
        }else if confirmPassword == false{
            CreateLabel.text = "輸入錯誤"
        }else{
            if let account = accountTextField.text,let password = passwordTextField.text {
                Auth.auth().createUser(withEmail: account, password: password){
                    result , error in
                    guard let user = result?.user,
                          error == nil else{
                              print("創建帳號錯誤: \(String(describing: error?.localizedDescription))")
                              return
                          }
                    print("使用者帳號: \(user.email),使用者id\(user.uid)")
                    self.CreateLabel.text = "創建成功"
                }
            }
        }
    }
    

    
    func varifyAccount() {
        if let loginAccount = accountTextField.text{
            if validateEmail(email: loginAccount) == true{
                print("帳號輸入成功")
                confirmAccount = true
            }else{
               print("帳號輸入錯誤")
                confirmAccount = false
            }
        }
    }
    
    func varifyPassword(){
        if let loginPassword = passwordTextField.text{
            if validatePassword(password: loginPassword) == true {
               print("密碼輸入成功")
                confirmPassword = true
            }else{
               print("密碼輸入錯誤")
                confirmPassword = false
            }
        }
    }
    func validatePassword(password: String) -> Bool {
        let passwordRegex = "[A-Z0-9a-z._%+-]{9,16}"
        let passwordTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: password)
    }
    
    
    func validateEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{3,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


