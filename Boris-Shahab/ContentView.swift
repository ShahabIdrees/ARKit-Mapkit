//
//  ContentView.swift
//  Boris-Shahab
//
//  Created by Shahab Idrees on 09/03/2024.
//

import SwiftUI
import RealityKit
import MapKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    var models: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try?
                filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        var availableModels: [Model] = []
        for filename in files where filename.hasSuffix("usdz"){
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
        
        return availableModels
    }()
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
//            MapView()
//                .edgesIgnoringSafeArea(.all)
                
            if isPlacementEnabled {
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            }
            else{
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
            
        }
    }
}


struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .standard // Set map type to standard
        mapView.showsBuildings = true // Enable 3D buildings if needed
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the map view if needed
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
        arView.session.run( config)
        let focusSquare = FocusEntity(on: arView, focus: .classic)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedForPlacement {
            
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: Adding model to scene \(self.modelConfirmedForPlacement!)")
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            }
            else{
                print("DEBUG: unable to load modelEntity for model to scene \(model.modelName)")
            }
//            let fileName = model + ".usdz"
//            let modelEntity = try!
//                ModelEntity.loadModel(named: fileName)
            
            
            
            
            DispatchQueue.main.async{
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

//class customARView: ARView {
//        required init(frame frameRect: CGRect) {
//        super.init(frame: frameRect)
//        focusSquare.viewDelegate = self
//        focusSquare.delegate = self
//    }
//    
//    @MainActor required dynamic init?(coder decoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    var body: some View {
        
        HStack(spacing: 20){
            Button(action: {
                print("Model placement canceled")
                self.resetPlacementParameters()
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .tint(.red)
                    .font(.title)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(30)
                    .padding(20)
                
            }
            )
            
            Button(action: {
                print("Model placement verified")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
            }, label: {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .tint(.green)
                    .font(.title)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(30)
                    .padding(20)
                
            }
            )
        }
    }
    func resetPlacementParameters(){
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}


struct ModelPickerView: View{
    @Binding var isPlacementEnabled : Bool
    @Binding var selectedModel : Model?
    var models: [Model]
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 30){
                ForEach(0..<self.models.count){
                    index in
                    
                    Button(action: {
                        print(self.models[index].modelName)
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }, label: {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1 , contentMode: .fit)
                            .cornerRadius(12)
                    })
                }
            }
            .padding(10)
        }

    }
}

#Preview {
    ContentView()
}
