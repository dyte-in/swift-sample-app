//
//  JoinMeetingViewController.swift
//  JoinMeetingViewController
//
//  Created by Akshay Bhalotia on 01/11/21.
//

import UIKit
import Alamofire
import DyteSdk

class JoinMeetingViewController: UIViewController {
    
    //  Outlets for view components
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var meetings: Array<Dictionary<String, AnyObject>> = []
    var searchedMeetings: Array<Dictionary<String, AnyObject>> = []
    
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadingView.isHidden = true
        
        //  Add "pull to refresh" to the meeting list
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = UIColor.systemIndigo
        tableView.refreshControl?.addTarget(self, action: #selector(getMeetingList), for: .valueChanged)
        
        //  Get list of all meetings
        self.getMeetingList()
    }
    
    //  Get the list of all meetings available to join under this organization.
    //  Depending on your use case, this logic could also be built on the backend,
    //  so feel free to ignore this part.
    @objc func getMeetingList() -> Void {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        self.view.isUserInteractionEnabled = false
        
        //  API calls to Dyte should NEVER be made from the frontend.
        //  API calls should be made from your own backend,
        //  and the app should connect to your backend to do operations like get all meetings.
        //  A sample implementation of the backend can be found at: https://github.com/dyte-in/sample-app-backend.
        //  The below request is being made to a hosted instance of the above sample backend,
        //  so treat it as if it were your own backend and not Dyte.
        AF.request("https://dyte-sample.herokuapp.com/meetings", method: .get, parameters: nil, encoding: JSONEncoding.prettyPrinted).responseString {
            response in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.loadingView.isHidden = true
                self.view.isUserInteractionEnabled = true
            }
            print("Response String: \(response.value ?? "error")")
            let data = response.value!.data(using: .utf8)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Dictionary<String, AnyObject>
                self.meetings = json["data"]!["meetings"] as! Array<Dictionary<String, AnyObject>>
                DispatchQueue.main.async {
                    
                    //  Display meeting list in table view
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
            catch {
                print("caught error")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Some error occurred, please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    alert.view.tintColor = UIColor.systemIndigo
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    //  Get participant's name as input.
    //  Depending on your use case, this logic could also be built on the backend,
    //  so feel free to ignore this part.
    func getParticipantInfo(meeting: Dictionary<String, AnyObject>) -> Void {
        var info: Dictionary<String, Any> = [:]
        
        let alert = UIAlertController(title: "Name", message: "Let us know your name to join the meeting", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.systemIndigo
        alert.addTextField { textField in
            textField.placeholder = "Steve Jobs"
            textField.tintColor = UIColor.systemIndigo
        }
        //  Option to join the meeting as a host
        alert.addAction(UIAlertAction(title: "Join as Host", style: UIAlertAction.Style.default, handler: { _ in
            info["name"] = alert.textFields?.first?.text
            info["preset"] = TabViewController.presetType.host
            
            //  Pass meeting details and participant details for adding the participant to the meeting
            self.addParticipant(meetingID: meeting["id"] as! String, roomName: meeting["roomName"] as! String, participantData: info)
        }))
        //  Option to join the meeting as a participant
        alert.addAction(UIAlertAction(title: "Join as Participant", style: UIAlertAction.Style.default, handler: { _ in
            info["name"] = alert.textFields?.first?.text
            info["preset"] = TabViewController.presetType.participant
            
            //  Pass meeting details and participant details for adding the participant to the meeting
            self.addParticipant(meetingID: meeting["id"] as! String, roomName: meeting["roomName"] as! String, participantData: info)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    //  Add participant to the meeting.
    //  Depending on your use case, this logic could also be built on the backend,
    //  so feel free to ignore this part.
    func addParticipant(meetingID: String, roomName: String, participantData: Dictionary<String, Any>) -> Void {
        
        //  Parameters to add the participant to the meeting
        let userDetails: Parameters = [ "name": participantData["name"]! ]
        var participantDetails: Parameters = [ "meetingId": meetingID, "clientSpecificId": UUID().uuidString, "userDetails": userDetails ]
        
        let demoType = (self.tabBarController as! TabViewController).demoType
        
        //  Select the appropriate role or preset based on the type of demo.
        //  You would have your own roles, and presets.
        //  You would also write your own logic based on use cases to select the relevant one.
        //  Depending on your use case, this logic could also be built on the backend,
        //  so feel free to ignore this part.
        switch demoType {
            case .webinar:
            switch participantData["preset"] as! TabViewController.presetType {
                case .host:
                    participantDetails["presetName"] = "default_webinar_host_preset"
                    break
                case .participant:
                    participantDetails["presetName"] = "default_webinar_participant_preset"
                    break
                }
                break
            case .group_call, .custom_controls, .dynamic_switching, .none:
            switch participantData["preset"] as! TabViewController.presetType {
                    case .host:
                        participantDetails["roleName"] = "host"
                        break
                    case .participant:
                        participantDetails["roleName"] = "participant"
                        break
                }
                break
        }
        
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        self.view.isUserInteractionEnabled = false
        
        //  API calls to Dyte should NEVER be made from the frontend.
        //  API calls should be made from your own backend,
        //  and the app should connect to your backend to do operations like add participant.
        //  A sample implementation of the backend can be found at: https://github.com/dyte-in/sample-app-backend.
        //  The below request is being made to a hosted instance of the above sample backend,
        //  so treat it as if it were your own backend and not Dyte.
        AF.request("https://dyte-sample.herokuapp.com/participant/create", method: .post, parameters: participantDetails, encoding: JSONEncoding.prettyPrinted).responseString {
            response in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.loadingView.isHidden = true
                self.view.isUserInteractionEnabled = true
            }
            print("Response String: \(response.value ?? "error")")
            let data = response.value!.data(using: .utf8)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Dictionary<String, AnyObject>
                print(json)
                let auth = json["data"]!["authResponse"] as! Dictionary<String, AnyObject>
                let authToken = auth["authToken"] as! String
                DispatchQueue.main.async {
                    
                    //  Use the authToken and the roomName to join the meeting via Dyte SDK.
                    //  This demo shows all of this info being generated via user actions,
                    //  but if you have already obtained this info via backend you can skip to this part directly.
                    self.addDyteView(roomName: roomName, authToken: authToken)
                }
            }
            catch {
                print("caught error")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Some error occurred, please try again later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    alert.view.tintColor = UIColor.systemIndigo
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //  The juicy part. The real deal.
    //  Join the meeting using Dyte SDK.
    func addDyteView(roomName: String, authToken: String) -> Void {
        
        //  Create meeting configuration
        let config = DyteMeetingConfig()
        config.roomName = roomName
        config.authToken = authToken
        var dyteView: DyteMeetingView
        
        //  Initialize meeting's view with an appropriate frame.
        //  The logic here is built to keep the different demos in mind,
        //  but you could assign whatever size to the meeting.
        if (self.tabBarController as! TabViewController).demoType == .custom_controls {
            
            //  Offsetting the height a bit to account for the extra control bar that we will add
            dyteView = DyteMeetingView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.safeAreaLayoutGuide.layoutFrame.size.width, height: self.view.safeAreaLayoutGuide.layoutFrame.size.height-40 ))
        } else {
            
            //  Taking up the full safe view area
            dyteView = DyteMeetingView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.safeAreaLayoutGuide.layoutFrame.size.width, height: self.view.safeAreaLayoutGuide.layoutFrame.size.height ))
        }
        dyteView.tag = 10
        
        //  Setting delegate to self to listen for events
        dyteView.delegate = self
        
        //  Add the meeting view to the view heirarchy
        self.view.addSubview(dyteView)
        
        //  Join the meeting using the config
        dyteView.join(config)
    }
    
    //  Handler for custom audio control
    @objc func toggleAudio(_ sender: UIBarButtonItem) {
        if DyteSelfParticipant.sharedInstance().audioEnabled {
            DyteSelfParticipant.sharedInstance().disableAudio()
            sender.image = UIImage(systemName: "mic.slash.fill")
        } else {
            DyteSelfParticipant.sharedInstance().enableAudio()
            sender.image = UIImage(systemName: "mic.fill")
        }
    }
    
    //  Handler for custom video control
    @objc func toggleVideo(_ sender: UIBarButtonItem) {
        if DyteSelfParticipant.sharedInstance().videoEnabled {
            DyteSelfParticipant.sharedInstance().disableVideo()
            sender.image = UIImage(systemName: "video.slash.fill")
        } else {
            DyteSelfParticipant.sharedInstance().enableVideo()
            sender.image = UIImage(systemName: "video.fill")
        }
    }
    
    //  Handler for custom control to end the meeting
    @objc func quitMeeting(_ sender: UIBarButtonItem) {
        DyteSelfParticipant.sharedInstance().leaveRoom()
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

extension JoinMeetingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //  Save the selected meeting details for further use
        self.getParticipantInfo(meeting: isSearching ? self.searchedMeetings[indexPath.row] : self.meetings[indexPath.row])
    }
}

extension JoinMeetingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? self.searchedMeetings.count : self.meetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "meetingCell", for: indexPath)
        cell.textLabel?.text = isSearching ? (self.searchedMeetings[indexPath.row])["title"] as? String : (self.meetings[indexPath.row])["title"] as? String
        return cell
    }
}

//  Manage search in the table
extension JoinMeetingViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchedMeetings = self.meetings.filter({ meeting in
            (meeting["title"] as! String).lowercased().prefix(searchText.count) == searchText.lowercased()
        })
        isSearching = true
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.tableView.reloadData()
    }
}

//  Meeting event listener delegate
extension JoinMeetingViewController: DyteMeetingViewDelegate {
    func meetingConnected() {
        DispatchQueue.main.async {
            
            //  Add custom controls to the view, based on the demo type
            if (self.tabBarController as! TabViewController).demoType == .custom_controls {
                (self.view.viewWithTag(10) as! DyteMeetingView).updateUiConfig(["controlBar" : false ])
                let toolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.safeAreaLayoutGuide.layoutFrame.height+self.view.safeAreaLayoutGuide.layoutFrame.origin.y-40, width: self.view.safeAreaLayoutGuide.layoutFrame.width, height: 40))
                print(toolbar.frame)
                toolbar.tag = 20
                toolbar.tintColor = UIColor.systemIndigo
                let micButton = UIBarButtonItem(image: UIImage(systemName: "mic.fill"), style: .plain, target: self, action: #selector(self.toggleAudio))
                let cameraButton = UIBarButtonItem(image: UIImage(systemName: "video.fill"), style: .plain, target: self, action: #selector(self.toggleVideo))
                let endButton = UIBarButtonItem(image: UIImage(systemName: "phone.down.fill"), style: .plain, target: self, action: #selector(self.quitMeeting))
                endButton.tintColor = UIColor.systemRed
                let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                toolbar.items = [micButton, spacer, cameraButton, spacer, endButton]
                self.view.addSubview(toolbar)
            }
        }
    }
    
    func meetingJoined() {
    }
    
    func meetingEnded() {
        DispatchQueue.main.async {
            
            //  Remove custom controls from the view, based on the demo type
            if (self.tabBarController as! TabViewController).demoType == .custom_controls {
                self.view.viewWithTag(20)?.removeFromSuperview()
            }
        }
    }
    
    func meetingDisconnect() {
    }
}
