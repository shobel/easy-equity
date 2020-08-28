//
//  SubscriptionViewController.swift
//  stonks
//
//  Created by Samuel Hobel on 8/26/20.
//  Copyright © 2020 Samuel Hobel. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    private var product:SKProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestProducts()
    }
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    public func requestProducts() {
        var productIds:Set<String> = Set()
        productIds.insert("shobel.stonks")
        var productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    @IBAction func buyTapped(_ sender: Any) {
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
        print("fail...")
        if let transactionError = transaction.error as NSError?, let localizedDescription = transaction.error?.localizedDescription {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
