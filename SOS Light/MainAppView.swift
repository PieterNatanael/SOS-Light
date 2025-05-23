//
//  MainAppView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 30/11/24.
//

import SwiftUI
import CoreLocation

struct MainAppView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "light.max")
                    Text("SOS")
                }
                .tag(0)
            
            CompassView()
                .tabItem {
                    Image(systemName: "location.north.circle.fill")
                    Text("Compass")
                }
                .tag(1)
            
            DiaryView(dataStore: DataStore())
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Diary")
                }
                .tag(2)
            
            
            DirectionView()
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Location")
                }
                .tag(3)
            
            SOSRelaxView()
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("Relax")
                }
                .tag(4)

            
        }
        
    }
}
