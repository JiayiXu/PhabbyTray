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
    var myDiffs: [Differential] = []
    var reviewDiffs: [Differential] = []
    var lastUpdate = Date()
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let apiToken = loadApiToken() {
            NSApp.setActivationPolicy(.accessory)
            let popover = NSPopover()
            popover.contentSize = NSSize(width: 800, height: 400)
            popover.behavior = .transient
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
            onPhabStatusChange()
            self.refresh(apiToken: apiToken)
        } else {
            let contentView = ContentView(apiTokenClicked: self.tokenStored)

            // Create the window and set the content view.
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            window.center()
            window.setFrameAutosaveName("Main Window")
            window.contentView = NSHostingView(rootView: contentView)
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    @objc func tokenStored(_ sender: String) {
        print("Main app: \(sender)")
        let toSet = sender.isEmpty ? nil : sender
        let defaults = UserDefaults.standard
        defaults.setValue(toSet, forKey: "api_token")
        restartSelf()
    }
    
    func restartSelf() {
        let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
        let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [path]
        task.launch()
        exit(0)
    }
    
    func loadApiToken() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "api_token")
    }
    
    func loadPhabUser() -> PhabUser? {
        if let phabId = UserDefaults.standard.string(forKey: "phab_id") {
            return PhabUser(phabId: phabId)
        }
        return nil
    }
    
    func setPhabid(phabId: String) {
        let defaults = UserDefaults.standard
        defaults.setValue(phabId, forKey: "phab_id")
    }
    
    func fetchAll(conduitApi: ConduitAPI, phabUser: PhabUser) {
        conduitApi.getMyOpenDiffs(phabUser: phabUser).subscribe(
            onNext: { diffs in
                self.myDiffs = diffs
                conduitApi.getMyReviewDiffs(phabUser: phabUser).subscribe(
                    onNext: { diffs in
                        self.reviewDiffs = diffs
                        self.lastUpdate = Date()
                        self.onPhabStatusChange()
                    }
                ).disposed(by: self.disposeBag)
            }
        ).disposed(by: self.disposeBag)
    }
    
    func refresh(apiToken: String) {
        let conduitAPI = ConduitAPI(apiToken: apiToken)
        if let phabUser = loadPhabUser() {
            self.fetchAll(conduitApi: conduitAPI, phabUser: phabUser)
        } else {
            conduitAPI.getLoggedinUser()
                .subscribe(
                    onNext: {  phabUser in
                        self.setPhabid(phabId: phabUser.phabId)
                        self.fetchAll(conduitApi: conduitAPI, phabUser: phabUser)
                    }
            ).disposed(by: self.disposeBag)
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 5) {
            self.refresh(apiToken: apiToken)
        }
    }
    
    func onPhabStatusChange() {
        DispatchQueue.main.async {
            self.statusBarItem.button?.title = "M:\(self.myDiffs.count) R:\(self.reviewDiffs.count)"
        }
    }
    
    func showSettings() {
        let contentView = ContentView(apiTokenClicked: self.tokenStored)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func quit() {
        exit(0)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
         if let button = self.statusBarItem.button {
              if self.popover.isShown {
                   self.popover.performClose(sender)
              } else {
                let listView = DifferentialViewList(myDiffs: self.myDiffs,
                                                    otherDiffs: self.reviewDiffs,
                                                    lastUpdateTime: self.lastUpdate,
                                                    settingsClicked: self.showSettings,
                                                    quit: self.quit)
                self.popover.contentViewController = NSHostingController(rootView: listView)
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
              }
         }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

