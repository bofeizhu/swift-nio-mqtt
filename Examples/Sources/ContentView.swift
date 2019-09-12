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
                client.connect().whenSuccess {
                    client.publish(topic: "healthtap", message: "Hello World!")
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
