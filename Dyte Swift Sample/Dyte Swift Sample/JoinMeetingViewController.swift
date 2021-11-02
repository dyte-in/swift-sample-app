//
//  JoinMeetingViewController.swift
//  JoinMeetingViewController
//
//  Created by Akshay Bhalotia on 01/11/21.
//

import UIKit
import Alamofire

class JoinMeetingViewController: UIViewController {
    
    @IBOutlet var roomName: UITextField!
    @IBOutlet var participantName: UITextField!
    @IBOutlet var joinButton: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        roomName.layer.borderWidth = 1
        roomName.layer.borderColor = UIColor.systemIndigo.cgColor
        roomName.layer.cornerRadius = 10
        participantName.layer.borderWidth = 1
        participantName.layer.borderColor = UIColor.systemIndigo.cgColor
        participantName.layer.cornerRadius = 10
        
        loadingView.isHidden = true
    }
    
    @IBAction func joinButtonAction () {
        if roomName.text?.isEmpty ?? true || participantName.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Error", message: "Empty fields are not allowed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            alert.view.tintColor = UIColor.systemIndigo
            self.present(alert, animated: true, completion: nil)
        } else {
            
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

extension JoinMeetingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            self.view.viewWithTag(2)?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
