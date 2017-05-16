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

class BackButtonWidget : UIButton {
	
	weak var parentViewController : UIViewController?
	
	init () {
		super.init(frame: CGRectMake(0,0,100,100))
		createLayout()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func addToView(viewController : YCViewController, view : UIView?) {
		parentViewController = viewController
		let targetView = view != nil ? view! : viewController.view!
		
		targetView.addSubview(self)
		Layout.setConstraints(targetView,
			constraints : [
				"V:[b(H)]|",
				"H:|[b(W)]"],
			metrics: [
				"W" : 100.0,
				"H" : 100.0
			],
			views: [
				"b" : self
			],
			options: nil)
		targetView.bringSubviewToFront(self)
		viewController.registerWidget(self)
	}

	func buttonPressed() {
		NavigationManager.Singleton.backToController(HomeViewController.self)
	}
	
	private func createLayout() {
		setImage(UIImage(named: "BackButton"), forState: .Normal)
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = Colors.TransparentColor
		
		addTarget(self,
			action: "buttonPressed",
			forControlEvents: UIControlEvents.TouchUpInside)
	}
}
