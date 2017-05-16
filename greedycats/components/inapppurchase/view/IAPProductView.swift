//
//  IAPProductWidget.swift
//  greedycats
//
//  Created by David Yuste on 10/26/15.
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
import UIKit

class IAPProductView: UIView {
	//Make button and label
	var imageView : UIImageView!
	var titleLabel : UILabel!
	var descriptionLabel: UILabel!
	var statusLabel : UILabel!
	var priceLabel : UILabel!
	var actionButton : UIButton!
	var buyActionEnabled : Bool = false
	
	var product : Product? {
		set {
			_product = newValue
			if _product != nil {
				updateLayoutWithProduct(_product!)
			}
		}
		get {
			return _product
		}
	}
	
	private var _product : Product?
	
	//func actionButtonPressed() {
	//
	//}
	
	override init (frame : CGRect) {
		super.init(frame : frame)
		
		createLayout()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func updateLayoutWithProduct(product : Product) {
		if product.skProduct != nil {
			let numberFormatter = NSNumberFormatter()
			numberFormatter.formatterBehavior = .Behavior10_4
			numberFormatter.numberStyle = .CurrencyStyle
			numberFormatter.locale = product.skProduct!.priceLocale
			let formattedPrice = numberFormatter.stringFromNumber(product.skProduct!.price)
			
			var actionImageName : String = "BuyButton"
			buyActionEnabled = true
			var statusText : String = ""
			switch (product.status) {
			case .Available:
				statusText = NSLocalizedString("Available", comment: "InAppPurchase product state")			case .InProgress:
				statusText = NSLocalizedString("Starting purchase", comment: "InAppPurchase product state")
				buyActionEnabled = false
			case .Purchasing:
				statusText = NSLocalizedString("Purchasing", comment: "InAppPurchase product state")
				buyActionEnabled = false
			case .Purchased:
				statusText = NSLocalizedString("Purchased", comment: "InAppPurchase product state")
				buyActionEnabled = false
				actionImageName = "OkButton"
			case .Failed:
				statusText = NSLocalizedString("Purchase failed, try again", comment: "InAppPurchase product state")
			case .Restored:
				statusText = NSLocalizedString("Purchase restored", comment: "InAppPurchase product state")
				buyActionEnabled = false
				actionImageName = "OkButton"
			case .Deferred:
				statusText = NSLocalizedString("Purchase deferred", comment: "InAppPurchase product state")
			default: statusText = ""
			}
			titleLabel.text = product.skProduct!.localizedTitle
			descriptionLabel.text = product.skProduct!.localizedDescription
			statusLabel.text = statusText
			priceLabel.text = formattedPrice
			
			actionButton.setImage(UIImage(named: actionImageName), forState: .Normal)
			imageView.image = UIImage(named: "ProductPremiumUser")
		}
	}
	
	private func createLayout() {
		backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
		imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		titleLabel = UILabel()
		titleLabel.textColor = Colors.ButtonTextColor
		titleLabel.font = Fonts.DefaultH1Font
		titleLabel.shadowColor = UIColor.blackColor()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel = UILabel()
		descriptionLabel.textColor = Colors.ButtonTextColor
		descriptionLabel.font = Fonts.DefaultH3Font
		descriptionLabel.adjustsFontSizeToFitWidth = false
		descriptionLabel.numberOfLines = 0
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		statusLabel = UILabel()
		statusLabel.textColor = Colors.DisabledButtonTextColor
		statusLabel.font = Fonts.DefaultH3Font
		statusLabel.translatesAutoresizingMaskIntoConstraints = false
		priceLabel = UILabel()
		priceLabel.textColor = Colors.ButtonTextColor
		priceLabel.font = Fonts.DefaultH1Font
		priceLabel.shadowColor = UIColor.blackColor()
		priceLabel.translatesAutoresizingMaskIntoConstraints = false
		actionButton = UIButton()
		actionButton.translatesAutoresizingMaskIntoConstraints = false

		let leftColumnView = UIView()
		leftColumnView.addSubview(imageView)
		leftColumnView.translatesAutoresizingMaskIntoConstraints = false
		
		let middleColumnView = UIView()
		middleColumnView.addSubview(descriptionLabel)
		middleColumnView.addSubview(statusLabel)
		middleColumnView.translatesAutoresizingMaskIntoConstraints = false
		
		let rightColumnView = UIView()
		rightColumnView.addSubview(actionButton)
		rightColumnView.translatesAutoresizingMaskIntoConstraints = false
		
		let contentColumnView = UIView()
		contentColumnView.addSubview(leftColumnView)
		contentColumnView.addSubview(middleColumnView)
		contentColumnView.addSubview(rightColumnView)
		contentColumnView.translatesAutoresizingMaskIntoConstraints = false
		
		let headColumnView = UIView()
		headColumnView.addSubview(titleLabel)
		headColumnView.addSubview(priceLabel)
		headColumnView.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(headColumnView)
		addSubview(contentColumnView)
		
		let viewsDictionary = [
			"image" : imageView,
			"title" : titleLabel,
			"desc" : descriptionLabel,
			"status" : statusLabel,
			"price" : priceLabel,
			"action" : actionButton,
			"left" : leftColumnView,
			"middle" : middleColumnView,
			"right" : rightColumnView,
			"head" : headColumnView,
			"content" : contentColumnView
		]
		
		let metricsDictionary = [
			"imageW" : 150.0,
			"cardH" : 300.0,
			"actionW" : 90.0
		]
		
		Layout.setConstraints(leftColumnView,
			constraints : [
				"V:|[image]",
				"H:|[image]"],
			metrics: metricsDictionary, views: viewsDictionary,
			options: nil)
		Layout.setConstraints(middleColumnView,
			constraints : [
				"V:|-[desc]-30-[status]",
				"H:|[desc]|",
				"H:[status]-20-|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		Layout.setConstraints(rightColumnView,
			constraints : [
				"V:|-[action(actionW)]",
				"H:[action(actionW)]-|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		Layout.setConstraints(contentColumnView,
			constraints : [
				"V:|[left(imageW)]",
				"V:|[middle(cardH)]",
				"V:|[right(cardH)]",
				"H:|[left(imageW)]-[middle(>=imageW)]-[right(actionW)]|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		
		Layout.setConstraints(headColumnView,
			constraints : [
				"H:|[title(>=imageW)][price]|",
				"V:|-12-[title]|",
				"V:|-12-[price]|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		
		Layout.setConstraints(self,
			constraints : [
				"H:|-16-[head]-30-|",
				"H:|-[content]-|",
				"V:|-[head]-30-[content]"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		
		
		if _product != nil {
			updateLayoutWithProduct(_product!)
		}
	}
}
