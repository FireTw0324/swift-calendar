//
//  FSCalendarVC.swift
//  Mapd36_lee
//
//  Created by student on 2022/2/21.
//

import UIKit
import FSCalendar
import CoreData
import EventKit
import EventKitUI
import Firebase
import FirebaseAuth
import FacebookLogin

class FSCalendarVC: UIViewController,FSCalendarDataSource , FSCalendarDelegate,FSCalendarDelegateAppearance, UITableViewDelegate, EKEventEditViewDelegate ,UITableViewDataSource {
    
    
    @IBOutlet weak var CalendarList: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    let db = Firestore.firestore()
    var array1:[[String:Any]] = []
    var UserInfo:[String:Any] = [:]
    var date = Date()
    var dateFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 17.0)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize: 18.0)
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 16.0)
        
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.todayColor = .systemPink
        calendar.appearance.titleTodayColor = .white
        calendar.appearance.titleDefaultColor = .systemBlue

        
        
        //calendar.allowsMultipleSelection = true
        calendar.appearance.borderRadius = 0
        CalendarList.delegate = self
        
        //MARK: TABLEVIEW
        ListTableView.delegate = self
        ListTableView.dataSource = self
        
        verifyUser()
    }
    
    @IBAction func SideMenuBtn(_ sender: Any) {
    }
    func verifyUser(){
        if let user = Auth.auth().currentUser{
            UserInfo = ["userId": user.uid, "userEmail": user.email as Any, "userDisplayName": user.displayName as Any,"userPhoto":user.photoURL as Any]
            print("VerfySuccess")
        }
    }
    
    func verifyFBUser(){
        if AccessToken.current != nil {
            Profile.loadCurrentProfile { (profile, error) in
                if let profile = profile ,let image = profile.imageURL(forMode: .square, size: CGSize(width: 300, height: 300)){
                    self.UserInfo = ["userId": profile.userID, "userEmail": profile.email as Any, "userDisplayName": profile.name as Any,"userPhoto": image]
                }
            }
        }
    }
    
    
    @IBAction func logout(_ sender: Any) {
        print("123")
        let manager = LoginManager()
        manager.logOut()
        try? Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "loginPage")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormatter.dateFormat = "dd-MM-YYYY"
        print("Date Select == \(dateFormatter.string(from: date))")
        let datetime = dateFormatter.string(from: date)
        
        self.loadEvent(datetime)
        print("success,\(datetime)")
        
    }
    
    
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateFormatter.dateFormat = "dd-MM-YYYY"
        print("Date De-Select == \(dateFormatter.string(from: date))")
    }
    
    
    
    //    func minimumDate(for calendar: FSCalendar) -> Date {
    //        return Date()
    //    }
    //
    //    func maximumDate(for calendar: FSCalendar) -> Date {
    //        return Date().addingTimeInterval((24*60*60)*5)//標出特定時間段 5 == 5天
    //    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        guard let eventDate = dateFormatter.date(from: "21-02-2022")else{return 0}
        if date.compare(eventDate) == .orderedSame {
            
            return 2
        }
        return 0
    }
    
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        guard let excludeDate = dateFormatter.date(from: "22-02-2022") else {
            return true
        }
        if date.compare(excludeDate) == .orderedSame{
            return false
        }
        return true
    }
    

    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        dateFormatter.dateFormat = "dd-MM-yyyy"
        guard let excludeDate = dateFormatter.date(from: "22-02-2022") else {
            return nil
        }
        if date.compare(excludeDate) == .orderedSame{
            return .red
        }
        return nil
    }
    //MARK: Add Event
    let eventstore = EKEventStore()
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addEventbtn(_ sender: Any) {
        switch EKEventStore.authorizationStatus(for: .event){
        case .notDetermined:
            eventstore.requestAccess(to: .event) { granted, error in
                if granted{
                    print("Autorized")
                    presentEventVC()
                }
            }
        case .authorized:
            print("Authorize")
            presentEventVC()
            
        default:
            break
        }
        func presentEventVC(){
            let eventVC = EKEventEditViewController()
            eventVC.editViewDelegate = self
            eventVC.eventStore = EKEventStore()
            let event = EKEvent(eventStore: eventVC.eventStore)
            event.title = "Add Your Event..."
            event.startDate = Date()
            event.endDate = Date()
            eventVC.event = event
            
            self.present(eventVC, animated: true, completion: nil)
        }
        
        request()
        
    }
    //MARK: request
    @IBAction func requestBtn(_ sender: Any) {
        request()
    }
    func request(){
        eventstore.requestAccess(to: .event) { granted, error in
            if granted && error == nil{
                print("granted \(granted)")
                print("error \(String(describing: error))")
            }
            let calendars = self.eventstore.calendars(for: .event).filter({
                (calender) -> Bool in
                return calender.type == .local || calender.type == .calDAV
            })
            
            let startDate = Date().addingTimeInterval(-3600*24*90)
            let endDate = Date().addingTimeInterval(3600*24*90)
            let predicate2 = self.eventstore.predicateForEvents(withStart: startDate,
                                                                end: endDate, calendars: calendars)
            
            print("查詢範圍 :\(startDate)，結束:\(endDate)")
            
            if let eV = self.eventstore.events(matching: predicate2) as [EKEvent]? {
                for i in eV {
                    
                    print("title  \(String(describing: i.title))" )
                    print("startTime: \(String(describing: i.startDate))")
                    print("endTime: \(String(describing:i.endDate))" )
                }
            }
        }
        
    }
    
    
    //MARK: tableView ,load from firebase
    
    
    func loadEvent(_ datetime: String){
        var passIn = false
        print("Loading")
        if let user = Auth.auth().currentUser {
            db.collection(user.uid).whereField("date",isEqualTo: datetime).addSnapshotListener(){ querySnapshot, error in
                if querySnapshot?.isEmpty != nil{
                    print(querySnapshot?.count)
                }
                self.array1 = []
                
                if let error = error{
                    print("there was an issue retrieving data from FireStore .\(error)")
                }else {
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let title = data[getEvent.title] as? String,let note = data[getEvent.note] as? String, let start = data[getEvent.startdate] as? String ,let end = data[getEvent.enddate] as? String ,let date = data[getEvent.date] as? String{
                                passIn = true
                                let newData:[String:String] = ["title": title, "note": note ,"date": date, "start": start,"end": end ]
                                self.array1.append(newData)
                            }
                            DispatchQueue.main.async{
                                self.CalendarList.reloadData()
                            }
                        }
                    }else{
                        print("error")
                    }
                }
            }
        }
        if passIn == false {
            print("there is no data in this date")
            array1.removeAll()
            DispatchQueue.main.async {
                self.CalendarList.reloadData()
            }
            print("AllClear")
        }else{
            print("--------")
            print(array1)
        }
    }
    
    @IBOutlet weak var ListTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array1.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("使用者點選了 \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        print("==========")
        print(array1)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row > array1.count-1){
            return UITableViewCell()
        }
        else{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Cell", for: indexPath as IndexPath)
            let event = self.array1[indexPath.row]
            cell.textLabel?.text = event["title"] as? String
            cell.detailTextLabel?.text = event["date"] as? String
            return cell
        }
    }
    
    
    //:MARK: Segue
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let indexpath = ListTableView.indexPathForSelectedRow{
                let controller = segue.destination as! EventDetailVC
                let event = array1[indexpath.row]
                controller.note = event
                
            }
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
    
    
}
