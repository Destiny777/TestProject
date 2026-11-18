//
//  ListService.swift
//  TestProject
//

import Foundation

struct ListService: ListServicing {
    var url: URL
    var session: URLSession

    init(
        url: URL = URL(string: "https://dummyjson.com/products?limit=20")!,
        session: URLSession = .shared
    ) {
        self.url = url
        self.session = session
    }

    func fetchProducts() async throws -> [ItemModel] {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw ListServiceError.requestFailed(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw ListServiceError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw ListServiceError.requestFailed("The server returned an error (\(http.statusCode)).")
        }

        do {
            let decoded = try JSONDecoder().decode(ProductsResponse.self, from: data)
            return decoded.products
        } catch {
            throw ListServiceError.invalidResponse
        }
    }
}
