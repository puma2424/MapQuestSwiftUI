//
//  CustomPointAnnotation.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/6.
//

import Foundation
import MapKit

protocol CustomPointAnnotationDelegate: AnyObject {
    func didChangeHeading(newHeading: CLHeading?)
}

class CustomPointAnnotation: MKPointAnnotation {
    enum Role {
        case main
        case selfUser
        case otherUser
    }

    weak var delegate: CustomPointAnnotationDelegate?
    
    // 用戶
    var user: User
    var role: Role = .otherUser
    
    var heading: CLHeading? {
        didSet {
            delegate?.didChangeHeading(newHeading: heading)
        }
    }
    
    // 自定義初始化方法
    init(user: User, role: Role = .otherUser, title: String? = nil, subtitle: String? = nil) {
        self.user = user
        self.role = role
        super.init()
        self.coordinate = user.location.coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    deinit {
        print("---------------------- CustomPointAnnotation ----------------------")
        print("☠️ \(user.name) will dead")
        print("deinit")
    }
}
