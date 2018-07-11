//
//  Challenge.swift
//  zen
//
//  Created by Anton Popov on 6/27/18.
//  Copyright © 2018 Anton Popov. All rights reserved.
//

import Foundation


/// Challenge model
struct Challenge: Decodable {
    let content: String
    let details: String
    let quote: String
    let source: String
    let type: String
    let url: String
}
