//
//  OPTLYVariationViewController.swift
//  OptimizelyiOSDemoApp
//
//  Created by Haley Bash on 1/11/17.
//  Copyright © 2017 Optimizely. All rights reserved.
//

import UIKit

class OPTLYVariationViewController: UIViewController {
    
    var variationKey :String = ""

    @IBOutlet weak var variationLetterLabel: UILabel!
    @IBOutlet weak var variationSubheaderLabel: UILabel!
    @IBOutlet weak var variationBackgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        switch self.variationKey {
            case "variation_a":
                self.variationLetterLabel.text = "A"
                self.variationLetterLabel.textColor = UIColor.black
                self.variationSubheaderLabel.textColor = UIColor.black
                self.variationBackgroundImage.image = UIImage(named: "background_variA")
            case "variation_b":
                self.variationLetterLabel.text = "B"
                self.variationLetterLabel.textColor = UIColor.white
                self.variationSubheaderLabel.textColor = UIColor.white
            self.variationBackgroundImage.image = UIImage(named: "background_variB-marina")
            default:
                break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToVariationAction(unwindSegue: UIStoryboardSegue) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
