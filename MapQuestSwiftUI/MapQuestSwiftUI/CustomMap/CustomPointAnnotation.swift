//
//  CustomPointAnnotation.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/6.
//

import Foundation
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    deinit {
        print("---------------------- CustomPointAnnotation ----------------------")
        print("☠️ \(user.name) will dead")
        print("deinit")
    }
    // 用戶
    var user: User
    
    // 自定義初始化方法
    init(coordinate: CLLocationCoordinate2D, user: User, title: String? = nil, subtitle: String? = nil) {
        self.user = user
        super.init()
        self.coordinate = user.location.coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
