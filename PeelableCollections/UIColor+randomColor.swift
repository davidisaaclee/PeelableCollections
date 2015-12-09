import Foundation
import UIKit



private func randomFloat() -> CGFloat {
	return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
}

public extension UIColor {
	public class func randomColor() -> UIColor {
		return UIColor(red: randomFloat(), green: randomFloat(), blue: randomFloat(), alpha: 1.0)
	}
}
