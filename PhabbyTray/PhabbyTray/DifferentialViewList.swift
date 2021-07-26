//
//  DifferentialViewList.swift
//  PhabbyTray
//
//  Created by Tony Xu on 4/9/21.
//

import SwiftUI

struct DifferentialViewList: View {
    var myDiffs: [Differential]
    var otherDiffs: [Differential]
    var lastUpdateTime: Date
    
    var settingsClicked: (() -> Void)?
    var quit: (() -> Void)?
    
    var body: some View {
        VStack {
            Text("Last Updated: \(lastUpdateTime.timeAgoDisplay())").italic().fontWeight(.regular).padding(.top, 15.0)
            HStack {
                Button(action: {
                    settingsClicked?()
                }) {
                    Text("Settings")
                }
                Button(action: {
                    quit?()
                }) {
                    Text("Quit")
                }
            }
            Text("My Diffs:")
                .fontWeight(.bold)
            List(myDiffs, id: \.id) {
                diff in
                DifferentialView(differential: diff)
            }
            Text("Diffs to Review:").fontWeight(.bold)
            List(otherDiffs, id: \.id) {
                diff in
                DifferentialView(differential: diff)
            }
        }
    }
}

struct DifferentialViewList_Previews: PreviewProvider {
    static var previews: some View {
        DifferentialViewList(myDiffs: [
            Differential(id: 12345, url: "https://phabricator.dropboxer.net/D751211" ,
                         title: "[FileProvider] [PUMA] WIP: Have pre-local return per-user metadata as part of hash_result()\'s FoundMetadata",
                         dateCreated: NSDate(timeIntervalSince1970: 1617919675),
                         dateModified: NSDate(timeIntervalSince1970: 1617916339)),
            Differential(id: 34567, url: "https://phabricator.dropboxer.net/D751211" ,
                         title: "Add mutagen to rust_patched_vendor",
                         dateCreated: NSDate(timeIntervalSince1970: 1617919675),
                         dateModified: NSDate(timeIntervalSince1970: 1617916339))
        ],
        otherDiffs: [
            Differential(id: 32145, url: "https://phabricator.dropboxer.net/D751211" ,
                         title: "Another diff", dateCreated: NSDate(timeIntervalSince1970: 1617919675),
                         dateModified: NSDate(timeIntervalSince1970: 1617916339)),
            Differential(id: 132, url: "https://phabricator.dropboxer.net/D751211" ,
                         title: "Another diff", dateCreated: NSDate(timeIntervalSince1970: 1617919675),
                         dateModified: NSDate(timeIntervalSince1970: 1617916339))
        ],
        lastUpdateTime: Date()
        )
    }
}
