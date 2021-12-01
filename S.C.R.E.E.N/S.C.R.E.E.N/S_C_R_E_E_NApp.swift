//
//  S_C_R_E_E_NApp.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/3/21.
//

import SwiftUI

@main
struct S_C_R_E_E_NApp: App {
    
    init() {
        UITableView.appearance().backgroundColor = UIColor(Color.clear)
    }
    
    let persistenceController = PersitenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }.onChange(of: scenePhase) { newValue in
            switch newValue {
                
            case .background:
                persistenceController.save()
            case .inactive:
                break
            case .active:
                break
            @unknown default:
                break
            }
        }
    }
}


//custom divider structure
struct MyDivider: View {
    var color: Color = .black
    var width: CGFloat = 1
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
    }
}
