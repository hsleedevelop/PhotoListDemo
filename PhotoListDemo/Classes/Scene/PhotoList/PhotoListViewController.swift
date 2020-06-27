//
//  PhotoListViewController.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/25.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoListViewController: UIViewController {
    
    var viewModel: PhotoListViewModel!
    var resultViewController: UIViewController!
    
    // MARK: - * Properties --------------------
    private let disposeBag = DisposeBag()
    private let photoPressedRelay: BehaviorRelay<IndexPath?> = .init(value: nil)
    private let draggingRelay = BehaviorRelay<Bool>(value: false)
    private let fetchNextRelay = BehaviorRelay<Void>(value: ())
    
    
    private lazy var searchController: UISearchController = {
        return UISearchController(searchResultsController: resultViewController)
    }()
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupTableView()
        
        setupRx()
        bindViewModel()
    }
    
    private func setupAppearance() {
        title = "Photo List"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .white
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos"

        searchController.obscuresBackgroundDuringPresentation = true
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController

        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
    }
    
    private func setupTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        
        tableView.register(PhotoListTableViewCell.self, forCellReuseIdentifier: "PhotoListTableViewCell")
    }
    
    private func setupRx() {
        Observable.merge(tableView.rx.willBeginDragging.asObservable(),
                         tableView.rx.willBeginDecelerating.asObservable())
            .map { true }
            .bind(to: draggingRelay)
            .disposed(by: disposeBag)
        
        Observable.merge(tableView.rx.didEndDragging.asObservable(),
                         tableView.rx.didEndDecelerating.map { false }.asObservable())
            .filter { $0 == false }
            .bind(to: draggingRelay)
            .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell.withLatestFrom(draggingRelay) { ($0, $1) }
            .filter { $0.1 }
            .map { $0.0 }
            .filter ({ [unowned self] _, indexPath in
                indexPath.row + 1 == self.tableView.numberOfRows(inSection: 0)
            })
            .map { [unowned self] _ in self.tableView.numberOfRows(inSection: 0) }
            .distinctUntilChanged()
            .mapToVoid()
            .bind(to: fetchNextRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        
        let output = viewModel.transform(input: .init(fetchList: fetchNextRelay.asObservable(),
                                                      search: .empty(),
                                                      photoPressed: photoPressedRelay.unwrap().map { $0.row }))
        
        output.list
            .drive(tableView.rx.items)({ [unowned self] (tv, row, photoItem) -> UITableViewCell in
                let indexPath = IndexPath(row: row, section: 0)
                guard let cell = tv.dequeueReusableCell(withIdentifier: "PhotoListTableViewCell", for: indexPath) as? PhotoListTableViewCell else {
                    return .init()
                }
                cell.bind(viewModel: .init(with: photoItem), indexPath: indexPath)
                cell.rx.imagePressed
                    .bind(to: self.photoPressedRelay)
                    .disposed(by: cell.disposeBag)
                return cell
            })
            .disposed(by: disposeBag)
        
        output.currentIndex
            .drive(onNext: { [unowned self] index in
                self.tableView.scrollToRow(at: .init(row: index, section: 0), at: .middle, animated: false)
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [unowned self] error in
                self.showAlert(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.searchBar.text = ""
        return true
    }
}

extension PhotoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResults=\(searchController.searchBar.text)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.search.accept(searchController.searchBar.text)
    }
    
    
}
