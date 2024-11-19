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
                    Marker("User Point", coordinate: userLocation!)
                }
                
                MapPolygon(coordinates: MockRountCLLocations2D)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .padding()
    }
    
    func startWalk() {
        count = 0
        userWalking?.invalidate()
        userLocation = nil
        userWalking = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if count < MockRountCLLocations2D.count {
                userLocation = MockRountCLLocations2D[count]
                count += 1
            }
        })
    }
}

#Preview {
    ContentView()
}

let MockRountCLLocations2D: [CLLocationCoordinate2D] = [
    CLLocationCoordinate2D(latitude: 24.81216358, longitude: 121.22090078),
    CLLocationCoordinate2D(latitude: 24.81221446, longitude: 121.22089592),
    CLLocationCoordinate2D(latitude: 24.81224690, longitude: 121.22093028),
    CLLocationCoordinate2D(latitude: 24.81226399, longitude: 121.22098669),
    CLLocationCoordinate2D(latitude: 24.81226299, longitude: 121.22103707),
    CLLocationCoordinate2D(latitude: 24.81226592, longitude: 121.22109138),
    CLLocationCoordinate2D(latitude: 24.81227280, longitude: 121.22114218),
    CLLocationCoordinate2D(latitude: 24.81229886, longitude: 121.22119264),
    CLLocationCoordinate2D(latitude: 24.81228202, longitude: 121.22124184),
    CLLocationCoordinate2D(latitude: 24.81223826, longitude: 121.22122382),
    CLLocationCoordinate2D(latitude: 24.81224237, longitude: 121.22127679),
    CLLocationCoordinate2D(latitude: 24.81227154, longitude: 121.22131878),
    CLLocationCoordinate2D(latitude: 24.81224681, longitude: 121.22136262),
    CLLocationCoordinate2D(latitude: 24.81223449, longitude: 121.22141912),
    CLLocationCoordinate2D(latitude: 24.81221303, longitude: 121.22146681),
    CLLocationCoordinate2D(latitude: 24.81217188, longitude: 121.22150226),
    CLLocationCoordinate2D(latitude: 24.81215260, longitude: 121.22155088),
    CLLocationCoordinate2D(latitude: 24.81211329, longitude: 121.22158181),
    CLLocationCoordinate2D(latitude: 24.81207758, longitude: 121.22162229),
    CLLocationCoordinate2D(latitude: 24.81204120, longitude: 121.22166119),
    CLLocationCoordinate2D(latitude: 24.81204640, longitude: 121.22171064),
    CLLocationCoordinate2D(latitude: 24.81199820, longitude: 121.22169547),
    CLLocationCoordinate2D(latitude: 24.81195051, longitude: 121.22170896),
    CLLocationCoordinate2D(latitude: 24.81190793, longitude: 121.22168021),
    CLLocationCoordinate2D(latitude: 24.81186443, longitude: 121.22166772),
    CLLocationCoordinate2D(latitude: 24.81181850, longitude: 121.22169748),
    CLLocationCoordinate2D(latitude: 24.81178933, longitude: 121.22173562),
    CLLocationCoordinate2D(latitude: 24.81175060, longitude: 121.22177610),
    CLLocationCoordinate2D(latitude: 24.81170970, longitude: 121.22180200),
    CLLocationCoordinate2D(latitude: 24.81165161, longitude: 121.22180091),
    CLLocationCoordinate2D(latitude: 24.81160660, longitude: 121.22179463),
    CLLocationCoordinate2D(latitude: 24.81156176, longitude: 121.22177828),
    CLLocationCoordinate2D(latitude: 24.81151356, longitude: 121.22179010),
    CLLocationCoordinate2D(latitude: 24.81146612, longitude: 121.22182438),
    CLLocationCoordinate2D(latitude: 24.81143109, longitude: 121.22187878),
    CLLocationCoordinate2D(latitude: 24.81139823, longitude: 121.22192597),
    CLLocationCoordinate2D(latitude: 24.81136587, longitude: 121.22197811),
    CLLocationCoordinate2D(latitude: 24.81133042, longitude: 121.22201021),
    CLLocationCoordinate2D(latitude: 24.81129756, longitude: 121.22204407),
    CLLocationCoordinate2D(latitude: 24.81125741, longitude: 121.22206662),
    CLLocationCoordinate2D(latitude: 24.81124501, longitude: 121.22211582),
    CLLocationCoordinate2D(latitude: 24.81120997, longitude: 121.22214742),
    CLLocationCoordinate2D(latitude: 24.81118633, longitude: 121.22218992),
    CLLocationCoordinate2D(latitude: 24.81115423, longitude: 121.22223099),
    CLLocationCoordinate2D(latitude: 24.81111282, longitude: 121.22225069),
    CLLocationCoordinate2D(latitude: 24.81108064, longitude: 121.22228539),
    CLLocationCoordinate2D(latitude: 24.81105373, longitude: 121.22233308),
    CLLocationCoordinate2D(latitude: 24.81103990, longitude: 121.22238639),
    CLLocationCoordinate2D(latitude: 24.81100503, longitude: 121.22242738),
    CLLocationCoordinate2D(latitude: 24.81096874, longitude: 121.22247733),
    CLLocationCoordinate2D(latitude: 24.81096002, longitude: 121.22253156),
    CLLocationCoordinate2D(latitude: 24.81094661, longitude: 121.22257993),
    CLLocationCoordinate2D(latitude: 24.81090101, longitude: 121.22258546),
    CLLocationCoordinate2D(latitude: 24.81086438, longitude: 121.22263148),
    CLLocationCoordinate2D(latitude: 24.81084184, longitude: 121.22267741),
    CLLocationCoordinate2D(latitude: 24.81081828, longitude: 121.22273826),
    CLLocationCoordinate2D(latitude: 24.81076866, longitude: 121.22274044),
    CLLocationCoordinate2D(latitude: 24.81073019, longitude: 121.22277413),
    CLLocationCoordinate2D(latitude: 24.81070882, longitude: 121.22282476),
    CLLocationCoordinate2D(latitude: 24.81069842, longitude: 121.22287413),
    CLLocationCoordinate2D(latitude: 24.81068417, longitude: 121.22293121),
    CLLocationCoordinate2D(latitude: 24.81065283, longitude: 121.22297337),
    CLLocationCoordinate2D(latitude: 24.81063372, longitude: 121.22301931),
    CLLocationCoordinate2D(latitude: 24.81059038, longitude: 121.22304127),
    CLLocationCoordinate2D(latitude: 24.81058057, longitude: 121.22309223),
    CLLocationCoordinate2D(latitude: 24.81055803, longitude: 121.22313674),
    CLLocationCoordinate2D(latitude: 24.81053338, longitude: 121.22318158),
    CLLocationCoordinate2D(latitude: 24.81052131, longitude: 121.22323866),
    CLLocationCoordinate2D(latitude: 24.81052450, longitude: 121.22331108),
    CLLocationCoordinate2D(latitude: 24.81049684, longitude: 121.22335098),
    CLLocationCoordinate2D(latitude: 24.81047044, longitude: 121.22339238),
    CLLocationCoordinate2D(latitude: 24.81046281, longitude: 121.22345156),
    CLLocationCoordinate2D(latitude: 24.81045132, longitude: 121.22350437),
    CLLocationCoordinate2D(latitude: 24.81042693, longitude: 121.22355734),
    CLLocationCoordinate2D(latitude: 24.81038913, longitude: 121.22358810),
    CLLocationCoordinate2D(latitude: 24.81034177, longitude: 121.22361241),
    CLLocationCoordinate2D(latitude: 24.81029224, longitude: 121.22361057),
    CLLocationCoordinate2D(latitude: 24.81023993, longitude: 121.22364518),
    CLLocationCoordinate2D(latitude: 24.81020540, longitude: 121.22370888),
    CLLocationCoordinate2D(latitude: 24.81018143, longitude: 121.22375096),
    CLLocationCoordinate2D(latitude: 24.81016902, longitude: 121.22380821),
    CLLocationCoordinate2D(latitude: 24.81014513, longitude: 121.22385590),
    CLLocationCoordinate2D(latitude: 24.81014086, longitude: 121.22391449),
    CLLocationCoordinate2D(latitude: 24.81012946, longitude: 121.22397702),
    CLLocationCoordinate2D(latitude: 24.81010607, longitude: 121.22402321),
    CLLocationCoordinate2D(latitude: 24.81008671, longitude: 121.22407434),
    CLLocationCoordinate2D(latitude: 24.81007037, longitude: 121.22413443),
    CLLocationCoordinate2D(latitude: 24.81004807, longitude: 121.22418137),
    CLLocationCoordinate2D(latitude: 24.81001899, longitude: 121.22422077),
    CLLocationCoordinate2D(latitude: 24.80999853, longitude: 121.22427776),
    CLLocationCoordinate2D(latitude: 24.80998529, longitude: 121.22432621),
    CLLocationCoordinate2D(latitude: 24.80998764, longitude: 121.22437583),
    CLLocationCoordinate2D(latitude: 24.80995218, longitude: 121.22441992),
    CLLocationCoordinate2D(latitude: 24.80992394, longitude: 121.22445999),
    CLLocationCoordinate2D(latitude: 24.80988923, longitude: 121.22450609),
    CLLocationCoordinate2D(latitude: 24.80983400, longitude: 121.22454951),
    CLLocationCoordinate2D(latitude: 24.80979008, longitude: 121.22459033),
    CLLocationCoordinate2D(latitude: 24.80976778, longitude: 121.22464238),
    CLLocationCoordinate2D(latitude: 24.80977398, longitude: 121.22469736),
    CLLocationCoordinate2D(latitude: 24.80977658, longitude: 121.22474899),
    CLLocationCoordinate2D(latitude: 24.80979703, longitude: 121.22480013),
    CLLocationCoordinate2D(latitude: 24.80976384, longitude: 121.22484656),
    CLLocationCoordinate2D(latitude: 24.80971338, longitude: 121.22489953),
    CLLocationCoordinate2D(latitude: 24.80967608, longitude: 121.22493742),
    CLLocationCoordinate2D(latitude: 24.80964750, longitude: 121.22497573),
    CLLocationCoordinate2D(latitude: 24.80962068, longitude: 121.22502007),
    CLLocationCoordinate2D(latitude: 24.80958967, longitude: 121.22506231),
    CLLocationCoordinate2D(latitude: 24.80957349, longitude: 121.22511486),
    CLLocationCoordinate2D(latitude: 24.80953418, longitude: 121.22514672),
    CLLocationCoordinate2D(latitude: 24.80950601, longitude: 121.22518678),
    CLLocationCoordinate2D(latitude: 24.80947433, longitude: 121.22522341),
    CLLocationCoordinate2D(latitude: 24.80943359, longitude: 121.22524864),
    CLLocationCoordinate2D(latitude: 24.80940308, longitude: 121.22528720)
]
