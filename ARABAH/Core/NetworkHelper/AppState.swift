//
//  AppState.swift
//  ARABAH
//
//  Created by cqlm2 on 15/07/25.
//

/// Enum representing various possible UI states
enum AppState<Value> {
    case idle                           // Default state, no operation
    case loading                        //  In progress
    case success(Value)                 // Succeeded with response
    case failure(NetworkError)          // Failed with error
    case validationError(NetworkError)  // Validatation failed with error
}
