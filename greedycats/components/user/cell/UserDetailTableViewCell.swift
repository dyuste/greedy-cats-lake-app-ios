//
//  UserDetailTableViewCell.swift
//  greedycats
//
//  Created by David Yuste on 11/16/15.
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

class UserDetailTableViewCell : YCTableViewCell
{
	var userNameLabel: UILabel!
	var pointsLabel: UILabel!
	var userThumbnail: UIImageView!
	var settingsIcon : UIImageView!
	
	var preferredHeight : CGFloat = 100
	
	init(reuseIdentifier : String)
	{
		super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
		preferredHeight = Metrics.UserDetailHeight
		createView()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
	
	func setUser(user : User?)
	{
		if user != nil {
			userNameLabel!.text = NSLocalizedString("User: ", comment: "") + user!.userName
			pointsLabel!.text = NSLocalizedString("Score: ", comment: "") + "\(user!.score)"
		} else {
			userNameLabel!.text = NSLocalizedString("User: ", comment: "")
			pointsLabel!.text = NSLocalizedString("Score: ", comment: "")
		}
	}
	
	private func createView()
	{
		selectionStyle = UITableViewCellSelectionStyle.None
		
		userThumbnail = UIImageView(image: UIImage(named: "PlayerThumbnail"))
		userThumbnail.translatesAutoresizingMaskIntoConstraints = false
		userThumbnail.contentMode = UIViewContentMode.ScaleAspectFit
		contentView.addSubview(userThumbnail)
		
		let middleColumn = UIView()
		middleColumn.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(middleColumn)
		
		userNameLabel = UILabel()
		userNameLabel.textColor = Colors.ButtonTextColor
		userNameLabel.autoresizingMask = UIViewAutoresizing.None
		userNameLabel.textAlignment = NSTextAlignment.Left
		userNameLabel.font = Fonts.DefaultH2Font
		userNameLabel.translatesAutoresizingMaskIntoConstraints = false
		middleColumn.addSubview(userNameLabel)
		
		pointsLabel = UILabel()
		pointsLabel.textColor = Colors.ButtonTextColor
		pointsLabel.autoresizingMask = UIViewAutoresizing.None
		pointsLabel.textAlignment = NSTextAlignment.Left
		pointsLabel.font = Fonts.DefaultH2Font
		pointsLabel.translatesAutoresizingMaskIntoConstraints = false
		middleColumn.addSubview(pointsLabel)
		
		settingsIcon = UIImageView(image: UIImage(named: "Settings"))
		settingsIcon.contentMode = UIViewContentMode.ScaleAspectFit
		settingsIcon.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(settingsIcon)

		Layout.setConstraints(middleColumn,
			constraints : [
				"V:[un]-[pl]-|",
				"H:|-[un]",
				"H:|-[pl]"],
			metrics: nil,
			views: [
				"un" : userNameLabel,
				"pl" : pointsLabel
			],
			options: nil)
		
		Layout.setConstraints(contentView,
			constraints : [
				"V:|[ut]|",
				"V:[mc]|",
				"V:[si]|",
				"H:|[ut(\(Metrics.UserDetailHeight))][mc(>=100)][si(\(Metrics.UserDetailHeight))]|"],
			metrics: nil,
			views: [
				"ut" : userThumbnail,
				"mc" : middleColumn,
				"si" : settingsIcon
			],
			options: nil)
	}

}
