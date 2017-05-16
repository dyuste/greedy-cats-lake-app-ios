//
//  QuickSort.swift
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

func quicksort<T: Comparable>(var list: [T]) -> [T] {
	if list.count <= 1 {
		return list
	}
	
	let pivot = list.removeAtIndex(0)
	return quicksort(list.filter { $0 <= pivot }) + [pivot] + quicksort(list.filter { $0 >  pivot })
}
