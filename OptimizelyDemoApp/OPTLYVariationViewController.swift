/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

import UIKit
#if os(iOS)
    import OptimizelySDKiOS
#elseif os(tvOS)
    import OptimizelySDKTVOS
#endif

class OPTLYVariationViewController: UIViewController {
    
    var eventKey :String = ""
    var optimizelyClient :OPTLYClient? = nil
    var variationKey :String = ""
    var userId :String = ""

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
    
    @IBAction func attemptTrackAndShowSuccessOrFailure(_ sender: Any) {
        self.optimizelyClient?.track(self.eventKey, userId: userId)
        self.performSegue(withIdentifier: "OPTLYConversionSuccessSegue", sender: self)
    }
}
