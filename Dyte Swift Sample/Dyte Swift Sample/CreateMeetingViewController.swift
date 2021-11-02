//
//  CreateMeetingViewController.swift
//  CreateMeetingViewController
//
//  Created by Akshay Bhalotia on 01/11/21.
//

import UIKit
import Alamofire
import DyteSdk

class CreateMeetingViewController: UIViewController {
    
    @IBOutlet var meetingTitle: UITextField!
    @IBOutlet var participantName: UITextField!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        meetingTitle.layer.borderWidth = 1
        meetingTitle.layer.borderColor = UIColor.systemIndigo.cgColor
        meetingTitle.layer.cornerRadius = 10
        participantName.layer.borderWidth = 1
        participantName.layer.borderColor = UIColor.systemIndigo.cgColor
        participantName.layer.cornerRadius = 10
        
        loadingView.isHidden = true
    }
    
    @IBAction func createButtonAction () {
        if meetingTitle.text?.isEmpty ?? true || participantName.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Error", message: "Empty fields are not allowed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        } else {
            createMeeting(meetingTitle: meetingTitle.text!, participantName: participantName.text!)
        }
    }
    
    func createMeeting(meetingTitle: String, participantName: String) -> Void {
        let meetingDetails: Parameters = ["title": meetingTitle]
        
        activityIndicator.startAnimating()
        loadingView.isHidden = false
        self.view.isUserInteractionEnabled = false
        
        AF.request("https://dyte-sample.herokuapp.com/meeting/create", method: .post, parameters: meetingDetails, encoding: JSONEncoding.prettyPrinted).responseString {
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
                let meeting = json["data"]!["meeting"] as! Dictionary<String, AnyObject>
                self.addParticipant(meetingID: meeting["id"] as! String, roomName: meeting["roomName"] as! String, participantName: participantName)
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
    
    func addParticipant(meetingID: String, roomName: String, participantName: String) -> Void {
        let userDetails: Parameters = [ "name": participantName ]
        let participantDetails: Parameters = [ "meetingId": meetingID, "clientSpecificId": UUID().uuidString, "userDetails": userDetails ]
        
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
        config.authToken = authToken;
        config.width = self.view.safeAreaLayoutGuide.layoutFrame.size.width
        config.height = self.view.safeAreaLayoutGuide.layoutFrame.size.height
        let dyteView = DyteMeetingView(frame: CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.safeAreaLayoutGuide.layoutFrame.size.width, height: self.view.safeAreaLayoutGuide.layoutFrame.size.height ))
        dyteView.tag = 10
        self.view.addSubview(dyteView)
        dyteView.join(config);
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

extension CreateMeetingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            self.view.viewWithTag(2)?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
