//
//  ViewControllerReset.swift
//  ARKitVisionObjectDetection
//
//  Created by Davide Garavaso on 29/12/20.
//  Copyright © 2020 Rozengain. All rights reserved.
//

import ARKit
import RealityKit

extension ViewController {
    
    //Funzione che pulisce la scena
    /* La funzione resetTracking si occupa di inizializzare una nuova configurazione.
    Al primo avvio essa sarà pulita e non avrà Anchors, ma dopo il riconoscimento di alcuni oggetti ci saranno dei riferimenti che vengono puliti dalle opzioni di configurazione*/
    func resetTracking(){
        //Rimuovo i legami precedentemente esistenti
        //self.sceneView.session.pause() //La scena è in pausa-> stop
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        //Pulizia scena generale
        //Nei parametri options è possibile resettare la scena aggiungendo .resetTracking
        self.sceneView.session.run(configuration, options: [.removeExistingAnchors])

        //Contatori da azzerare
        modelCount = 0
        NumberOfComponents = 0
        //Resetto i movimenti
        RotateLabel.isHidden = true
        explodeResetButton.isHidden = true
        explodeReady = false
        press = false
        boolModel = true
    }
        
    func resetAll(){
        resetTracking()
        let title = "Clean"
        let message = "Now you can detect another object"
        //let buttonTitle = "Restart Scan"
        showAlert(title: title, message: message, showCancel: false)
        print("Scena resettata")
        
        //Chiamata della funzione Message
        MessageLabel.text = Message(this: "clear")
    }
    
    /*Funzione che richiama la funzione resetTracking se viene toccato il bottone associato*/
    @IBAction func didTouchClearButton(_ sender: UIButton) {
        resetAll()
    }

    
}
