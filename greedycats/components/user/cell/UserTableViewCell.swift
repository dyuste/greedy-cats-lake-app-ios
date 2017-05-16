//
//  UserTableViewCell.swift
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

class UserTableViewCell : YCTableViewCell {
	var addButtonLabel: UILabel?
	var addButtonEnabled: Bool
	var linkColor : UIColor
	
	init(linkColor : UIColor, withAddButton : Bool,
		reuseIdentifier: String?) {
			self.addButtonEnabled = withAddButton
			self.linkColor = linkColor
			super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
		createView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func createView() {
		selectionStyle = UITableViewCellSelectionStyle.None
		
		detailTextLabel?.textColor = linkColor
		textLabel?.textColor = linkColor
		
		if addButtonEnabled {
			addButtonLabel = UILabel()
			addButtonLabel!.textColor = Colors.ButtonTextColor
			addButtonLabel!.backgroundColor = UIColor(patternImage: UIImage(named: "CircleButton.png")!)
			addButtonLabel!.autoresizingMask = UIViewAutoresizing.None
			addButtonLabel!.textAlignment = NSTextAlignment.Center
			addButtonLabel!.text = "+"
			addButtonLabel!.font = Fonts.DefaultH2Font
			addButtonLabel!.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(addButtonLabel!)
			
			Layout.setConstraints(self.contentView,
				constraints: [
					"H:[b(50)]-20-|",
					"V:|-10-[b(50)]"
				],
				metrics: nil,
				views: ["b" : addButtonLabel!],
				options: nil)
		}
	}
	
	func setUser(user: User) {
		if user.isLocal {
			textLabel!.text = user.userName.isEmpty ? NSLocalizedString("Unnamed", comment: "") : user.userName
			detailTextLabel?.text = NSLocalizedString("Local player", comment: "")
			imageView?.image = UIImage(named: "LocalUser")
		} else {
			if user.id == SessionManager.Singleton.userId && (user.name == nil || user.name!.isEmpty) {
				textLabel!.text = NSLocalizedString("Me", comment: "")
			} else {
				textLabel!.text = (user.name == nil || user.name!.isEmpty) ? NSLocalizedString("Unnamed", comment: "") : user.name!
			}
			detailTextLabel?.text = user.userName
			imageView?.image = UIImage(named: "RemoteUser")
		}
	}
}
