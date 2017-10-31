//
//  ViewController.swift
//  tutorial
//
//  Created by Raymond Francis Sapida on 10/7/17.
//  Copyright © 2017 Merchant. All rights reserved.
//

import UIKit
import Alamofire
import IngenicoConnectKit

class ViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties
    @IBOutlet weak var creditCardNumberTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!

    var session: Session?
    var context: Context?
    var paymentProductId: String?
    let paymentRequest = PaymentRequest()
    let amountValue = 3000
    let currencyCode = "EUR"
    let amountOfMoney = PaymentAmountOfMoney(totalAmount: amountValue, currencyCode: currencyCode)


    override public func viewDidLoad() {
      super.viewDidLoad()
      Alamofire.request("http://localhost:3000/api/ingenico-session", method: .post).responseJSON { response in
        guard let responseJSON = response.result.value as? [String: Any],
        let body = responseJSON["body"] as? [[String: Any]],
        let clientSessionId = body["clientSessionId"],
        let customerId = body["customerId"] else {
          print("Invalid session parameters in api call")
          return
        }

        session = Session(clientSessionId: clientSessionId, customerId: customerId, region: Region.EU, environment: Environment.sandbox, appIdentifier: AppConstants.kApplicationIdentifier)

        let countryCode = "FR"
        let isRecurring = false
        let groupPaymentProducts = true

        context = PaymentContext(amountOfMoney: amountOfMoney, isRecurring: isRecurring,
                                    countryCode: countryCode)
      }

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
      paymentRequest.setValue(creditCardNumberTextField.text, forField: "cardNumber")
      paymentRequest.setValue(cvvTextField.text, forField: "cvv")
      paymentRequest.setValue(expiryDateTextField.text, forField: "expiryDate")
      doIinLookup()
    }


    func doIINLookup() {
        guard let unmasked = paymentRequest.unmaskedValue(forField: "cardNumber") else {
            fatalError("Payment request didn't contain cardNumber field")
        }
        session.iinDetails(forPartialCreditCardNumber: unmasked, context: context, success: { response in
          paymentProductId = response.paymentProductId
          retrievePaymentProduct();
        }, failure: { error in
            fatalError("Payment request couldn't find a corresponding payment product id")
        })
    }


    func retrievePaymentProduct(){
      session.paymentProduct(withId: paymentProductId, context: context,
                                  success: { paymentProduct in
          paymentRequest.paymentProduct = paymentProduct
          encryptRequest()
      }, failure: { error in
          fatalError("A payment product couldn't be found with the payment product id")
      })
    }

    func encryptRequest(){
      session.prepare(paymentRequest, success: { preparedPaymentRequest in
        let parameters: Parameters = [
          "encryptedCustomerInput": preparedPaymentRequest,
          "order": [
            "amountOfMoney": [
              "amount": amountValue,
              "currencyCode": currencyCode
            ]
          ]

        ]

        Alamofire.request("http://localhost:3000/api/ingenico-encrypted", method: .post, parameters: parameters).responseJSON { response in
          
          guard let responseJSON = response.result.value as? [String: Any],
          let body = responseJSON["body"] as? [[String: Any]] else {
            print("Invalid response parameters in api call")
            return
          }
          showSuccessAlert()

        }

      }, failure: { error in
        fatalError("The payment request couldn't be encrypted")
      })
    }

}
