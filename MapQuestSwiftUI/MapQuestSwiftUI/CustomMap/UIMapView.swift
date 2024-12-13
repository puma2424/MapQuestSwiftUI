//
//  UIMapView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/2.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import SwiftUI
import Combine

protocol UIMapViewDelegate: AnyObject {
    func regionWillChangeAnimated()
}

class UIMapView: UIView {
    
    weak var delegate: UIMapViewDelegate?
    
    var mapView: MKMapView!
    var mapOtherUsersAnnotation: [String: CustomPointAnnotation] = [:]
    var mapCurrentUserAnnotation: CustomPointAnnotation?
    var userTrackingMode: MKUserTrackingMode = .followWithHeading
    var mainRoute: [CLLocationCoordinate2D] = [] {
        didSet {
            updateRoute(mainRoute)
        }
    }
    
    var routePolyline: MKPolyline?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupMapView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMapView()
    }
    
    private func setupMapView() {
        mapView = MKMapView(frame: self.bounds)
        mapView.delegate = self
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(mapView)
    }
    
    func updateRoute(_ coordinates: [CLLocationCoordinate2D]) {
        // 移除舊的路線
        if let routePolyline = routePolyline {
            mapView.removeOverlay(routePolyline)
        }
        
        // 添加新的路線
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        routePolyline = polyline
    }
    
    @MainActor
    func addMapCurrentUser(customPointAnnotation: CustomPointAnnotation) {
        mapCurrentUserAnnotation = customPointAnnotation
        mapView.addAnnotation(customPointAnnotation)
        update(customPointAnnotation: customPointAnnotation)
        print("--------------UIMapView------------")
        print("+ Add current user annotation: \(customPointAnnotation)")
        print("+ Add user annotation: \(customPointAnnotation)")
        print("------------------------------------\n")
    }
    
    @MainActor
    func addMapOtherUsers(name: String, customPointAnnotation: CustomPointAnnotation) {
        guard mapOtherUsersAnnotation[name] == nil else { return }
        mapOtherUsersAnnotation[name] = customPointAnnotation
        customPointAnnotation.title = name
        mapView.addAnnotation(customPointAnnotation)
        update(customPointAnnotation: customPointAnnotation)
        print("--------------UIMapView------------")
        print("+ Add user name: \(name)")
        print("+ Add user annotation: \(customPointAnnotation)")
        print("------------------------------------\n")
    }
    
    @MainActor
    func update(customPointAnnotation: CustomPointAnnotation) {
        // 強制刷新地圖標註
        if let customView = mapView.annotations.first(where: { annotation in
            guard let customAnnotation = annotation as? CustomPointAnnotation else { return false }
            return customAnnotation === customPointAnnotation
        }) as? CustomAnnotationView {
            customView.updateContent(for: customPointAnnotation)
        }
    }
    @MainActor
    func updateOtherUsersLocation(userName: String, to location: CLLocationCoordinate2D) {
        guard let userAnnotation = mapOtherUsersAnnotation[userName] else { return }
        UIView.animate(withDuration: 1.0, animations: {
            userAnnotation.coordinate = location
        })
    }
    
    @MainActor
    func updateUserLocation(userAnnotation: MKPointAnnotation, to location: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 1.0, animations: {
            userAnnotation.coordinate = location
        })
    }
    
    func removeAnnotation(name: String) {
        guard let userAnnotation = mapOtherUsersAnnotation[name] else { return }
        
        mapView.removeAnnotation(userAnnotation)
        
        mapOtherUsersAnnotation.removeValue(forKey: name)
    }
    
    func changeUserHeading(newHeading: CLHeading?) {
        mapCurrentUserAnnotation?.heading = newHeading
    }
    
    func didChange(userTrackingMode: MKUserTrackingMode) {
        // TODO: - 變更追蹤模式後實現的邏輯
        print("---UIMapView did Change User Tracking Mode---")
        print(userTrackingMode.rawValue)
        print("--------------------------------------\n")
    }
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    func rotateMap(to angle: CLLocationDirection, animated: Bool = true) {
        var camera = mapView.camera
        camera.heading = angle // 設置旋轉角度（0-360 度）
        mapView.setCamera(camera, animated: animated)
    }
}

extension UIMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let customAnnotation = annotation as? CustomPointAnnotation else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            print("--------------UIMapView------------")
            print("🌁 Annotation: \(annotation)")
            print("------------------------------------\n")
            //Create View
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            print("--------------UIMapView------------")
            print("🌁 Annotation: \(annotation)")
            if let view = annotationView as? CustomAnnotationView {
                print("🌁 Create Vire: \(view.nameLabel.text)")
            }
            print("------------------------------------\n")
            
        } else {
            //Assign annotation
            annotationView?.annotation = annotation
        }
        // 確保標註視圖的內容被更新
        if let customView = annotationView as? CustomAnnotationView {
            customView.updateContent(for: customAnnotation)
            // 設定 CustomAnnotationView ui
            switch customAnnotation.role {
            case .selfUser:
                customView.headingDirection(isShow: true)
            default:
                customView.headingDirection(isShow: false)
            }
        }
        annotationView?.canShowCallout = true
        
        
        return annotationView
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // 偵測到使用者手動滑動地圖
        delegate?.regionWillChangeAnimated()
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    
    @Binding var mapOtherUsers: [String: User]
    @Binding var mapCurrentUser: User?
    @Binding var route: [CLLocationCoordinate2D]
    @Binding var userTrackingMode: MKUserTrackingMode
    
    func makeUIView(context: Context) -> UIMapView {
        let uiMapView = UIMapView()
        uiMapView.delegate = context.coordinator
        return uiMapView
    }
    
    func updateUIView(_ uiView: UIMapView, context: Context) {
        removeUser(uiView)
        setCurrentUser(uiView)
        setupOtherUsers(uiView)
        didChangeUserTrackingMode(uiView)
        uiView.mainRoute = route
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func didChangeUserTrackingMode(_ uiView: UIMapView) {
        uiView.didChange(userTrackingMode: userTrackingMode)
    }
    
    func moveToOtherUsersCenter(_ uiView: UIMapView) {
        guard !mapOtherUsers.isEmpty else { return }
        var sumLat: CLLocationDegrees = 0
        var sumLng: CLLocationDegrees = 0
        mapOtherUsers.forEach { (name, user) in
            sumLat += user.location.coordinate.latitude
            sumLng += user.location.coordinate.longitude
            
        }
        let averageCoordinate = CLLocationCoordinate2D(
            latitude: sumLat / Double(mapOtherUsers.count),
            longitude: sumLng / Double(mapOtherUsers.count)
        )
        uiView.centerMapOnLocation(coordinate: averageCoordinate)
    }
    
    func setupHeadings(_ uiView: UIMapView) {
        guard let mapCurrentUser else { return }
        uiView.changeUserHeading(newHeading: mapCurrentUser.heading)
    }
    
    func setupOtherUsers(_ uiView: UIMapView) {
        guard !mapOtherUsers.isEmpty else { return }
        mapOtherUsers.forEach { (name, user) in
            if uiView.mapOtherUsersAnnotation[name] == nil {
                uiView.addMapOtherUsers(name: name,
                               customPointAnnotation: .init(user: user))
                print("-------Map View Representable------")
                print("▶️ add name: \(name)")
                print("▶️ add User: \(user)")
                print("------------------------------------\n")
            } else {
                uiView.updateOtherUsersLocation(userName: name, to: user.location.coordinate)
            }
        }
    }
    
    func setCurrentUser(_ uiView: UIMapView) {
        guard let mapCurrentUser else { return }
        if let userAnnotation = uiView.mapCurrentUserAnnotation {
            uiView.updateUserLocation(userAnnotation: userAnnotation, to: mapCurrentUser.location.coordinate)
        }else {
            uiView.addMapCurrentUser(customPointAnnotation: .init(user: mapCurrentUser))
        }
        setupHeadings(uiView)
        uiView.mapCurrentUserAnnotation?.role = .selfUser
        
        switch userTrackingMode {
        case .none:
            return
        case .follow:
            uiView.centerMapOnLocation(coordinate: mapCurrentUser.location.coordinate)
        case .followWithHeading:
            uiView.centerMapOnLocation(coordinate: mapCurrentUser.location.coordinate)
            guard let heading = mapCurrentUser.heading else { return }
            uiView.rotateMap(to: heading.trueHeading)
        }
    }
    
    
    func removeUser(_ uiView: UIMapView) {
        // 移除地圖中不再存在的用戶
        let existingUserKeys = Set(uiView.mapOtherUsersAnnotation.keys)
        let currentUserKeys = Set(mapOtherUsers.keys)
        
        let removedUsers = existingUserKeys.subtracting(currentUserKeys)
        if !removedUsers.isEmpty {
            print("-------------MapViewRepresentable---------------")
            print("🫥🫥")
            print(removedUsers)
            print("----------------------------")
            removedUsers.forEach {
                uiView.removeAnnotation(name: $0)
                
            }
            
        }
        removedUsers.forEach { uiView.removeAnnotation(name: $0) }
    }
}

extension MapViewRepresentable {
    class Coordinator: NSObject, UIMapViewDelegate {
        func regionWillChangeAnimated() {
            // TODO: - 偵測到使用者手動滑動地圖
        }
    }
}

    
#Preview {
    @State var mapOtherUsers: [String : User] = ["aa": .init(name: "ya", location: .init(latitude: 25.059093026560458, longitude: 121.52061640290475), walkingIndex: 0)]
    @State var mapCurrentUser: User? = .init(name: "Puma", location: .init(latitude: 25.059093026560458, longitude: 121.52061640290475), walkingIndex: 0)
    @State var userRoute: [CLLocationCoordinate2D] = []
    @State var userTrackingMode: MKUserTrackingMode = .followWithHeading
    MapViewRepresentable(mapOtherUsers: $mapOtherUsers, mapCurrentUser: $mapCurrentUser, route: $userRoute, userTrackingMode: $userTrackingMode)
    
}
//25.059093026560458
//121.52061640290475
