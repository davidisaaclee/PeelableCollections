//
//  PeelableCollectionView.swift
//  Buy
//
//  Created by David Lee on 12/8/15.
//  Copyright © 2015 Sometimes. All rights reserved.
//

import UIKit


class PeelableCollectionView: UICollectionView {
	func peelContentFromCellAtIndexPath(indexPath: NSIndexPath) -> PeeledContentViewData? {
		return peelContentFromCellAtIndexPath(indexPath, withNewSuperview: nil)
	}

	func peelContentFromCellAtIndexPath(indexPath: NSIndexPath, withNewSuperview newSuperview: UIView?) -> PeeledContentViewData? {
		guard let data = PeeledContentViewData(collectionView: self, indexPath: indexPath) else { return nil }

		data.contentView.removeFromSuperview()
		if let newSuperview = newSuperview {
			let frameInNewSuperview = newSuperview.convertRect(data.frameRelativeToCollectionView, fromView: self)
			data.contentView.frame = frameInNewSuperview
			newSuperview.addSubview(data.contentView)
		}
		return data
	}
}


protocol PeelableCell {
	var peelableView: UIView! { get set }
}


struct PeeledContentViewData {
	var contentView: UIView!
	var originalSuperview: UIView!
	var frameRelativeToOriginalSuperview: CGRect!
	var frameRelativeToCollectionView: CGRect!

	init?(collectionView: UICollectionView, indexPath: NSIndexPath) {
		guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else {
			print("Could not find cell")
			return nil
		}
		guard let peeledView = (cell as? PeelableCell)?.peelableView else {
			print("Could not find peelable view")
			return nil
		}

		contentView = peeledView

		// If there isn't a superview, then we can't "peel" the view off of anything.
		guard let superview = contentView.superview else { return nil }

		originalSuperview = superview
		frameRelativeToOriginalSuperview = peeledView.frame
		frameRelativeToCollectionView = collectionView.convertRect(peeledView.frame, fromView: originalSuperview)
	}

	func restorePeeledContent() {
		restorePeeledContentAnimations()
		restorePeeledContentSuccessfulCompletion()
	}

	func restorePeeledContentAnimations() {
		self.contentView.frame = self.originalSuperview.convertRect(self.frameRelativeToOriginalSuperview, toView: self.contentView.superview)
	}

	func restorePeeledContentSuccessfulCompletion() {
		self.contentView.removeFromSuperview()
		self.contentView.frame = self.frameRelativeToOriginalSuperview
		self.originalSuperview.addSubview(self.contentView)
	}
}