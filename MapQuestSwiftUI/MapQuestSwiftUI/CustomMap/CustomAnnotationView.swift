//
//  CustomAnnotationView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/6.
//

import Foundation
import MapKit
class CustomAnnotationView: MKAnnotationView {
    private(set) lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private(set) var imageContainerView: ImageContainerView = {
        let container = ImageContainerView()
        return container
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = true
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupSubviews() {
        // 添加 nameLabel
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        // 添加 imageContainerView
        addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageContainerView.widthAnchor.constraint(equalToConstant: 35),
            imageContainerView.heightAnchor.constraint(equalToConstant: 35),
            imageContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -5)
        ])
    }
    
    @MainActor
    func setupUserImage(annotation: CustomPointAnnotation) {
        // 设置名称
        nameLabel.text = annotation.user.name
        
        // 设置图片
        if let userImage = annotation.user.image {
            imageContainerView.configure(userImage: userImage)
        } else {
            imageContainerView.configure(userImage: UIImage(systemName: "person")!)
        }
    }
    
    func updateContent(for annotation: CustomPointAnnotation) {
        setupUserImage(annotation: annotation)
    }
}

class ImageContainerView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 17.5 // 圆形图片
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(userImage: UIImage) {
        imageView.image = userImage
    }
}
