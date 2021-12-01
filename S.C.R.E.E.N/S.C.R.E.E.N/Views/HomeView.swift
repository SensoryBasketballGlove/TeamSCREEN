//
//  Home View.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/19/21.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var gloveViewModel: GloveViewModel
    
    @State var newSession: Bool = true
    var body: some View {
        VStack {
            headerView
            
            if !newSession {
                CurrentSessionView(gloveViewModel: gloveViewModel);
            } else {
                SessionsView(gloveViewModel: gloveViewModel)
            }
            Spacer()
            if !gloveViewModel.hideStartSessionButton && gloveViewModel.targetShotSet {
                sessionButton
            } else {
                Text("Please go to User tab and set Target Shot")
            }
        }.background(background)
        .onAppear {
            gloveViewModel.hideStartSessionButton = false
        }
    }
}

struct Home_View_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(gloveViewModel: GloveViewModel())
    }
}

extension HomeView {
    
    private var background: some View {
        
        Color(.gray)
            .ignoresSafeArea()
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                
                
                Text("S.C.R.E.E.N")
                    .foregroundColor(.white)
                    .font(.title)
            }
            MyDivider(width: 3)
        }
        
    }
    
    private var sessionButton: some View {
        VStack {
            if !newSession {
                Button {
                    newSession.toggle()
                    gloveViewModel.addSession()
                    gloveViewModel.disconnect()
                } label: {
                    Text("End Session")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 2)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            } else {
                Button {
                    newSession.toggle()
                    gloveViewModel.startScanning()
                    gloveViewModel.glove.shotHistory.removeAll()
                } label: {
                    Text("Start Session")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 2)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
        }.padding(.bottom
        )
    }
}
