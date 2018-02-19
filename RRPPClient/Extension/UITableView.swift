//
//  UITableView.swift
//  Mosaic
//
//  Created by 이용민 on 2017. 12. 14..
//  Copyright © 2017년 MORAMCNT. All rights reserved.
//

import UIKit

extension UITableView
{
	public func showIndicator()
	{
		let aivFooter = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		aivFooter.frame.size.height = 50
		aivFooter.hidesWhenStopped = true
		aivFooter.startAnimating()
		tableFooterView = aivFooter
	}
	
	public func hideIndicator()
	{
		let boolTableContentSufficentlyTall = (contentSize.height > frame.size.height)
		let boolAtBottomOfTable = (contentOffset.y >= contentSize.height - frame.size.height)
		if boolAtBottomOfTable && boolTableContentSufficentlyTall
		{
			UIView.animate(withDuration: 0.2, animations: {
				self.contentOffset.y = self.contentOffset.y - 50
			}, completion: { finished in
				self.tableFooterView = UIView()
			})
		}
		else
		{
			self.tableFooterView = UIView()
		}
	}
	
	public func isIndicatorShowing() -> Bool
	{
		return tableFooterView is UIActivityIndicatorView
	}
}
