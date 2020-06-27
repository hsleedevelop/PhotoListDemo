//
//  PhotoListTableViewCell.swift
//  PhotoListDemo
//
//  Created by HS Lee on 2020/06/26.
//  Copyright © 2020 HS Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

protocol CellViewModel: class {
    
}

final class PhotoListTableViewCellViewModel: CellViewModel {
    
    let image = BehaviorRelay<UIImage?>(value: nil)
    let imageUrl = BehaviorRelay<String?>(value: nil)
    
    let photo: Photo

    init(with photo: Photo) {
        self.photo = photo
        
        bindRx()
        imageUrl.accept(photo.urls?.regular)
    }
    
    private func bindRx() {
        _ = imageUrl.asObservable()
            .flatMap ({ url in
                url.map(ImageProvider.shared.get) ?? .empty()
            })
            .bind(to: image)
    }
}


final class PhotoListTableViewCell: UITableViewCell {
    
    // MARK: - * Properties --------------------
    var disposeBag = DisposeBag()
    var viewModel: PhotoListTableViewCellViewModel!

    var indexPath: IndexPath!

    var photoImageView: UIImageView!
    var aspectConstraint: NSLayoutConstraint?
        
    // MARK: - * Initialize --------------------
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        photoImageView = .init()
        _ = dispatchOnce
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        
        aspectConstraint?.isActive = false
        aspectConstraint = nil
    }
    
    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.isUserInteractionEnabled = false
        photoImageView.clipsToBounds = true
        
        contentView.addSubview(photoImageView)
        
        photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    lazy var dispatchOnce: Void = {
        setupViews()
    }()
    
    lazy var reloadRowOnce: Void = {
        DispatchQueue.main.async {
            if let tableView = (self.superview as? UITableView) {
                tableView.beginUpdates()
                tableView.reloadRows(at: [self.indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }()

    func bind(viewModel: PhotoListTableViewCellViewModel, indexPath: IndexPath) {
        self.viewModel = viewModel
        self.indexPath = indexPath
        
        viewModel.image
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] image in
                guard let image = image else { return }
                
                let aspect = image.size.width / image.size.height
                self.aspectConstraint = self.photoImageView.widthAnchor.constraint(equalTo: self.photoImageView.heightAnchor, multiplier: aspect)
                self.aspectConstraint?.priority = .init(999)
                self.aspectConstraint?.isActive = true
                
                self.photoImageView.layoutIfNeeded()
                _ = self.reloadRowOnce
            })
            .bind(to: photoImageView.rx.image)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: PhotoListTableViewCell {
    var imageLoaded: Observable<IndexPath> {
        return base.photoImageView.rx.observe(UIImage.self, "image").asObservable()
            .map { _ in self.base.indexPath }
    }
    
    var imagePressed: Observable<IndexPath> {
        return base.photoImageView.rx.tapGesture().when(.recognized)
        .map { _ in self.base.indexPath }
    }
}
