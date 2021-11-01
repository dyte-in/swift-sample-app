//
//  CreateMeetingViewController.swift
//  CreateMeetingViewController
//
//  Created by Akshay Bhalotia on 01/11/21.
//

import UIKit
import Alamofire

class CreateMeetingViewController: UIViewController {
    
    @IBOutlet var meetingTitle: UITextField!
    @IBOutlet var participantName: UITextField!
    @IBOutlet var createButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButtonAction () {
        if meetingTitle.text?.isEmpty ?? true || participantName.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Error", message: "Empty fields are not allowed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
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
