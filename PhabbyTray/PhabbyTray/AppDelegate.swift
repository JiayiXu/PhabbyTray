//
//  AppDelegate.swift
//  PhabbyTray
//
//  Created by Tony Xu on 4/9/21.
//

import Cocoa
import SwiftUI
import RxSwift

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        let DEFAULT_W = 80
        let DEFAULT_H = 22
        let txt = NSTextField(frame: NSMakeRect(0, 0, CGFloat(DEFAULT_W), CGFloat(DEFAULT_H)))
        txt.stringValue = "FFF"
        
        let mStatusBackgroundView = NSView(frame: NSMakeRect(0, 0, CGFloat(DEFAULT_W), CGFloat(DEFAULT_H)))
        mStatusBackgroundView.addSubview(txt)
        
        if let button = self.statusBarItem.button {
            button.action = #selector(togglePopover(_:))
        }
        onPhabStatusChange(PhabStatus(numMydiffs: 2, numReviewerDiffs: 1, subscribedDiffs: 2))
        self.refresh()
    }
    
    func refresh() {
        let conduitAPI = ConduitAPI(apiToken: "api-d2hwntdrdwnyoe63zg3xowejwaqi")
        conduitAPI.getLoggedinUser()
            .subscribe(
                    onNext: {  PhabUser in
                        print("Got a user: \(PhabUser)")
                    },
                    onError: { error in
                        print("Got an error: \(error)")
                    }
            ).disposed(by: self.disposeBag)
        
        conduitAPI.getMyReviewDiffs(phabUser: PhabUser(phabId: "PHID-USER-d7uxk4xwxr2dw2ttitai"))
            .subscribe(
                    onNext: {  diffs in
                        print("Got a user: \(diffs)")
                    },
                    onError: { error in
                        print("Got an error: \(error)")
                    }
            ).disposed(by: self.disposeBag)
    }
    
    func onPhabStatusChange(_ newStatus: PhabStatus) {
        DispatchQueue.main.async {
            self.statusBarItem.button?.title = newStatus.description()
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
         if let button = self.statusBarItem.button {
              if self.popover.isShown {
                   self.popover.performClose(sender)
              } else {
                   self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
              }
         }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

