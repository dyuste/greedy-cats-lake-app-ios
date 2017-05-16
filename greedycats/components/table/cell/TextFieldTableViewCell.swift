//
//  TextFieldTableViewCell.swift
//  greedycats
//
//  Created by David Yuste on 11/15/15.
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

class TextFieldTableViewCell: YCTableViewCell, UITextFieldDelegate {
	var captionLabel: UILabel!
	var textField: UITextField!
	var editCallback : ((String)->Void)?
	
	init(caption : String, reuseIdentifier : String)
	{
		super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
		createView(caption)
		textField.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createView(caption : String)
	{
		selectionStyle = UITableViewCellSelectionStyle.None
		
		captionLabel = UILabel()
		captionLabel.text = caption
		captionLabel.textColor = Colors.ButtonTextColor
		captionLabel.autoresizingMask = UIViewAutoresizing.None
		captionLabel.textAlignment = NSTextAlignment.Center
		captionLabel.font = Fonts.DefaultH2Font
		captionLabel.translatesAutoresizingMaskIntoConstraints = false
		
		textField = UITextField()
		textField.borderStyle = .RoundedRect
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.tintColor = Colors.BlackColor
		
		contentView.addSubview(captionLabel)
		contentView.addSubview(textField)
		
		let viewsDictionary = [
			"label" : captionLabel,
			"text" : textField
		]
		
		let availableSpace = Metrics.TextFieldRowHeight - 3 * 8
		let metricsDictionary = [
			"labelH" : 2 * availableSpace / 6,
			"textH" : 4 * availableSpace / 6
		]
		
		Layout.setConstraints(contentView,
			constraints : [
				"V:|-8-[label(labelH)]-8-[text(textH)]",
				"H:|-[label]",
				"H:|-[text]-|"],
			metrics: metricsDictionary, views: viewsDictionary,
			options: nil)
	}
	
	func textField(textField: UITextField,
		shouldChangeCharactersInRange range: NSRange,
		replacementString string: String) -> Bool
	{
		let finalString : String = NSString(string: textField.text!).stringByReplacingCharactersInRange(range, withString:string)
			
		editCallback?(finalString)
		
		return true
	}
}
