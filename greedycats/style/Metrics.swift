//
//  Metrics.swift
//  greedycats
//
//  Created by David Yuste on 11/23/15.
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

class BaseMetrics {
	var WideWidth : CGFloat = 300
	var OneThirdWidth : CGFloat = 150
	var RoundButtonWidth : CGFloat = 90
	
	var HeaderHeight : CGFloat = 130
	var ButtonRowHeight : CGFloat = 55
	var BigRowHeight : CGFloat = 280
	var TextFieldRowHeight : CGFloat = 100
	var GroupTitleWidth : CGFloat = 200
	var GroupTitleHeight : CGFloat = 30
	
	var GameRowHeight : CGFloat = 80
	var UserDetailHeight : CGFloat = 100
	
	var HugeSeparator : CGFloat = 20
	var BigSeparator : CGFloat = 12
	
	var DefaultMargin : CGFloat = 8
	
	var DefaultTableSectionHeaderHeight : CGFloat = 12.0
	var DefaultTableSectionFooterHeight : CGFloat = 12.0
	
	var StatusBarHeight : CGFloat = 20
	
	var MarketIconWidth : CGFloat = 90
	var MarketIconHeight : CGFloat = 91
	
	var ShareIconWidth : CGFloat = 173
	var ShareIconHeight : CGFloat = 91
	
	required init() {
		
	}
}

class Iphone4Metrics : BaseMetrics {
	required init() {
		super.init()
		WideWidth = 240
		OneThirdWidth = 90
		RoundButtonWidth = 50
		
		HeaderHeight = 70
		ButtonRowHeight = 50
		BigRowHeight = 230
		TextFieldRowHeight = 80
		GroupTitleWidth = 150
		GroupTitleHeight = 25
		GameRowHeight = 60
		UserDetailHeight = 85
		
		HugeSeparator = 12
		BigSeparator = 6
		DefaultMargin = 0
		
		DefaultTableSectionHeaderHeight = 8.0
		DefaultTableSectionFooterHeight = 8.0
		
		MarketIconWidth = 63
		MarketIconHeight = 63.7
		
		ShareIconWidth  = 121.1
		ShareIconHeight = 63.7
	}
}

class Iphone5Metrics : Iphone4Metrics {
	required init() {
		super.init()
		
	}
}

class Iphone6Metrics : Iphone5Metrics {
	required init() {
		super.init()
		
	}
}

var Metrics : BaseMetrics!

func buildMetrics() {
	if IS_IPHONE_4_OR_LESS {
		Metrics = Iphone4Metrics()
	} else if IS_IPHONE_5 {
		Metrics = Iphone5Metrics()
	} else if IS_IPHONE_6 || IS_IPHONE_6P {
		Metrics = Iphone6Metrics()
	} else {
		Metrics = BaseMetrics()
	}
}

