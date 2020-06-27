//
//  CarouselViewController.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum SwipeDirection {
    case left, right
}

final class CarouselViewController: UIViewController {

    var viewModel: CarouselViewModel!
    
    // MARK: - * Properties --------------------
    private let disposeBag = DisposeBag()
    var swipeRelay: BehaviorRelay<SwipeDirection> = .init(value: .left)
    var indexRelay: BehaviorRelay<Int> = .init(value: 0)
    
    // MARK: - * IBOutlets --------------------
    @IBOutlet weak var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupCollectionView()
        
        bindViewModel()
        setupRx()
    }
    
    override func viewDidLayoutSubviews() {
        updateCollectionViewLayout()
    }

    @objc private func closeButtonTouched() {
        viewModel.cancelRelay.accept(())
    }
    
    private func setupAppearance() {
        navigationItem.leftBarButtonItem = .init(title: "닫기", style: .plain, target: self, action: #selector(closeButtonTouched))
    }

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.isPagingEnabled = true
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(CarouselCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
    }
    
    
    private func updateCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.estimatedItemSize = collectionView.frame.size
            layout.itemSize = UICollectionViewFlowLayout.automaticSize
            
            layout.invalidateLayout()
        }
    }
    
    private func setupRx() {
        collectionView.rx.didScroll
            .map ({ [unowned self] _ -> Int? in
                let center = CGPoint(x: self.collectionView.contentOffset.x + (self.collectionView.frame.width / 2), y: (self.collectionView.frame.height / 2))
                return self.collectionView.indexPathForItem(at: center)?.row
            })
            .unwrap()
            .distinctUntilChanged()
            .bind(to: viewModel.indexRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let output = viewModel.transform(input: .init())
        
        output.currentPhoto
            .map { $0.user?.name ?? "" }
            .drive(self.rx.title)
            .disposed(by: disposeBag)
        
        output.photos
            .do(afterNext: { [unowned self] _ in
                DispatchQueue.main.async {
                    self.collectionView.scrollToItem(at: .init(item: self.viewModel.indexRelay.value, section: 0), at: .centeredHorizontally, animated: false)
                }
            })
            .drive(collectionView.rx.items)  ({ (cv, item, photo) -> UICollectionViewCell in
                let indexPath = IndexPath(item: item, section: 0)
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? CarouselCollectionViewCell else {
                    return .init()
                }
                cell.bind(viewModel: .init(with: photo), indexPath: indexPath)
                return cell
            })
            .disposed(by: disposeBag)
    }
}
