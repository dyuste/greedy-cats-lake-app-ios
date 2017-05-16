//
//  GameAdapter.swift
//  Greedy Cats
//
//  Created by David Yuste on 2/21/15.
//  Copyright (c) 2015 David Yuste Romero
//
//  THIS MATERIAL IS PROVIDED AS IS, WITH ABSOLUTELY NO WARRANTY EXPRESSED
//  OR IMPLIED.  ANY USE IS AT YOUR OWN RISK.
//
//  Permission is hereby granted to use or copy this program
//  for any purpose,  provided the above notices are retained on all copies.
//  Permission to modify the code and to distribute modified code is granted,
//  provided the above notices are retained, and a notice that the code was
//  modified is included with the above copyright notice.
//

import Foundation
import AVFoundation

class SoundManager : Manager {
	override init () {
		super.init();
	}
	
	class var Singleton : SoundManager {
		struct singleton {
			static let instance = SoundManager()
		}
		return singleton.instance
	}
	
	private var backgroundMusicPlayer: AVAudioPlayer!
	
	func startMusic(backgroundMusicFileName : String) {
		if backgroundMusicPlayer != nil {
			backgroundMusicPlayer.stop()
			backgroundMusicPlayer = nil
		}
		
		dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
			let url = NSBundle.mainBundle().URLForResource(
				backgroundMusicFileName, withExtension: nil)
			if (url == nil) {
				Logger.Warn("SoundManager::startMusic: Could not find file: \(backgroundMusicFileName)")
				return
			}
			
			var error: NSError? = nil
			let backgroundMusicPlayer: AVAudioPlayer!
			do {
				backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: url!)
			} catch let error1 as NSError {
				error = error1
				backgroundMusicPlayer = nil
			} catch {
				fatalError()
			}
			if backgroundMusicPlayer == nil {
				Logger.Warn("SoundManager::startMusic: Could not create audio player: \(error!)")
				return
			}
			self.backgroundMusicPlayer = backgroundMusicPlayer
			dispatch_async( dispatch_get_main_queue(), {
				self.backgroundMusicPlayer.numberOfLoops = -1
				self.backgroundMusicPlayer.prepareToPlay()
				self.backgroundMusicPlayer.play()
				self.fadeMusic(1.0, duration: 5.0, fromVolume: 0, toVolume: 0.3, finally: nil)
			});
		});
	}
	
	func stopMusic() {
		if backgroundMusicPlayer != nil {
			fadeMusic(0, duration: 1.0, fromVolume: backgroundMusicPlayer.volume, toVolume: 0, finally: {
				if self.backgroundMusicPlayer != nil {
					self.backgroundMusicPlayer.stop()
				}
			})
		}
	}
	
	private func fadeMusic(delay : Float, duration : Float, fromVolume : Float, toVolume : Float, finally: (() -> Void)?) {
		let fadeSteps = 100
		let sign : Float = fromVolume < toVolume ? 1 : -1
		let module : Float = (toVolume - fromVolume) * sign
		
		backgroundMusicPlayer.volume = fromVolume
		for step in 0...fadeSteps {
			let delayInSeconds : Float = Float(delay) + Float(step) * Float(duration)/Float(fadeSteps)
			let popTime = dispatch_time(DISPATCH_TIME_NOW,
				Int64(delayInSeconds * Float(NSEC_PER_SEC)));
			
			dispatch_after(popTime, dispatch_get_main_queue()) {
				if self.backgroundMusicPlayer != nil {
					let fraction = (Float(step) / Float(fadeSteps))
					self.backgroundMusicPlayer.volume = fromVolume + sign * module * fraction
				}
				if step == fadeSteps {
					finally?()
				}
			}
		}
	}

	
}
