//
//  ItemModel.swift
//  TestProject
//

import Foundation

nonisolated struct ProductsResponse: Decodable, Sendable {
    let products: [ItemModel]
}

nonisolated struct ItemModel: Decodable, Sendable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let rating: Double
    let thumbnail: String
}

extension ItemModel {
    var priceText: String {
        Self.priceFormatter.string(from: NSNumber(value: price))
            ?? String(format: "$%.2f", price)
    }

    private static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()
}
