//
//  MockCoreAPIOperation.swift
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

import CoreResolve

public enum MockCoreAPIOperationError: Error {
	case missingGenerateRequestDataHandler
}

open class MockCoreAPIOperation<APIRequest>: CoreAPIOperation<APIRequest> where APIRequest: CoreAPIRequest {
	
	open var handleCancel = { }
	open var handleFinish = { }
	open var handleGenerateRequestData: (() throws -> APIRequest.RequestDataType)?
	
	override open func cancel() {
		handleCancel()
		super.cancel()
	}
	
	override open func finish() {
		handleFinish()
		super.finish()
	}
	
	override open func generateRequestData() throws -> APIRequest.RequestDataType {
		guard let handleGenerateRequestData = handleGenerateRequestData else {
			throw MockCoreAPIOperationError.missingGenerateRequestDataHandler
		}
		return try handleGenerateRequestData()
	}
}
