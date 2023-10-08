import ARKit
import RealityKit

extension ViewController {
 
    @IBAction func didTouchExplodeButton(_ sender: Any) {
        if(explodeReady == true){
            if(modelCount == 1) {
                explodeResetButton.isHidden = false
                //let modelPosition = modelFlattenedNode!.position
                let modelScale = modelFlattenedNode!.scale
                //let modelOrientation = modelFlattenedNode!.orientation
                modelFlattenedNode!.removeFromParentNode()
                sceneView.scene.rootNode.addChildNode(modelNode!)
                //modelNode!.position = modelPosition
                modelNode!.scale = modelScale
                //modelNode!.orientation = modelOrientation
                
                recursive(array: modelNode!.childNode(withName: "PARTS", recursively: true)!.childNodes)
                for node in arrayChildNodes{
                    let min = node.boundingBox.min
                    let max = node.boundingBox.max
                    let width = CGFloat(max.x - min.x)
                    let heigth = CGFloat(max.y - min.y)
                    //let length = CGFloat(max.z - min.z)
                    var difX = (modelNode!.position.x - node.position.x) + Float(width/8)
                    if(checkIfLastIsPositiveOrNegative.isEmpty){
                    } else {
                        if(checkIfLastIsPositiveOrNegative.last! < 0.0){
                            if(difX < 0.0){
                                difX = difX * -1.0
                            }
                        } else if(checkIfLastIsPositiveOrNegative.last! > 0.0) {
                            if(difX > 0.0){
                                difX = difX * -1.0
                            }
                        }
                    }
                    var difZ = (modelNode!.position.z - node.position.z) + Float(heigth/8)
                    if(difZ < modelNode!.position.z){
                        difZ = difZ * -1
                    }
                    let nodeFinalPosition = SCNVector3(x: node.position.x + difX, y: node.position.y, z: node.position.z + difZ)
                    let moveAction = SCNAction.move(to: nodeFinalPosition, duration: 0.5)
                    checkIfLastIsPositiveOrNegative.append(difX)
                    dictionaryForNodeExplosion.updateValue(nodeFinalPosition, forKey: node)
                    
                    node.runAction(moveAction)
                }
                explodeReady = false
            }
        } else {
            if(!dictionaryForNodeExplosion.isEmpty){
                explodeResetButton.isHidden = false
                let modelPosition = modelFlattenedNode!.position
                let modelScale = modelFlattenedNode!.scale
                //let modelOrientation = modelFlattenedNode!.orientation
                modelFlattenedNode!.removeFromParentNode()
                sceneView.scene.rootNode.addChildNode(modelNode!)
                modelNode!.position = modelPosition
                modelNode!.scale = modelScale
                //modelNode!.orientation = modelOrientation
                
                for item in dictionaryForNodeExplosion.keys {
                    let moveAction = SCNAction.move(to: dictionaryForNodeExplosion[item]!, duration: 0.5)
                    item.runAction(moveAction)
                }
            }
        }
        
    }
    
    @IBAction func didTouchExplodeResetButton(_ sender: Any) {
        explodeResetButton.isHidden = true
        let modelPosition = modelNode!.position
        let modelScale = modelNode!.scale
        //let modelOrientation = modelNode!.orientation
        modelNode!.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(modelFlattenedNode!)
        modelFlattenedNode!.position = modelPosition
        modelFlattenedNode!.scale = modelScale
        
    }
    
    func recursive(array: Array<SCNNode>) {
        if(!array.isEmpty){
            arrayChildNodes += array
            recursive(array: temp(array: array))
        }
    }
    
    func temp(array: Array<SCNNode>) -> Array<SCNNode>{
        var temp: Array<SCNNode> = []
            for node in array{
                if(!node.childNodes.isEmpty){
                    temp += node.childNodes
                }
                    
            }
        return temp
    }

}

