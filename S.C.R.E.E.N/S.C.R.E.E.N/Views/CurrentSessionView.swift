//
//  HomeView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/3/21.
//


import SwiftUI

struct CurrentSessionView: View {
    
    @ObservedObject var gloveViewModel: GloveViewModel
    
    @State var selectedRow: String = ""
    @State var displayLiveReading: Bool = true
    @State var displayTarget: Bool = false
    @State var displayShot: ShotModel = ShotModel()
    @State var selectedTab: Int = 0
    @State var listCount = 0
    var body: some View {
            
        VStack {
            
            VStack {
                ZStack {
                    if displayLiveReading {
                        GraphsView(shot: gloveViewModel.glove.currentShot, selectedTab: $selectedTab)
                    } else {
                        ZStack {
                            GraphsView(shot: displayShot, selectedTab: $selectedTab)
                            if displayTarget {
                                GraphsView(shot: gloveViewModel.glove.targetShot, selectedTab: $selectedTab)
                                    .opacity(0.2)
                            }
                        }
                        
                    }
                    VStack(alignment: .trailing) {
                        HStack {
                            showTargetButton
                            Spacer()
                            liveReadingButton
                        }
                        Spacer()
                    }
                        .frame(height: 233, alignment: .center)
                }
                ZStack {
                    pageBubbles
                }.frame(height: 10)
            }
            MyDivider()
            
            List {
                ForEach(gloveViewModel.glove.shotHistory, id: \.id) { shot in
                    HStack {
                        shotID(shot: shot)
                        Spacer()
                        overallSimilarity(shot: shot)

                        subSimilarity(shot: shot, selectedTab: selectedTab)
                    }.onTapGesture {
                        displayShot = shot
                        displayLiveReading = false
                        selectedRow = shot.id
                    }
                    .listRowBackground(selectedRow == shot.id ? Color("AccentColor") : getColor(val: Double(shot.overallSimilarity)) )
                }
                .onDelete(perform: deleteShot)
            }.listStyle(PlainListStyle())

            Spacer()
            connectionStatus
        }
            .background(background)
            .onAppear(perform: {
                gloveViewModel.glove.currentShot = ShotModel()
                displayLiveReading = true
            })
    }
}

struct CurrentSessionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CurrentSessionView(gloveViewModel: GloveViewModel())
            
    }
}

extension CurrentSessionView {
    
    private var background: some View {
        
        Color(.gray)
            .ignoresSafeArea()
    }
    
    private var liveReadingButton: some View {
        VStack(alignment: .trailing) {
            HStack {
                Spacer()
                HStack {
                    if !displayLiveReading {
                        
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
                        displayLiveReading.toggle()
                        selectedRow = ""
                    } label: {
                        
                        Text("Live")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                    }
                }.background(Color.accentColor)
                    .cornerRadius(10)
                    .frame(height: 30)
                    .padding(.horizontal)
            }
            Spacer()
        }
            .frame(height: 233, alignment: .center)
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
                            .font(.system(size: 15))
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
    
    private var connectionStatus: some View {
        VStack {
            if gloveViewModel.connectionStatus {
                Text("Connected")
            } else {
                Text("Not Connected")
            }
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
    
    struct shotID: View {
        var shot: ShotModel
        var body: some View {
            Text("Shot \(String(shot.id))")
                .font(.title)
                .foregroundColor(.black)
                .lineLimit(1).fixedSize(horizontal: false, vertical: true)
        }
    }
    
    struct overallSimilarity: View {
        var shot: ShotModel
        var body: some View {
            Text("\(shot.overallSimilarity, specifier: "%.2f")")
                .font(.title)
                .foregroundColor(.white)
                .lineLimit(1).fixedSize(horizontal: false, vertical: true)
        }
    }
    
    struct subSimilarity: View {
        var shot: ShotModel
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
    
    private var overalLabel: some View {
        
        Text("Overall\nAccuracy")
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        
    }
    
    private var subLabel: some View {
        VStack{
            switch selectedTab {
            case 0:
                Text("Accelerometer\nAccuracy")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            case 1:
                Text("Gyroscope\nAccuracy")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            case 2:
                Text("Flex Sensor\nAccuracy")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            default:
                Text("Accelerometer\nAccuracy")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

extension CurrentSessionView {
    
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
    
    func deleteShot(index: IndexSet) {
        
        gloveViewModel.glove.deleteShot(index: index)
    }
}

