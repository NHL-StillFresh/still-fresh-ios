//
//  ContentView.swift
//  Still Fresh
//
//  Created by Gideon Dijkhuis on 26/04/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: TestSearchView()) {
                    Text("Open Test Search")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Test Menu")
        }
    }
}

#Preview {
    ContentView()
}