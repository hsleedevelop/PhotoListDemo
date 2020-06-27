//
//  ImageCollectionViewCell.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/27.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift

///Common CollectionView
final class CarouselCollectionViewCell: UICollectionViewCell {
    
    // MARK: - * Properties --------------------
    private var disposeBag = DisposeBag()
    private var viewModel: PhotoListTableViewCellViewModel!
    
    private var indexPath: IndexPath!
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    
    private let gesture1 = UITapGestureRecognizer() //toggle tollbar gesture
    private let gesture2 = UITapGestureRecognizer() //zoom gesture
    
    private lazy var gestureObs2: Observable<UITapGestureRecognizer> = {
        gesture2.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(gesture2)
        return gesture2.rx.event.asObservable()
    }()
    
    private lazy var gestureObs1: Observable<UITapGestureRecognizer> = {
        gesture1.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture1)
        
        gesture1.require(toFail: gesture2)
        return gesture1.rx.event.asObservable()
    }()
    
    
    // MARK: - * Initialize --------------------
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView = .init(frame: self.bounds)
        self.scrollView = .init(frame: self.bounds)
    
        self.imageView.backgroundColor = .green
        
        setupViews()
        setupScrollView()
    }
    
    override func didMoveToSuperview() {
        guard self.superview != nil else { return }
        _ = dispatchOnce
    }
    
    private lazy var dispatchOnce: Void = {
        setupGesture()
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        
        scrollView.setZoomScale(0, animated: true)
        setupGesture()
    }
    
    private func setupViews() {
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
        
        let scrollConstraints = [scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                 scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                                 scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                 scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)]
        
        scrollConstraints.forEach { $0.priority = .init(750); $0.isActive = true }
        
        let imageViewConstraints = [imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                                 imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                                 imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                                 imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)]
        
        imageViewConstraints.forEach { $0.priority = .init(750); $0.isActive = true }
        
        let equalWidthConstraint = imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        equalWidthConstraint.priority = .init(749)
        equalWidthConstraint.isActive = true

        let equalHeightConstraint = imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        equalHeightConstraint.priority = .init(749)
        equalHeightConstraint.isActive = true
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.isScrollEnabled = true
    }
    
    private func setupGesture() {
        gestureObs1
            .map { [unowned self] _ in self.parentViewControllerOfSelf?.navigationController?.navigationBar.isHidden }
            .unwrap()
            .map { !$0 }
            .do(onNext: { [unowned self] isHidden in
                self.parentViewControllerOfSelf?.view.backgroundColor = isHidden ? .black : .white
            })
            .bind(to: self.parentViewControllerOfSelf!.navigationController!.navigationBar.rx.isHidden)
            .disposed(by: disposeBag)
        
        gestureObs2
            .subscribe(onNext: { [unowned self] recognizer in
                self.zoom(center: recognizer.location(in: recognizer.view))
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - * UI Events --------------------
    private func zoom(center: CGPoint) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.zoom(to: (zoomRectForScale(scale: scrollView.maximumZoomScale, center: center)), animated: true)
        }
    }

    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func bind(viewModel: PhotoListTableViewCellViewModel, indexPath: IndexPath) {
        self.viewModel = viewModel
        self.indexPath = indexPath
        
        viewModel.image
            .observeOn(MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }
}


//refer: https://github.com/aFrogleap/SimpleImageViewer
extension CarouselCollectionViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let image = imageView.image else { return }
        
        let imageViewSize = Utilities.aspectFitRect(forSize: image.size, insideRect: imageView.frame)
        let verticalInsets = -(scrollView.contentSize.height - max(imageViewSize.height, scrollView.bounds.height)) / 2
        let horizontalInsets = -(scrollView.contentSize.width - max(imageViewSize.width, scrollView.bounds.width)) / 2
        
        scrollView.contentInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
    }
}
