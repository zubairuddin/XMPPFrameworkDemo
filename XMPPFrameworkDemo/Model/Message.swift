//
//  Message.swift
//  XMPPFrameworkDemo
//
//  Created by Zubair.Nagori on 23/11/18.
//  Copyright © 2018 applligent. All rights reserved.
//

import Foundation

enum MessageState {
    case sent
    case received
}

struct Message {
    var strMessage: String
    var state: MessageState
}
