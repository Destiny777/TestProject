//
//  ProductDetailViewModel.swift
//  TestProject
//

import Foundation

final class ProductDetailViewModel {
    let product: ItemModel
    private let favorites: FavoritesStoring
    private(set) var isFavorite: Bool
    var onChange: ((Bool) -> Void)?

    init(product: ItemModel, favorites: FavoritesStoring) {
        self.product = product
        self.favorites = favorites
        self.isFavorite = favorites.isFavorite(id: product.id)
    }

    func toggleFavorite() {
        isFavorite.toggle()
        favorites.setFavorite(isFavorite, id: product.id)
        onChange?(isFavorite)
    }
}
