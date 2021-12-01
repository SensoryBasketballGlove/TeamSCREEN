//
//  MainView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/5/21.
//

import SwiftUI

struct MainView: View {
    
    var gloveViewModel: GloveViewModel = GloveViewModel()
 
    var body: some View {
        TabView {
            HomeView(gloveViewModel: gloveViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            UserView(gloveViewModel: gloveViewModel)
                .tabItem {
                    Label("User", systemImage: "person")
                }
            
            PairGloveView(gloveViewModel: gloveViewModel, connectedStatus: "False", selectedRow: "!")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(gloveViewModel: GloveViewModel())
            //.environmentObject(GloveViewModel())
    }
}
