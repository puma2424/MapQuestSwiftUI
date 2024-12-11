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

class UIMapView: UIView {
    var mapView: MKMapView!
    var userAnnotations: [String: CustomPointAnnotation] = [:]
    var pinImage: [String: UIImage?] = [:]
    
    var mainRoute: [CLLocation] = [] {
        didSet {
            updateRoute(mainRoute.map(\.coordinate))
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
    
    func addUser(name: String, customPointAnnotation: CustomPointAnnotation) {
        guard userAnnotations[name] == nil else { return }
        userAnnotations[name] = customPointAnnotation
        customPointAnnotation.title = name
        mapView.addAnnotation(customPointAnnotation)
        // 強制刷新地圖標註
        if let customView = mapView.annotations.first(where: { annotation in
            guard let customAnnotation = annotation as? CustomPointAnnotation else { return false }
            return customAnnotation === customPointAnnotation
        }) as? CustomAnnotationView {
            customView.updateContent(for: customPointAnnotation)
        }
        print("--------------UIMapView------------")
        print("+ Add user name: \(name)")
        print("+ Add user annotation: \(customPointAnnotation)")
        print("------------------------------------\n")
    }
    @MainActor
    func updateUserLocation(userName: String, _ location: CLLocationCoordinate2D) {
        guard let userAnnotation = userAnnotations[userName] else { return }
        UIView.animate(withDuration: 1.0, animations: {
            userAnnotation.coordinate = location
        })
    }
    
    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    func removeAnnotation(name: String) {
        guard let userAnnotation = userAnnotations[name] else { return }
        
        mapView.removeAnnotation(userAnnotation)
        
        userAnnotations.removeValue(forKey: name)
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
    
}

struct MapViewRepresentable: UIViewRepresentable {
    
    @Binding var userAnnotations: [String: User]
    func makeUIView(context: Context) -> UIMapView {
        let uiMapView = UIMapView()
        return uiMapView
    }
    
    func updateUIView(_ uiView: UIMapView, context: Context) {
        removeUser(uiView)
        
        guard !userAnnotations.isEmpty else { return }
        
        var sumLat: CLLocationDegrees = 0
        var sumLng: CLLocationDegrees = 0
        
        userAnnotations.forEach { (name, user) in
            if name == "Puma" {
                uiView.mainRoute.append(user.location)
            }
            if uiView.userAnnotations[name] == nil {
                uiView.addUser(name: name,
                               customPointAnnotation: .init(coordinate: user.location.coordinate, user: user))
                print("-------Map View Representable------")
                print("▶️ add name: \(name)")
                print("▶️ add User: \(user)")
                print("------------------------------------\n")
            } else {
                uiView.updateUserLocation(userName: name, user.location.coordinate)
            }
//            sumLat += location.coordinate.latitude
//            sumLng += location.coordinate.longitude
//            
            
        }
        let averageCoordinate = CLLocationCoordinate2D(
            latitude: sumLat / Double(userAnnotations.count),
            longitude: sumLng / Double(userAnnotations.count)
        )
        if let location =  userAnnotations["Puma"]?.location.coordinate {
            uiView.centerMapOnLocation(coordinate: location)
        }
    }
    
    
    func removeUser(_ uiView: UIMapView) {
        // 移除地圖中不再存在的用戶
        let existingUserKeys = Set(uiView.userAnnotations.keys)
        let currentUserKeys = Set(userAnnotations.keys)
        
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

    
#Preview {
    @State var userAnnotations: [String : User] = ["aa": .init(name: "ya", location: .init(latitude: 25.059093026560458, longitude: 121.52061640290475), walkingIndex: 0)]
    
    MapViewRepresentable(userAnnotations: $userAnnotations)
    
}
//25.059093026560458
//121.52061640290475
