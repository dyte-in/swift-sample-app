//
//  DemoOptionsViewController.swift
//  DemoOptionsViewController
//
//  Created by Akshay Bhalotia on 12/11/21.
//

import UIKit

public enum demoOptions {
    case group_call
    case webinar
    case custom_controls
    case dynamic_switching
}

class DemoOptionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func groupCallAction(_ sender: Any) {
        performSegue(withIdentifier: "segueToJoinScreen", sender: demoOptions.group_call)
    }
    
    @IBAction func webinarAction(_ sender: Any) {
        performSegue(withIdentifier: "segueToJoinScreen", sender: demoOptions.webinar)
    }
    
    @IBAction func customControlsAction(_ sender: Any) {
        performSegue(withIdentifier: "segueToJoinScreen", sender: demoOptions.custom_controls)
    }
    
    @IBAction func dynamicSwitchingAction(_ sender: Any) {
        performSegue(withIdentifier: "segueToJoinScreen", sender: demoOptions.dynamic_switching)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? TabViewController else {return}
        destinationVC.demoType = sender as? demoOptions
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
