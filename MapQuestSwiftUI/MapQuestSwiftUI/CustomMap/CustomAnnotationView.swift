//
//  CustomAnnotationView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/6.
//

import Foundation
import MapKit
class CustomAnnotationView: MKAnnotationView {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private let imageContainerView: UIView = {
            let view = UIView()
            view.clipsToBounds = true  // 圓形圖片的容器
            return view
        }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let annotation = annotation as? CustomPointAnnotation else { return }
        // 初始化自定义外观
        self.canShowCallout = true
        
        self.setupUserImage(annotation: annotation)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    @MainActor
    func setupUserImage(annotation: CustomPointAnnotation ) {
        // 設置圖片
        if let userImage = annotation.user.image {
            let imageSize: CGFloat = 35  // 設定圖片大小
            
            // 創建 UIImageView
            let imageView = UIImageView(image: userImage)
            imageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = imageSize / 2
            imageView.clipsToBounds = true  // 圓形圖片
            imageContainerView.addSubview(imageView)
            
            // 將圖片容器添加到 Annotation View
            self.addSubview(imageContainerView)
            
            // 使用 AutoLayout 來設置 imageContainerView
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageContainerView.widthAnchor.constraint(equalToConstant: imageSize),
                imageContainerView.heightAnchor.constraint(equalToConstant: imageSize),
                imageContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                imageContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }else {
            self.image = UIImage(systemName: "person")
        }
        
        nameLabel.text = annotation.title
        print(annotation.title)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(nameLabel)
        
        
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 20),
        ])
    }
}
