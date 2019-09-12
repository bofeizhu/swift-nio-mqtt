//
//  Session+Action.swift
//  NIOMQTT
//
//  Created by Bofei Zhu on 9/10/19.
//  Copyright © 2019 HealthTap Inc. All rights reserved.
//

extension Session {

    enum Action {
        case publish(topic: String, payload: PublishPacket.Payload)
        case subscribe(topic: String)
        case unsubscribe(topic: String)
    }
}
