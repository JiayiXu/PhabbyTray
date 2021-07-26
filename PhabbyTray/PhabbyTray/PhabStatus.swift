//
//  PhabStatus.swift
//  PhabbyTray
//
//  Created by Tony Xu on 4/9/21.
//

import Foundation

struct PhabStatus {
    let numMydiffs: Int
    let numReviewerDiffs: Int
    let subscribedDiffs: Int
    
    
    func description() -> String {
        return "M:\(numMydiffs) R:\(numReviewerDiffs) S:\(subscribedDiffs)"
    }
}

