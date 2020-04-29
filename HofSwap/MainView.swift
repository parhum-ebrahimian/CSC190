//
//  MainView.swift
//  HofSwap
//
//  Created by Trey Jean on 4/7/20.
//  Copyright © 2020 Trey Jean. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            VStack { // Profile View
                HStack(spacing: 16) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(minWidth: 0, maxWidth: 56, minHeight: 0, maxHeight:56)
                    VStack(alignment: .leading) {
                        Text("First Last")
                            .font(.system(size: 20, weight: .medium))
                        Button(action: {}) {
                            HStack {
                                Text("Options")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    Spacer()
                }
            }
            
            VStack { // Menu
                Text("Menu")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
