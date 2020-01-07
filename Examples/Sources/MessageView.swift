//
//  MessageView.swift
//  NIOMQTTExample
//
//  Created by Bofei Zhu on 8/30/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import SwiftUI
import NIOMQTTClient

struct Message: Identifiable {
    let id: Int
    let text: String
}

struct MessageView: View {
    @State var messages: [Message] = [Message(id: 0, text: "Hello!")]
    let client: MQTTClient = {
        let configuration = MQTTClient.Configuration(
            host: "test.mosquitto.org",
            port: 8883,
            clientId: "niomqtt",
            qos: .atLeastOnce,
            tlsEnabled: true)
        return MQTTClient(configuration: configuration)
    }()

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

            self.client.onConnect = {
                self.client.subscribe(topic: "niomqtt")
                self.client.publish(topic: "niomqtt", message: "Hello~")
            }

            self.client.connect()
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
