//
//  GloveModel.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/3/21.
//

import Foundation

struct GloveModel: Identifiable {
    
    let id: String = UUID().uuidString
    let name: String
    let dataSize: Int = 256
    let numAfter: Int = 100
    var currentShot: ShotModel = ShotModel()
    var targetShot: ShotModel = ShotModel()
    var displayShot: ShotModel = ShotModel()
    var shotHistory: [ShotModel]
    var numShotsStored: Int
    var shotBegan: Bool = false
    var shotEnded: Bool = false
    init(name: String, shotHistory: [ShotModel] = [ShotModel]()) {
        
        self.name = name
        self.numShotsStored = shotHistory.count
        self.shotHistory = shotHistory
    }
    
    func updateCompletion() -> GloveModel {
        
        return GloveModel(name: name)
    }
    
    func compareShots(shot: ShotModel) -> ShotModel {
        var newShot = shot
        
        if targetShot.zAccVals.count > 1 {
            var xAccSimilarity: Float = 0
            var yAccSimilarity: Float = 0
            var zAccSimilarity: Float = 0
            
            var xGyroSimilarity: Float = 0
            var yGyroSimilarity: Float = 0
            var zGyroSimilarity: Float = 0
            
            var pointFlexSimilarity: Float = 0
            var middleFlexSimilarity: Float = 0
            var ringFlexSimilairty: Float = 0
            var pinkieFlexSimilarity: Float = 0
            var thumbFlexSimilarity: Float = 0
            var wristFlexSimilarity: Float = 0
            
            //comparsion shot vs targetShot
            //50, some number durring, 100 after
            for i in 1...numAfter {
                let shotXAccVal = shot.xAccVals[(shot.xAccVals.count) - i]
                let shotYAccVal = shot.yAccVals[(shot.yAccVals.count) - i]
                let shotZAccVal = shot.zAccVals[(shot.zAccVals.count) - i]
                
                let shotXGyroVal = shot.xGyroVals[(shot.xGyroVals.count) - i]
                let shotYGyroVal = shot.yGyroVals[(shot.yGyroVals.count) - i]
                let shotZGyroVal = shot.zGyroVals[(shot.zGyroVals.count) - i]
                
                let shotPointFlexVal = shot.pointFlexVals[(shot.pointFlexVals.count) - i]
                let shotMiddleFlexVal = shot.middleFlexVals[(shot.middleFlexVals.count) - i]
                let shotRingFlexVal = shot.ringFlexVals[(shot.ringFlexVals.count) - i]
                let shotPinkytFlexVal = shot.pinkieFlexVals[(shot.pinkieFlexVals.count) - i]
                let shotThumbFlexVal = shot.thumbFlexVals[(shot.thumbFlexVals.count) - i]
                let shotWristFlexVal = shot.wristFlexVals[(shot.wristFlexVals.count) - i]
                
                let targetShotXAccVal = targetShot.xAccVals[targetShot.xAccVals.count - i]
                let targetShotYAccVal = targetShot.yAccVals[targetShot.yAccVals.count - i]
                let targetShotZAccVal = targetShot.zAccVals[targetShot.zAccVals.count - i]
                
                let targetShotXGyroVal = targetShot.xGyroVals[targetShot.xGyroVals.count - i]
                let targetShotYGyroVal = targetShot.yGyroVals[targetShot.yGyroVals.count - i]
                let targetShotZGyroVal = targetShot.zGyroVals[targetShot.zGyroVals.count - i]
                
                let targetPointFlexVal = targetShot.pointFlexVals[(targetShot.pointFlexVals.count) - i]
                let targetMiddleFlexVal = targetShot.middleFlexVals[(targetShot.middleFlexVals.count) - i]
                let targetRingFlexVal = targetShot.ringFlexVals[(targetShot.ringFlexVals.count) - i]
                let targetPinkieFlexVal = targetShot.pinkieFlexVals[(targetShot.pinkieFlexVals.count) - i]
                let targetThumbFlexVal = targetShot.thumbFlexVals[(targetShot.thumbFlexVals.count) - i]
                let targetWristFlexVal = targetShot.wristFlexVals[(targetShot.wristFlexVals.count) - i]
                
                
                xAccSimilarity       += similairityValue(v1: shotXAccVal, v2: targetShotXAccVal)
                yAccSimilarity       += similairityValue(v1: shotYAccVal, v2: targetShotYAccVal)
                zAccSimilarity       += similairityValue(v1: shotZAccVal, v2: targetShotZAccVal)
                xGyroSimilarity      += similairityValue(v1: shotXGyroVal, v2: targetShotXGyroVal)
                yGyroSimilarity      += similairityValue(v1: shotYGyroVal, v2: targetShotYGyroVal)
                zGyroSimilarity      += similairityValue(v1: shotZGyroVal, v2: targetShotZGyroVal)
                pointFlexSimilarity  += similairityValue(v1: shotPointFlexVal, v2: targetPointFlexVal)
                middleFlexSimilarity += similairityValue(v1: shotMiddleFlexVal, v2: targetMiddleFlexVal)
                ringFlexSimilairty   += similairityValue(v1: shotRingFlexVal, v2: targetRingFlexVal)
//                pinkieFlexSimilarity += similairityValue(v1: shotPinkytFlexVal, v2: targetPinkieFlexVal)
//                thumbFlexSimilarity  += similairityValue(v1: shotThumbFlexVal, v2: targetThumbFlexVal)
//                wristFlexSimilarity  += similairityValue(v1: shotWristFlexVal, v2: targetWristFlexVal)
            }
            
            let numPoints: Float = Float(numAfter) - 1
            
            
            var accVal = (100 - ((xAccSimilarity / numPoints + yAccSimilarity / numPoints + zAccSimilarity / numPoints) / 3))
            if accVal < 80 {
                accVal = 0
            } else {
                accVal = (accVal - 80) / 20 * 100
            }
            
            var gyroVal = 100 - ((xGyroSimilarity / numPoints + yGyroSimilarity / numPoints + zGyroSimilarity / numPoints) / 3)
            if gyroVal < 80 {
                
                gyroVal = 0
            } else {
                gyroVal = (gyroVal - 80) / 20 * 100
            }
            
            //var flexVal = 100 - (((1 / 3) * pointFlexSimilarity + (1 / 3) * middleFlexSimilarity + (3 / 9) * ringFlexSimilairty + (0 / 9) * pinkieFlexSimilarity) / numPoints)
            var flexVal = 100 - (((3 / 9) * pointFlexSimilarity + (3 / 9) * middleFlexSimilarity + (3 / 9) * ringFlexSimilairty + (0 / 9) * pinkieFlexSimilarity + (0 / 9) * thumbFlexSimilarity + (0 / 9) + wristFlexSimilarity)) / numPoints 

            
            if flexVal < 30 {
                flexVal = 0
            } else {
                flexVal = (flexVal - 30) / 70 * 100
            }
            let overallVal = ((1/5) * accVal + (2 / 5) * gyroVal + (2 / 5) * flexVal)
            
            newShot.setSimilarities(accVal: accVal, gyroVal: gyroVal, flexVal: flexVal, overallVal: overallVal)
            
        }
        
        return newShot
    }
    //50, -100
    func similairityValue(v1: Float, v2: Float) -> Float {
        
        if v1 > v2 {
            return (v1-v2)/v1 * 100
        } else {
            return (v2-v1)/v2 * 100
        }
    }
    
    mutating func deleteShot(index: IndexSet) {
        
        shotHistory.remove(atOffsets: index)
    }
}


