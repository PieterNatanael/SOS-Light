//
//  StoreManager.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 01/05/25.
//


//import StoreKit
//import SwiftUI
//
//@MainActor
//class SubscriptionManager: ObservableObject {
//    static let shared = SubscriptionManager()
//    
//    @Published var products: [Product] = []
//    @Published var primaryProduct: Product?
//    @Published var isSubscribed: Bool = false
//
//    private let subscriptionID = "com.soslight.fullversion" // Your only product
//
//    func loadProducts() async {
//        do {
//            let fetched = try await Product.products(for: [subscriptionID])
//            products = fetched
//            primaryProduct = fetched.first
//            await updateSubscriptionStatus()
//        } catch {
//            print("Error loading products: \(error)")
//        }
//    }
//
//    func startTransactionListener() {
//        Task.detached {
//            for await update in Transaction.updates {
//                if case .verified(let transaction) = update,
//                   transaction.productID == self.subscriptionID {
//                    await transaction.finish()
//                    await MainActor.run {
//                        self.isSubscribed = true
//                    }
//                }
//            }
//        }
//    }
//
//    
//    
//    func purchase() async {
//        // Ensure product is loaded
//        if primaryProduct == nil {
//            await loadProducts()
//        }
//        guard let product = primaryProduct else {
//            print("Product not available")
//            return
//        }
//
//        do {
//            let result = try await product.purchase()
//            switch result {
//            case .success(let verification):
//                if case .verified(let transaction) = verification {
//                    await transaction.finish()
//                    await updateSubscriptionStatus()
//                }
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
//            if case .verified(let transaction) = result,
//               transaction.productID == subscriptionID,
//               transaction.revocationDate == nil,
//               transaction.expirationDate ?? .distantFuture > Date() {
//                isSubscribed = true
//                return
//            }
//        }
//        isSubscribed = false
//    }
//
//    func restorePurchases() async {
//        try? await AppStore.sync()
//        await updateSubscriptionStatus()
//    }
//}

//import StoreKit
//import SwiftUI
//
//@MainActor
//class SubscriptionManager: ObservableObject {
//    static let shared = SubscriptionManager()
//    
//    @Published var products: [Product] = []
//    @Published var isSubscribed: Bool = false
//    
//    private let subscriptionID = "com.soslight.fullversion" // Replace with your actual Product ID
//    
//    func loadProducts() async {
//        do {
//            products = try await Product.products(for: [subscriptionID])
//            await updateSubscriptionStatus()
//        } catch {
//            print("Error loading products: \(error)")
//        }
//    }
//    
//    func purchase(product: Product) async {
//        do {
//            let result = try await product.purchase()
//            switch result {
//            case .success(let verification):
//                if case .verified(let transaction) = verification {
//                    await transaction.finish()
//                    await updateSubscriptionStatus()
//                }
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
//            if case .verified(let transaction) = result,
//               transaction.productID == subscriptionID,
//               transaction.revocationDate == nil,
//               transaction.expirationDate ?? .distantFuture > Date() {
//                isSubscribed = true
//                return
//            }
//        }
//        isSubscribed = false
//    }
//    
//    func restorePurchases() async {
//        try? await AppStore.sync()
//        await updateSubscriptionStatus()
//    }
//}


//import StoreKit
//import Foundation
//
//class InAppPurchaseManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    static let shared = InAppPurchaseManager()
//    private override init() {
//        super.init()
//        SKPaymentQueue.default().add(self)
//    }
//
//    @Published var isSubscribed = false
//    @Published var product: SKProduct?
//
//    private let subscriptionProductID = "soslight.fullaccess"
//    private var productsRequest: SKProductsRequest?
//
//    func fetchProduct() {
//        let productIdentifiers = Set([subscriptionProductID])
//        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
//        productsRequest?.delegate = self
//        productsRequest?.start()
//    }
//
//    func buySubscription() {
//        guard let product = product else { return }
//        let payment = SKPayment(product: product)
//        SKPaymentQueue.default().add(payment)
//    }
//
//    // MARK: - SKProductsRequestDelegate
//
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        DispatchQueue.main.async {
//            if let foundProduct = response.products.first(where: { $0.productIdentifier == self.subscriptionProductID }) {
//                self.product = foundProduct
//            }
//        }
//    }
//
//    // MARK: - SKPaymentTransactionObserver
//
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased, .restored:
//                if transaction.payment.productIdentifier == subscriptionProductID {
//                    complete(transaction: transaction, isSubscribed: true)
//                }
//            case .failed:
//                SKPaymentQueue.default().finishTransaction(transaction)
//            default:
//                break
//            }
//        }
//    }
//
//    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        let hasSubscription = queue.transactions.contains {
//            $0.payment.productIdentifier == subscriptionProductID && $0.transactionState == .restored
//        }
//        DispatchQueue.main.async {
//            self.isSubscribed = hasSubscription
//        }
//    }
//
//    private func complete(transaction: SKPaymentTransaction, isSubscribed: Bool) {
//        DispatchQueue.main.async {
//            self.isSubscribed = isSubscribed
//        }
//        SKPaymentQueue.default().finishTransaction(transaction)
//    }
//}

//import Foundation
//import StoreKit
//
//class InAppPurchaseManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    static let shared = InAppPurchaseManager()
//
//    @Published var isSubscribed = false
//    @Published var product: SKProduct?
//    @Published var productFetchFailed = false
//
//    let productID = "com.soslight.fullversion"
//
//    private override init() {
//        super.init()
//        SKPaymentQueue.default().add(self)
//        fetchProduct()
//        checkSubscriptionStatus()
//    }
//
//    // MARK: - Fetch Product
//    func fetchProduct() {
//        let request = SKProductsRequest(productIdentifiers: [productID])
//        request.delegate = self
//        request.start()
//
//        // Timeout fallback in case nothing returns
//        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//            if self.product == nil {
//                print("⚠️ Product fetch timed out.")
//                self.productFetchFailed = true
//            }
//        }
//    }
//
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        DispatchQueue.main.async {
//            if let fetchedProduct = response.products.first {
//                print("✅ Product fetched: \(fetchedProduct.localizedTitle)")
//                self.product = fetchedProduct
//                self.productFetchFailed = false
//            } else {
//                print("⚠️ No valid products found.")
//                self.productFetchFailed = true
//            }
//
//            if !response.invalidProductIdentifiers.isEmpty {
//                print("❌ Invalid product IDs: \(response.invalidProductIdentifiers)")
//            }
//        }
//    }
//
//    // MARK: - Buy
//    func buySubscription() {
//        guard let product = product else {
//            print("❌ Cannot purchase: product not loaded.")
//            return
//        }
//        let payment = SKPayment(product: product)
//        SKPaymentQueue.default().add(payment)
//    }
//
//    // MARK: - Restore & Status Check
//    func checkSubscriptionStatus() {
//        print("🔄 Checking for restored transactions...")
//        SKPaymentQueue.default().restoreCompletedTransactions()
//    }
//
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased, .restored:
//                DispatchQueue.main.async {
//                    self.isSubscribed = true
//                    print("✅ Subscription active.")
//                }
//                SKPaymentQueue.default().finishTransaction(transaction)
//            case .failed:
//                if let error = transaction.error {
//                    print("❌ Purchase failed: \(error.localizedDescription)")
//                }
//                SKPaymentQueue.default().finishTransaction(transaction)
//            default:
//                break
//            }
//        }
//    }
//
//    // Optional: Helper for formatted price
//    func localizedPrice() -> String {
//        guard let product = product else { return "" }
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.locale = product.priceLocale
//        return formatter.string(from: product.price) ?? ""
//    }
//}



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
//            DispatchQueue.main.async {
//                self.product = fetchedProduct
//            }
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
//                DispatchQueue.main.async {
//                    self.isSubscribed = true
//                }
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
