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
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = UIColor.systemIndigo
        tableView.refreshControl?.addTarget(self, action: #selector(getMeetingList), for: .valueChanged)
        
        self.getMeetingList()
    }
    
    @objc func getMeetingList() -> Void {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        self.view.isUserInteractionEnabled = false
        
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
    
    func getParticipantInfo(meeting: Dictionary<String, AnyObject>) -> Void {
        var info: Dictionary<String, Any> = [:]
        
        let alert = UIAlertController(title: "Name", message: "Let us know your name to join the meeting", preferredStyle: UIAlertController.Style.alert)
        alert.view.tintColor = UIColor.systemIndigo
        alert.addTextField { textField in
            textField.placeholder = "Steve Jobs"
            textField.tintColor = UIColor.systemIndigo
        }
        alert.addAction(UIAlertAction(title: "Join as Host", style: UIAlertAction.Style.default, handler: { _ in
            info["name"] = alert.textFields?.first?.text
            info["preset"] = TabViewController.presetType.host
            
            self.addParticipant(meetingID: meeting["id"] as! String, roomName: meeting["roomName"] as! String, participantData: info)
        }))
        alert.addAction(UIAlertAction(title: "Join as Participant", style: UIAlertAction.Style.default, handler: { _ in
            info["name"] = alert.textFields?.first?.text
            info["preset"] = TabViewController.presetType.participant
            
            self.addParticipant(meetingID: meeting["id"] as! String, roomName: meeting["roomName"] as! String, participantData: info)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func addParticipant(meetingID: String, roomName: String, participantData: Dictionary<String, Any>) -> Void {
        let userDetails: Parameters = [ "name": participantData["name"]! ]
        var participantDetails: Parameters = [ "meetingId": meetingID, "clientSpecificId": UUID().uuidString, "userDetails": userDetails ]
        
        let demoType = (self.tabBarController as! TabViewController).demoType
        
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
    
    func addDyteView(roomName: String, authToken: String) -> Void {
        let config = DyteMeetingConfig();
        config.roomName = roomName;
        config.authToken = authToken
        var dyteView: DyteMeetingView
        if (self.tabBarController as! TabViewController).demoType == .custom_controls {
            dyteView = DyteMeetingView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.safeAreaLayoutGuide.layoutFrame.size.width, height: self.view.safeAreaLayoutGuide.layoutFrame.size.height-40 ))
        } else {
            dyteView = DyteMeetingView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.safeAreaLayoutGuide.layoutFrame.size.width, height: self.view.safeAreaLayoutGuide.layoutFrame.size.height ))
        }
        dyteView.tag = 10
        dyteView.delegate = self
        
        self.view.addSubview(dyteView)
        
        dyteView.join(config);
    }
    
    @objc func toggleAudio(_ sender: UIBarButtonItem) {
        if DyteSelfParticipant.sharedInstance().audioEnabled {
            DyteSelfParticipant.sharedInstance().disableAudio()
            sender.image = UIImage(systemName: "mic.slash.fill")
        } else {
            DyteSelfParticipant.sharedInstance().enableAudio()
            sender.image = UIImage(systemName: "mic.fill")
        }
    }
    
    @objc func toggleVideo(_ sender: UIBarButtonItem) {
        if DyteSelfParticipant.sharedInstance().videoEnabled {
            DyteSelfParticipant.sharedInstance().disableVideo()
            sender.image = UIImage(systemName: "video.slash.fill")
        } else {
            DyteSelfParticipant.sharedInstance().enableVideo()
            sender.image = UIImage(systemName: "video.fill")
        }
    }
    
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

extension JoinMeetingViewController: DyteMeetingViewDelegate {
    func meetingConnected() {
        DispatchQueue.main.async {
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
            self.view.viewWithTag(20)?.removeFromSuperview()
        }
    }
    
    func meetingDisconnect() {
    }
}
