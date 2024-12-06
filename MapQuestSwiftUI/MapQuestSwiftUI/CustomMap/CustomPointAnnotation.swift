//
//  CustomPointAnnotation.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/6.
//

import Foundation
import MapKit
class CustomPointAnnotation: MKPointAnnotation {
    // 用戶圖片
    var userImage: UIImage?
    
    // 默認初始化
    override init() {
        super.init()
    }
    
    // 自定義初始化方法
    init(coordinate: CLLocationCoordinate2D, userImage: UIImage? = nil, title: String? = nil, subtitle: String? = nil) {
        self.userImage = userImage
        super.init()
    }
}
