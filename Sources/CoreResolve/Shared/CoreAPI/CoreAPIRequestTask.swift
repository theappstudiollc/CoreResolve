//
//  CoreAPIRequestAgent.swift
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

/// Performs a single CoreAPIRequest via a URLSessionDataTask
open class CoreAPIRequestTask<APIRequest> where APIRequest: CoreAPIRequest {
	
	public typealias CoreAPIRequestTaskResult = Result<APIRequest.ResponseDataType, CoreAPIError>
	
	/// Represents the state of this task
	///
	/// - running: The task is executing via the URLSession
	/// - suspended: The task is suspended
	/// - canceling: The task is canceling
	/// - completed: The task has completed
	/// - notStarted: The task has not been started
	public enum State: Int {
		case running
		case suspended
		case canceling
		case completed
		case notStarted
	}
	
	public let apiRequest: APIRequest
	public var priority: Float {
		didSet { task?.priority = priority }
	}
	internal var task: URLSessionDataTask?
	public let urlSession: URLSession
	
	public init(apiRequest: APIRequest, priority: Float = URLSessionTask.defaultPriority, urlSession: URLSession = .shared) {
		self.apiRequest = apiRequest
		// http://www.openradar.me/23956486 - iOS 8 optimized compiles can't access URLSessionTask.defaultPriority or peers without crashing
		self.priority = priority
		self.urlSession = urlSession
	}
	
	public func cancel() {
		guard let task = task else { return }
		switch task.state {
		case .running, .suspended:
			task.cancel()
		default: break
		}
	}
	
	public func performRequest(requestData: APIRequest.RequestDataType, completionHandler: @escaping (CoreAPIRequestTaskResult) -> Void) {
		guard task == nil else {
			completionHandler(.failure(.invalidOperation))
			return
		}
		do {
			let urlRequest = try apiRequest.makeRequest(from: requestData)
			task = urlSession.dataTask(with: urlRequest) { data, response, error in
				guard let data = data else {
					guard let error = error else {
						return completionHandler(.failure(.unexpectedError(response)))
					}
					return completionHandler(.failure(.sessionError(error, response)))
				}
				if let httpResponse = response as? HTTPURLResponse {
					if !(200..<300).contains(httpResponse.statusCode) {
						return completionHandler(.failure(.httpError(data, httpResponse)))
					}
				}
				do {
					let parsedResponse = try self.apiRequest.parseResponse(data: data)
					completionHandler(.success(parsedResponse))
				} catch {
					completionHandler(.failure(.parseResponseError(error, response)))
				}
			}
			task!.priority = priority
			task!.resume()
		} catch {
			completionHandler(.failure(.prepareRequestError(error)))
		}
	}
	
	public var state: State {
		guard let task = task else { return .notStarted }
		switch task.state {
		case .running:
			return .running
		case .canceling:
			return .canceling
		case .completed:
			return .completed
		case .suspended:
			return .suspended
		@unknown default:
			fatalError("Unexpected session task.state: \(task.state)")
		}
	}
}

extension CoreAPIRequestTask {
	
	public func cachedResponse(for requestData: APIRequest.RequestDataType, in cache: URLCache = .shared) -> APIRequest.ResponseDataType? {
		let request = try? apiRequest.makeRequest(from: requestData)
		guard let urlRequest = request, let response = cache.cachedResponse(for: urlRequest) else { return nil }
		return try? apiRequest.parseResponse(data: response.data)
	}
}
