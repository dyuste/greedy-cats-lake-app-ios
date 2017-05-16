//
//  GameAdapter.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/21/15.
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
import iAd


protocol AdDelegate : Delegate {
	func adsStatusUpdated(adsEnabled : Bool)
}

class AdManager : Manager, ADInterstitialAdDelegate, InAppPurchaseDelegate {
	override init () {
		super.init()
		InAppPurchaseManager.Singleton.addDelegate(self)
		InAppPurchaseManager.Singleton.loadProducts()
	}
	
	class var Singleton : AdManager {
		struct singleton {
			static let instance = AdManager()
		}
		return singleton.instance
	}

	// ---
	/// InAppPurchaseDelegate
	var adsEnabled : Bool = false
	func productsUpdated(products: [String: Product]) {
		if let premiumUserProduct = products[InAppPurchaseManager.ProductPremiumUserId] {
			adsEnabled = !premiumUserProduct.purchased
			Logger.Info("AdManager::productsUpdated - Product status updated to \(adsEnabled)")
			
			for delegate in delegates {
				if let adDelegate = delegate as? AdDelegate {
					adDelegate.adsStatusUpdated(adsEnabled)
				}
			}
		}
	}
	
	// ---
	// Interstitial
	private var interstitialAd : ADInterstitialAd!
	private var interstitialAdViewController : AdInterstitialViewController!
	private var interstitialAdComplete : ((Bool) -> Void)?

	var interstitialIsLoaded : Bool {
		get {
			return interstitialAd != nil && interstitialAd.loaded
		}
	}
	
	func loadInterstitial() {
		if interstitialAd == nil {
			interstitialAd = ADInterstitialAd()
			interstitialAd.delegate = self
		}
	}
	
	func presentInterstitial(complete : ((Bool) -> Void)?) {
		if interstitialIsLoaded && adsEnabled {
			let appDelegate = UIApplication.sharedApplication().delegate
			let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
			
			// Instantiate view and controller
			interstitialAdViewController = storyboard.instantiateViewControllerWithIdentifier("AdInterstitialView") as! AdInterstitialViewController
			//let interstitialAdView = interstitialAdViewController.adSubView
			
			// Get top application view controller
			var topController : UIViewController! = appDelegate!.window?!.rootViewController;
			while (topController.presentedViewController != nil) {
				topController = topController.presentedViewController;
			}
			
			// Set up view
			//interstitialAdView.frame = topController.view.bounds
			
			// Present view
			interstitialAdComplete = complete
			topController?.presentViewController(interstitialAdViewController, animated: true, completion: {
				self.interstitialAd.presentInView(self.interstitialAdViewController.adSubView)
			})
		} else {
			complete?(false)
			interstitialAd = nil
		}
	}
	
	func dismissInterstitial() {
		if interstitialAdViewController != nil && interstitialAdViewController.presentingViewController != nil {
			interstitialAdViewController.dismissViewControllerAnimated(true, completion: {
				if self.interstitialAdComplete != nil {
					self.interstitialAdComplete?(true)
				}
				
				self.interstitialAdViewController = nil
				self.interstitialAdComplete = nil
			})
		}
		self.interstitialAd = nil
	}
	
	// ---
	// InterstitialDelegate
	func interstitialAdWillLoad(interstitialAd: ADInterstitialAd!) {
		Logger.Info("AdManager::interstitialAdWillLoad - start loading")

	}
	
	func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
		Logger.Info("AdManager::interstitialAdDidLoad - loaded")
	}
	
	func interstitialAdActionDidFinish(interstitialAd: ADInterstitialAd!) {
		dismissInterstitial()
	}
	
	func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
		return true
	}
	
	func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
		Logger.Error("AdManager::interstitialAd:didFailWithError - \(error.localizedDescription)")

		dismissInterstitial()
	}
	
	func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
		dismissInterstitial()
	}
}
