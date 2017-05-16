//
//  YCViewController.swift
//  greedycats
//
//  Created by David Yuste on 6/14/15.
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

class YCViewController: UIViewController {
	private var enterForegroundNotification : NSObjectProtocol!
	private var resignForegroundNotification : NSObjectProtocol!
	
	weak var backgroundView : UIView!
	weak var contentView : UIView!
	weak var topView : UIView!
	weak var bannerView : UIView!
	
	var widgets : [UIView] = []
	
	private var backgroundImageView : UIImageView?
	var appendBackgroundDuringLoad = true
	
	required init()
	{
		super.init(nibName: nil, bundle: nil)
		connectNotifications()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
	{
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		connectNotifications()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(enterForegroundNotification)
		NSNotificationCenter.defaultCenter().removeObserver(resignForegroundNotification)
		widgets = []
	}

	func registerWidget(widget : UIView) {
		widgets.append(widget)
	}
	
	private func connectNotifications() {
		enterForegroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			[unowned self] notification in
			self.applicationDidBecomeActive()
		}
		resignForegroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
			[unowned self] notification in
			self.applicationWillResignActive()
		}
	}
	
	func applicationDidBecomeActive() {
	}
	
	func applicationWillResignActive() {
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if appendBackgroundDuringLoad {
			setUpBackground()
		}
		showLoading()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		attachWidgets(topView)
		attachBanner(bannerView)
		attachManagers()
		kickOffView()
		hideLoading()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		attachWidgets(topView)
		attachBanner(bannerView)
		detachManagers()
		releaseView()
	}
	
	func showLoading() {}
	
	func hideLoading() {}
	
	func attachManagers() {}
	
	func detachManagers() {}
	
	func kickOffView() {}
	
	func attachWidgets(topView : UIView) {}
	
	func attachBanner(bannerView : UIView) {}
	
	func releaseView() {
		for widget in widgets {
			widget.removeFromSuperview()
		}
		widgets = []
	}
	
	override func loadView() {
		super.loadView()
		
		view = UIView()
		view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
		view.backgroundColor = UIColor.clearColor()
		view.opaque = true
		
		let backgroundView = UIView()
		backgroundView.opaque = true
		backgroundView.backgroundColor = UIColor.clearColor()
		backgroundView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
		view.addSubview(backgroundView)
		self.backgroundView = backgroundView
		
		self.contentView = createContentView()
		
		let topView = YCPassThroughView()
		topView.backgroundColor = UIColor.clearColor()
		topView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(topView, aboveSubview: contentView)
		self.topView = topView
		
		let bannerView = YCPassThroughView()
		bannerView.backgroundColor = UIColor.clearColor()
		bannerView.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(bannerView, aboveSubview: contentView)
		self.bannerView = bannerView
		
		Layout.setConstraints(view,
			constraints : [
				"V:|[t][b(<=66)]|",
				"H:|[t]|",
				"H:|[b]|"],
			metrics: nil,
			views: ["t" : topView, "b" : bannerView],
			options: nil)
	}
	
	func createContentView() -> UIView {
		let contentView = UIView()
		view.insertSubview(contentView, aboveSubview: backgroundView)
		contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
		return contentView
	}
	
	override func viewWillTransitionToSize(size: CGSize,
		withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
			super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
			if backgroundImageView != nil {
				if size.width > size.height {
					backgroundImageView!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
				} else {
					backgroundImageView!.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
				}
			}
	}
	
	func setUpBackground() {
		let backgroundImage = UIImage(named: "Background.png")!
		backgroundImageView = UIImageView(image: backgroundImage)
		backgroundImageView?.removeFromSuperview()
		backgroundImageView!.frame = self.view.bounds
		backgroundImageView!.contentMode = .ScaleAspectFill
		if self.view.bounds.width > self.view.bounds.height {
			backgroundImageView!.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2.0))
		} else {
			backgroundImageView!.transform = CGAffineTransformMakeRotation(CGFloat(0.0))
		}
		backgroundImageView!.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
		backgroundView.addSubview(backgroundImageView!)
	}
}
