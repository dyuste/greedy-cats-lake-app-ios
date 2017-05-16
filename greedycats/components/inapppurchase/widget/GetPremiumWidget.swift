import Foundation
import UIKit

class GetPremiumWidget : UIButton, AdDelegate {
	
	weak var parentViewController : UIViewController?
	var getPremiumLabel : ShadowLabel?
	
	init () {
		super.init(frame: CGRectMake(0,0,0,0))
		createLayout()
		addTarget(self,
			action: "buttonPressed",
			forControlEvents: UIControlEvents.TouchUpInside)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func addToView(viewController : YCViewController, view : UIView?) {
		parentViewController = viewController
		let targetView = view != nil ? view! : viewController.view!
		
		targetView.addSubview(self)
		let width = frame.size.width
		let height = frame.size.height
		Layout.setConstraints(targetView,
			constraints : [
				"V:[btn(h)]-20-|",
				"H:[btn(w)]-20-|"],
			metrics: ["w" : width, "h" : height],
			views: ["btn" : self],
			options: nil)
		AdManager.Singleton.addDelegate(self)
		viewController.registerWidget(self)
	}

	override func removeFromSuperview() {
		super.removeFromSuperview()
		
		AdManager.Singleton.removeDelegate(self)
	}
	
	func buttonPressed() {
		InAppPurchaseManager.Singleton.showShoppingCenter()
	}
	
	private func createLayout() {
		translatesAutoresizingMaskIntoConstraints = false
		
		let imageView = UIImageView(
			image: UIImage(named: "Market"))
		imageView.backgroundColor = Colors.TransparentColor
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)

		let label = ShadowLabel()
		label.text = NSLocalizedString("Get Premium", comment: "")
		label.backgroundColor = Colors.TransparentColor
		label.font = Fonts.OverlayFont
		label.textColor = UIColor.whiteColor()
		label.sizeToFit()
		label.hidden = !AdManager.Singleton.adsEnabled
		label.translatesAutoresizingMaskIntoConstraints = false
		addSubview(label)
		self.getPremiumLabel = label
		
		Layout.setConstraints(self,
			constraints : [
				"V:[img(imgH)]|",
				"V:[label]-|",
				"H:[label]-[img(imgW)]|"],
			metrics: [
				"imgW" : Metrics.MarketIconWidth,
				"imgH" : Metrics.MarketIconHeight
			],
			views: [
				"img" : imageView,
				"label" : label
			],
			options: nil)
		
		frame.size = CGSizeMake(
			label.frame.size.width + 8 + 90,
			90)
	}
	
	func adsStatusUpdated(adsEnabled : Bool) {
		getPremiumLabel?.hidden = !adsEnabled
	}
	
}
