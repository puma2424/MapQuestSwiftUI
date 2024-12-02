//
//  GPXParser.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/2.
//
import Foundation
import CoreLocation

// GPX 解析器
class GPXParser: NSObject, XMLParserDelegate {
    private var locations: [CLLocation] = []
    private var currentLatitude: CLLocationDegrees?
    private var currentLongitude: CLLocationDegrees?
    private var currentElevation: CLLocationDistance?
    private var currentTimestamp: Date?
    private var currentElement: String?

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    func parse(data: Data) -> [CLLocation] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return locations
    }

    // XMLParser Delegate Methods
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "trkpt" {
            if let lat = attributeDict["lat"], let lon = attributeDict["lon"] {
                currentLatitude = Double(lat)
                currentLongitude = Double(lon)
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let currentElement = currentElement else { return }

        switch currentElement {
        case "ele":
            currentElevation = Double(string)
        case "time":
            currentTimestamp = dateFormatter.date(from: string)
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "trkpt" {
            if let lat = currentLatitude, let lon = currentLongitude {
                let elevation = currentElevation ?? 0.0
                let timestamp = currentTimestamp ?? Date()
                let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                          altitude: elevation,
                                          horizontalAccuracy: kCLLocationAccuracyBest,
                                          verticalAccuracy: kCLLocationAccuracyBest,
                                          timestamp: timestamp)
                locations.append(location)
            }
            currentLatitude = nil
            currentLongitude = nil
            currentElevation = nil
            currentTimestamp = nil
        }
        currentElement = nil
    }
    
    
}
