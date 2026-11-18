//
//  TableCell.swift
//  TestProject
//

import UIKit

final class TableCell: UITableViewCell {
    static let reuseID = "TableCell"

    var onFavoriteTapped: (() -> Void)?

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    private var imageTask: Task<Void, Never>?
    private var imageURL: URL?

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        imageURL = nil
        thumbnailView.image = placeholder
        thumbnailView.contentMode = .scaleAspectFit
        onFavoriteTapped = nil
    }

    func configure(with product: ItemModel, isFavorite: Bool) {
        titleLabel.text = product.title
        priceLabel.text = product.priceText
        applyFavorite(isFavorite)
        loadThumbnail(product.thumbnail)
    }

    private func applyFavorite(_ isFavorite: Bool) {
        let symbol = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: symbol), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemRed : .secondaryLabel
    }

    private func loadThumbnail(_ urlString: String) {
        imageTask?.cancel()
        guard let url = URL(string: urlString) else {
            thumbnailView.image = placeholder
            thumbnailView.contentMode = .scaleAspectFit
            return
        }

        imageURL = url
        if let cached = ImageLoader.shared.cachedImage(for: url) {
            thumbnailView.image = cached
            thumbnailView.contentMode = .scaleAspectFill
            return
        }

        thumbnailView.image = placeholder
        thumbnailView.contentMode = .scaleAspectFit
        imageTask = Task { [weak self] in
            let image = await ImageLoader.shared.image(from: url)
            guard let self, !Task.isCancelled, self.imageURL == url else { return }
            if let image {
                self.thumbnailView.image = image
                self.thumbnailView.contentMode = .scaleAspectFill
            }
        }
    }

    @IBAction private func favoriteTapped() {
        onFavoriteTapped?()
    }

    private var placeholder: UIImage? {
        UIImage(systemName: "photo")
    }
}
