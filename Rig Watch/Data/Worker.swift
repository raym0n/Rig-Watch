//
//  Worker.swift
//  Miner Office
//
//  Created by Nikita Marinosyan on 08.01.2018.
//  Copyright © 2018 Nikita Marinosyan. All rights reserved.
//

import Foundation

class Worker: NSObject, NSCoding {
    
    var name: String!
    var address: String!
    var lastSeen: String!
    //var time: String!
    //var reportedHashrate: String!
    //var averageHashrate: String!
    var currentHashrate: String!
    var validShares: String!
    var invalidShares: String!
    var staleShares: String!
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(lastSeen, forKey: "lastSeen")
        aCoder.encode(currentHashrate, forKey: "currentHashrate")
        aCoder.encode(validShares, forKey: "validShares")
        aCoder.encode(invalidShares, forKey: "invalidShares")
        aCoder.encode(staleShares, forKey: "staleShares")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.address = aDecoder.decodeObject(forKey: "address") as? String
        self.lastSeen = aDecoder.decodeObject(forKey: "lastSeen") as? String
        self.currentHashrate = aDecoder.decodeObject(forKey: "currentHashrate") as? String
        self.validShares = aDecoder.decodeObject(forKey: "validShares") as? String
        self.invalidShares = aDecoder.decodeObject(forKey: "invalidShares") as? String
        self.staleShares = aDecoder.decodeObject(forKey: "staleShares") as? String
    }
    
}
