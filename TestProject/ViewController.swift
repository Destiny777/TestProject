//
//  ViewController.swift
//  TestProject
//

import UIKit

final class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var statusStack: UIStackView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    var viewModel: ListVm!
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Products"
        navigationItem.largeTitleDisplayMode = .always
        configureSearch()
        configureTable()
        configureStatusView()
        bind()
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadFavorites()
    }

    private func configureSearch() {
        search.placeholder = "Search by title"
        search.autocapitalizationType = .none
        search.autocorrectionType = .no
        search.delegate = self
    }

    private func configureTable() {
        tableView.register(UINib(nibName: "TableCell", bundle: nil), forCellReuseIdentifier: TableCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 260
        tableView.keyboardDismissMode = .onDrag
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func configureStatusView() {
        spinner.hidesWhenStopped = true
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
    }

    private func bind() {
        viewModel.onChange = { [weak self] state in
            self?.render(state)
        }
        viewModel.onError = { [weak self] message in
            self?.presentError(message)
        }
    }

    private func render(_ state: ListState) {
        tableView.reloadData()

        if !state.isLoading {
            refreshControl.endRefreshing()
        }

        let showLoader = state.isLoading && state.products.isEmpty
        if showLoader {
            spinner.startAnimating()
            messageLabel.text = "Loading products..."
            messageLabel.isHidden = false
            retryButton.isHidden = true
            statusStack.isHidden = false
            return
        }
        spinner.stopAnimating()

        if let error = state.errorMessage, state.products.isEmpty {
            messageLabel.text = error
            messageLabel.isHidden = false
            retryButton.isHidden = false
            statusStack.isHidden = false
            return
        }

        if state.filtered.isEmpty {
            let query = state.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            messageLabel.text = query.isEmpty
                ? "No products available."
                : "No products match “\(query)”."
            messageLabel.isHidden = false
            retryButton.isHidden = true
            statusStack.isHidden = false
            return
        }

        statusStack.isHidden = true
    }

    private func presentError(_ message: String) {
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(title: "Couldn't Update Products", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func openDetail(_ product: ItemModel) {
        performSegue(withIdentifier: "showDetail", sender: product)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail",
              let detail = segue.destination as? ProductDetailViewController,
              let product = sender as? ItemModel else { return }
        detail.viewModel = viewModel.makeDetailViewModel(for: product)
    }

    @IBAction private func retryTapped() {
        viewModel.load()
    }

    @objc private func refreshPulled() {
        viewModel.load()
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state.filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.reuseID, for: indexPath) as! TableCell
        guard let product = viewModel.product(at: indexPath.row) else { return cell }
        cell.configure(with: product, isFavorite: viewModel.isFavorite(id: product.id))
        cell.onFavoriteTapped = { [weak self] in
            self?.viewModel.toggleFavorite(id: product.id)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let product = viewModel.product(at: indexPath.row) else { return }
        openDetail(product)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearch(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
