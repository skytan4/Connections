//
//  ContentView.swift
//  Connections
//
//  Created by John Tanner on 4/15/26.
//

import SwiftUI

struct ContentView: View {
    @State private var session = SessionManager()

    var body: some View {
        NavigationStack {
            HomeView()
        }
        .environment(session)
    }
}

#Preview {
    ContentView()
}
