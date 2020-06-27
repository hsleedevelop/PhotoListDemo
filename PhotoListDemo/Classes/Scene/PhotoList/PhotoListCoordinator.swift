//
//  PhotoListCoordinator.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/25.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt

final class PhotoListCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    private var viewController: PhotoListViewController!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        guard let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PhotoListViewController") as? PhotoListViewController,
            let resultViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController else {
            fatalError("PhotoListViewController can't load")
        }
        self.viewController = viewController
        
        let viewModel = PhotoListViewModel()
        viewController.viewModel = viewModel
        viewController.resultViewController = resultViewController
        setupResultViewController(resultViewController, searchObs: viewModel.search.asObservable())
        
        viewModel.showCarousel
            .flatMap ({ [unowned self] in
                self.showCarousel(photosObs: $0.0, index: $0.1, on: viewController)
            })
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: viewModel.carouselIndex)
            .disposed(by: disposeBag)

        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return Observable.never()
    }
    
    private func setupResultViewController(_ resultViewController: SearchResultViewController, searchObs: Observable<String?>) {
        let searchResultViewModel = SearchResultViewModel(searchObs: searchObs)
        resultViewController.viewModel = searchResultViewModel
        
        searchResultViewModel.showCarousel
            .flatMap ({ [unowned self] in
                self.showCarousel(photosObs: $0.0, index: $0.1, on: resultViewController)
            })
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: searchResultViewModel.carouselIndex)
            .disposed(by: disposeBag)
    }

    private func showCarousel(photosObs: Observable<[Photo]>, index: Int, on rootViewController: UIViewController) -> Observable<Int?> {
        let coordinator = CarouselCoordinator(photosObs: photosObs, index: index, rootViewController: rootViewController)
        return coordinate(to: coordinator)
            .map { result in
                switch result {
                case .photo(let photoId):
                    return photoId
                case .cancel:
                    self.viewController.parent?.dismiss(animated: true, completion: nil)
                    return nil
                }
            }
    }
}
