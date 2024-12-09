//
//  ContentView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/11/19.
//

import SwiftUI
import MapKit
import Combine

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
                    
                } label: {
                    Text("Stop Walk")
                    
                }
            }
            HStack {
//                Button {
//                    vm.userLocationDict = [:]
//                    vm.userImages = [:]
//                    vm.userTimer.keys.forEach {
//                        vm.userTimer[$0]?.invalidate()
//                        vm.userTimer[$0] = nil
//                    }
//                } label: {
//                    Text("Remove All User")
//                    
//                }
                
                Button {
                    isShowingDialog.toggle()
                } label: {
                    Text("Remove User")
                    
                }
            }
            MapViewRepresentable(userAnnotations: $vm.users)
        }
        .padding()
        .confirmationDialog(
            "Permanently erase the items in the Trash?",
            isPresented: $isShowingDialog
        ) {
            ForEach(vm.users.keys.sorted() , id: \.self) { user in
                Button("\(user)", role: .destructive) {
                    print("---------------ContentView----------------")
                    print("🚮 Remove \(user)")
                    vm.removeUser(name: user)
                    print("-------------------------------")
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
    private var cancellable: AnyCancellable?
    
    @Published var userManager = UserManager()
    @Published var users: [String: User] = [:]
    
    let waypoints: [CLLocation]
    var userTimer: [String: Timer] = [:]
    
    let userNameArr = ["RedPanda", "Ray", "Cindy", "Jason", "Hydee", "Jenny", "Antita", "Chris Tang", "Fi", "Tree"]
    var userNumber: Int = 0
    
    init() {
        waypoints = parser.parse(data: gpxData)
        userManager.resetUsers()
        userTimer = [:]
        cancellable = userManager.$users
            .receive(on: DispatchQueue.main)
            .assign(to: \.users, on: self)
    }
    
    func removeUser(name: String) {
        userManager.removeUser(name: name)
        userTimer[name]?.invalidate()
        userTimer.removeValue(forKey: name)
    }
    
    func addUserWalking() {
        
        let newUserName = userNameArr[ userNumber % userNameArr.count ]
        let startCount = (0...waypoints.count).randomElement()!
        
        if userTimer[newUserName] != nil {
            userTimer[newUserName]?.invalidate()
            userTimer.removeValue(forKey: newUserName)
        }
        
        userManager.addUser(.init(name: newUserName, image: UIImage(named: newUserName) ?? .init(systemName: "person"), location: waypoints[startCount], walkingIndex: startCount))
        
        let timer =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            updateUserLocation(name: newUserName)
            
        })
        userTimer[newUserName] = timer
        print("-------------View Model-------------")
        print("▶️ addUserWalking: \(newUserName)")
        print("------------------------------------\n")
        userNumber += 1
    }
    
    func updateUserLocation(name: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let walkingIndex = self.userManager.users[name]?.walkingIndex, walkingIndex < self.waypoints.count {
                let newIndex = (walkingIndex + 1) % self.waypoints.count
                // 更新座標
                self.userManager.updateUserLocation(userID: name, location: self.waypoints[newIndex], newIndex: newIndex)
            }
        }
    }
}
