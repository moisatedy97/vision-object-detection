import ARKit
import RealityKit

extension ViewController {

    //Gestore dell'interazione
    //Esso contiene la dichiarazione di tutti i movimenti disponibili
    func GestureRecognizer(){
        //Scale
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target:self, action: #selector(scale))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)

        //Move
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(move))
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
        
        //Rotate
        let rotateGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(rotate))
        self.sceneView.addGestureRecognizer(rotateGestureRecognizer)
        
        //Remove object
        let removeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(remove))
        removeGestureRecognizer.numberOfTapsRequired = 2
        self.sceneView.addGestureRecognizer(removeGestureRecognizer)
    }
    
    //Funzione che implementa lo scale (scale fatto con 2 dita)
    @objc func scale(recognizer: UIPinchGestureRecognizer){
        guard let recognizerView = recognizer.view as? ARSCNView else { return }
        
        let touch = recognizer.location(in: recognizerView)
        let hitTestResults = self.sceneView.hitTest(touch, options: nil)
        
        if let hitTest = hitTestResults.first {
            let objNode = hitTest.node
            let pinchScaleX = Float(recognizer.scale) * objNode.scale.x
            let pinchScaleY = Float(recognizer.scale) * objNode.scale.y
            let pinchScaleZ = Float(recognizer.scale) * objNode.scale.z
            
            objNode.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
            recognizer.scale = 1
        }
    }
    
    @objc func move(recognizer: UILongPressGestureRecognizer){
        //Se press = false posso accedere alla funzione move
        if(press == false){
            switch recognizer.state {
                case .began:
                    let location = recognizer.location(in: sceneView)
                    
                    guard let hitNodeResult = sceneView.hitTest(location, options: nil).first else { return } //Test per capire quale oggetto 3d utilizzo -> se non sto toccando un oggetto 3d faccio un return e non svolgo il resto della funzioneù
                        lastPanPosition = hitNodeResult.worldCoordinates
                        gestureModelNode = hitNodeResult.node
                        //projectPoint: da 3 dimensioni a 2 dimensioni
                        //unprojectPoint: da 2 dimensioni a 3 dimensioni
                        zPosition = CGFloat(sceneView.projectPoint(lastPanPosition!).z) //Ricavo la z
                case .changed:
                    
                    //Controllo quale tipo di oggetto sto andando a muovere. Se mi sto interfacciando con un piano i movimenti vengono bloccati
                    if(gestureModelNode?.name?.hasPrefix("planeNode") == false){
                        guard lastPanPosition != nil, gestureModelNode != nil, zPosition != nil else {return}
                        let location = recognizer.location(in: sceneView)
                        
                        //gesturModelNode viene mosso e worldTouchPosition è la nuova posizione
                        let worldTouchPosition = sceneView.unprojectPoint(SCNVector3(location.x, location.y, zPosition!))
                        
                        //Viene calcolato il movimento dell'oggetto nel mondo
                        let movementVector =
                            SCNVector3(worldTouchPosition.x - lastPanPosition!.x,
                                       worldTouchPosition.y - lastPanPosition!.y,
                                       worldTouchPosition.z - lastPanPosition!.z)
                        

                        
                        /*Se devo muovere un oggetto modificato con Blender considero la differenza degli assi
                        var movementVector =
                            SCNVector3(worldTouchPosition.x - lastPanPosition!.x,
                                       worldTouchPosition.z - lastPanPosition!.z,
                                       lastPanPosition!.y - worldTouchPosition.y)*/

                        
                        //gestureModelNode viene traslato nella nuova posizione
                        gestureModelNode?.localTranslate(by: movementVector)
                        //lastPanPosizion = worldTouchPosition in quanto quest'ultima è l'ultima posizione in cui si trova gestureModelNode
                        self.lastPanPosition = worldTouchPosition
                    }
                    
                case .ended:
                    //Nel momento in cui il movimento finisce resetto i valori
                    //Verranno riempiti nel momento in cui inizia di nuovo il movimento
                    (lastPanPosition, gestureModelNode, zPosition) = (nil, nil, nil)
                default:
                    return
            }
        }
    }
    
    //Funzione che implementa la rotazione
    @objc func rotate(recognizer: UIPanGestureRecognizer){
            if recognizer.state == .changed {
                guard let recognizerView = recognizer.view as? ARSCNView else {
                    return
                }
                
                let touch = recognizer.location(in: recognizerView)
                let translation = recognizer.translation(in: sceneView)
                let hitTestResults = self.sceneView.hitTest(touch, options: nil)
                
                if let hitTest = hitTestResults.first {
                    let objNode = hitTest.node
                    //ass x
                    self.newAngleX = Float(translation.y) * (Float)(Double.pi)/180
                    self.newAngleX += self.currentAngleX
                    objNode.eulerAngles.x = self.newAngleX
                    //asse y
                    self.newAngleY = Float(translation.x) * (Float)(Double.pi)/180
                    self.newAngleY += self.currentAngleY
                    objNode.eulerAngles.y = self.newAngleY
                }
            } else if recognizer.state == .ended {
                self.currentAngleX = self.newAngleX
                self.currentAngleY = self.newAngleY
            }
    }
    
    //Funzione che rimuove un oggetto dalla scena
    @objc func remove(recognizer: UIPanGestureRecognizer){
                guard let sceneView = recognizer.view as? ARSCNView else {
                    return
                }
                
                let touch = recognizer.location(in: sceneView)
                let hitTestResults = self.sceneView.hitTest(touch, options: nil)
                
                if let hitTest = hitTestResults.first {
                    let objNode = hitTest.node
                    if(objNode.name == modelName){
                        objNode.removeFromParentNode()
                        
                        for item in listOfAddedComponents{
                            item.removeFromParentNode()
                        }
                        listOfAddedComponents = []

                        resetAll()
                    } else {
                        objNode.removeFromParentNode()
                        NumberOfComponents -= 1
                    }
                }
    }
}
