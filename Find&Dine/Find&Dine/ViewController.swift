//
//  ViewController.swift
//  Find&Dine
//
//  Created by Gregory Lee on 6/4/18.
//  Copyright © 2018 WIT Senior Design. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // init location manager
    let locationManager = CLLocationManager()
    
    // init GMSPlacesClient
    var placesClient: GMSPlacesClient!
    
    // Connections to input fields for ViewController
    @IBOutlet weak var locationInput: UITextField!
    @IBOutlet weak var travelDistanceInput: UITextField!
    @IBOutlet weak var searchKeywordsInput: UITextField!
    @IBOutlet weak var ratingInput: UISlider!
    @IBOutlet weak var reviewServiceInput: UISwitch!
    @IBOutlet weak var minPriceInput: UISegmentedControl!
    @IBOutlet weak var maxPriceInput: UISegmentedControl!
    @IBOutlet weak var ratingOutput: UILabel!
    
    // variables used for storing values from non text fields
    // each set to a default value
    var currentLocationUse = 0
    var rating = 3.0
    var service = "Google"
    var minPrice = 1
    var maxPrice = 2
    var sv = UIView()
    
    /** get value of slider and set rating
     Purpose: Retrieve value of the rating slider if it is moved.
     
     Parameter: UISlider: The position of the slider indicates its value
     
     */
    @IBAction func ratingChange(_ sender: UISlider) {
        // set current value to the input from the UISlider
        let currentValue = ratingInput.value
        
        // update label in ViewController to display current value
        ratingOutput.text = "\(currentValue)"
        
        // set the current value as the rating
        rating = Double(currentValue)
    }
    
    /**
     Purpose: To determine which rating service to use (Google (default) or Yelp)
     
     Parameter: UISwitch: the switch's position determines which service is used
     
     */
    @IBAction func serviceChange(_ sender: UISwitch) {
        // if the switch is in the on position, then use the Yelp service
        if reviewServiceInput.isOn {
            service = "Yelp"
        }
        else {
            service = "Google"
        }
    }
    
    /**
     Purpose: to get the minPrice set by the user
     
     Parameter: sender: This is a UISegmentedControl which contains 4 options in this implementation
     
     */
    @IBAction func minPriceChange(_ sender: UISegmentedControl) {
        // Go into switch to determine which option was selected then set minPrice to the corresponding value
        // disable options in maxPriceInput if the minPriceInput > maxPriceInput 
        switch minPriceInput.selectedSegmentIndex {
        case 0:
            minPrice = 1
            maxPriceInput.setEnabled(true, forSegmentAt: 0)
            maxPriceInput.setEnabled(true, forSegmentAt: 1)
            maxPriceInput.setEnabled(true, forSegmentAt: 2)
            maxPriceInput.setEnabled(true, forSegmentAt: 3)
        case 1:
            minPrice = 2
            maxPriceInput.setEnabled(false, forSegmentAt: 0)
            maxPriceInput.setEnabled(true, forSegmentAt: 1)
            maxPriceInput.setEnabled(true, forSegmentAt: 2)
            maxPriceInput.setEnabled(true, forSegmentAt: 3)
        case 2:
            minPrice = 3
            maxPriceInput.setEnabled(false, forSegmentAt: 0)
            maxPriceInput.setEnabled(false, forSegmentAt: 1)
            maxPriceInput.setEnabled(true, forSegmentAt: 2)
            maxPriceInput.setEnabled(true, forSegmentAt: 3)
        case 3:
            minPrice = 4
            maxPriceInput.setEnabled(false, forSegmentAt: 0)
            maxPriceInput.setEnabled(false, forSegmentAt: 1)
            maxPriceInput.setEnabled(false, forSegmentAt: 2)
            maxPriceInput.setEnabled(true, forSegmentAt: 3)
        default:
            maxPrice = minPrice
            break
        }
    }
    
    /**
     Purpose: to get the maxPrice set by the user
     
     Parameter: sender: This is a UISegmentedControl which contains 4 options in this implementation
     
     */
    @IBAction func maxPriceChange(_ sender: UISegmentedControl) {
        // Go into switch to determine which option was selected then set maxPrice to the corresponding value
        switch maxPriceInput.selectedSegmentIndex {
        case 0:
            maxPrice = 1
        case 1:
            maxPrice = 2
        case 2:
            maxPrice = 3
        case 3:
            maxPrice = 4
        default:
            break
        }
    }
    
    /**
     Purpose: Prepare to send data from this ViewController to resultsViewController
     
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // init resultsViewController as the segue destination
        let resultsViewController = segue.destination as! resultsViewController
        resultsViewController.locationFlag = currentLocationUse
        resultsViewController.location = locationInput.text! 
        resultsViewController.travelDistance = travelDistanceInput.text!
        resultsViewController.keyword = searchKeywordsInput.text!
        resultsViewController.service = service
        resultsViewController.minPrice = minPrice
        resultsViewController.maxPrice = maxPrice
        resultsViewController.minRating = Float(rating)
    }
    
    /**
     Purpose: Send data to the specified variables in resultsViewController from above
     
     Parameter: sender: the UIBarButtonItem which navigates to the next ViewController
     
     TESTTEST
     */
    @IBAction func Find(_ sender: UIBarButtonItem) {
        // make sure that location and distance are filled out before sending data
        if locationInput.text != "" && travelDistanceInput.text != "" && searchKeywordsInput.text != "" {
            performSegue(withIdentifier: "resultsViewController", sender: self)
        }
        print("hello test test test")
    }
    
    private func convertDist(dist: Double) -> Double {
        let temp = dist * 1609.334
        return temp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        // set numeric keypad with decimal to travel dist input
        travelDistanceInput.keyboardType = UIKeyboardType.decimalPad
        
        //Looks for single or multiple taps.
        
        // set location manager as delegate
        locationManager.delegate = self
        
        // request for use of location
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // add Done buttons to keyboard tool bar. Used to dismiss keyboard when user is done with input
        locationInput.addDoneButtonOnKeyboard()
        travelDistanceInput.addDoneButtonOnKeyboard()
        searchKeywordsInput.addDoneButtonOnKeyboard()
    }

    /**
     Purpose: Retrieve current location's address
     
     Parameter: sender: UIButton, when the button is pressed, execute this function
     */
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        // get the current place
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            // if there is an error then output the error
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            // if there is info about this place then retrieve it and then set the location field to the formatted address of the current location
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.locationInput.text = place.formattedAddress?.components(separatedBy: ", ").joined(separator: "\n")
                 }
            }
        })
        
        // flag for use in resultsViewController
        currentLocationUse = 1
    }    
    
}

extension ViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UITextField{
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
