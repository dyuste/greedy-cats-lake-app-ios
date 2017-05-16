//
//  IAPProductTableViewCell.swift
//  greedycats
//
//  Created by David Yuste on 11/18/15.
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

class IAPProductTableViewCell: YCTableViewCell {
	//Make button and label
	var productImageView : UIImageView!
	var titleLabel : UILabel!
	var descriptionLabel: UILabel!
	var statusLabel : UILabel!
	var priceLabel : UILabel!
	var actionButton : UIButton!
	var buyActionEnabled : Bool = false
	
	init(reuseIdentifier : String)
	{
		super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
		createLayout()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	var product : Product?
	{
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
	
	func updateLayoutWithProduct(product : Product)
	{
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
			productImageView.image = UIImage(named: "ProductPremiumUser")
		}
	}
	
	private func createLayout() {
		selectionStyle = UITableViewCellSelectionStyle.None
		
		backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
		productImageView = UIImageView()
		productImageView.contentMode = .Center
		productImageView.translatesAutoresizingMaskIntoConstraints = false
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
		leftColumnView.addSubview(productImageView)
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
		
		contentView.addSubview(headColumnView)
		contentView.addSubview(contentColumnView)
		
		let viewsDictionary = [
			"image" : productImageView,
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
			"imageW" : Metrics.OneThirdWidth,
			"actionW" : Metrics.RoundButtonWidth
		]
		
		Layout.setConstraints(leftColumnView,
			constraints : [
				"V:|[image]|",
				"H:|[image]|"],
			metrics: metricsDictionary, views: viewsDictionary,
			options: nil)
		Layout.setConstraints(middleColumnView,
			constraints : [
				"V:|-[desc]-\(Metrics.HugeSeparator)-[status]",
				"H:|[desc]|",
				"H:[status]-\(Metrics.HugeSeparator)-|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		Layout.setConstraints(rightColumnView,
			constraints : [
				"V:[action(actionW)]-|",
				"H:[action(actionW)]-|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		Layout.setConstraints(contentColumnView,
			constraints : [
				"V:|[left]|",
				"V:|[middle]|",
				"V:|[right]|",
				"H:|[left(imageW)]-[middle(>=imageW)]-[right(actionW)]|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		
		Layout.setConstraints(headColumnView,
			constraints : [
				"H:|[title(>=imageW)][price]|",
				"V:|-\(Metrics.HugeSeparator)-[title]|",
				"V:|-\(Metrics.HugeSeparator)-[price]|"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		
		Layout.setConstraints(contentView,
			constraints : [
				"H:|-16-[head]-\(Metrics.HugeSeparator)-|",
				"H:|-[content]-|",
				"V:|-[head]-\(Metrics.HugeSeparator)-[content]"],
			metrics: metricsDictionary, views: viewsDictionary, options: nil)
		
		
		if _product != nil {
			updateLayoutWithProduct(_product!)
		}
	}
}
