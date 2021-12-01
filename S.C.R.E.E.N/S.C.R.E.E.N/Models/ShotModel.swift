//
//  ShotModel.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/3/21.
//

import Foundation

struct ShotModel: Identifiable {
    
    var id: String
    
    var pointFlexVals:  [Float] = [] //50 before beggining, some number middle, 50 after
    var middleFlexVals: [Float] = []
    var ringFlexVals:   [Float] = []
    var pinkieFlexVals: [Float] = []
    var wristFlexVals:  [Float] = []
    var xGyroVals:      [Float] = []
    var yGyroVals:      [Float] = []
    var zGyroVals:      [Float] = []
    var xAccVals:       [Float] = []
    var yAccVals:       [Float] = []
    var zAccVals:       [Float] = []
    
    var accSimilarity: Float = 0.0
    var gyroSimilarity: Float = 0.0
    var flexSimilarity: Float = 0.0
    var overallSimilarity: Float = 0.0
    var selectedTab: Int = 0
    
    init(id: String = String(0)) {
        self.id = id
    }
    
    mutating func setSimilarities(accVal: Float, gyroVal: Float, flexVal: Float, overallVal: Float) {
        overallSimilarity = overallVal
        accSimilarity = accVal
        gyroSimilarity = gyroVal
        flexSimilarity = flexVal
    }
}
