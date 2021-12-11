//
//  SessionsView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/19/21.
//

import SwiftUI

struct SessionsView: View {
    @ObservedObject var gloveViewModel: GloveViewModel
    
    @State var selectedRow: String = ""
    var body: some View {
        NavigationView {
            VStack {
                
                List {
                    Text("Training History")
                        .foregroundColor(.black)
                        .bold()
                        .font(.title)
                    ForEach(gloveViewModel.sessions, id:\.self) { session in
                        
                        NavigationLink(session.name ?? "Unknown", destination: SessionView(gloveViewModel: gloveViewModel, session: session))
                            .listRowBackground(Color.black)
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .onDelete(perform: gloveViewModel.deleteSession )
                }.onAppear {
                    gloveViewModel.hideStartSessionButton = false
                }
            
            }
            .background(background)
            .navigationBarHidden(true)
        }
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView(gloveViewModel: GloveViewModel())
            .background(Color.gray)
            .ignoresSafeArea()
    }
}

extension SessionsView {
    
    private var background: some View {
        
        Color(.gray)
    }
}
