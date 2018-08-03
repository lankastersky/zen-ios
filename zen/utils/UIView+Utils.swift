import Foundation
import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        guard let views = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil) else {
            assertionFailure("Failed to instantiate view")
            return T()
        }
        guard let view = views[0] as? T else {
            assertionFailure("Failed to instantiate view")
            return T()
        }
        return view
    }
}
