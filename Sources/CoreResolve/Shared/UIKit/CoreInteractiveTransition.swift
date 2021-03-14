//
//  CoreInteractiveTransition.swift
//  CoreResolve
//
//  Created by David Mitchell
//  Copyright © 2018 The App Studio LLC.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//	   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if canImport(UIKit) && !os(watchOS)

import UIKit

open class CoreInteractiveTransition: NSObject {
	
	public private(set) weak var animator: UIViewControllerAnimatedTransitioning!
	
	public init(with animator: UIViewControllerAnimatedTransitioning) {
		self.animator = animator
		super.init()
	}
	
	public func cancelInteractiveTransition() {
		guard let transitionContext = transitionContext else {
			fatalError("Unexpected state where transitionContext is nil")
		}
		transitionContext.cancelInteractiveTransition()
		let containerLayer = transitionContext.containerView.layer
		containerLayer.speed = -1
		containerLayer.beginTime = CACurrentMediaTime()
		// TODO: Find a better way to restore the layer's animation speed
		let delay = Double(1.0 - completionSpeed) * animator.transitionDuration(using: transitionContext) + 0.05
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
			containerLayer.speed = 1
		}
	}
	
	public func finishInteractiveTransition() {
		guard let transitionContext = transitionContext else {
			fatalError("Unexpected state where transitionContext is nil")
		}
		transitionContext.finishInteractiveTransition()
		resumeLayer(transitionContext.containerView.layer)
	}
	
	public func updateInteractiveTransition(_ percentComplete: CGFloat) {
		completionSpeed = 1 - percentComplete
		guard let transitionContext = transitionContext else {
			fatalError("Unexpected state where transitionContext is nil")
		}
		transitionContext.updateInteractiveTransition(percentComplete)
		let elapsedDuration = animator.transitionDuration(using: transitionContext) * Double(percentComplete)
		transitionContext.containerView.layer.timeOffset = pausedTime + elapsedDuration
	}
	
	public var completionSpeed: CGFloat = 0
	
	internal var pausedTime: CFTimeInterval = 0
	
	fileprivate func pauseLayer(_ layer: CALayer) {
		pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
		layer.speed = 0
		layer.timeOffset = pausedTime
	}
	
	private func resumeLayer(_ layer: CALayer) {
		let pausedTime = layer.timeOffset
		layer.speed = 1
		layer.timeOffset = 0
		layer.beginTime = 0
		let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
		layer.beginTime = timeSincePause
	}
	
	internal weak var transitionContext: UIViewControllerContextTransitioning? = nil
}

extension CoreInteractiveTransition: UIViewControllerInteractiveTransitioning {
	
	public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		// NOTE: According to Apple docs this class is responsible for telling the animator to begin...
		animator.animateTransition(using: transitionContext)
		pauseLayer(transitionContext.containerView.layer)
	}
}

#endif
