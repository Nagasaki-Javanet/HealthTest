//
//  ContentView.swift
//  HealthTest
//
//  Created by 강효민 on 11/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var healthManager = HealthManager()
    var body: some View {
        VStack {
            NavigationMapView()
            
            
        }
    
    }
}

#Preview {
    ContentView()
}
