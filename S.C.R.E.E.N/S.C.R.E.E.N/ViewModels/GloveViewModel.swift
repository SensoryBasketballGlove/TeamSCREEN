//
//  GloveViewModel.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/3/21.
//

import Foundation
import CoreBluetooth
import CoreData

class GloveViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    var myPeripheral: CBPeripheral?
    var targetService: CBService?
    var flexSensorChar: CBCharacteristic?
    var buzzerChar: CBCharacteristic?
    let serviceUUID         = "a98662ad-6993-4143-8fa6-4fadfcba0574"
    let gloveSensorCharUUID = "82d72018-f4dd-45e2-a3e3-c363a1e14ada"
    let buzzerCharUUID =      "1cc868c0-4703-11ec-81d3-0242ac130003"
    @Published var bluetoothDevices: [CBPeripheral] = [] //simply for displaying the list in the pairing view
    
    @Published var glove: GloveModel = GloveModel(name: "Not Found", shotHistory: [ShotModel(id: String(1)), ShotModel(id: String(2))])
    @Published var bluetoothOn: Bool = false
    @Published var connectionStatus: Bool = false
    @Published var hideStartSessionButton: Bool = false
    @Published var targetShotSet: Bool = false
    
    var beginLookingForTargetShot: Bool = false
    var endBuffer: Int = 0
    
    var recordingShot: ShotModel = ShotModel()
    
    let sessionManager = PersitenceController.shared
    @Published var sessions: [SessionEntity] = []
    @Published var sessionShots: [ShotEntity] = []
    @Published var targetShotEntity: [TargetEntity] = []
    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
        myCentral.delegate = self
        getSessions()
        getTarget()
    }
}

//MARK: Shot Functions
extension GloveViewModel {
    //this is called everytime a value is read from the sensors
    func recordShot() {
        
        if beginLookingForTargetShot == true {
            //detect beggining of the shot
            if (glove.currentShot.zAccVals.last! < 40.0) && (!glove.shotBegan) {
                glove.shotBegan = true
                endBuffer = 0
            }
            
            //detect the end of the shot
            if (glove.shotBegan) && (glove.currentShot.zAccVals.last! > 40.0) {
                glove.shotEnded = true
                glove.targetShot = glove.currentShot
            }
            
            //there might be a better way to do it
            //get x number of points after the end
            if glove.shotEnded == true && endBuffer < glove.numAfter {
                
                endBuffer += 1
                glove.targetShot.xAccVals.append(glove.currentShot.xAccVals.last!)
                glove.targetShot.yAccVals.append(glove.currentShot.yAccVals.last!)
                glove.targetShot.zAccVals.append(glove.currentShot.zAccVals.last!)
                glove.targetShot.xGyroVals.append(glove.currentShot.xGyroVals.last!)
                glove.targetShot.yGyroVals.append(glove.currentShot.yGyroVals.last!)
                glove.targetShot.zGyroVals.append(glove.currentShot.zGyroVals.last!)
                glove.targetShot.pointFlexVals.append(glove.currentShot.pointFlexVals.last!)
                glove.targetShot.middleFlexVals.append(glove.currentShot.middleFlexVals.last!)
                glove.targetShot.ringFlexVals.append(glove.currentShot.ringFlexVals.last!)
                glove.targetShot.pinkieFlexVals.append(glove.currentShot.pinkieFlexVals.last!)
                
            }
            
            if endBuffer == glove.numAfter {
                glove.shotEnded = false
                glove.shotBegan = false
                endBuffer = 0
                targetShotSet = true
                addTargetShot(shot: glove.targetShot)
                beginLookingForTargetShot = false
                disconnect()
            }
        } else if targetShotSet {
            
            if (glove.currentShot.zAccVals.last! < 50.0) && (!glove.shotBegan) {
                glove.shotBegan = true
                endBuffer = 0
            }
            
            //detect the end of the shot
            if (glove.shotBegan) && (glove.currentShot.zAccVals.last! > 50.0) {
                glove.shotEnded = true
                recordingShot = glove.currentShot
            }
            
            //there might be a better way to do it
            //get x number of points after the end
            if glove.shotEnded == true && endBuffer < glove.numAfter {
                
                endBuffer += 1
                recordingShot.xAccVals.append(glove.currentShot.xAccVals.last!)
                recordingShot.yAccVals.append(glove.currentShot.yAccVals.last!)
                recordingShot.zAccVals.append(glove.currentShot.zAccVals.last!)
                recordingShot.xGyroVals.append(glove.currentShot.xGyroVals.last!)
                recordingShot.yGyroVals.append(glove.currentShot.yGyroVals.last!)
                recordingShot.zGyroVals.append(glove.currentShot.zGyroVals.last!)
                recordingShot.pointFlexVals.append(glove.currentShot.pointFlexVals.last!)
                recordingShot.middleFlexVals.append(glove.currentShot.middleFlexVals.last!)
                recordingShot.ringFlexVals.append(glove.currentShot.ringFlexVals.last!)
                recordingShot.pinkieFlexVals.append(glove.currentShot.pinkieFlexVals.last!)
                
                
            }
            
            if endBuffer == glove.numAfter {
                glove.shotEnded = false
                glove.shotBegan = false
                recordingShot = glove.compareShots(shot: recordingShot)
                recordingShot.id = String(glove.shotHistory.count)
                endBuffer = 0
                
                if recordingShot.overallSimilarity > 60.0 && recordingShot.accSimilarity > 58 {
                    glove.shotHistory.append(recordingShot)
                    if recordingShot.overallSimilarity > 85 {
                        writeValue(val: 1)
                    } else {
                        writeValue(val: 2)
                    }
                    print("Shot recorded")
                } else {
                    print("\(recordingShot.overallSimilarity), \(recordingShot.flexSimilarity), \(recordingShot.gyroSimilarity), \(recordingShot.accSimilarity)")
                    print("Not a shot")
                }
            }
        }
    }


    //each time the glove sends new sensor values this is executed
    //append new values of the sensors to the arrays
    //call detectShot after every new value
    func appendSensorData(sensorValues: [Float]) {
        
        let pointFlexSensorValue = sensorValues[0]
        var xAccValue       = sensorValues[1]
        var yAccValue       = sensorValues[2]
        var zAccValue       = sensorValues[3]
        var xGyroValue      = sensorValues[4]
        var yGyroValue      = sensorValues[5]
        var zGyroValue      = sensorValues[6]
        let middleFlexSensorValue = sensorValues[7]
        let ringFlexSensorValue = sensorValues[8]
        let pinkieFlexSensorValue = sensorValues[9]
        
        let accValues = [xAccValue, yAccValue, zAccValue]
        let gyroValues = [xGyroValue, yGyroValue, zGyroValue]
        let newAccValues = accValues.map { (($0 + 4) / 8) * 100 }
        let newGyroValues = gyroValues.map { ((($0 + 2000) / 4000) * 100)}
        
        xAccValue       = newAccValues[0]
        yAccValue       = newAccValues[1]
        zAccValue       = newAccValues[2]
        xGyroValue      = newGyroValues[0]
        yGyroValue      = newGyroValues[1]
        zGyroValue      = newGyroValues[2]
        
        //if the number of data points is less than the amount we desire append new values
        if (glove.currentShot.pointFlexVals.count) < glove.dataSize {
            
            glove.currentShot.pointFlexVals.append(pointFlexSensorValue)
            glove.currentShot.xAccVals.append(xAccValue)
            glove.currentShot.yAccVals.append(yAccValue)
            glove.currentShot.zAccVals.append(zAccValue)
            glove.currentShot.xGyroVals.append(xGyroValue)
            glove.currentShot.yGyroVals.append(yGyroValue)
            glove.currentShot.zGyroVals.append(zGyroValue)
            glove.currentShot.middleFlexVals.append(middleFlexSensorValue)
            glove.currentShot.ringFlexVals.append(ringFlexSensorValue)
            glove.currentShot.pinkieFlexVals.append(pinkieFlexSensorValue)
        } else {
            
            //append new values
            glove.currentShot.pointFlexVals.append(pointFlexSensorValue)
            glove.currentShot.xAccVals.append(xAccValue)
            glove.currentShot.yAccVals.append(yAccValue)
            glove.currentShot.zAccVals.append(zAccValue)
            glove.currentShot.xGyroVals.append(xGyroValue)
            glove.currentShot.yGyroVals.append(yGyroValue)
            glove.currentShot.zGyroVals.append(zGyroValue)
            glove.currentShot.middleFlexVals.append(middleFlexSensorValue)
            glove.currentShot.ringFlexVals.append(ringFlexSensorValue)
            glove.currentShot.pinkieFlexVals.append(pinkieFlexSensorValue)

            
            //remove the first values
            glove.currentShot.pointFlexVals.remove(at: 0)
            glove.currentShot.xAccVals.remove(at: 0)
            glove.currentShot.yAccVals.remove(at: 0)
            glove.currentShot.zAccVals.remove(at: 0)
            glove.currentShot.xGyroVals.remove(at: 0)
            glove.currentShot.yGyroVals.remove(at: 0)
            glove.currentShot.zGyroVals.remove(at: 0)
            glove.currentShot.middleFlexVals.remove(at: 0)
            glove.currentShot.ringFlexVals.remove(at: 0)
            glove.currentShot.pinkieFlexVals.remove(at: 0)

        }
        recordShot()
    }
}

//MARK: Session Functions
extension GloveViewModel {
    
    func shotEntityToModel(shotEntity: ShotEntity) -> ShotModel {
        var shotModel: ShotModel = ShotModel()
        shotModel.id                = shotEntity.id!
        shotModel.selectedTab       = Int(shotEntity.selectedTab)
        shotModel.accSimilarity     = shotEntity.accSimilarity
        shotModel.gyroSimilarity    = shotEntity.gyroSimilarity
        shotModel.flexSimilarity    = shotEntity.flexSimilarity
        shotModel.overallSimilarity = shotEntity.overallSimilarity
        shotModel.pointFlexVals     = shotEntity.pointFlexVals!
        shotModel.middleFlexVals    = shotEntity.middleFlexVals!
        shotModel.ringFlexVals      = shotEntity.ringFlexVals!
        shotModel.pinkieFlexVals    = shotEntity.pinkieFlexVals!
        shotModel.wristFlexVals     = shotEntity.wristFlexVals!
        shotModel.xGyroVals         = shotEntity.xGyroVals!
        shotModel.yGyroVals         = shotEntity.yGyroVals!
        shotModel.zGyroVals         = shotEntity.zGyroVals!
        shotModel.xAccVals          = shotEntity.xAccVals!
        shotModel.yAccVals          = shotEntity.yAccVals!
        shotModel.zAccVals          = shotEntity.zAccVals!
        
        return shotModel
    }
    
    func setTargetShot(shotEntity: TargetEntity) -> ShotModel {
        var shotModel: ShotModel = ShotModel()
        shotModel.id                = shotEntity.id!
        shotModel.selectedTab       = Int(shotEntity.selectedTab)
        shotModel.accSimilarity     = shotEntity.accSimilarity
        shotModel.gyroSimilarity    = shotEntity.gyroSimilarity
        shotModel.flexSimilarity    = shotEntity.flexSimilarity
        shotModel.overallSimilarity = shotEntity.overallSimilarity
        shotModel.pointFlexVals     = shotEntity.pointFlexVals!
        shotModel.middleFlexVals    = shotEntity.middleFlexVals!
        shotModel.ringFlexVals      = shotEntity.ringFlexVals!
        shotModel.pinkieFlexVals    = shotEntity.pinkieFlexVals!
        shotModel.wristFlexVals     = shotEntity.wristFlexVals!
        shotModel.xGyroVals         = shotEntity.xGyroVals!
        shotModel.yGyroVals         = shotEntity.yGyroVals!
        shotModel.zGyroVals         = shotEntity.zGyroVals!
        shotModel.xAccVals          = shotEntity.xAccVals!
        shotModel.yAccVals          = shotEntity.yAccVals!
        shotModel.zAccVals          = shotEntity.zAccVals!
        
        return shotModel
    }
   
    func getSessions() {
        
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        
        do {
            sessions = try sessionManager.context.fetch(request)
        } catch {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func getTarget() {
        
        let request = NSFetchRequest<TargetEntity>(entityName: "TargetEntity")
        
        do {
            targetShotEntity = try sessionManager.context.fetch(request)
            
            for shot in targetShotEntity {

                glove.targetShot = setTargetShot(shotEntity: shot)

                targetShotSet = true
                beginLookingForTargetShot = false
            }
        } catch {
            print("Error fetching. \(error.localizedDescription)")
        }
    }
    
    func addTargetShot(shot: ShotModel) {
        print("Adding!")
        //delete the old target shot
        if targetShotEntity.count != 0 {
            print("Delete target")
            self.sessionManager.delete(targetShotEntity[0])
            targetShotEntity.removeAll()
            self.sessionManager.save()
        }
        //save a new target
        let shotEntity: TargetEntity = TargetEntity(context: sessionManager.context)
        
        shotEntity.id                = shot.id
        shotEntity.selectedTab       = Int16(shot.selectedTab)
        shotEntity.accSimilarity     = shot.accSimilarity
        shotEntity.gyroSimilarity    = shot.gyroSimilarity
        shotEntity.flexSimilarity    = shot.flexSimilarity
        shotEntity.overallSimilarity = shot.overallSimilarity
        shotEntity.pointFlexVals     = shot.pointFlexVals
        shotEntity.middleFlexVals    = shot.middleFlexVals
        shotEntity.ringFlexVals      = shot.ringFlexVals
        shotEntity.pinkieFlexVals    = shot.pinkieFlexVals
        shotEntity.wristFlexVals     = shot.wristFlexVals
        shotEntity.xGyroVals         = shot.xGyroVals
        shotEntity.yGyroVals         = shot.yGyroVals
        shotEntity.zGyroVals         = shot.zGyroVals
        shotEntity.xAccVals          = shot.xAccVals
        shotEntity.yAccVals          = shot.yAccVals
        shotEntity.zAccVals          = shot.zAccVals
        
        sessionManager.save()
        getTarget()
    }
    
    func addSession() {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, hh:mm:ss"
        
        let newSession = SessionEntity(context: sessionManager.context)
        
        newSession.name = dateFormatter.string(from: Date())
        
        for shot in glove.shotHistory {
            let newShot: ShotEntity = ShotEntity(context: sessionManager.context)
            newShot.id                = shot.id
            newShot.selectedTab       = Int16(shot.selectedTab)
            newShot.accSimilarity     = shot.accSimilarity
            newShot.gyroSimilarity    = shot.gyroSimilarity
            newShot.flexSimilarity    = shot.flexSimilarity
            newShot.overallSimilarity = shot.overallSimilarity
            newShot.pointFlexVals     = shot.pointFlexVals
            newShot.middleFlexVals    = shot.middleFlexVals
            newShot.ringFlexVals      = shot.ringFlexVals
            newShot.pinkieFlexVals    = shot.pinkieFlexVals
            newShot.wristFlexVals     = shot.wristFlexVals
            newShot.xGyroVals         = shot.xGyroVals
            newShot.yGyroVals         = shot.yGyroVals
            newShot.zGyroVals         = shot.zGyroVals
            newShot.xAccVals          = shot.xAccVals
            newShot.yAccVals          = shot.yAccVals
            newShot.zAccVals          = shot.zAccVals
            newSession.addToShots(newShot)
        }
        save()
    }
    
    func save() {
        sessions.removeAll()
        sessionShots.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.sessionManager.save()
            self.getSessions()
        }
       
    }
    
    func deleteSession(indexSet: IndexSet) {
        for index in indexSet {
            
            if let shots = sessions[index].shots?.allObjects as? [ShotEntity] {
                for shot in shots {
                    sessionManager.delete(shot)
                }
            }
            sessionManager.delete(sessions[index])
            save()
        }
    }
    
    func deleteSessionShot(session: SessionEntity, indexSet: IndexSet) {
        if let shots = session.shots?.allObjects as? [ShotEntity] {
            
            for index in indexSet {
                sessionManager.delete(shots[index])
            }
        }
        save()
    }
}

//MARK: BLE Functions
extension GloveViewModel {

    func writeValue(val: UInt8) {
                
        let data: [UInt8] = [val]
        guard let char = buzzerChar else {
            return
        }
        myPeripheral?.writeValue(Data(fromArray: data), for: char, type: .withResponse)
    }
    func startScanning() {
        
        //scan for the glove using the known service UUID that it should have
        myCentral.scanForPeripherals(withServices: [CBUUID(string: serviceUUID)], options: nil)
        print("Started Scanning")
    }
    
    func disconnect() {
        if myPeripheral != nil {
            myCentral.cancelPeripheralConnection(myPeripheral!)
        }
    }
}

//MARK: Central Manager Delegate
extension GloveViewModel {
    
    //will execute when the bluetooth on the phone is turned off or on
    //if on connect to the peripheral with the matching serviceUUID
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
         if central.state == .poweredOn {
             bluetoothOn = true
         }
         else {
             bluetoothOn = false
         }
    }
    
    //is called is the scanning process found a peripheral that matches our needs
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Connect to the newly discovered device
        myPeripheral = peripheral
        myPeripheral?.delegate = self
        print("Connecting to \(peripheral.name ?? "Unknown")")
        bluetoothDevices.append(peripheral) //so that i can be displayed in the pairing view
        central.connect(peripheral, options: nil)
        // Stop scanning for devices
        self.myCentral.stopScan()
    }
    
    //is called when the central connectted successfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        connectionStatus = true
        //print(connectionStatus)
        myPeripheral?.discoverServices([CBUUID(string: serviceUUID)])
    
    }
    
    //is called when the central connectted successfully
    func centralManager(_ central: CBCentralManager, didDisconnect peripheral: CBPeripheral) {
        
        connectionStatus = false
        //print(connectionStatus)
    }
}

//MARK: Peripheral Delegate
extension GloveViewModel {
    
    //is called when myPeripheral executes discoverServices
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        let service = myPeripheral?.services?.first
        myPeripheral?.discoverCharacteristics([CBUUID(string: gloveSensorCharUUID), CBUUID(string: buzzerCharUUID)], for: service!)
    }
    
    //is called when myPeripheral.discoverCharacteristics is called
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let chars = service.characteristics {
            for c in chars {
                //print(c)
                if (c.uuid == CBUUID(string: gloveSensorCharUUID)) {

                    flexSensorChar = c
                    myPeripheral?.setNotifyValue(true, for: flexSensorChar!)
                }
                if c.uuid == CBUUID(string: buzzerCharUUID) {
                    buzzerChar = c
                }
            }
        }
    }
    
    //is called when a peripheral enable notifaction for characteristic.
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        // not sure if any code is needed in here
    }
    
    //each time one of the characteristics is notified that a value is changed this is executed
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic.uuid == CBUUID(string: gloveSensorCharUUID) {
            guard let value = characteristic.value else {
                    return
            }
            guard value.count == 40  else {
                return
            }
            
            let byteArray: [UInt8] = [UInt8](value)
            let data: Data = Data(bytes: byteArray, count: 40)
            let floatsFromData = data.toArray(type: Float.self)
            
            appendSensorData(sensorValues: floatsFromData)
            //print(floatsFromData)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
}

//MARK: Helper Extensions
//converting byte array to float array
extension Data {

    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}



