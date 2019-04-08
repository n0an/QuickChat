//
//  BackgroundViewController.swift
//  QuickChat2.0
//
//  Created by David Kababyan on 23/10/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit

class BackgroundViewController: UIViewController {

    
    @IBOutlet weak var redSliderOutlet: UISlider!
    @IBOutlet weak var greenSliderOutlet: UISlider!
    @IBOutlet weak var blueSliderOutlet: UISlider!
    @IBOutlet weak var colorCube: UIView!
    
    let userDefaults = UserDefaults.standard
    var firstLoad: Bool?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colorCube.layer.borderWidth = 1
        colorCube.layer.borderColor = UIColor.black.cgColor
        
        loadUserDefaults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: IBActions

    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        saveUserDefaults()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        
        updateUI()
    }
    
    //MARK: userDefaults
    
    func saveUserDefaults() {
        
        userDefaults.set(redSliderOutlet.value, forKey: kRED)
        userDefaults.set(greenSliderOutlet.value, forKey: kGREEN)
        userDefaults.set(blueSliderOutlet.value, forKey: kBLUE)
        
        userDefaults.synchronize()
    } 
    

    
    func loadUserDefaults() {
        
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)

            userDefaults.set(1.0, forKey: kRED)
            userDefaults.set(1.0, forKey: kGREEN)
            userDefaults.set(1.0, forKey: kBLUE)

            userDefaults.synchronize()
            
        }
        
        redSliderOutlet.setValue(userDefaults.float(forKey: kRED), animated: true)
        greenSliderOutlet.setValue(userDefaults.float(forKey: kGREEN), animated: true)
        blueSliderOutlet.setValue(userDefaults.float(forKey: kBLUE), animated: true)
        
        updateUI()
    }
    
    func updateUI() {
        
        colorCube.backgroundColor = UIColor(colorLiteralRed: redSliderOutlet.value, green: greenSliderOutlet.value, blue: blueSliderOutlet.value, alpha: 1)
    }

}
