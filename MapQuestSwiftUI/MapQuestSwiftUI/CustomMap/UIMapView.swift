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
    
    func addUser(name: String, customPointAnnotation: CustomPointAnnotation) {
        guard userAnnotations[name] == nil else { return }
        userAnnotations[name] = customPointAnnotation
        customPointAnnotation.title = name
        mapView.addAnnotation(customPointAnnotation)
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
}

extension UIMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? CustomPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
            
            if annotationView == nil {
                //Create View
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            } else {
                //Assign annotation
                annotationView?.annotation = annotation
            }
            annotationView?.canShowCallout = true
            
            return annotationView
        }
        return nil
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    
    @Binding var userAnnotations: [String: CLLocation]
    @Binding var userImages: [String: UIImage]
    func makeUIView(context: Context) -> UIMapView {
        let uiMapView = UIMapView()
        return uiMapView
    }
    
    func updateUIView(_ uiView: UIMapView, context: Context) {
        guard !userAnnotations.isEmpty else { return }
        
        var sumLat: CLLocationDegrees = 0
        var sumLng: CLLocationDegrees = 0
        
        userAnnotations.forEach { (name, location) in
            
            if uiView.userAnnotations[name] == nil {
                let image = userImages[name]
                uiView.addUser(name: name,
                               customPointAnnotation: .init(coordinate: location.coordinate,
                                                            userImage: image,
                                                            title: name))
            } else {
                uiView.updateUserLocation(userName: name, location.coordinate)
            }
            sumLat += location.coordinate.latitude
            sumLng += location.coordinate.longitude
            
            
        }
        
        let averageCoordinate = CLLocationCoordinate2D(
            latitude: sumLat / Double(userAnnotations.count),
            longitude: sumLng / Double(userAnnotations.count)
        )
//        uiView.centerMapOnLocation(coordinate: averageCoordinate)
    }
    
    func updateUserImages(_ uiView: UIMapView, user name: String, imageIs userImages: UIImage) {
        uiView.userAnnotations[name]?.userImage = userImages
    }
}

    
#Preview {
    @State var userAnnotations: [String : CLLocation] = ["aa": .init(latitude: 25.059093026560458, longitude: 121.52061640290475)]
    @State var userImages: [String : UIImage] = ["aa": .redPanda]
    MapViewRepresentable(userAnnotations: $userAnnotations, userImages: $userImages)
}
//25.059093026560458
//121.52061640290475
