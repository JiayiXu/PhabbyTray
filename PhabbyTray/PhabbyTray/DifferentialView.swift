//
//  DifferentialView.swift
//  PhabbyTray
//
//  Created by Tony Xu on 4/9/21.
//

import SwiftUI

struct DifferentialView: View {
    var differential: Differential
    
    
    var body: some View {
        HStack {
            Text(differential.url)
            .foregroundColor(.blue)
            .onTapGesture {
                if let url = URL.init(string: differential.url) {
                    NSWorkspace.shared.open(url)
                }
            }
            .onHover(perform: { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            })
            Spacer()
            Text(differential.title.trimmingCharacters(in: .whitespacesAndNewlines)).multilineTextAlignment(.leading).padding(.leading, 0.0).frame(alignment: .center)
            Spacer()
            Text("Created:\(differential.dateCreated.timeAgoDisplay())")
            Spacer()
            Text("Modified: \(differential.dateModified.timeAgoDisplay())")
        }
    }
}

struct DifferentialView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DifferentialView(differential: Differential(
                                id: 12345, url: "https://phabricator.dropboxer.net/D751211" ,
                                title: "Add mutagen to rust_patched_vendor",
                             dateCreated: NSDate(timeIntervalSince1970: 1617919675),
                            dateModified: NSDate(timeIntervalSince1970: 1617916339)
                ))
            
            DifferentialView(differential: Differential(id: 12345, url: "https://phabricator.dropboxer.net/D751211" ,
                         title: "[FileProvider] [PUMA] WIP: Have pre-local return per-user metadata as part of hash_result()\'s FoundMetadata",
                         dateCreated: NSDate(timeIntervalSince1970: 1617919675),
                         dateModified: NSDate(timeIntervalSince1970: 1617916339)
                         ))
        }
    }
}
