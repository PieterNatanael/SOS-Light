//
//  MainAppView.swift
//  SOS Light
//
//  Created by Pieter Yoshua Natanael on 30/11/24.
//

import SwiftUI
import CoreLocation
import UIKit

struct MainAppView: View {
    @State private var selectedTab = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black

        let normalColor = UIColor(white: 0.65, alpha: 1.0)
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = false
    }
    
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
