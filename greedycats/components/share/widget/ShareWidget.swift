import Foundation
import UIKit

class ShareWidget : UIButton {
	
	weak var parentViewController : UIViewController?
	weak var targetView : UIView?
	
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
		targetView = view != nil ? view! : viewController.view!
		
		targetView!.addSubview(self)
		let width = frame.size.width
		let height = frame.size.height
		Layout.setConstraints(targetView!,
			constraints : [
				"V:[btn(h)]-20-|",
				"H:|-20-[btn(w)]"],
			metrics: ["w" : width, "h" : height],
			views: ["btn" : self],
			options: nil)
		
		viewController.registerWidget(self)
	}
	
	func buttonPressed() {
		if parentViewController != nil {
			let text = NSLocalizedString("I am playing @GreedyCatsLake. Get it on the #AppStore and compete with me.", comment: "")
			let url = NSURL(string: "https://itunes.apple.com/in/app/greedy-cats-lake/id1039692073")
			let image = UIImage(named:"MainPicture")
		
			let activityViewController =
				UIActivityViewController(activityItems: [text, url!, image!], applicationActivities:nil);
			
			activityViewController.excludedActivityTypes = [
				UIActivityTypePostToWeibo,
				UIActivityTypeMessage,
				UIActivityTypePrint,
				UIActivityTypeAssignToContact,
				UIActivityTypeSaveToCameraRoll,
				UIActivityTypeAddToReadingList,
				UIActivityTypePostToFlickr,
				UIActivityTypePostToVimeo,
				UIActivityTypePostToTencentWeibo,
				UIActivityTypeAirDrop];
			
			if let presentationController = activityViewController.popoverPresentationController {
				presentationController.permittedArrowDirections = .Down
				presentationController.sourceView = self
				parentViewController?.presentViewController(activityViewController, animated:true, completion:nil)
			}
		}
	}
	
	private func createLayout() {
		translatesAutoresizingMaskIntoConstraints = false
		
		let imageView = UIImageView(
			image: UIImage(named: "ShareButton"))
		imageView.backgroundColor = Colors.TransparentColor
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		
		Layout.setConstraints(self,
			constraints : [
				"V:[img(imgH)]|",
				"H:|[img(imgW)]"],
			metrics: [
				"imgW" : Metrics.ShareIconWidth,
				"imgH" : Metrics.ShareIconHeight
			],
			views: [
				"img" : imageView
			],
			options: nil)
		
		frame.size = CGSizeMake(90, 90)
	}
}
