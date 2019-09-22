//
//  MessageView.swift
//  NIOMQTTExample
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

import SwiftUI
import NIOMQTT

struct Message: Identifiable {
    let id: Int
    let text: String
}

struct MessageView: View {
    @State var messages: [Message] = [Message(id: 0, text: "Hello!")]
    let client = MQTT(host: "test.mosquitto.org", port: 1883)

    var body: some View {
        NavigationView {
            List(messages) { message in
                HStack {
                    Text(message.text)
                }
             }.navigationBarTitle(Text("Messages"))
        }.onAppear {
            self.client.onData = { (_, data) in
                let text = String(decoding: data, as: UTF8.self)
                self.addMessage(text: text)
            }
            self.client.connect().whenSuccess {
                self.client.subscribe(topic: "healthtap")
            }
        }
    }

    func addMessage(text: String) {
        let newMessage = Message(id: messages.count, text: text)
        messages.append(newMessage)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
