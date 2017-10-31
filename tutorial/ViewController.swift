//
//  ViewController.swift
//  tutorial
//
//  Created by Raymond Francis Sapida on 10/7/17.
//  Copyright © 2017 Merchant. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var creditCardNumberTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
    }

    // MARK: Actions
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the leopard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       // mealNameLabel.text = textField.text
    }
    
    @IBAction func submitField(_ sender: UIButton) {
    }
}

