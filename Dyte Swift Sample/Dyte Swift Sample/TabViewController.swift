//
//  TabViewController.swift
//  TabViewController
//
//  Created by Akshay Bhalotia on 12/11/21.
//

import UIKit

class TabViewController: UITabBarController {
    
    var demoType: demoOptions!
    
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
