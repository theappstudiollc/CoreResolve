//
//  CoreAPIContainer.swift
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

import Foundation

public protocol CoreAPIRequestProviding {
	
	func provideRequest<APIRequest>(for type: APIRequest.Type) throws -> APIRequest where APIRequest: CoreAPIRequest
}

open class CoreAPIContainer {
	
	internal let queue: OperationQueue
	internal let requestProvider: CoreAPIRequestProviding
	internal let session: URLSession
	
	public init(with requestProvider: CoreAPIRequestProviding, queue: OperationQueue = OperationQueue(), session: URLSession = .shared) {
		self.queue = queue
		self.requestProvider = requestProvider
		self.session = session
	}
	
	public func addOperation<APIRequest>(_ operation: CoreAPIOperation<APIRequest>) throws where APIRequest: CoreAPIRequest {
		let request = try requestProvider.provideRequest(for: APIRequest.self)
		let priority = taskPriority(for: operation)
		operation.task = CoreAPIRequestTask(apiRequest: request, priority: priority, urlSession: session)
		queue.addOperation(operation)
	}
	
	public func cachedValue<APIRequest>(_ operation: CoreAPIOperation<APIRequest>) throws -> APIRequest.ResponseDataType? where APIRequest: CoreAPIRequest {
		let data = try operation.generateRequestData()
		let request = try requestProvider.provideRequest(for: APIRequest.self)
		let task = CoreAPIRequestTask(apiRequest: request, urlSession: session)
		return task.cachedResponse(for: data, in: session.configuration.urlCache ?? .shared)
	}

	func taskPriority(for operation: Operation) -> Float {
		switch operation.qualityOfService {
		case .background:
			return URLSessionTask.lowPriority
		case .default, .utility:
			return URLSessionTask.defaultPriority
		case .userInitiated, .userInteractive:
			return URLSessionTask.highPriority
		@unknown default:
			LogManager.coreApi.debug("%{public}@ taskPriority(for:) - unexpected .qualityOfService: %d (defaulting to .default)", "\(self)", operation.qualityOfService.rawValue)
			return URLSessionTask.defaultPriority
		}
	}
}
