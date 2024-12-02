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

class UIMapView: UIView {
    var mapView: MKMapView!
    var userAnnotations: [String: MKPointAnnotation] = [:]

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

    func addUser(name: String, location: CLLocation) {
        guard userAnnotations[name] == nil else { return }
        let annotation = MKPointAnnotation()
        annotation.title = name
        annotation.coordinate = location.coordinate
        
        userAnnotations[name] = annotation
        mapView.addAnnotation(annotation)
    }

    func updateUserLocation(userName: String, _ location: CLLocation) {
        guard let userAnnotation = userAnnotations[userName] else { return }
        UIView.animate(withDuration: 1.0, animations: {
            userAnnotation.coordinate = location.coordinate
        })
    }

    func centerMapOnLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
}

extension UIMapView: MKMapViewDelegate {
    
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var userAnnotations: [String: CLLocation]

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
                uiView.addUser(name: name, location: location)
            } else {
                uiView.updateUserLocation(userName: name, location)
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
}
