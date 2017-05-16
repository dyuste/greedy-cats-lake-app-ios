//
//  CollectionManipulation.swift
//  greedycats
//
//  Created by David Yuste on 10/11/15.
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

func +=<K, V> (inout left: Dictionary<K, V>, right: Dictionary<K, V>) -> Dictionary<K, V> {
	for (k, v) in right {
		left.updateValue(v, forKey: k)
	}
	return left
}

func JoinCollection<T : SequenceType>(col : T, separator : String) -> String {
	var sep = ""
	var str = ""
	for obj in col {
		str = "\(str)\(sep)\(obj)"
		sep = separator
	}
	return str
}
