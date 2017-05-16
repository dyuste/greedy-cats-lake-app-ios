//
//  Fonts.swift
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

class BaseFonts {
	var OverlayFontName :String = "Futura-CondensedExtraBold"
	var OverlayFontSize :CGFloat = 38
	var OverlayFont :UIFont!
	
	var HugeOverlayFontName :String = "Futura-CondensedExtraBold"
	var HugeOverlayFontSize :CGFloat = 44
	var HugeOverlayFont :UIFont!
	
	var DefaultH1FontName :String = "Marker Felt"
	var DefaultH1FontSize :CGFloat = 32
	var DefaultH1Font :UIFont!
	
	var DefaultH2FontName :String = "Marker Felt"
	var DefaultH2FontSize :CGFloat = 26
	var DefaultH2Font :UIFont!
	
	var DefaultH3FontName :String = "Marker Felt"
	var DefaultH3FontSize :CGFloat = 22
	var DefaultH3Font :UIFont!
	
	var TableHeaderFontName : String = "Marker Felt"
	var TableHeaderFontSize : CGFloat = 22
	var TableHeaderFont :UIFont!
	
	required init() {
	}
	
	func loadFonts() {
		OverlayFont = UIFont(name: OverlayFontName, size: OverlayFontSize)
		HugeOverlayFont = UIFont(name: HugeOverlayFontName, size: HugeOverlayFontSize)
		DefaultH1Font = UIFont(name: DefaultH1FontName, size: DefaultH1FontSize)
		DefaultH2Font = UIFont(name: DefaultH2FontName, size: DefaultH2FontSize)
		DefaultH3Font = UIFont(name: DefaultH3FontName, size: DefaultH3FontSize)
		TableHeaderFont = UIFont(name: TableHeaderFontName, size: TableHeaderFontSize)
	}
}

class Iphone5Fonts : BaseFonts {
	required init () {
		super.init()
		OverlayFontSize = 30
		HugeOverlayFontSize = 34
		DefaultH1FontSize = 22
		DefaultH2FontSize = 20
		DefaultH3FontSize = 18
		TableHeaderFontSize = 16
	}
}


class Iphone6Fonts : Iphone5Fonts {
	required init () {
		super.init()
	}
}

var Fonts : BaseFonts!

func buildFonts() {
	if IS_IPHONE_4_OR_LESS {
		Fonts = Iphone5Fonts()
	} else if IS_IPHONE_5 {
		Fonts = Iphone5Fonts()
	} else if IS_IPHONE_6 || IS_IPHONE_6P {
		Fonts = Iphone6Fonts()
	} else {
		Fonts = BaseFonts()
	}
	Fonts.loadFonts()
}

