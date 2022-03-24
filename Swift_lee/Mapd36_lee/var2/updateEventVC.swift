//
//  updateEventVC.swift
//  Mapd36_lee
//
//  Created by student on 2022/3/4.
//
import Firebase
import UIKit
import FirebaseAuth

class updateEventVC: UIViewController,UITextViewDelegate {

    @IBOutlet weak var updateTitle: UITextField!
    @IBOutlet weak var updateText: UITextView!
    @IBOutlet weak var updateEnd: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var updateSendPressedBtn: UIButton!
    var note : [String:Any]! = [:]
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("inupdate: \(String(describing: note)) ")
        updateLabel.text = note["start"] as? String
        updateText.text = note["note"] as? String
        updateEnd.text = note["end"] as? String
        updateTitle.text = note["title"] as? String
        // Do any additional setup after loading the view.
        updateText.delegate = self
        updateText.returnKeyType = UIReturnKeyType.done
    }
    @IBAction func cancelPressedBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func updatePressedBtn(_ sender: Any) {
        self.updateDate()
        self.dismiss(animated: true, completion: nil)
    }
    func updateDate(){
        if let updateText = updateText.text, let updateTitle = updateTitle.text,let user = Auth.auth().currentUser,let start = note["start"]{
            print("update success")
            db.collection(user.uid).document(start as! String).updateData([
                "note" : updateText ,
                "title" : updateTitle
            ])
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
