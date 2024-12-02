//
//  ContentView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/11/19.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State var showRoute: Bool = false
    @ObservedObject var vm = ViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    vm.addUserWalking()
                } label: {
                    Text("Start Walk")
                }
                Button {
                    vm.userTimer = [:]
                    vm.userWalking = [:]
                    
                } label: {
                    Text("Stop Walk")
                    
                }
                Button {
                    showRoute.toggle()
                } label: {
                    Text("Show Route")
                    
                }
                
            }
            MapViewRepresentable(userAnnotations: $vm.userLocationDict)
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}

class ViewModel: ObservableObject {
    private let parser = GPXParser()
    let waypoints: [CLLocation]
    @Published var userLocationDict: [String: CLLocation]
    var userTimer: [String: Timer]
    var userWalking: [String: Int]
    
    let user = ["RedPanda", "Puma", "Ray", "Cindy", "Jason", "Ray", "Hydee", "Luna", "Jenny"]
    init() {
        waypoints = parser.parse(data: gpxData)
        userLocationDict = [:]
        userWalking = [:]
        userTimer = [:]
    }
    func addUserWalking() {
        let randomName = user.randomElement()!
        let startCount = (0...waypoints.count).randomElement()!
        
        if userTimer[randomName] != nil {
            userWalking[randomName] = nil
            userTimer[randomName]?.invalidate()
            userTimer[randomName] = nil
        }
        userWalking[randomName] = startCount
        
        let timer =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            if userWalking[randomName] ?? waypoints.count < waypoints.count {
                userLocationDict[randomName] = waypoints[userWalking[randomName] ?? 0]
                userWalking[randomName]? += 1
                
            }
        })
        userTimer[randomName] = timer
    }
}
