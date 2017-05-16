import Foundation
import UIKit
import iAd

class AdBannerWidget : UIView, ADBannerViewDelegate, AdDelegate
{
	
	weak var parentViewController : YCViewController?
	weak var parentView : UIView?
	
	var adBannerView : ADBannerView!
	var bannerAttached : Bool = false
	
	init () {
		super.init(frame: CGRectMake(0,0,0,0))
		createLayout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func addToView(viewController : YCViewController, view : UIView?) {
		parentViewController = viewController
		parentView = view != nil ? view! : viewController.view!
		parentView!.addSubview(self)
		translatesAutoresizingMaskIntoConstraints = false
		Layout.setConstraints(parentView,
			constraints : [
				"V:|[b]|",
				"H:|[b]|"],
			metrics: nil,
			views: ["b" : self],
			options: nil)

		
		if AdManager.Singleton.adsEnabled {
			attachBanner()
		}
		
		AdManager.Singleton.addDelegate(self)
		viewController.registerWidget(self)
	}
	
	override func removeFromSuperview() {
		super.removeFromSuperview()
		
		AdManager.Singleton.removeDelegate(self)
	}
	
	func adsStatusUpdated(adsEnabled : Bool) {
		if adsEnabled {
			attachBanner()
		} else {
			detachBanner()
		}
	}
	
	private func attachBanner() {
		if parentView != nil
			&& !bannerAttached {
			addSubview(adBannerView)
			adBannerView.translatesAutoresizingMaskIntoConstraints = false
			Layout.setConstraints(self,
				constraints : [
					"V:|[b]|",
					"H:|[b]|"],
				metrics: nil,
				views: ["b" : adBannerView],
				options: nil)
			
			bannerAttached = true
		}
	}
	
	private func detachBanner() {
		if parentView != nil && bannerAttached {
			adBannerView.removeFromSuperview()
			bannerAttached = false
		}
	}
	
	private func createLayout() {
		backgroundColor = UIColor.clearColor()
		
		adBannerView = ADBannerView(frame: CGRect.zero)
		adBannerView.delegate = self
		adBannerView.hidden = true
	}
	
	func bannerViewWillLoadAd(banner: ADBannerView!) {}
	
	func bannerViewDidLoadAd(banner: ADBannerView!) {
		adBannerView.hidden = false
	}
	
	func bannerViewActionDidFinish(banner: ADBannerView!) {}
	
	func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
		return true
	}
	
	func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
		Logger.Error("AdBannerWidget::didFailToReceiveAdWithError - \(error.localizedDescription)")
	}
}
