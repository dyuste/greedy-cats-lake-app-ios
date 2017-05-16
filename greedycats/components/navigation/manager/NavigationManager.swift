import Foundation
import UIKit

protocol NavigationDelegate : Delegate {
}

class NavigationManager : Manager {
	override init () {
		super.init();
	}
	
	class var Singleton : NavigationManager {
		struct singleton {
			static let instance = NavigationManager()
		}
		return singleton.instance
	}
	
	var rootController : YCViewController! {
		get {
			let appDelegate = UIApplication.sharedApplication().delegate
			return appDelegate!.window?!.rootViewController as! YCViewController!
		}
	}
	
	var topController : YCViewController {
		get {
			var topController = rootController;
			while (topController.presentedViewController != nil) {
				topController = topController.presentedViewController as! YCViewController!
			}
			return topController
		}
	}
	
	func forwardToController<T : YCViewController>(
		controllerType : T.Type) -> T
	{
		var controller = findController(controllerType)
		
		if controller == nil {
			controller = createController(controllerType)
		}
		
		activateController(controller!)

		return controller!
	}
	
	func backToController<T : YCViewController>(
		controllerType : T.Type) -> T
	{
		var targetController = findController(controllerType)
		let onTopController = targetController == nil ?
			rootController :
			targetController

		dismissControllersOnTopOf(
			onTopController as YCViewController?, completion:{
				if targetController == nil {
					targetController = self.createController(controllerType)
				}
				
				self.activateController(targetController!)
		})
		
		return targetController!
	}
	
	private func findController<T : YCViewController>(controllerType : T.Type) -> T?
	{
		var controller = rootController
		while controller != nil && !(controller is T) {
			controller = controller!.presentedViewController as! YCViewController?
		}
		return controller as! T?
	}
	
	private func dismissControllersOnTopOf(controller : YCViewController?, completion: (() -> Void))
	{
		if topController !== controller {
			topController.dismissViewControllerAnimated(true, completion: {
				self.dismissControllersOnTopOf(controller, completion: completion)
			})
		} else {
			completion()
		}
	}
	
	private func createController<T : YCViewController>(
		controllerType : T.Type) -> T
	{
		return T()
	}
	
	private func activateController<T : YCViewController>(
		controller : T)
	{
		let topController = self.topController
		if topController !== controller {
			topController.presentViewController(controller, animated: true, completion: nil)
		}
	}
	
}
