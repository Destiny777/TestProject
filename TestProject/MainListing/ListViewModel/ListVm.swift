//
//  ListVm.swift
//  TestProject
//

import Foundation

struct ListState {
    var isLoading = false
    var products: [ItemModel] = []
    var filtered: [ItemModel] = []
    var searchText = ""
    var errorMessage: String?
    var favoriteIDs: Set<Int> = []
}

final class ListVm {
    var onChange: ((ListState) -> Void)?
    var onError: ((String) -> Void)?

    private(set) var state: ListState
    private let service: ListServicing
    private let favorites: FavoritesStoring

    init(service: ListServicing, favorites: FavoritesStoring) {
        self.service = service
        self.favorites = favorites
        state = ListState(favoriteIDs: favorites.favoriteIDs())
    }

    func makeDetailViewModel(for product: ItemModel) -> ProductDetailViewModel {
        ProductDetailViewModel(product: product, favorites: favorites)
    }

    func load() {
        state.isLoading = true
        state.errorMessage = nil
        notify()

        Task {
            do {
                let products = try await service.fetchProducts()
                state.isLoading = false
                state.products = products
                applySearch()
            } catch {
                state.isLoading = false
                let message = error.localizedDescription
                if state.products.isEmpty {
                    state.errorMessage = message
                } else {
                    onError?(message)
                }
                notify()
            }
        }
    }

    func updateSearch(_ text: String) {
        state.searchText = text
        applySearch()
    }

    func product(at index: Int) -> ItemModel? {
        state.filtered.indices.contains(index) ? state.filtered[index] : nil
    }

    func isFavorite(id: Int) -> Bool {
        state.favoriteIDs.contains(id)
    }

    func toggleFavorite(id: Int) {
        let isFavorite = !state.favoriteIDs.contains(id)
        favorites.setFavorite(isFavorite, id: id)
        if isFavorite {
            state.favoriteIDs.insert(id)
        } else {
            state.favoriteIDs.remove(id)
        }
        notify()
    }

    func reloadFavorites() {
        state.favoriteIDs = favorites.favoriteIDs()
        notify()
    }

    private func applySearch() {
        let query = state.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        state.filtered = query.isEmpty
            ? state.products
            : state.products.filter { $0.title.localizedCaseInsensitiveContains(query) }
        notify()
    }

    private func notify() {
        onChange?(state)
    }
}
