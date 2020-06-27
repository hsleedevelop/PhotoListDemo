//
//  CarouselViewModel.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import RxSwift
import RxCocoa
import RxSwiftExt

final class CarouselViewModel: ViewModelType {

    private var disposeBag = DisposeBag()
    private var photosObs: Observable<[Photo]>
    
    var indexRelay: BehaviorRelay<Int>
    var cancelRelay: PublishRelay<Void>
    
    init(photosObs: Observable<[Photo]>, index: Int) {
        self.photosObs = photosObs

        self.indexRelay = .init(value: index)
        self.cancelRelay = .init()
    }
    
    func transform(input: Input) -> Output {

        let selectedPhoto = indexRelay.withLatestFrom(self.photosObs) { ($0, $1) }
            .map { $0.1[$0.0] }
        
        return Output(currentPhoto: selectedPhoto.asDriverOnErrorJustComplete(),
                      photos: photosObs.asDriverOnErrorJustComplete())
    }
}

extension CarouselViewModel {
    struct Input {
    }
    
    struct Output {
        var currentPhoto: Driver<Photo>
        var photos: Driver<[Photo]>
    }
}
