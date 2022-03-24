//
//  EventDetailVC.swift
//  Mapd36_lee
//
//  Created by student on 2022/3/3.
//

import UIKit
import Firebase

class EventDetailVC: UIViewController {
    var note : [String:Any]! = [:]
    @IBOutlet weak var EventNote: UILabel!
    @IBOutlet weak var EventTitle: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var startDate: UILabel!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventNote.text = note["note"] as? String
        EventTitle.text = note["title"] as? String
        endDate.text = note["end"] as? String
        startDate.text = note["start"] as? String
    }
    @IBAction func deletPressedBtn(_ sender: Any) {
        if let start = note["start"]{
            if let user = Auth.auth().currentUser{
                db.collection(user.uid).document("\(String(describing: start))").delete()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUpdate"{
            let controller = segue.destination as? updateEventVC
            let event = note
            controller?.note = event
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

    //talbeView
    
    
    
}
