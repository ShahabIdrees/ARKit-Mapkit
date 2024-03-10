//
//  Model.swift
//  Boris-Shahab
//
//  Created by Shahab Idrees on 10/03/2024.
//

import UIKit
import RealityKit
import Combine
import CoreLocation

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    var coordinate: CLLocationCoordinate2D
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                //For error handling
                print ("DEBUG: unable to load model entity named: \(self.modelName)")
            }, receiveValue: { modelEntity in
                //Get our Model Entity here
                self.modelEntity = modelEntity
                print ("DEBUG: Successfully loaded model entity named: \(self.modelName)")

            })
    }
}
