//
//  InAppPurchaseManager.swift
//  greedycats
//
//  Created by David Yuste on 10/3/15.
//  Copyright (c) 2015 David Yuste Romero
//
//  THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED
//  OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.
//
//  Permission is hereby granted to use or copy this program
//  for any purpose,  provided the above notices are retained on all copies.
//  Permission to modify the code and to distribute modified code is granted,
//  provided the above notices are retained, and a notice that the code was
//  modified is included with the above copyright notice.
//

import Foundation
import StoreKit

protocol InAppPurchaseDelegate : Delegate {
	func productsUpdated(products: [String: Product])
}

class InAppPurchaseManager : Manager, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	static let ProductPremiumUserId = "com.greedycatslake.premiumuser"
	
	override init () {
		super.init();
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
	}
	
	class var Singleton : InAppPurchaseManager {
		struct singleton {
			static let instance = InAppPurchaseManager()
		}
		return singleton.instance
	}
	
	private var iapViewController : IAPListViewController!
	
	private var products : [String: Product]?
	
	func showShoppingCenter() {
		if iapViewController == nil || !iapViewController.visible {
			displayProductList()
		}
	}
	
	func loadProducts() {
		struct SkProductsCache {
			static var skProducts : [SKProduct]?
		}
		
		if SkProductsCache.skProducts != nil {
			products = self.getPersistentProductDictionaryWithStoreKitList(SkProductsCache.skProducts!)
			self.triggerProductsUpdated()
		} else {
			// Dispatch cached data
			if products == nil {
				products = getPersistentProductDictionary()
			}
			if products!.count >= 0 {
				self.triggerProductsUpdated()
			}
			
			// Refresh products with SkProduct data
			let productIds = getProductIdentifierList()
			fetchProductList(productIds) { skProducts in
				SkProductsCache.skProducts = skProducts
				self.products = self.getPersistentProductDictionaryWithStoreKitList(skProducts)
				self.triggerProductsUpdated()
			}
		}
	}
	
	func buyProduct(product : Product, amount : Int) {
		if let skProduct = product.skProduct {
			let payment = SKPayment(product: skProduct)
			SKPaymentQueue.defaultQueue().addPayment(payment)
			updateProductStatus(product.id, status: .InProgress)
		}
	}
	
	private func triggerProductsUpdated() {
		for delegate in delegates {
			if let iapDelegate = delegate as? InAppPurchaseDelegate {
				iapDelegate.productsUpdated(products!)
			}
		}
	}
	
	private func displayProductList() {
		// Get top application view controller
		NavigationManager.Singleton.forwardToController(IAPListViewController.self)

	}
	
	// MARK: Product fetching
	private var _onProductListFetch : ([SKProduct] -> Void)?
	func fetchProductList(productIds : [String], complete: [SKProduct] -> Void) {
		let productIdSet = NSSet(array: productIds)
		let productsRequest:SKProductsRequest = SKProductsRequest (productIdentifiers: productIdSet as Set<NSObject> as! Set<String>);
		
		self._onProductListFetch = complete
		productsRequest.delegate = self;
		productsRequest.start();
	}
	
	private func getProductIdentifierList() -> [String] {
		var products : [String] = []
		
		if let resourceUrl = NSBundle.mainBundle().URLForResource("iap_products", withExtension: "plist") {
			if NSFileManager.defaultManager().fileExistsAtPath(resourceUrl.path!) {
				let fileContents = NSArray(contentsOfURL: resourceUrl)
				if let foundProducts = fileContents as? [String] {
					products = foundProducts
				}
			} else {
				Logger.Error("InAppPurchaseManager::getProducList : iap_products.plist not found")
			}
		}
		
		return products
	}

	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		let skProducts = response.products
		
		for invalidIdentifier in response.invalidProductIdentifiers {
				Logger.Error("InAppPurchaseManager::productsRequest : Invalid product identifier \(invalidIdentifier)")
		}
		
		_onProductListFetch?(skProducts)
		_onProductListFetch = nil
	}
	
	// MARK: Product buying
	private func addProductToPaymentQueue(product : SKProduct) {
		let payment = SKPayment(product: product)
		SKPaymentQueue.defaultQueue().addPayment(payment)
		updateProductStatus(product.productIdentifier, status: .InProgress)
	}
	
	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			let productIdentifier = transaction.payment.productIdentifier
			
			switch transaction.transactionState {
			case .Purchasing:
				updateProductStatus(productIdentifier, status: .Purchasing)
				
			case .Purchased:
				updateProductStatus(productIdentifier, status: .Purchased)
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				
			case .Failed:
				updateProductStatus(productIdentifier, status: .Failed)
				var errorString : String = ""
				if let error = transaction.error {
					errorString = "(\(error.localizedDescription) - \(error.localizedFailureReason) - \(error.localizedRecoverySuggestion))"
				}
				Logger.Error("InAppPurchaseManager::paymentQueue : Transaction Failed \(errorString)");
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				
			case .Restored:
				updateProductStatus(productIdentifier, status: .Restored)
				
			case .Deferred:
				updateProductStatus(productIdentifier, status: .Deferred)
			}
		}
	}
	
	// MARK: Persistence
	private func updateProductStatus(productIdentifier: String, status : Product.Status) {
		let product = getPersistentProduct(productIdentifier)
		product.status = status
		savePersistentProduct(product)
		loadProducts()
	}
	
	// MARK: Internal product persistence
	// Note: ios UserDefaults persistent storage used
	func getPersistentProductDictionary() -> [String: Product] {
		var products = [String: Product]()
		if let productsData = NSUserDefaults.standardUserDefaults().objectForKey("products")
			as? NSDictionary {
			for (id, productData) in productsData {
				let idNSString = id as? NSString
				let productNSData = productData as? NSData
				if idNSString != nil && productNSData != nil {
					let product = NSKeyedUnarchiver.unarchiveObjectWithData(productNSData!) as? Product
					if product != nil {
						products[idNSString! as String] = product!
					}
				}
			}
		}
		return products
	}
	
	func getPersistentProductDictionaryWithStoreKitList(skProducts : [SKProduct]) -> [String: Product] {
		var products : [String: Product] = getPersistentProductDictionary()
		for skProduct in skProducts {
			var product : Product?
			product = products[skProduct.productIdentifier]
			if product == nil {
				product = Product(id: skProduct.productIdentifier)
				product!.status = .Available
				products[skProduct.productIdentifier] = product
			}
			product!.skProduct = skProduct
		}
		
		// Remove deprecated products
		if products.count != skProducts.count {
			var deprecatedProductIds : [String] = []
			Logger.Info("InAppPurchaseManager::getPersistentProductDictionaryWithStoreKitList : removing deprecaed products")
			for (productId, _) in products {
				var found = false
				for skProduct in skProducts {
					if skProduct.productIdentifier == productId {
						found = true
						break;
					}
				}
				if !found {
					Logger.Info("InAppPurchaseManager::getPersistentProductDictionaryWithStoreKitList : deprecaed product \(productId)")
					deprecatedProductIds.append(productId)
				}
			}
			for productId in deprecatedProductIds {
				products.removeValueForKey(productId)
			}
			savePersistentProductDictionary(products)
		}
		return products
	}
	
	func getPersistentProduct(id : String) -> Product {
		if let product = restorePersistentProduct(id) {
			return product
		} else {
			return Product(id: id)
		}
	}
	
	private func restorePersistentProduct(id : String) -> Product? {
		if let products = NSUserDefaults.standardUserDefaults().objectForKey("products") as? NSDictionary {
			if let productData = products.objectForKey(id) as? NSData {
				return NSKeyedUnarchiver.unarchiveObjectWithData(productData) as? Product
			}
		}
		return nil;
	}
	
	func savePersistentProduct(product : Product) {
		var productsDictionary : NSMutableDictionary?
		let existingProductsDictionary = NSUserDefaults.standardUserDefaults().objectForKey("products") as? NSDictionary
		if existingProductsDictionary == nil {
			productsDictionary = NSMutableDictionary()
		} else {
			productsDictionary = NSMutableDictionary(dictionary: existingProductsDictionary! as [NSObject : AnyObject], copyItems: true)
		}
		
		let productData = NSKeyedArchiver.archivedDataWithRootObject(product)
		productsDictionary!.setObject(productData, forKey: product.id)
		
		NSUserDefaults.standardUserDefaults().setObject(productsDictionary!, forKey: "products")
	}
	
	func savePersistentProductDictionary(products : [String: Product]) {
		let productsDictionary = NSMutableDictionary()
		for (productId, product) in products {
			let productData = NSKeyedArchiver.archivedDataWithRootObject(product)
			productsDictionary.setObject(productData, forKey: productId)
		}
		
		NSUserDefaults.standardUserDefaults().setObject(productsDictionary, forKey: "products")
	}
}
