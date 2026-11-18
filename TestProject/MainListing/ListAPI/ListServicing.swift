//
//  ListServicing.swift
//  TestProject
//

import Foundation

protocol ListServicing {
    func fetchProducts() async throws -> [ItemModel]
}

enum ListServiceError: LocalizedError {
    case invalidResponse
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The product list could not be read. Please try again."
        case .requestFailed(let message):
            return message
        }
    }
}
