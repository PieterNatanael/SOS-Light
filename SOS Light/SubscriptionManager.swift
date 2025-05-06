//
//  SubscriptionManager.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 05/05/25.
//


import SwiftUI
import StoreKit

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    private let yearlySubscriptionID = "com.soslight.fullversion"
    
    @Published var products: [Product] = []
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Transaction listener
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        // Check subscription status on init
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // Listen for transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Update the user's subscription status
                    await self.checkSubscriptionStatus()
                    
                    // Always finish a transaction
                    await transaction.finish()
                } catch {
                    // Handle errors here
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    // Load available products
    @MainActor
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Request products from the App Store
            let storeProducts = try await Product.products(for: [yearlySubscriptionID])
            
            // Update the published products property
            products = storeProducts
            
            if products.isEmpty {
                self.errorMessage = "No products found."
            }
        } catch {
            self.errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Failed to load products: \(error)")
        }
        
        isLoading = false
    }
    
    // Purchase a product
    @MainActor
    func purchase() async {
        guard let product = products.first(where: { $0.id == yearlySubscriptionID }) else {
            errorMessage = "Product not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Begin a purchase
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check if the transaction is verified
                let transaction = try checkVerified(verification)
                
                // Update subscription status
                await checkSubscriptionStatus()
                
                // Always finish a transaction
                await transaction.finish()
                
            case .userCancelled:
                errorMessage = "Purchase cancelled"
                
            case .pending:
                errorMessage = "Purchase pending"
                
            @unknown default:
                errorMessage = "Unknown purchase result"
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            print("Purchase failed: \(error)")
        }
        
        isLoading = false
    }
    
    // Restore purchases
    @MainActor
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        // Try-catch block because AppStore.sync() can throw errors
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
            print("Failed to restore purchases: \(error)")
        }
        
        isLoading = false
    }
    
    // Check subscription status
    @MainActor
    func checkSubscriptionStatus() async {
        // Remove the unnecessary do-catch block that was causing the warning
        var isCurrentlySubscribed = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this transaction is for our subscription product
                if transaction.productID == yearlySubscriptionID {
                    isCurrentlySubscribed = true
                    break
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        self.isSubscribed = isCurrentlySubscribed
    }
    
    // Helper function to verify transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // Custom error enum
    enum StoreError: Error {
        case failedVerification
    }
}

//perbaiki warning catchblock
//import SwiftUI
//import StoreKit
//
//class SubscriptionManager: ObservableObject {
//    static let shared = SubscriptionManager()
//    
//    private let yearlySubscriptionID = "com.soslight.fullversion"
//    
//    @Published var products: [Product] = []
//    @Published var isSubscribed = false
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    // Transaction listener
//    private var updateListenerTask: Task<Void, Error>?
//    
//    init() {
//        updateListenerTask = listenForTransactions()
//        
//        // Check subscription status on init
//        Task {
//            await checkSubscriptionStatus()
//        }
//    }
//    
//    deinit {
//        updateListenerTask?.cancel()
//    }
//    
//    // Listen for transactions
//    private func listenForTransactions() -> Task<Void, Error> {
//        return Task.detached {
//            // Iterate through any transactions that don't come from a direct call to `purchase()`.
//            for await result in Transaction.updates {
//                do {
//                    let transaction = try self.checkVerified(result)
//                    
//                    // Update the user's subscription status
//                    await self.checkSubscriptionStatus()
//                    
//                    // Always finish a transaction
//                    await transaction.finish()
//                } catch {
//                    // Handle errors here
//                    print("Transaction failed verification: \(error)")
//                }
//            }
//        }
//    }
//    
//    // Load available products
//    @MainActor
//    func loadProducts() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            // Request products from the App Store
//            let storeProducts = try await Product.products(for: [yearlySubscriptionID])
//            
//            // Update the published products property
//            products = storeProducts
//            
//            if products.isEmpty {
//                self.errorMessage = "No products found."
//            }
//        } catch {
//            self.errorMessage = "Failed to load products: \(error.localizedDescription)"
//            print("Failed to load products: \(error)")
//        }
//        
//        isLoading = false
//    }
//    
//    // Purchase a product
//    @MainActor
//    func purchase() async {
//        guard let product = products.first(where: { $0.id == yearlySubscriptionID }) else {
//            errorMessage = "Product not available"
//            return
//        }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            // Begin a purchase
//            let result = try await product.purchase()
//            
//            switch result {
//            case .success(let verification):
//                // Check if the transaction is verified
//                let transaction = try checkVerified(verification)
//                
//                // Update subscription status
//                await checkSubscriptionStatus()
//                
//                // Always finish a transaction
//                await transaction.finish()
//                
//            case .userCancelled:
//                errorMessage = "Purchase cancelled"
//                
//            case .pending:
//                errorMessage = "Purchase pending"
//                
//            @unknown default:
//                errorMessage = "Unknown purchase result"
//            }
//        } catch {
//            errorMessage = "Purchase failed: \(error.localizedDescription)"
//            print("Purchase failed: \(error)")
//        }
//        
//        isLoading = false
//    }
//    
//    // Restore purchases
//    @MainActor
//    func restorePurchases() async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            try await AppStore.sync()
//            await checkSubscriptionStatus()
//        } catch {
//            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
//            print("Failed to restore purchases: \(error)")
//        }
//        
//        isLoading = false
//    }
//    
//    // Check subscription status
//    @MainActor
//    func checkSubscriptionStatus() async {
//        do {
//            // Check for active subscriptions
//            var isCurrentlySubscribed = false
//            
//            for await result in Transaction.currentEntitlements {
//                do {
//                    let transaction = try checkVerified(result)
//                    
//                    // Check if this transaction is for our subscription product
//                    if transaction.productID == yearlySubscriptionID {
//                        isCurrentlySubscribed = true
//                        break
//                    }
//                } catch {
//                    print("Failed to verify transaction: \(error)")
//                }
//            }
//            
//            self.isSubscribed = isCurrentlySubscribed
//        } catch {
//            print("Failed to check subscription status: \(error)")
//        }
//    }
//    
//    // Helper function to verify transaction
//    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
//        switch result {
//        case .unverified:
//            throw StoreError.failedVerification
//        case .verified(let safe):
//            return safe
//        }
//    }
//    
//    // Custom error enum
//    enum StoreError: Error {
//        case failedVerification
//    }
//}
