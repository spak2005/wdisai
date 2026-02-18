//
//  wdisaiApp.swift
//  wdisai
//
//  Created by Israel Ogbonna on 2/18/26.
//

import SwiftUI

@main
struct wdisaiApp: App {
    @State private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appVM)
        }
    }
}
