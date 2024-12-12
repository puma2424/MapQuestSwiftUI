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
                    isShowingDialog.toggle()
                } label: {
                    Text("Remove User")
                    
                }
                
            }
            HStack {
                Button("Start Updating Heading") {
                    vm.updatingHeadingToggle()
                }
            }
            MapViewRepresentable(mapOtherUsers: $vm.mapOtherUsers, mapCurrentUser: $vm.mapCurrentUser, route: $vm.currentUserRoute)
        }
        .padding()
        .confirmationDialog(
            "Permanently erase the items in the Trash?",
            isPresented: $isShowingDialog
        ) {
            ForEach(vm.mapOtherUsers.keys.sorted() , id: \.self) { user in
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
    @Published var mapOtherUsers: [String: User] = [:]
    @Published var mapCurrentUser: User?
    @Published var currentUserRoute: [CLLocationCoordinate2D] = []
    
    @Published var isStartUpdateHeading: Bool = false
    
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
            .assign(to: \.mapOtherUsers, on: self)
        setupLocationManager()
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 請求使用使用者位置的許可權
        locationManager.startUpdatingLocation() // 開始更新使用者的位置
    }
    
    func updatingHeadingToggle() {
        isStartUpdateHeading.toggle()
        switch isStartUpdateHeading {
        case true:
            locationManager.startUpdatingHeading()
        case false:
            locationManager.stopUpdatingHeading()
        }
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
        userManager.addUser(.init(name: userName, image: UIImage(named: userName) ?? .init(systemName: "person"), location: location, walkingIndex: walkingIndex ?? 0))
        
        
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
                print(self.userManager.users[name]?.location)
            }
        }
    }
}

extension ViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] // The first location in the array
        
        if mapCurrentUser == nil {
            mapCurrentUser = .init(name: "Puma", location: userLocation)
            currentUserRoute.append(userLocation.coordinate)
        }else {
            mapCurrentUser?.location = userLocation
            currentUserRoute.append(userLocation.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
        print("---ViewModel didFailWithError---")
        print(error.localizedDescription)
        print("-------------------------------\n")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        mapCurrentUser?.heading = newHeading
        if newHeading.headingAccuracy < 0 { return }
        
        print("----- LocationManager didUpdateHeading -----")
        print("newHeading: \(newHeading)")
        print("newHeading.headingAccuracy:", newHeading.headingAccuracy)
        print("newHeading.trueHeading: ", newHeading.trueHeading)
        print("newHeading.magneticHeading: ", newHeading.magneticHeading)
        print("--------------------------------------\n")
    }
}
