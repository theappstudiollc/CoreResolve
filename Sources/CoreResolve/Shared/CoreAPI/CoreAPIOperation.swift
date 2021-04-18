//
//  CoreAPIOperation.swift
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

open class CoreAPIOperation<APIRequest>: CoreAsynchronousOperation where APIRequest: CoreAPIRequest {
	
	public typealias CoreAPIRequestTaskResult = Result<APIRequest.ResponseDataType, CoreAPIError>
	
	public var operationError: Error?
	
	internal var task: CoreAPIRequestTask<APIRequest>!
	
	open override func cancel() {
		task?.cancel()
		super.cancel()
	}
	
	open override func main() {
		do {
			let data = try generateRequestData()
			task.performRequest(requestData: data, completionHandler: processAgentResponse)
		} catch {
			operationError = error
			finish()
		}
	}
	
	open func generateRequestData() throws -> APIRequest.RequestDataType {
		fatalError("Subclasses must implement `generateRequestData` (and not call super.generateRequestData).")
	}
	
	open func processResponse(_ response: CoreAPIRequestTaskResult, completion: @escaping (Error?) -> Void) -> Void {
		fatalError("Subclasses must implement `processResponse` (and not call super.processResponse).")
	}
	
	func processAgentResponse(_ response: CoreAPIRequestTaskResult) -> Void {
		processResponse(response, completion: processResponseCompletion)
	}
	
	func processResponseCompletion(_ error: Error?) {
		// TODO: Maybe wrap this error if the operation is cancelled
		if !isCancelled {
			operationError = error
		}
		finish()
	}
}
