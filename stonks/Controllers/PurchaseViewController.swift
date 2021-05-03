//
//  SubscriptionViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/26/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import StoreKit
import XLActionController
import EFCountingLabel
import FCAlertView

class PurchaseViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, UITableViewDelegate, UITableViewDataSource {

    private var productId = "premiumstockinfo"
    private var cancelSubscriptionUrl:String = "https://apps.apple.com/account/subscriptions"
    private var productsApple:[SKProduct] = []
    private var products:[Product] = []
    private var receipt: [String : Any]?
    
    private var currentSelectedProduct:Product?
    
    @IBOutlet weak var currentCredits: EFCountingLabel!
    @IBOutlet weak var purchaseTable: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var pullDownBar: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.cornerRadius = 15.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.transparentView.addGestureRecognizer(tapGesture)
        self.pullDownBar.layer.cornerRadius = 3.0
        
        self.purchaseTable.delegate = self
        self.purchaseTable.dataSource = self
        self.purchaseTable.isHidden = true
        self.getProducts()
        self.currentCredits.counter.timingFunction = EFTimingFunction.linear
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.requestProducts()
        self.currentSelectedProduct = nil
//        self.receiptValidation()
        NetworkManager.getMyRestApi().getCreditsForCurrentUser { credits in
            self.currentCredits.countFromCurrentValueTo(CGFloat(credits), withDuration: 1.0)
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func getProducts(){
        NetworkManager.getMyRestApi().getProducts { (products) in
            self.products = products
            self.requestAppleProducts()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseCell") as! PurchaseTableViewCell
        
        let product = self.products[indexPath.row]
        cell.credits.text = String(product.credits!)
        cell.price.setTitle("$" + String(product.usd!), for: .normal)
        cell.icon.image = UIImage(named: self.getCoinIconName(product.usd!))
        if product.usd! == 0.99 {
            cell.bonusIcon.isHidden = true
        } else {
            cell.bonusIcon.isHidden = false
        }
        cell.bonusIcon.image = UIImage(named: self.getBonusIconName(product.usd!))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = self.products[indexPath.row]
        self.currentSelectedProduct = product
        let appleProduct = self.getAppleProduct(product)
        if appleProduct != nil {
            self.loadingView.isHidden = false
            self.buyProduct(appleProduct!)
        }
    }
    
    private func getAppleProduct(_ product:Product) -> SKProduct? {
        for p in self.productsApple {
            if p.productIdentifier == product.id {
                return p
            }
        }
        return nil
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    public func requestAppleProducts() {
        var productIds:Set<String> = Set()
        for p in self.products {
            productIds.insert(p.id ?? "")
        }
        let productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    public func receiptRefreshRequest(){
        let refreshRequest = SKReceiptRefreshRequest()
        refreshRequest.delegate = self
        refreshRequest.start()
    }
        
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products:[SKProduct] = response.products
        self.productsApple = products
        if products.count > 0 {
            var validProducts:[Product] = []
            for p in self.products {
                if products.contains(where: { (product) -> Bool in
                    product.productIdentifier == p.id
                }) {
                    validProducts.append(p)
                }
            }
            self.products = validProducts.sorted(by: { (p1, p2) -> Bool in
                return p1.usd! < p2.usd!
            })
            DispatchQueue.main.async {
                self.purchaseTable.isHidden = false
                self.purchaseTable.reloadData()
            }
        }
    }
  
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                case .purchased:
                    complete(transaction: transaction)
                    break
                case .failed:
                    //user cancelled or auth failed
                    fail(transaction: transaction)
                    break
                case .restored:
                    restore(transaction: transaction)
                    break
                case .deferred:
                    print("deferred")
                    break
                case .purchasing:
                    print("purchasing")
                    break
            @unknown default:
                print("ERROR")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("should add store payment")
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("error")
        self.loadingView.isHidden = true
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        
        //tell our backend that the user purchased successfully

        //notify user that the purchase was successful
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        self.receiptValidation(transaction)
        
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        //deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        var message:String = "Something went wrong"
        if let error = transaction.error as? NSError {
            if error.domain == SKErrorDomain {
                // handle all possible errors
                switch (error.code) {
                case SKError.unknown.rawValue:
                    message = "Something went wrong"
                case SKError.clientInvalid.rawValue:
                    message = "Client is not allowed to issue the request"
                case SKError.paymentCancelled.rawValue:
                    message = "Request cancelled"
                case SKError.paymentInvalid.rawValue:
                    message = "Payment method invalid"
                case SKError.paymentNotAllowed.rawValue:
                    message = "This device is not allowed to make the payment"
                default:
                    break;
                }
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        self.loadingView.isHidden = true
        //show error
        self.showErrorAlert(message: message)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        NotificationCenter.default.post(name: .init("Test Notification"), object: identifier)
     }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("SKRequest " + request.description + " failed: " + error.localizedDescription)
    }
    
    func receiptValidation(_ transaction:SKPaymentTransaction) {
        let receiptPath = Bundle.main.appStoreReceiptURL?.path
        if FileManager.default.fileExists(atPath: receiptPath!) {
            var receiptData:NSData?
            do {
                receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
            }
            catch{
                print("ERROR: " + error.localizedDescription)
            }
            let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
            
            guard let encodedReceipt = base64encodedReceipt else {
                print("error: receipt cant be encoded")
                return
            }
            
            NetworkManager.getMyRestApi().verifyReceipt(encodedReceipt, productid: (self.currentSelectedProduct?.id)!) { (credits) in
                if credits != nil {
                    self.currentCredits.countFromCurrentValueTo(CGFloat(credits!), withDuration: 1.0)
                    SKPaymentQueue.default().finishTransaction(transaction)
//                    self.receiptRefreshRequest()
                    DispatchQueue.main.async {
                        self.loadingView.isHidden = true
                        self.showSuccessAlert(self.currentSelectedProduct?.credits ?? 0)
                    }
                } else {
                    self.showErrorAlert(message: "Contact support immediately")
                }
            }
        }
    }
    
    func showSuccessAlert(_ credits:Int){
        let alert = FCAlertView()
        alert.colorScheme = Constants.green
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: "Success",
                        withSubtitle: String(credits) + " credits have been added to your account!",
                        withCustomImage: UIImage(systemName: "checkmark"),
                        withDoneButtonTitle: nil,
                        andButtons: nil)
    }
    
    func showErrorAlert(message:String){
        let alert = FCAlertView()
        alert.colorScheme = .red
        alert.dismissOnOutsideTouch = true
        alert.detachButtons = true
        alert.showAlert(inView: self,
                        withTitle: "Error",
                        withSubtitle: message,
                        withCustomImage: UIImage(systemName: "exclamationmark.triangle.fill"),
                        withDoneButtonTitle: nil,
                        andButtons: nil)
    }

    func getBonusIconName(_ usd:Double) -> String {
        if usd <= 5.0 {
            return "bonus_10.png"
        } else if usd <= 10.0 {
            return "bonus_20.png"
        } else if usd <= 50.0 {
            return "bonus_30.png"
        } else if usd <= 100.0 {
            return "bonus_50.png"
        }
        return ""
    }
    
    func getCoinIconName(_ usd:Double) -> String {
        if usd == 0.99 {
            return "coin_stack_1.png"
        } else if usd == 4.99 {
            return "coin_stack_2.png"
        } else if usd == 9.99 {
            return "coin_stack_3.png"
        } else if usd == 49.99 {
            return "coin_stack_4.png"
        } else if usd == 99.99 {
            return "coin_stack_4.png"
        } else {
            return "coin.png"
        }
    }
    

    // reading receipt data
    //                if let jsonstring = data.rawString() {
    //                    let data = jsonstring.data(using: .utf8)
    //                    if let data = data {
    //                        do {
    //                            self.receipt = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
    //                            if let receipt = self.receipt as [String:AnyObject]? {
    //                                //print(receipt)
    //                                if receipt["receipt"] != nil {
    //                                    if receipt["receipt"]!["in_app"] != nil {
    //                                        let inapp = receipt["receipt"]!["in_app"] as! NSArray
    //                                        if inapp.count > 0 {
    //                                            let first = inapp[0] as! NSDictionary
    //                                            if first["transaction_id"] != nil {
    //                                                print(first["transaction_id"]!)
    //                                            }
    //                                        }
    //                                    }
    //                                }
    //                        }
    //                    }
    //                }
    //           }
    //        }
    
    
    
//            let requestDictionary = ["receipt-data":base64encodedReceipt!,"password":SUBSCRIPTION_SECRET]
//
//            guard JSONSerialization.isValidJSONObject(requestDictionary) else {  print("requestDictionary is not valid JSON");  return }
//            do {
//                let requestData = try JSONSerialization.data(withJSONObject: requestDictionary)
//                let validationURLString = "https://sandbox.itunes.apple.com/verifyReceipt"  // this works but as noted above it's best to use your own trusted server
//                guard let validationURL = URL(string: validationURLString) else { print("the validation url could not be created, unlikely error"); return }
//                let session = URLSession(configuration: URLSessionConfiguration.default)
//                var request = URLRequest(url: validationURL)
//                request.httpMethod = "POST"
//                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
//                let task = session.uploadTask(with: request, from: requestData) { (data, response, error) in
//                    if let data = data , error == nil {
//                        do {
//                            let appReceiptJSON = try JSONSerialization.jsonObject(with: data)
//                            print("success. here is the json representation of the app receipt: \(appReceiptJSON)")
//                            // if you are using your server this will be a json representation of whatever your server provided
//                        } catch let error as NSError {
//                            print("json serialization failed with error: \(error)")
//                        }
//                    } else {
//                        print("the upload task returned an error: \(error)")
//                    }
//                }
//                task.resume()
//            } catch let error as NSError {
//                print("json serialization failed with error: \(error)")
//            }
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
