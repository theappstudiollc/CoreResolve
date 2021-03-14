//
//  TouchForwardingView.swift
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

/// A UIView that fowards touches to a specified UIView
public final class TouchForwardingView: UIView {
	
	// MARK: - Public properties and methods
	
    /// The UIView to forward UITouch events to
	public var forwardView: UIView?
	
	// MARK: - UIView overrides
	
	public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		if self.point(inside: point, with: event), let subview = forwardView ?? subviews.first {
			return subview
		}
		return super.hitTest(point, with: event)
	}
}

#endif
