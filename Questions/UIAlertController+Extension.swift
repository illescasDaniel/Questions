import UIKit

extension UIAlertController {
	
	func addAction(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) {
		let alertAction = UIAlertAction(title: title, style: style, handler: handler)
		self.addAction(alertAction)
	}
}
