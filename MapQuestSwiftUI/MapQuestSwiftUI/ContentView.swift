//
//  ContentView.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/11/19.
//

import SwiftUI
import MapKit
import Combine
import CoreLocation

struct ContentView: View {
    @State var showRoute: Bool = false
    @ObservedObject var vm = ViewModel()
    @State var isShowingDialog: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    vm.addOtherUser()
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

class ViewModel: NSObject, ObservableObject {
    private let parser = GPXParser()
    private var cancellable: AnyCancellable?
    private let locationManager = CLLocationManager()
    
    @Published var userManager = UserManager()
    @Published var users: [String: User] = [:]
    
    let waypoints: [CLLocation]
    var userTimer: [String: Timer] = [:]
    
    let userNameArr = ["RedPanda", "Ray", "Cindy", "Jason", "Hydee", "Jenny", "Antita", "Chris Tang", "Fi", "Tree"]
    var userNumber: Int = 0
    
    override init() {
        waypoints = parser.parse(data: gpxData)
        userTimer = [:]
        super.init()
        userManager.resetUsers()
        userTimer = [:]
        cancellable = userManager.$users
            .receive(on: DispatchQueue.main)
            .assign(to: \.users, on: self)
        setupLocationManager()
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 請求使用使用者位置的許可權
        locationManager.startUpdatingLocation() // 開始更新使用者的位置
    }
    
    func removeUser(name: String) {
        userManager.removeUser(name: name)
        userTimer[name]?.invalidate()
        userTimer.removeValue(forKey: name)
    }
    
    func addOtherUser() {
        let newUserName = userNameArr[ userNumber % userNameArr.count ]
        let startCount = (0...waypoints.count).randomElement()!
        
        if userTimer[newUserName] != nil {
            userTimer[newUserName]?.invalidate()
            userTimer.removeValue(forKey: newUserName)
        }
        let location = waypoints[startCount]
        
        addUserToMap(userName: newUserName, location: location)
        
        let timer =  Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            updateUserLocation(name: newUserName)
            
        })
        userTimer[newUserName] = timer
        userNumber += 1
    }
    
    func addUserToMap(userName: String, location: CLLocation, walkingIndex: Int? = nil) {
        userManager.addUser(.init(name: userName, image: UIImage(named: userName) ?? .init(systemName: "person"), location: location, walkingIndex: walkingIndex))
        
        
        print("-------------View Model-------------")
        print("▶️ addUserWalking: \(userName)")
        print("------------------------------------\n")
        
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

extension ViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] // The first location in the array
        if users["Puma"] == nil {
            addUserToMap(userName: "Puma", location: userLocation)
        }else {
            userManager.updateUserLocation(userID: "Puma", location: userLocation, newIndex: 0)
        }
        
        print("location: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
    }

        func locationManager(_ manager: CLLocationManager,
                             didFailWithError error: Error) {
            
            print("---ViewModel didFailWithError---")
            print(error.localizedDescription)
            print("-------------------------------\n")
        }
}
