//
//  PeelableCollectionViewController.swift
//  PeelableCollections
//
//  Created by David Lee on 12/8/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class PeelableCollectionViewController: UIViewController {
	@IBOutlet var collectionView: UICollectionView!

	// where peels go to live
	@IBOutlet var peeledStageView: UIView!

	var peeledData: PeeledContentViewData?

	var focusedIndexPath: NSIndexPath? {
		didSet {
			guard let collectionView = collectionView as? PeelableCollectionView else { return }
			guard focusedIndexPath != oldValue else { return }

			if let focusedIndexPath = focusedIndexPath {
				peeledData = collectionView.peelContentFromCellAtIndexPath(focusedIndexPath, withNewSuperview: view)
			} else {
				collectionView.restorePeeledContent(peeledData)
				peeledData = nil
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		// Register cell classes
		self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
	}
}

// MARK: UICollectionViewDelegate
extension PeelableCollectionViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		focusedIndexPath = focusedIndexPath == indexPath ? nil : indexPath
	}

	// TODO: check these!

//	override func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
//		print("hiled", indexPath.item)
//	}
//
//	override func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
//		print("unhiled", indexPath.item)
//	}
}