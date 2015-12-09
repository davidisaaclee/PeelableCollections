
//  PeelableCollectionViewController.swift
//  PeelableCollections
//
//  Created by David Lee on 12/8/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class PeelableCollectionViewController: UIViewController {

	@IBOutlet var delegate: PeelableCollectionDelegate?
	@IBOutlet var collectionView: UICollectionView!
	// where peels go to live
	@IBOutlet var peeledStageView: UIView!

	var peeledData: PeeledContentViewData?
	var peeledView: UIView? { return peeledData?.contentView }

	var shouldAnimateRestore: Bool = true
	var animationDuration: NSTimeInterval = 0.3
	var animationFunction: (NSTimeInterval, () -> Void, (Bool -> Void)?) -> Void = { duration, animations, completion in
		UIView.animateWithDuration(duration, animations: animations, completion: completion)
	}

	var focusedIndexPath: NSIndexPath? {
		didSet {
			guard let collectionView = collectionView as? PeelableCollectionView else { return }
			guard focusedIndexPath != oldValue else { return }

			// Clean up after old peeled views.
			// TODO: Multiple peeled?
			if oldValue != nil, let peeledData = peeledData {
				delegate?.peeleableCollection?(self, willUnpeelView: peeledData.contentView)
				_restorePeeled(peeledData)
				delegate?.peeleableCollection?(self, didUnpeelView: peeledData.contentView)
				self.peeledData = nil
			}

			if let focusedIndexPath = focusedIndexPath {
				// Check that there is a view to peel.
				guard let viewToPeel = collectionView.cellForItemAtIndexPath(focusedIndexPath)?.contentView else {
					return
				}
				delegate?.peeleableCollection?(self, willPeelView: viewToPeel)
				peeledData = collectionView.peelContentFromCellAtIndexPath(focusedIndexPath, withNewSuperview: view)
				if let peeledData = peeledData {
					assert(viewToPeel == peeledData.contentView)
					delegate?.peeleableCollection?(self, didPeelView: peeledData.contentView)
				}
			} else {
				if let peeledData = peeledData {
					delegate?.peeleableCollection?(self, willUnpeelView: peeledData.contentView)
					_restorePeeled(peeledData)
					delegate?.peeleableCollection?(self, didUnpeelView: peeledData.contentView)
				}
				peeledData = nil
			}
		}
	}

	private func _restorePeeled(pd: PeeledContentViewData) {
		if shouldAnimateRestore {
			animationFunction(animationDuration, pd.restorePeeledContentAnimations, { _ in pd.restorePeeledContentSuccessfulCompletion() })
		} else {
			pd.restorePeeledContent()
		}
	}
}



@objc protocol PeelableCollectionDelegate {
	optional func peeleableCollection(peelableCollection: PeelableCollectionViewController, willPeelView: UIView)
	optional func peeleableCollection(peelableCollection: PeelableCollectionViewController,  didPeelView: UIView)
	optional func peeleableCollection(peelableCollection: PeelableCollectionViewController, willUnpeelView: UIView)
	optional func peeleableCollection(peelableCollection: PeelableCollectionViewController,  didUnpeelView: UIView)
}
