//
//  EventVC.swift
//  Mapd36_lee
//
//  Created by student on 2022/2/28.
//

import UIKit
import Firebase
import FSCalendar
import CoreData

class EventVC: UIViewController, UITextViewDelegate {
    let db = Firestore.firestore()
    var UserInfo:[String:Any] = [:]
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyUser()
        // Do any additional setup after loading the view.
        noteTextView.delegate = self
        noteTextView.returnKeyType = UIReturnKeyType.done
    }
    func verifyUser(){
        if let user = Auth.auth().currentUser{
            UserInfo = ["userId": user.uid, "userEmail": user.email as Any, "userDisplayName": user.displayName as Any,"userPhoto":user.photoURL as Any]
        }
    }
    @IBAction func cancelPressedBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateFormat = "dd-MM-YYYY HH:mm"
        
        let dateFormatterDate = DateFormatter()
        dateFormatterDate.dateFormat = "dd-MM-YYYY"
        
        let start = dateFormatterTime.string(from: startDatePicker.date)
        let end = dateFormatterTime.string(from: endDatePicker.date)
        let date = dateFormatterDate.string(from: startDatePicker.date)
        
        
        if let title = titleTextField.text ,let note = noteTextView.text ,let user = Auth.auth().currentUser {
            db.collection(user.uid).document("\(start)").setData([
                getEvent.title : title,
                getEvent.note : note,
                getEvent.startdate : start,
                getEvent.enddate : end,
                getEvent.date : date
            ]){
                error in
                if let error = error{
                    print("error to solve to firebase. \(error)")
                    
                }else{
                    print("data send succesful.")
                }
            }
            
            
        }
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            self.view.endEditing(true)
            return true
        }
        return true
    }
   
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
