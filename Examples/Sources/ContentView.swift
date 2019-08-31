//
//  ContentView.swift
//  NIOMQTTExample
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import SwiftUI
import NIOMQTT

struct ContentView: View {
    var body: some View {
        Text("Hello World")
            .onAppear() {
                let client = MQTT(host: "mqtt.fluux.io", port: 1883)
                client.connect().whenSuccess { _ in
                    print("Disconnected!")
                }
            }
    }
}
