//
//  DemoOptionsViewController.swift
//  DemoOptionsViewController
//
//  Created by Akshay Bhalotia on 12/11/21.
//

import UIKit

//  the four features that we are going to demo
//  saved as enums to make passing data around safer
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
        //  pass the appropriate sender to the segue
        //  so that it is available to the next controller
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
        //  set the demo type for the next controller
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
