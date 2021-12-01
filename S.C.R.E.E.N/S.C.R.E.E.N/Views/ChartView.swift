//
//  ChartView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/3/21.
//

import SwiftUI

struct ChartView: View {
    
    var data0: [Float] = []
    var data1: [Float] = []
    var data2: [Float] = []
    var data3: [Float] = []
    var data4: [Float] = []
    let maxY: Float
    let minY: Float
    var lineColors: [Color]
    let numLines: Int
    let labels: [String]
    
    init(values: [[Float]], setLabels: [String] = ["1", "2", "3", "4", "5"], range: [Float] = [-100, 100], setLineColors: [Color] = [Color.blue, Color.red, Color.green, Color.black, Color.yellow]) {
        switch values.count {
        case 1:
            data0 = values[0]
        case 2:
            data0 = values[0]
            data1 = values[1]
        case 3:
            data0 = values[0]
            data1 = values[1]
            data2 = values[2]
        case 4:
            data0 = values[0]
            data1 = values[1]
            data2 = values[2]
            data3 = values[3]
        case 5:
            data0 = values[0]
            data1 = values[1]
            data2 = values[2]
            data3 = values[3]
            data4 = values[4]
        default:
            break
        }
        
        numLines = values.count
        maxY = range[1]
        minY = range[0]
        lineColors = setLineColors
        labels = setLabels
    }
    var body: some View {
        VStack {
            chartView
                .frame(height: 200)
                .cornerRadius(10)
                .background(chartBackground)
                .overlay(yLabels, alignment: .leading)
                .overlay(
                    VStack {
                        HStack {
                            switch numLines {
                            case 1:
                                Text(labels[0])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[0])
                                    .padding(.top,3)
                            case 2:
                                Text(labels[0])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[0])
                                    .padding(.top,3)
                                Text(labels[1])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[1])
                                    .padding(.top,3)
                            case 3:
                                Text(labels[0])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[0])
                                    .padding(.top,3)
                                Text(labels[1])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[1])
                                    .padding(.top,3)
                                Text(labels[2])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[2])
                                    .padding(.top,3)
                            case 4:
                                Text(labels[0])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[0])
                                    .padding(.top,3)
                                Text(labels[1])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[1])
                                    .padding(.top,3)
                                Text(labels[2])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[2])
                                    .padding(.top,3)
                                Text(labels[3])
                                    .foregroundColor(.black)
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(lineColors[3])
                                    .padding(.top,3)
                            default:
                                Text(labels[0])
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    
                            }
                            
                        }
                        Spacer()
                    })
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(values: [[1,2], [1,3]], setLabels: ["x"])
    }
}

extension ChartView {
    
    private var chartView: some View {
        
        GeometryReader {geometry in
            ZStack {
                switch numLines {
                case 1:
                    Path { path in
                        for i in data0.indices {
                            let xPos = geometry.size.width / CGFloat(data0.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data0[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[0], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                case 2:
                    Path { path in
                        for i in data0.indices {
                            let xPos = geometry.size.width / CGFloat(data0.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data0[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[0], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data1.indices {
                            let xPos = geometry.size.width / CGFloat(data1.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data1[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[1], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                case 3:
                    Path { path in
                        for i in data0.indices {
                            let xPos = geometry.size.width / CGFloat(data0.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data0[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[0], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data1.indices {
                            let xPos = geometry.size.width / CGFloat(data1.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data1[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[1], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data2.indices {
                            let xPos = geometry.size.width / CGFloat(data2.count) * CGFloat(i + 1)

                            let yAxis = maxY - minY

                            let yPos = (1 - CGFloat((data2[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[2], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                case 4:
                    Path { path in
                        for i in data0.indices {
                            let xPos = geometry.size.width / CGFloat(data0.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data0[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[0], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data1.indices {
                            let xPos = geometry.size.width / CGFloat(data1.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data1[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[1], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data2.indices {
                            let xPos = geometry.size.width / CGFloat(data2.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data2[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[2], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data3.indices {
                            let xPos = geometry.size.width / CGFloat(data3.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data3[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[3], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data4.indices {
                            let xPos = geometry.size.width / CGFloat(data4.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data4[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[4], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                case 5:
                    Path { path in
                        for i in data0.indices {
                            let xPos = geometry.size.width / CGFloat(data0.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data0[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[0], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data1.indices {
                            let xPos = geometry.size.width / CGFloat(data1.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data1[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[1], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data2.indices {
                            let xPos = geometry.size.width / CGFloat(data2.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data2[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[2], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data3.indices {
                            let xPos = geometry.size.width / CGFloat(data3.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data3[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[3], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    Path { path in
                        for i in data4.indices {
                            let xPos = geometry.size.width / CGFloat(data4.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data4[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[4], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                default:
                    Path { path in
                        for i in data0.indices {
                            let xPos = geometry.size.width / CGFloat(data0.count) * CGFloat(i + 1)
                            
                            let yAxis = maxY - minY
                            
                            let yPos = (1 - CGFloat((data0[i] - minY) / yAxis)) * geometry.size.height
                            if i == 0 {
                                path.move(to: CGPoint(x: xPos, y: yPos))
                            }
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    .stroke(lineColors[0], style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
    
    private var chartBackground: some View {
        ZStack {
            Color(.white)
            VStack {
                Divider()
                Spacer()
                Divider()
                Spacer()
                Divider()
            }
        }.cornerRadius(10)
    }
    
    private var yLabels: some View {
        
        VStack {
            Text(String(maxY))
                .foregroundColor(.black)
            Spacer()
            Text(String((maxY+minY)/2))
                .foregroundColor(.black)
            Spacer()
            Text(String(minY))
                .foregroundColor(.black)
        }
    }
}

