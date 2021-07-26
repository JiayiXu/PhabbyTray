//
//  ContentView.swift
//  PhabbyTray
//
//  Created by Tony Xu on 4/9/21.
//

import SwiftUI

struct ContentView: View {
    @State private var apiToken: String = ""
    var apiTokenClicked: ((String) -> Void)?
    
    var body: some View {
        VStack {
            Text("Paste your phabricator API token here")
                .padding(.top, 20.0)
            TextField("API Token:", text: $apiToken)
                .padding(.horizontal, 30.0)
            Button(action: {
                            // Closure will be called once user taps your button
                print(self.apiToken)
                apiTokenClicked?(self.apiToken)
                        }) {
                Text("Save")
            }
            .padding(.bottom, 10.0)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(apiTokenClicked: nil)
    }
}
