
//
//  AdInterstitialViewController.swift
//  Hunter Cats
//
//  Created by David Yuste on 2/19/15.
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

class AdInterstitialViewController : UIViewController {
	
	@IBOutlet weak var adSubView: UIScrollView!
	@IBOutlet weak var skipButton: UIButton!
	private var skipCountDown : Int = 0
	private var visible : Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		visible = true
		fireCountDown()
	}
	
	override func viewWillDisappear(animated: Bool) {
		visible = false
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func skipButtonClick(sender: AnyObject) {
		AdManager.Singleton.dismissInterstitial()
	}
	
	private func fireCountDown() {
		skipCountDown = 10
		skipButton.enabled = false
		
		updateCountDownButton()
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64(NSEC_PER_SEC) * 1)), dispatch_get_main_queue(), updateCountDown)
	}
	
	private func updateCountDown() {
		if visible {
			skipCountDown--
			updateCountDownButton()
			
			if self.skipCountDown > 0 {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64(NSEC_PER_SEC) * 1)), dispatch_get_main_queue(), updateCountDown)
			}
		}
	}
	
	private func updateCountDownButton() {
		if visible {
			var buttonText : String = ""
			
			if skipCountDown > 0 {
				buttonText = NSLocalizedString("Skip in", comment: "") + " \(skipCountDown) " + NSLocalizedString("seconds", comment: "")
			} else {
				buttonText = NSLocalizedString("Skip Ad", comment: "")
				skipButton.enabled = true
			}
			skipButton.setTitle(buttonText, forState: .Normal)
			skipButton.setTitle(buttonText, forState: .Selected)
		}
	}
}
