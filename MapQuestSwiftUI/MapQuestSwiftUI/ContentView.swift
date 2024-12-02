//
//  ContentView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/11/19.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State var userLocation: CLLocationCoordinate2D?
    @State var userWalking: Timer?
    @State var count = 0
    
    var vm = ViewModel()
    var body: some View {
        VStack {
            HStack {
                Button {
                    startWalk()
                } label: {
                    Text("Start Walk")
                }
                Button {
                    userWalking?.invalidate()
                    userWalking = nil
                } label: {
                    Text("Stop Walk")
                    
                }
            }
            
            Map {
                if userLocation != nil {
                    Marker("User Point", image: "", coordinate: userLocation!)
                }
                MapPolyline(coordinates: vm.waypoints.map({ location in
                    location.coordinate
                }))
                .stroke(.blue, lineWidth: 2)
                
            }
        }
        .padding()
    }
    
    func startWalk() {
        count = 0
        userWalking?.invalidate()
        userLocation = nil
        userWalking = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            
            if count < vm.waypoints.count {
                DispatchQueue.main.async {
                    // 使用動畫平滑移動
                    withAnimation(.interpolatingSpring(stiffness: 100, damping: 90)) {
                        userLocation = vm.waypoints[count].coordinate
                        count += 1
                    }
                }
                
            }
        })
    }
}

#Preview {
    ContentView()
}

class ViewModel {
    private let parser = GPXParser()
    let waypoints: [CLLocation]
    
    init() {
        waypoints = parser.parse(data: gpxData)
        
    }
}
