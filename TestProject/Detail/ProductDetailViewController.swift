//
//  ProductDetailViewController.swift
//  TestProject
//

import UIKit

final class ProductDetailViewController: UIViewController {
    var viewModel: ProductDetailViewModel!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        showProduct()
        viewModel.onChange = { [weak self] isFavorite in
            self?.showFavorite(isFavorite)
        }
        showFavorite(viewModel.isFavorite)
        loadImage()
    }

    private func showProduct() {
        let product = viewModel.product
        titleLabel.text = product.title
        priceLabel.text = product.priceText
        descriptionLabel.text = product.description
    }

    private func showFavorite(_ isFavorite: Bool) {
        let symbol = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: symbol), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemRed : .secondaryLabel
    }

    private func loadImage() {
        guard let url = URL(string: viewModel.product.thumbnail) else { return }

        if let cached = ImageLoader.shared.cachedImage(for: url) {
            imageView.image = cached
            imageView.tintColor = nil
            return
        }

        imageSpinner.startAnimating()
        Task { [weak self] in
            let image = await ImageLoader.shared.image(from: url)
            guard let self else { return }
            self.imageSpinner.stopAnimating()
            if let image {
                self.imageView.image = image
                self.imageView.tintColor = nil
            }
        }
    }

    @IBAction private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
}
