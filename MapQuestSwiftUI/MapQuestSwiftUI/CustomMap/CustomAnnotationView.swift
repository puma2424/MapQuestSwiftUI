//
//  CustomAnnotationView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/6.
//

import Foundation
import MapKit
import SwiftUI
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
    
    private(set) var headingDirectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = true
        self.setupSubviews()
        self.setupHeadingDirection()
        guard let annotation = annotation as? CustomPointAnnotation else { return }
        annotation.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func headingDirection(isShow: Bool) {
        headingDirectionView.isHidden = !isShow
    }
    
    func setupHeadingDirection() {
        headingDirection(isShow: false)
        addSubview(headingDirectionView)
        headingDirectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headingDirectionView.widthAnchor.constraint(equalToConstant: 3),
            headingDirectionView.heightAnchor.constraint(equalToConstant: 10),
            headingDirectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            headingDirectionView.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -20)
        ])
    }
    
    private func setupSubviews() {
        // 添加 nameLabel
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 35)
        ])
        
        // 添加 imageContainerView
        addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageContainerView.widthAnchor.constraint(equalToConstant: 35),
            imageContainerView.heightAnchor.constraint(equalToConstant: 35),
            imageContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
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
    
    func updateHeadingRotation(rotation: CGFloat) {
        headingDirectionView.transform = CGAffineTransform(rotationAngle: rotation)
    }
}

extension CustomAnnotationView: CustomPointAnnotationDelegate {
    func didChangeHeading(newHeading: CLHeading?) {
        guard let userHeading = newHeading,
              userHeading.headingAccuracy > 0 else {
            headingDirection(isShow: false)
            return
        }
        
        let heading = userHeading.trueHeading > 0 ? userHeading.trueHeading : userHeading.magneticHeading
        let rotation = CGFloat(heading/180 * Double.pi)
        headingDirection(isShow: true)
        updateHeadingRotation(rotation: rotation)
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

struct CustomAnnotationViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIView {
        let view = CustomAnnotationView()
        view.nameLabel.text = "Hello World"
        view.imageContainerView.configure(userImage: UIImage.antita)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
#Preview {
    CustomAnnotationViewRepresentable()
            .frame(width: 200, height: 200) // 給定一個明確的框架大小
}
