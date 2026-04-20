//
//  ContentView.swift
//  Connections
//
//  Created by John Tanner on 4/15/26.
//

import SwiftUI

struct ContentView: View {
    @State private var session = SessionManager()
    @State private var settings = SettingsStore()

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .environment(session)
        .environment(settings)
    }
}

#Preview {
    ContentView()
}
