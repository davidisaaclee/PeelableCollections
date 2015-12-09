//
//  DemoClasses.swift
//  PeelableCollections
//
//  Created by David Lee on 12/8/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"


infix operator + {}
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

infix operator - {}
func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

class DemoViewController: PeelableCollectionViewController {
	let cellCount: Int = 30
	var cellColors: [UIColor]!

	var longPressGestureRecognizer: UILongPressGestureRecognizer!
	var tapGestureRecognizer: UITapGestureRecognizer!

	override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
		cellColors = (0..<cellCount).map { _ in UIColor.randomColor() }

		longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
		longPressGestureRecognizer.minimumPressDuration = 0.1
		longPressGestureRecognizer.delegate = self

		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
		tapGestureRecognizer.delegate = self

		view.addGestureRecognizer(longPressGestureRecognizer)
		view.addGestureRecognizer(tapGestureRecognizer)
	}

	private var _initialTouchLocation: CGPoint!
	private var _initialOrigin: CGPoint!
	func handleLongPress(recognizer: UILongPressGestureRecognizer) {

		switch recognizer.state {
		case .Began:
			focusedIndexPath = collectionView.indexPathForItemAtPoint(recognizer.locationInView(self.collectionView))
			if let peeledView = peeledView {
				_initialTouchLocation = recognizer.locationInView(self.view)
				_initialOrigin = peeledView.frame.origin
			}

		case .Changed:
			guard let peeledView = peeledView else { return }
			let loc = recognizer.locationInView(self.view)
			let delta = loc - _initialTouchLocation
			let newOrigin = _initialOrigin + delta

			peeledView.frame = CGRect(origin: newOrigin, size: peeledView.frame.size)

		case .Ended:
			focusedIndexPath = nil

		default:
			break
		}
	}

	func handleTap(recognizer: UITapGestureRecognizer) {
		switch recognizer.state {
		case .Ended:
			if focusedIndexPath != nil {
				focusedIndexPath = nil
			} else if let tappedOnIndexPath = collectionView.indexPathForItemAtPoint(recognizer.locationInView(self.collectionView)) {
				focusedIndexPath = tappedOnIndexPath
			}

		default:
			break
		}
	}
}


extension DemoViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		switch gestureRecognizer {
		case self.longPressGestureRecognizer:
			return peeledView != nil || collectionView.indexPathForItemAtPoint(touch.locationInView(collectionView)) != nil

		case self.tapGestureRecognizer:
			if let peeledView = peeledView {
				return !peeledView.pointInside(touch.locationInView(peeledView), withEvent: nil)
			} else {
				return collectionView.indexPathForItemAtPoint(touch.locationInView(collectionView)) != nil
			}

		default:
			return false
		}
	}
}

extension DemoViewController: UICollectionViewDataSource {
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cellCount
	}

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
		cell.contentView.backgroundColor = cellColors[indexPath.item]
		return cell
	}
}

extension DemoViewController: PeelableCollectionDelegate {
	func peeleableCollection(peelableCollection: PeelableCollectionViewController, didPeelView peeledView: UIView) {
		peeledView.layer.borderColor = UIColor.blackColor().CGColor
		peeledView.layer.borderWidth = 3.0

		let sizeʹ = CGSize(width: peeledView.bounds.size.width * 1.2, height: peeledView.bounds.size.height * 1.2)
		UIView.animateWithDuration(0.2, animations: {
			peeledView.bounds = CGRect(origin: peeledView.bounds.origin, size: sizeʹ)
		})
	}

	func peeleableCollection(peelableCollection: PeelableCollectionViewController, didUnpeelView unpeeledView: UIView) {
		unpeeledView.layer.borderColor = nil
		unpeeledView.layer.borderWidth = 0
	}
}


class DemoCell: UICollectionViewCell, PeelableCell {
	var peelableView: UIView! = UIView()

	override var contentView: UIView {
		return peelableView
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		_setupPeelable()
	}

	private func _setupPeelable() {
		peelableView.frame = super.contentView.bounds
		super.contentView.addSubview(peelableView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		peelableView.frame = super.contentView.bounds
	}
}