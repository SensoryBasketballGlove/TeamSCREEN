//
//  PairingView.swift
//  S.C.R.E.E.N
//
//  Created by Bogdan on 11/3/21.
//

import SwiftUI

struct PairGloveView: View {
   // @Environment(\.presentationMode) var presentationMode
    @ObservedObject var gloveViewModel: GloveViewModel
    
    @State var showConnectingStatus: Bool = false
    @State var connectedStatus: String
    @State var selectedRow: String
    var body: some View {
        
            
            
        VStack {
            
            HStack {
                Spacer()
                Spacer()
                Text("S.C.R.E.E.N")
                    .foregroundColor(.white)
                    .font(.title)
                Spacer()
                    
                Spacer()
            }
            MyDivider(width: 3)
        
            List {
                
                ForEach(gloveViewModel.bluetoothDevices, id: \.self) { device in
                    
                    Text(device.name ?? "No Name")
                    .padding()
                    .font(.title)
                    .foregroundColor(.black)
                    .lineLimit(1).fixedSize(horizontal: false, vertical: true)
                    .onTapGesture {
                        gloveViewModel.myCentral.connect(device, options: nil)
                        //print("attempting to connect the device \(device.name!)")
                        selectedRow = device.name ?? "No Name"
                        
                    }
                    .listRowBackground(selectedRow == device.name! ? Color("AccentColor") : Color(.gray))
                
                }
                .listRowBackground(Color("Background"))
                
                
            }
            
            Spacer()
        }.background(background)
    }
    
    func connectionRequested() {
        
        showConnectingStatus = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.showConnectingStatus = false
            
        })
        
    }
}

struct PairGloveView_Previews: PreviewProvider {
    static var previews: some View {
        
        PairGloveView(gloveViewModel: GloveViewModel(), connectedStatus: "",  selectedRow: "")
    }
}


extension PairGloveView {
    
    private var background: some View {
        
        Color(.gray)
            .ignoresSafeArea()
    }
}
