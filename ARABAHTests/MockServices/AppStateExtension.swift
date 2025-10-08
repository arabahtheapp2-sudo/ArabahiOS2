//
//  AppStateExtension.swift
//  ARABAHTests
//
//  Created by cqlm2 on 16/07/25.
//

import XCTest
import Combine
@testable import ARABAH
// MARK: - Equatable Conformance for AppState<LoginModal>
extension AppState: Equatable where Value: Equatable {
    public static func == (lhs: AppState<Value>, rhs: AppState<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.success(let lhsVal), .success(let rhsVal)):
            return lhsVal == rhsVal
        case (.failure(let lhsErr), .failure(let rhsErr)):
            return lhsErr == rhsErr
        case (.validationError(let lhsErr), .validationError(let rhsErr)):
            return lhsErr == rhsErr
        default:
            return false
        }
    }
}
