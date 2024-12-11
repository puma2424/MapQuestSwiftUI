//
//  UserManager.swift
//  MapQuestSwiftUI
//
//  Created by 莊雯聿 on 2024/12/9.
//

import Foundation
import MapKit
import Combine

struct User {
    let name: String
    var image: UIImage?
    var location: CLLocation
    var walkingIndex: Int = 0
}

class UserManager: ObservableObject {
    @Published private(set) var users: [String: User] = [:]
//    private var userTimers: [String: Timer] = [:]
    
    func addUser(_ user: User) {
        users[user.name] = user
    }
    
    func removeUser(name: String) {
        guard let user = users[name] else { return }
        
        users.removeValue(forKey: name)
//        userTimers[name]?.invalidate()
//        userTimers.removeValue(forKey: name)
    }
    
    func updateUserLocation(userID: String, location: CLLocation, newIndex: Int) {
        guard var user = users[userID] else { return }
        user.location = location
        user.walkingIndex = newIndex
        users[userID] = user
    }
    
//    func startWalking(userID: String, waypoints: [CLLocation], onUpdate: @escaping (CLLocation) -> Void) {
//        guard users[userID] != nil else { return }
//        
//        userTimers[userID]?.invalidate()
//        userTimers[userID] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
//            guard let self = self, var user = self.users[userID] else { return }
//            let newIndex = (user.walkingIndex + 1) % waypoints.count
//            user.location = waypoints[newIndex]
//            user.walkingIndex = newIndex
//            self.users[userID] = user
//            onUpdate(user.location)
//        })
//    }
    
    func resetUsers() {
        users.removeAll()
    }
}
