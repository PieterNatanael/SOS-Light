//
//  StoreManager.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 01/05/25.
//

import Foundation
import StoreKit

class InAppPurchaseManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = InAppPurchaseManager()

    @Published var isSubscribed = false
    @Published var product: SKProduct?

    let productID = "com.soslight.fullversion"

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProduct()
    }

    func fetchProduct() {
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let fetchedProduct = response.products.first {
            DispatchQueue.main.async {
                self.product = fetchedProduct
            }
        }
    }

    func buySubscription() {
        guard let product = product else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                DispatchQueue.main.async {
                    self.isSubscribed = true
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                if let error = transaction.error {
                    print("Purchase failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}


//import Foundation
//import StoreKit
//
//class InAppPurchaseManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    static let shared = InAppPurchaseManager()
//
//    @Published var isSubscribed = false
//    @Published var product: SKProduct?
//
//    let productID = "com.soslight.fullversion"
////    let productID = "com.yourcompany.soslight.fullversion"
//
//    private override init() {
//        super.init()
//        SKPaymentQueue.default().add(self)
//        fetchProduct()
//    }
//
//    func fetchProduct() {
//        let request = SKProductsRequest(productIdentifiers: [productID])
//        request.delegate = self
//        request.start()
//    }
//
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        if let fetchedProduct = response.products.first {
//            product = fetchedProduct
//        }
//    }
//
//    func buySubscription() {
//        guard let product = product else { return }
//        let payment = SKPayment(product: product)
//        SKPaymentQueue.default().add(payment)
//    }
//
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased, .restored:
//                isSubscribed = true
//                SKPaymentQueue.default().finishTransaction(transaction)
//            case .failed:
//                if let error = transaction.error {
//                    print("Purchase failed: \(error.localizedDescription)")
//                }
//                SKPaymentQueue.default().finishTransaction(transaction)
//            default:
//                break
//            }
//        }
//    }
//}


//import StoreKit
//
//@MainActor
//class StoreManager: ObservableObject {
//    @Published var isSubscribed = false
//    @Published var products: [Product] = []
//
//    let subscriptionID = "com.yourcompany.soslight.fullversion"
//
//    init() {
//        Task {
//            await requestProducts()
//            await updateSubscriptionStatus()
//        }
//    }
//
//    func requestProducts() async {
//        do {
//            let storeProducts = try await Product.products(for: [subscriptionID])
//            products = storeProducts
//        } catch {
//            print("Failed to fetch products: \(error)")
//        }
//    }
//
//    func purchase(product: Product) async {
//        do {
//            let result = try await product.purchase()
//            switch result {
//            case .success(.verified(let transaction)):
//                print("Purchase success: \(transaction.productID)")
//                await transaction.finish()
//                isSubscribed = true
//            case .userCancelled:
//                print("User cancelled.")
//            default:
//                break
//            }
//        } catch {
//            print("Purchase failed: \(error)")
//        }
//    }
//
//    func updateSubscriptionStatus() async {
//        for await result in Transaction.currentEntitlements {
//            switch result {
//            case .verified(let transaction) where transaction.productID == subscriptionID:
//                isSubscribed = true
//                return
//            default:
//                continue
//            }
//        }
//        isSubscribed = false
//    }
//}
