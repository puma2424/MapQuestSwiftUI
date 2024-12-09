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
    @State var isShowingDialog: Bool = false
    
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
            }
            HStack {
                Button {
                    vm.userLocationDict = [:]
                    vm.userImages = [:]
                    vm.userTimer.keys.forEach {
                        vm.userTimer[$0]?.invalidate()
                        vm.userTimer[$0] = nil
                    }
                } label: {
                    Text("Remove All User")
                    
                }
                
                Button {
                    isShowingDialog.toggle()
                } label: {
                    Text("Remove User")
                    
                }
            }
            MapViewRepresentable(userAnnotations: $vm.userLocationDict, userImages: $vm.userImages)
        }
        .padding()
        .confirmationDialog(
            "Permanently erase the items in the Trash?",
            isPresented: $isShowingDialog
        ) {
            ForEach(vm.userLocationDict.keys.sorted(), id: \.self) { user in
                Button("\(user)", role: .destructive) {
                    print("🚮 Remove \(user)")
                    print("📍 User's Location: \(String(describing: vm.userLocationDict[user]?.coordinate))")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

class ViewModel: ObservableObject {
    private let parser = GPXParser()
    
    @Published var userLocationDict: [String: CLLocation]
    @Published var userImages: [String: UIImage]
    let waypoints: [CLLocation]
    var userTimer: [String: Timer]
    var userWalking: [String: Int]
    
    let user = ["RedPanda", "Ray", "Cindy", "Jason", "Ray", "Hydee", "Jenny", "Antita", "Chris Tang", "Fi", "Tree"]
    init() {
        waypoints = parser.parse(data: gpxData)
        userLocationDict = [:]
        userWalking = [:]
        userTimer = [:]
        userImages = [:]
    }
    
    func addUserWalking() {
        
        let randomName = userLocationDict.keys.isEmpty ? "Tree" : user.randomElement()!
        let startCount = (0...waypoints.count).randomElement()!
        
        if userTimer[randomName] != nil {
            userWalking[randomName] = nil
            userTimer[randomName]?.invalidate()
            userTimer[randomName] = nil
        }
        userWalking[randomName] = startCount
        userLocationDict[randomName] =  waypoints[userWalking[randomName] ?? 0]
        userImages[randomName] = UIImage(named: randomName) ?? .init(systemName: "person")
        let timer =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            updateUserLocation(name: randomName)
            
        })
        userTimer[randomName] = timer
    }
    
    func updateUserLocation(name: String) {
        DispatchQueue.main.async {
            if let walkingIndex = self.userWalking[name], walkingIndex < self.waypoints.count {
                // 更新座標
                self.userLocationDict[name] = self.waypoints[walkingIndex]
                self.userWalking[name]? += 1
            }
        }
    }
}
