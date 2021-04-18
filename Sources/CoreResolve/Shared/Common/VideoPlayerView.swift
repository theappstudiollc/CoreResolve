//
//  VideoPlayerView.swift
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

#if !os(watchOS)

import AVFoundation

@objc public protocol VideoPlayerViewDelegate: NSObjectProtocol {

	@objc optional func videoPlayerView(_ videoPlayerView: VideoPlayerView, encountered error: Error)
	@objc optional func videoPlayerViewDidFinishPlaying(_ videoPlayerView: VideoPlayerView)
	@objc optional func videoPlayerViewReady(_ videoPlayerView: VideoPlayerView)
}

public final class VideoPlayerView: View {
	
	public enum ResizeMode {
		case resize
		case resizeAspectFit
		case resizeAspectFill
	}
	
	public typealias VideoPlayerViewLoadCompletion = (_ success: Bool, _ error: Error?) -> Void
	
	@IBOutlet public weak var delegate: VideoPlayerViewDelegate?
	
	public private(set) var isPlaying = false
	
	public var resizeMode: ResizeMode = .resizeAspectFill {
		didSet { updateResizeMode() }
	}
	
	public private(set) var videoSize = CGSize.zero
	
	public var videoUrl: URL? {
		get { return videoUrlPrivate }
		set { setVideoUrl(newValue, with: nil) }
	}
	
	deinit {
		presentationSizeObserver = nil
		statusObserver = nil
	}
	
	public required convenience init?(coder aDecoder: NSCoder) {
		// Swift 5: To reduce the size taken up by Swift metadata, convenience initializers defined in Swift now only allocate an object ahead of time if they’re calling a designated initializer defined in Objective-C (therefore add @objc)
		self.init(coder: aDecoder, notificationCenter: .default)
	}
	
	@objc public init?(coder aDecoder: NSCoder, notificationCenter: NotificationCenter) {
		self.notificationCenter = notificationCenter
		super.init(coder: aDecoder)
		#if os(iOS) || os(tvOS)
		let playerLayer = self.layer as! AVPlayerLayer
		playerLayer.player = self.player
		#elseif os(macOS)
		self.layer = AVPlayerLayer(player: player)
		self.wantsLayer = true
		self.layerContentsRedrawPolicy = .onSetNeedsDisplay
		#endif
		self.updateResizeMode()
	}
	
	// MARK: - Public methods
	
	public func play() {
		guard isPlaying == false else { return }
		if let currentItem = player.currentItem, currentItem.status == .readyToPlay {
			player.play()
		}
		isPlaying = true
	}
	
	public func pause() {
		player.pause()
		isPlaying = false
	}
	
	public func reset() {
		pause()
		player.seek(to: CMTime.zero) { finished in
			self.notifyReady()
		}
	}
	
	public func setVideoUrl(_ videoUrl: URL?, options: [String : Any]? = nil, with completion: VideoPlayerViewLoadCompletion?) {
		guard videoUrlPrivate != videoUrl else {
			guard let completion = completion else { return }
			completion(asset != nil && videoUrl != nil, nil)
			return
		}
		videoUrlPrivate = videoUrl
		guard let videoUrl = videoUrl else {
			self.asset = nil
			guard let completion = completion else { return }
			completion(true, nil)
			return
		}
		let pendingAsset = AVURLAsset(url: videoUrl, options: options)
		pendingAsset.loadValuesAsynchronously(forKeys: ["tracks"]) {
			DispatchQueue.runInMain {
				var error: NSError? = nil
				let loaded = pendingAsset.statusOfValue(forKey: "tracks", error: &error) == .loaded
				if loaded /*, pendingAsset.tracks(withMediaType: .video).contains(where: { $0.naturalSize != .zero })*/ {
					self.asset = pendingAsset
				} else {
					self.asset = nil
				}
				if let completion = completion {
					completion(loaded, error)
				}
				if let error = error {
					self.notifyError(error)
				}
			}
		}
	}
	
	// MARK: - ViewController overrides
	
	public override var intrinsicContentSize: Size {
		guard videoSize != .zero else { return .noIntrinsicSize }
		return videoSize
	}
	
	#if os(macOS)
	
	public override var wantsUpdateLayer: Bool {
		return true
	}
	
	#elseif os(iOS) || os(tvOS)
	
	public override class var layerClass: AnyClass {
		return AVPlayerLayer.self
	}

	#endif
	
	public override func removeFromSuperview() {
		self.asset = nil
		super.removeFromSuperview()
	}
	
	// MARK: - Private properties and methods
	
	var asset: AVAsset? {
		didSet { self.playerItem = asset == nil ? nil : AVPlayerItem(asset: asset!) }
	}
	let notificationCenter: NotificationCenter
	let player = AVPlayer()
	var playerItem: AVPlayerItem? {
		willSet {
			pause()
			presentationSizeObserver?.invalidate()
			statusObserver?.invalidate()
			guard let playerItem = playerItem else { return }
			notificationCenter.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
			notificationCenter.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
		}
		didSet {
			if let playerItem = playerItem {
				presentationSizeObserver = playerItem.observe(\AVPlayerItem.presentationSize) { item, change in
					DispatchQueue.runInMain {
						self.videoSize = playerItem.presentationSize
						self.invalidateIntrinsicContentSize()
					}
				}
				statusObserver = playerItem.observe(\AVPlayerItem.status) { item, change in
					DispatchQueue.runInMain {
						switch (playerItem.status, change.oldValue) {
						case (.readyToPlay, .readyToPlay?):
							// TODO: Determine why this rule was necessary at one point and document it
							if self.isPlaying {
								self.player.play()
							}
						case (.readyToPlay, _):
							self.notifyReady()
						case (.failed, _):
							guard let error = playerItem.error else {
								return
							}
							self.notifyError(error)
						default:
							break
						}
					}
				}
				notificationCenter.addObserver(self, selector: #selector(playerItemDidEncounterError(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
				notificationCenter.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
			} else {
				presentationSizeObserver = nil
				statusObserver = nil
			}
			player.replaceCurrentItem(with: playerItem)
			#if os(macOS)
			needsDisplay = true
			#elseif os(iOS) || os(tvOS)
			setNeedsDisplay()
			#endif
		}
	}
	var presentationSizeObserver: NSKeyValueObservation?
	var statusObserver: NSKeyValueObservation?
	var videoUrlPrivate: URL?
	
	fileprivate func notifyError(_ error: Error) {
		guard let videoPlayerViewEncounteredError = delegate?.videoPlayerView else { return }
		videoPlayerViewEncounteredError(self, error)
	}
	
	fileprivate func notifyFinishedPlaying() {
		guard let videoPlayerViewDidFinishPlaying = delegate?.videoPlayerViewDidFinishPlaying else { return }
		videoPlayerViewDidFinishPlaying(self)
	}
	
	fileprivate func notifyReady() {
		guard let videoPlayerViewReady = delegate?.videoPlayerViewReady else { return }
		videoPlayerViewReady(self)
	}
	
	func updateResizeMode() {
		let playerLayer = self.layer as! AVPlayerLayer
		switch resizeMode {
		case .resize:
			playerLayer.videoGravity = AVLayerVideoGravity.resize
		case .resizeAspectFill:
			playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
		case .resizeAspectFit:
			playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
		}
	}
}

// MARK: - Notification listeners
extension VideoPlayerView {
	
	@objc func playerItemDidEncounterError(_ notification: Notification) {
		guard let item = notification.object as? AVPlayerItem, item == player.currentItem, let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else {
			return
		}
		notifyError(error)
	}
	
	@objc func playerItemDidReachEnd(_ notification: Notification) {
		guard let item = notification.object as? AVPlayerItem, item == player.currentItem else {
			return
		}
		isPlaying = false
		notifyFinishedPlaying()
	}
}

#endif
