//
//  SessionView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/19/21.
//

import SwiftUI

struct SessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var gloveViewModel: GloveViewModel
    
    @State var displayShot: ShotModel = ShotModel()
    @State var displayTarget: Bool = false
    let session: SessionEntity
    @State var selectedTab: Int = 0
    @State var selectedRow: String = ""
    var body: some View {
        
            VStack {
                
                subHeader
                MyDivider(width: 1)
                ZStack {
                    ZStack {
                        
                        GraphsView(shot: displayShot, selectedTab: $selectedTab)
                        if displayTarget {
                            GraphsView(shot: gloveViewModel.glove.targetShot, selectedTab: $selectedTab)
                                .opacity(0.2)
                        }
                    }
                    VStack(alignment: .trailing) {
                        HStack {
                            showTargetButton
                            Spacer()
                        }
                        Spacer()
                    }
                        .frame(height: 233, alignment: .center)
                }
                ZStack {
                    pageBubbles
                }.frame(height: 10)
                
                
                if let shots = session.shots?.allObjects as? [ShotEntity] {
                    
                    List {
                        ForEach(shots, id: \.id) { shot in
                            HStack {
                                shotID(shot: shot)
                                Spacer()
                                overallSimilarity(shot: shot)
                                subSimilarity(shot: shot, selectedTab: 0)
                            }.onTapGesture {
                                displayShot = gloveViewModel.shotEntityToModel(shotEntity: shot)
                                selectedRow = shot.id!
                            }
                            .listRowBackground(selectedRow == shot.id ? Color("AccentColor") : getColor(val: Double(shot.overallSimilarity)) )
                        }
                        .onDelete { indexSet in
                            gloveViewModel.deleteSessionShot(session: session, indexSet: indexSet)
                        }
                    }.listStyle(PlainListStyle())
                        .onAppear {
                            if shots.count > 0 {
                                displayShot = gloveViewModel.shotEntityToModel(shotEntity: shots[0])
                                selectedRow = shots[0].id!
                            }
                        }
                }
                Spacer()
            }.navigationBarHidden(true)
            .background(background)
            .onAppear {
                gloveViewModel.hideStartSessionButton = true
            }
    }
}

//struct SessionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionView(session: SessionEntity())
//            .background(Color.gray)
//    }
//}

extension SessionView {
    
    private var background: some View {
        
        Color(.gray)
    }
    
    private var subHeader: some View {
        
        ZStack {
            Text("Session \(session.name ?? "Unknown")")
                .font(.title3)
                .bold()
            
            HStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    
                        Text("Back")
            
                }.padding(.leading)

                Spacer()
            }
        }
    }
    
    struct shotID: View {
        var shot: ShotEntity
        var body: some View {
            Text("Shot \(String(shot.id ?? ""))")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .lineLimit(1).fixedSize(horizontal: false, vertical: true)
        }
    }
    
    struct overallSimilarity: View {
        var shot: ShotEntity
        var body: some View {
            Text("\(shot.overallSimilarity, specifier: "%.2f")")
                .font(.title)
                .foregroundColor(.white)
                .lineLimit(1).fixedSize(horizontal: false, vertical: true)
        }
    }
    
    struct subSimilarity: View {
        var shot: ShotEntity
        var selectedTab: Int
        var body: some View {
            
            switch selectedTab {
            case 0:
                Text("\(shot.accSimilarity, specifier: "%.2f")")
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(1).fixedSize(horizontal: false, vertical: true)
            case 1:
                Text("\(shot.gyroSimilarity, specifier: "%.2f")")
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(1).fixedSize(horizontal: false, vertical: true)
            case 2:
                Text("\(shot.flexSimilarity, specifier: "%.2f")")
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(1).fixedSize(horizontal: false, vertical: true)
            default:
                Text("\(shot.accSimilarity, specifier: "%.2f")")
                    .font(.title)
                    .foregroundColor(.white)
                    .lineLimit(1).fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private var showTargetButton: some View {
        VStack(alignment: .trailing) {
            HStack {
                
                HStack {
                    if !displayTarget {
                        
                        Circle()
                            .frame(width: 10)
                            .foregroundColor(.gray)
                            .padding(.leading)
                    } else {
                        Circle()
                            .frame(width: 10)
                            .foregroundColor(.green)
                            .padding(.leading)
                    }
                    Button {
                        displayTarget.toggle()
                        selectedRow = ""
                    } label: {
                        
                        Text("Target")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                    }
                }.background(Color.accentColor)
                    .cornerRadius(10)
                    .frame(height: 30)
                    .padding(.horizontal)
                Spacer()
            }
            Spacer()
        }
            .frame(height: 233, alignment: .center)
    }
    
    private var overalLabel: some View {
        
        Text("Overall\nAccuracy")
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        
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
}

extension SessionView {
    func getColor(val: Double) -> Color {
        if val < 50{
            return Color(red: 1, green: 0, blue: 0)
        } else {
            if val < 60 {
                return Color(red: 0.9, green: 0.1, blue: 0)
            } else if val < 70 {
                return Color(red: 0.8, green: 0.2, blue: 0)
            } else if val < 80 {
                return Color(red: 0.7, green: 0.2, blue: 0)
            } else if val < 85 {
                return Color(red: 0.6, green: 0.2, blue: 0)
            } else if val < 90 {
                return Color(red: 0.5, green: 0.5, blue: 0)
            } else if val < 95 {
                return Color(red: 0.1, green: 0.7, blue: 0)
            } else if val < 97 {
                return Color(red: 0, green: 0.8, blue: 0)
            } else if val < 98 {
                return Color(red: 0, green: 0.9, blue: 0)
            } else  {
                return Color(red: 0, green: 1, blue: 0)
            }
            
        }
    }
}
