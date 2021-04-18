//
//  CoreScalableLabel.swift
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

/// A UILabel that automatically scales with Accessibility scaling, and cooperates well with UIAppearanceProxies
open class CoreScalableLabel: UILabel {

	@IBInspectable public var constrainsMinimumWidth: Bool = true {
		didSet { updateMinimumConstraint() }
	}

	@IBInspectable public var minimumWidthConstraintPriority: UILayoutPriority = .required - 1 {
		didSet { updateMinimumConstraint() }
	}

	/// The UIFontTextStyle that controls the scaling curve (defaults to `body` if unset)
	var scalableTextStyle: UIFont.TextStyle = .body {
		didSet { if scalableTextStyle != oldValue { updateFont() } }
	}

	/// Initializes a new instance with the provided UIFontTextStyle
	///
	/// - Parameter textStyle: The UIFontTextStyle that controls the scaling curve
	///   - notificationCenter: The NotificationCenter instance to use when observing system notifications
	public init(textStyle: UIFont.TextStyle, notificationCenter: NotificationCenter = .default) {
		self.notificationCenter = notificationCenter
		scalableTextStyle = textStyle
		super.init(frame: .zero)
		setupControl()
	}

	/// Initializes a new instance with the provided frame and NotificationCenter
	///
	/// - Parameters:
	///   - frame: The frame of the new instance
	///   - notificationCenter: The NotificationCenter instance to use when observing system notifications
	@objc public init(frame: CGRect, notificationCenter: NotificationCenter) {
		self.notificationCenter = notificationCenter
		super.init(frame: frame)
		setupControl()
	}

	/// Initializes a new instance with the provided Decoder and NotificationCenter
	///
	/// - Parameters:
	///   - aDecoder: The decoder with which to initialize the instance
	///   - notificationCenter: The NotificationCenter instance to use when observing system notifications
	@objc public init?(coder aDecoder: NSCoder, notificationCenter: NotificationCenter) {
		self.notificationCenter = notificationCenter
		super.init(coder: aDecoder)
		setupControl()
	}

	// MARK: - UILabel overrides

	open override func didMoveToWindow() {
		super.didMoveToWindow()
		updateMinimumSize()
	}

	public override convenience init(frame: CGRect) {
		self.init(frame: frame, notificationCenter: .default)
	}

	public required convenience init?(coder aDecoder: NSCoder) {
		self.init(coder: aDecoder, notificationCenter: .default)
	}

	open override var font: UIFont! {
		didSet {
			originalFont = font
			updateFont()
		}
	}

	open override var text: String? {
		didSet { if text != oldValue { updateMinimumSize() } }
	}

	// MARK: - Private properties and methods -

	private var minimumWidthConstraint: NSLayoutConstraint!
	private var needsUpdateMinimumSize: Bool = false
	private let notificationCenter: NotificationCenter
	private var originalFont: UIFont?

	@objc private func applicationDidBecomeActive(_ notification: Notification) {
		notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
		guard needsUpdateMinimumSize else { return }
		let text = self.text
		self.text = nil
		self.text = text
	}

	@objc private func contentSizeCategoryChanged(_ notification: Notification) {
		if let userInfo = notification.userInfo, let contentSizeCategory = userInfo[UIContentSizeCategory.newValueUserInfoKey] {
			// TODO: How to make this happen once even though we have many labels?
			print("contentSizeCategoryChanged: \(contentSizeCategory)")
		}
//		if #available(iOS 11.0, tvOS 11.0, *) { } else {
//
//		}
		notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
		updateMinimumSize()
		needsUpdateMinimumSize = true
	}

	private func setupControl() {
		if #available(iOS 10.0, tvOS 10.0, *) {
			adjustsFontForContentSizeCategory = true
		}
		originalFont = font
//		self.font = UIFont.systemFont(ofSize: 12, weight: .thin)
		updateFont()
		notificationCenter.addObserver(self, selector: #selector(contentSizeCategoryChanged(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
	}

	private func updateFont() {
		guard let originalFont = originalFont else { return }
		defer {
			updateMinimumSize()
		}
		do {
			super.font = try originalFont.scaledFor(textStyle: scalableTextStyle)
		} catch { // TODO: Switch to LogManager/os.log
			print("\(self) error setting font: \(error.localizedDescription)")
			super.font = originalFont
		}
	}

	private func updateMinimumConstraint() {
		guard let minimumWidthConstraint = minimumWidthConstraint else { return }
		minimumWidthConstraint.priority = minimumWidthConstraintPriority
		minimumWidthConstraint.isActive = constrainsMinimumWidth
	}

	private func updateMinimumSize() {
		guard let window = window, let text = text, text.count > 0 else { return }
		guard constrainsMinimumWidth, minimumWidthConstraintPriority > UILayoutPriority(0.0) else {
			minimumWidthConstraint?.isActive = false
			return
		}
		algorithmCount = 0
		let longestDimension = CGFloat.maximum(window.bounds.size.width, window.bounds.size.height)
		let increment = traitCollection.displayScale > 0 ? 1 / traitCollection.displayScale : 1
		var minimumWidth: CGFloat = 0.0
		var maximumHeight: CGFloat = 0.0
		var proposedWidth = longestDimension
		if numberOfLines == 1 {
			minimumWidth = textSize(for: proposedWidth, numberOfLines: numberOfLines).width
		} else {
			var lines = numberOfLines
			if lines == 0 {
				text.enumerateSubstrings(in: ..<text.endIndex, options: .byWords) { _,_,_,_ in
					lines += 1
				}
			}
			while proposedWidth > increment {
				let size = textSize(for: proposedWidth, numberOfLines: lines)
				if maximumHeight == 0 || size.height > maximumHeight {
					maximumHeight = size.height
					minimumWidth = size.width
				} else {
					break
				}
				// TODO: scan ahead to make the proposed value decrease faster (e.g. cut in half -- if height is same use it)
				proposedWidth = CGFloat.minimum(proposedWidth, size.width) - increment
			}
		}
		if traitCollection.displayScale > 0 {
			minimumWidth = ceil(minimumWidth * traitCollection.displayScale / traitCollection.displayScale)
		} else {
			minimumWidth = ceil(minimumWidth)
		}
//		print(" text rect (\(algorithmCount)) '\(text)'/\(proposedWidth) -> \(minimumWidth)")
		if let minimumWidthConstraint = minimumWidthConstraint {
			minimumWidthConstraint.constant = minimumWidth
		} else {
			minimumWidthConstraint = widthAnchor.constraint(greaterThanOrEqualToConstant: minimumWidth)
			minimumWidthConstraint.priority = minimumWidthConstraintPriority
			minimumWidthConstraint.isActive = true
		}
		needsUpdateMinimumSize = false
	}

	private var algorithmCount = 0

	private func textSize(for width: CGFloat, numberOfLines: Int) -> CGSize {
		algorithmCount += 1
		let bounds = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
		let size = textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines).size
//		print(" text rect '\(text!)'/\(numberOfLines) \(width) -> \(size)")
		return size
	}
}

#endif
