//
//  TabViewController.swift
//  TabViewController
//
//  Created by Akshay Bhalotia on 12/11/21.
//

import UIKit

class TabViewController: UITabBarController {
    
    //  custom property to hold the demo type
    //  makes it easier for all child controllers to access
    var demoType: demoOptions!
    
    // the two basic roles types we will be working with
    public enum presetType {
        case host
        case participant
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
