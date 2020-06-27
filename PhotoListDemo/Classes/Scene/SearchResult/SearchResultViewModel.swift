//
//  SearchResultViewModel.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/27.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt

final class SearchResultViewModel: ViewModelType {
    static let pageSize = 10
    
    private var currentPage = 0
    private var keyword: String?
    private var photosRelay: BehaviorRelay<[Photo]> = .init(value: [])
    
    var showCarousel: PublishRelay<(Observable<[Photo]>, Int)> = .init()
    var carouselIndex: BehaviorRelay<Int?> = .init(value: nil)
    var search: BehaviorRelay<String?> = .init(value: nil)
    let searchObs: Observable<String?>
    
    init(searchObs: Observable<String?>) {
        self.searchObs = searchObs
    }
    
    func transform(input: Input) -> Output {
        let activity = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let nextPage = carouselIndex.unwrap().withLatestFrom(photosRelay.asObservable()) { ($0, $1) }
            .filter { $0 + 2 >= $1.count  }
            .mapToVoid()

        let fetchNext = Observable.merge(input.fetchList, nextPage)
        let search = searchObs
            .distinctUntilChanged()
            .do(onNext: { [unowned self] _ in
                self.currentPage = 0
            })
        
        _ = Observable.combineLatest(search, fetchNext)
            .map { $0.0 }
            .map ({ [unowned self] in
                ($0, self.currentPage + 1)
            })
            .flatMap ({ arg -> Observable<([Photo], Int)> in
                let keyword = arg.0
                let page = arg.1
                return PhotosProvider.shared.search(page: page, pageSize: Self.pageSize, keyword: keyword ?? "")
                    .trackActivity(activity)
                    .trackError(errorTracker)
                    .catchErrorJustComplete()
                    .map {( $0.results ?? [], page )}
            })
            .scan([Photo]()) {
                $1.1 == 1 ? $1.0 : $0 + $1.0
            }
            .do(onNext: { [unowned self] in
                self.currentPage = ($0.count / Self.pageSize) + ($0.count % Self.pageSize > 0 ? 1 : 0)
            })
            .bind(to: photosRelay)
        
        _ = input.photoPressed.asObservable()
            .map { (self.photosRelay.asObservable(), $0) }
            .bind(to: showCarousel)
        
        return Output(list: photosRelay.asDriver(),
                      currentIndex: carouselIndex.unwrap().asDriverOnErrorJustComplete(),
                      isLoading: activity.asDriver(),
                      error: errorTracker.asDriver())
    }
}

extension SearchResultViewModel {
    struct Input {
        var fetchList: Observable<Void>
        var search: Observable<(String, Int)>
        var photoPressed: Observable<Int>
    }
    
    struct Output {
        var list: Driver<[Photo]>
        var currentIndex: Driver<Int>
        var isLoading: Driver<Bool>
        var error: Driver<Error>
    }
}
