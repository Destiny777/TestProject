//
//  FavoritesStore.swift
//  TestProject
//

import Foundation

protocol FavoritesStoring {
    func favoriteIDs() -> Set<Int>
    func isFavorite(id: Int) -> Bool
    func setFavorite(_ isFavorite: Bool, id: Int)
}

final class FavoritesStore: FavoritesStoring {
    private let key = "favoriteProductIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func favoriteIDs() -> Set<Int> {
        Set(defaults.array(forKey: key) as? [Int] ?? [])
    }

    func isFavorite(id: Int) -> Bool {
        favoriteIDs().contains(id)
    }

    func setFavorite(_ isFavorite: Bool, id: Int) {
        var ids = favoriteIDs()
        if isFavorite {
            ids.insert(id)
        } else {
            ids.remove(id)
        }
        defaults.set(Array(ids), forKey: key)
    }
}
