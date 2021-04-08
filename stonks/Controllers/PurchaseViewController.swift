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

class PurchaseViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    private var productId = "premiumstockinfo"
    private var cancelSubscriptionUrl:String = "https://apps.apple.com/account/subscriptions"
    private var subscriptionPrice:String = "$9.99"
    private var buttonAction:ButtonAction = ButtonAction.purchase
    private var product:SKProduct?
    private var receipt: [String : Any]?
    
    enum ButtonAction {
        case purchase
        case cancel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.requestProducts()
        self.receiptValidation()
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        if self.product != nil {
            self.buyProduct(self.product!)
        }
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    public func requestProducts() {
        var productIds:Set<String> = Set()
        productIds.insert(self.productId)
        let productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func cancelAction(){
        if let url = URL(string: self.cancelSubscriptionUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    func subscribeAction(){
        if self.product != nil {
            self.buyProduct(product!)
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
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        
        //tell our backend that the user purchased successfully
        
        //notify user that the purchase was successful
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        //deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        //called when user clicks cancel
        print("fail...")
        if let _ = transaction.error as NSError?, let localizedDescription = transaction.error?.localizedDescription {
            print("Transaction Error: \(localizedDescription)")
        }

        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        NotificationCenter.default.post(name: .init("Test Notification"), object: identifier)
     }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products:[SKProduct] = response.products
        if products.count > 0 {
            self.product = products[0]
            print("Found product: \(product!.productIdentifier) \(product!.localizedTitle) \(product!.price.floatValue)")
        }
    }
    
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("SKRequest failed")
    }
    
    func receiptValidation() {
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
            
            NetworkManager.getMyRestApi().verifyReceipt(encodedReceipt) { (data) in
                if let jsonstring = data.rawString() {
                    let data = jsonstring.data(using: .utf8)
                    if let data = data {
                        do {
                            self.receipt = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                            if let receipt = self.receipt as [String:AnyObject]? {
                                //print(receipt)
                                if receipt["receipt"] != nil {
                                    if receipt["receipt"]!["in_app"] != nil {
                                        let inapp = receipt["receipt"]!["in_app"] as! NSArray
                                        if inapp.count > 0 {
                                            let first = inapp[0] as! NSDictionary
                                            if first["transaction_id"] != nil {
                                                print(first["transaction_id"]!)
                                            }
                                        }
                                    }
                                }
                                var hasActiveSubscription:Bool = false
                                var expirationDate:Int?
                                var expirationDateString:String = ""
                                var autoRenews:Bool = false
                                var cancelled:Bool = false
                                var expirationReason:String = ""
                                if let latestReceipt = self.getLatestReceipt(receipt) {
                                    expirationDate = self.hasActiveSubscription(latestReceipt)
                                    if let expirationDate = expirationDate {
                                        expirationDateString = GeneralUtility.timestampToDateString(expirationDate)
                                        hasActiveSubscription = true
                                    }
                                    cancelled = self.subscriptionCancelled(latestReceipt)
                                    if let pri = self.getPendingRenewalInfo(receipt) {
                                        autoRenews = self.subscriptionAutoRenews(pri)
                                        expirationReason = self.expirationReason(pri)
                                    }
                                }
                                self.updateData(hasActiveSubscription: hasActiveSubscription, expirationDateString: expirationDateString, autoRenews: autoRenews, cancelled: cancelled, expirationReason: expirationReason)
//                                print("Active subscription: " + String(hasActiveSubscription))
//                                print("Expiration Date: " + expirationDateString)
//                                print("Expiration reason: " + String(expirationReason))
//                                print("Auto-renews: " + String(autoRenews))
//                                print("Cancelled: " + String(cancelled))
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }
            }
            
        }
    }
    
    func updateData(hasActiveSubscription:Bool, expirationDateString:String, autoRenews:Bool, cancelled:Bool, expirationReason:String){
        DispatchQueue.main.async {
            if hasActiveSubscription {
                var topText = ""
                if cancelled {
                    topText += ". Your subscription was cancelled and will not auto-renew. You will keep your subscription benefits until " + expirationDateString
                    self.buttonAction = .purchase
                } else {
                    if !autoRenews {
                        topText += " Your subscription will expire on " + expirationDateString + " and will not auto-renew."
                        self.buttonAction = .purchase
                    } else {
                        topText += " Your subscription will auto-renew on " + expirationDateString + "."
                        self.buttonAction = .cancel
                    }
                }
            } else {
                self.buttonAction = .purchase
            }
        }
    }
    
    func getLatestReceipt(_ receipt:[String:AnyObject]) -> [String:AnyObject]? {
        if let latestReceipts = receipt["latest_receipt_info"] as? [AnyObject] {
            if latestReceipts.count > 0 {
                return latestReceipts[0] as? [String:AnyObject]
            }
        }
        return nil
    }
    
    func getPendingRenewalInfo(_ receipt:[String:AnyObject]) -> [String:AnyObject]? {
        if let pris = receipt["pending_renewal_info"] as? [AnyObject] {
            for pri in pris {
                if let priDict = pri as? [String:AnyObject], priDict["product_id"] as! String == "shobel.stonks" {
                    return priDict
                }
            }
        }
        return nil
    }
    
    func hasActiveSubscription(_ latestReceipt:[String:AnyObject]) -> Int? {
        if latestReceipt["expires_date_ms"] == nil {
            return nil
        }
        if let latestExpiration = Int(latestReceipt["expires_date_ms"] as! String) {
            let now = Date().timeIntervalSince1970
            if latestExpiration/1000 > Int(now) {
                return latestExpiration/1000
            }
        }
        return nil
    }
    
    func subscriptionAutoRenews(_ pendingRenewalInfo:[String:AnyObject]) -> Bool {
        if pendingRenewalInfo["auto_renew_status"] == nil {
            return false
        }
        if let autoRenewStatus = Int(pendingRenewalInfo["auto_renew_status"] as! String) {
            if autoRenewStatus == 1 {
                return true
            }
        }
        return false
    }
    
    func subscriptionCancelled(_ latestReceipt:[String:AnyObject]) -> Bool {
        if latestReceipt["cancellation_date_ms"] != nil {
            return true
        }
        return false
    }
    
    func expirationReason(_ pendingRenewalInfo:[String:AnyObject]) -> String {
        if pendingRenewalInfo["expiration_intent"] == nil {
            return "Unknown"
        }
        if let expirationReason = Int(pendingRenewalInfo["expiration_intent"] as! String) {
            if expirationReason == 1 {
                return "Cancelled"
            } else if expirationReason == 2 {
                return "Billing error"
            } else {
                return "Unknown Error"
            }
        }
        return "Expired"
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
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