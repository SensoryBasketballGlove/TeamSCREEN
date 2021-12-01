//
//  TargetShotView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/7/21.
//

import SwiftUI

struct UserView: View {
    
    @ObservedObject var gloveViewModel: GloveViewModel
    //@State var displayShot: ShotModel = ShotModel()
    @State var displayLiveReading: Bool = true
    @State var selectedTab: Int = 0
    var body: some View {
        
        VStack {
            headerView
            user
            
            if !gloveViewModel.targetShotSet {
                GraphsView(shot: gloveViewModel.glove.currentShot, selectedTab: $selectedTab)
            } else {
                GraphsView(shot: gloveViewModel.glove.targetShot, selectedTab: $selectedTab)
            }
            pageBubbles
            if gloveViewModel.targetShotSet {
                
                Button {
                    //may wanna do a pop up to confirm
                    gloveViewModel.beginLookingForTargetShot = true
                    gloveViewModel.targetShotSet = false
                    gloveViewModel.startScanning()
                } label: {
                    Text("Reset Target Shot")
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
                    gloveViewModel.beginLookingForTargetShot = true
                    displayLiveReading = true
                    gloveViewModel.startScanning()
                } label: {
                    Text("Set Target Shot")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 2)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }.background(background)
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(gloveViewModel: GloveViewModel())
        
    }
}

//MARK: Components
extension UserView {
    
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
    
    private var pageBubbles: some View {
        
        VStack {
            switch selectedTab {
            case 0:
                HStack(alignment: .center, spacing: 5) {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                }
            case 1:
                HStack(alignment: .center, spacing: 5) {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                }
            case 2:
                HStack(alignment: .center, spacing: 5) {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 10, height: 10, alignment: .center)
                }
            default:
                HStack(alignment: .center, spacing: 5) {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 10, height: 10, alignment: .center)
                }
            }
        }
    }
    
    private var user: some View {
        VStack {
            HStack {
                
                Label {
                    Text("Bogdan")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding()
                } icon: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100, alignment: .trailing)
                        .padding()
                        .foregroundColor(.accentColor)
                }
                
            }
            MyDivider(color: Color.white, width: 1)
        }
    }
}
