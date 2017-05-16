//
//  Colors.swift
//  Greedy Cats
//
//  Created by David Yuste on 5/1/15.
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

struct Colors {
	static let BackgroundColor = UIColor(red: 0/255.0, green: 156/255.0, blue: 255/255.0, alpha: 1)
	static let PrimaryColor = UIColor(red: 242/255.0, green: 220/255.0, blue: 30/255.0, alpha: 1)
	static let LighterPrimaryColor = UIColor(red: 247/255.0, green: 234/255.0, blue: 120/255.0, alpha: 1)
	static let DarkerPrimaryColor = UIColor(red: 223/255.0, green: 201/255.0, blue: 13/255.0, alpha: 1)
	static let SecondaryColor = UIColor(red: 234/255.0, green: 184/255.0, blue: 13/255.0, alpha: 1)
	
	static let EnabledFaceColor = PrimaryColor
	static let DarkerEnabledFaceColor = DarkerPrimaryColor
	
	static let EnabledTextColor = UIColor.whiteColor()
	static let DisabledTextColor = UIColor(red: 255/255.0, green: 250/255.0, blue: 178/255.0, alpha: 0.6)
	
	static let ButtonHighlightedFaceColor = SecondaryColor
	static let ButtonFaceColor = PrimaryColor
	static let ButtonTextColor = UIColor.whiteColor()
	static let DisabledButtonTextColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
	
	static let InputBackgroundColor = LighterPrimaryColor
	static let InputTextColor = UIColor.whiteColor()
	static let InputPlaceHolderColor = UIColor.whiteColor()
	
	static let EnacedBlackgroundColor = UIColor(red: 75.0/255.0, green: 120.0/255.0, blue: 220.0/255.0, alpha: 1)
	
	static let TransparentColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
	static let BlackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
	static let WhiteColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
}
