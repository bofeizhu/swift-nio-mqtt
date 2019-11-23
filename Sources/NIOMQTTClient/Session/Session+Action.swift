//
//  Session+Action.swift
//  NIOMQTTClient
//
//  Created by Bofei Zhu on 9/10/19.
//  Copyright © 2019 Bofei Zhu. All rights reserved.
//

import MQTTCodec

extension Session {
    /// Session related actions.
    enum Action {
        case publish(topic: String, payload: PublishPacket.Payload)
        case subscribe(topic: String)
        case unsubscribe(topic: String)
    }
}
