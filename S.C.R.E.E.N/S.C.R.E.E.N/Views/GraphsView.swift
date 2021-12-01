//
//  GraphsView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/7/21.
//

import SwiftUI

struct GraphsView: View {
    
    var shot: ShotModel
    @Binding var selectedTab: Int
    @State var labelText: String = "Acc"
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                
                accGraph
                    .tag(0)
                gyroGraph
                    .tag(1)
                flexGraph
                    .tag(2)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: PageTabViewStyle.IndexDisplayMode.never))
                .frame(height: 240)
        }
    }
}

struct GraphsView_Previews: PreviewProvider {
    static var previews: some View {
        GraphsView(shot: ShotModel(), selectedTab: .constant(0))
            .background(Color.gray)
    }
}

extension GraphsView {
    
    private var accGraph: some View {
        VStack {
            label
            ChartView(values: [shot.xAccVals, shot.yAccVals, shot.zAccVals],
                      setLabels: ["x", "y", "z"],
                        range: [0, 100])
                .padding(.horizontal)
        }
    }
    private var gyroGraph: some View {
        VStack {
            label
            ChartView(values: [shot.xGyroVals, shot.yGyroVals, shot.zGyroVals],
                      setLabels: ["x", "y", "z"],
                        range: [0,100])
            
                .padding(.horizontal)
        }
    }
    private var flexGraph: some View {
        VStack {
            label
            ChartView(values: [shot.pointFlexVals, shot.middleFlexVals, shot.ringFlexVals, shot.pinkieFlexVals],
                      setLabels: ["p1", "m", "r", "p2"],
                        range: [0,100])
            
                .padding(.horizontal)
        }
    }
    
    private var label: some View {
        VStack {
            switch selectedTab {
            case 0:
                Text("Accelerometer")
                    .foregroundColor(.white)
                    .font(.headline)
            case 1:
                Text("Gyroscope")
                    .foregroundColor(.white)
                    .font(.headline)
            case 2:
                Text("Flex Sensors")
                    .foregroundColor(.white)
                    .font(.headline)
            default:
                Text("Accelerometer")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
    }
}
