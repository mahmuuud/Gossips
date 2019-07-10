//
//  Message.swift
//  Gossips
//
//  Created by mahmoud mohamed on 7/8/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import Foundation

struct Message:Codable {
    var chatId:String
    var content:String
    var senderId:String
    var recieverId:String
    var timeStamp:TimeInterval
}
