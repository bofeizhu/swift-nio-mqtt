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
            .onAppear {
                let client = MQTT(host: "test.mosquitto.org", port: 1883)
                client.connect().whenFailure { error in
                    print(error)
                }
            }
    }
}

// swiftlint:disable:next type_name
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
