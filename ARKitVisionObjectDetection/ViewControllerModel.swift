//
//  ViewControllerModel.swift
//  ARKitVisionObjectDetection
//
//  Created by Davide Garavaso on 29/12/20.
//  Copyright © 2020 Rozengain. All rights reserved.
//

import ARKit
import RealityKit

extension ViewController {
 
    @IBAction func didTouchAddButton(_ sender: Any) {
        //Controllo che verifica che l'utente abbia rilevato almeno un oggetto
        if(modelCount == 0 && modelName == "Nessun oggetto rilevato"){
            //Messaggio di warning in caso l'utente non abbia ancora rilevato un oggetto
            let title = "Warning: No object detected"
            let message = "Detect a real world object to add its 3d model"
            self.showAlert(title: title, message: message, showCancel: false)
        }
        
        //Se il modello 3d non è ancora stato caricato ed ho rilevato un ogetto posso andare a caricare il suo modello 3d nella scena
        else if(modelCount == 0 && modelName != "Nessun oggetto rilevato"){
            
            modelCount += 1
            print("Model from   art.scnassets/" + modelName + "/" + modelName + ".usdz LOADED!")
            modelScene = SCNScene(named: "art.scnassets/" + modelName + "/" + modelName + ".usdz")
            
            modelNode = modelScene!.rootNode.childNode(withName: modelName, recursively: true)
 
            modelNode!.position = SCNVector3(scaleModelX, scaleModelY, scaleModelZ)
            
            modelFlattenedNode = modelNode!.flattenedClone()
            sceneView.scene.rootNode.addChildNode(modelFlattenedNode!)
            explodeReady = true
            
           
            
            //Chiamata della funzione Message
            MessageLabel.text = Message(this: "model")
            
            //Messaggio di attivazione gesture
            showMessageGesture(message: "s/m")
    
        }
        //Controllo che interviene quando l'utente tenta di aggiungere un nuovo modello nonostante esso sia già stato caricato nella scena
        else if(modelCount > 0 && modelName != "Nessun oggetto rilevato"){
            //Messaggio di warning poichè il modello è già stato aggiunto
            let title = "Warning: \(modelName)"
            let message = "The 3d model has already been loaded into the scene"
            self.showAlert(title: title, message: message, showCancel: false)
            
        }
    }

}
