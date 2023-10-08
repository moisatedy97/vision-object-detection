//
//  Extensions.swift
//  ARKitVisionObjectDetection
//
//  Created by Andrea Giachetti on 10/03/21.
//  Copyright © 2021 Rozengain. All rights reserved.
//

import ARKit
import UIKit
import RealityKit

extension UIView {
    //funzione che aggiunge diverse funzionalità alle celle del menù
    func addConstraintWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension ViewController {
    //funzione che aggiunge in un array i nomi dei componenti del rispettivo modelName riconosciuto
    func addComponentNamesToArray(modelName: String){
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent("art.scnassets/" + modelName)
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            let usdzFiles = contents.filter{$0.pathExtension == "usdz"}
            let usdzFileNames = usdzFiles.map{ $0.deletingPathExtension().lastPathComponent }
            componentsArray = []
            
            for item in usdzFileNames{
                if(item != modelName){
                    componentsArray.append(Setting(name: item))
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    //funzione che aggiungo il rispettivo componente alla scena
    func addComponent(componentName: String){
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent("art.scnassets/" + modelName)
        let i = 0.5
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            let usdzFiles = contents.filter{$0.pathExtension == "usdz"}
            let usdzFileNames = usdzFiles.map{ $0.deletingPathExtension().lastPathComponent }
            
            if(usdzFileNames.contains(componentName)){
                NumberOfComponents += 1
                let componentScene = SCNScene(named: "art.scnassets/" + modelName + "/" + componentName + ".usdz")
                let component = componentScene?.rootNode.childNode(withName: componentName, recursively: true)
                listOfAddedComponents.append(component!)
                component?.name = componentName
                if(NumberOfComponents == 1){
                    component?.position = SCNVector3(scaleModelX - Float(i), scaleModelY, scaleModelZ)
                    componentPosition = component?.position
                } else if(NumberOfComponents > 1){
                    componentPosition.x -= Float(i)
                    component?.position = componentPosition
                }
                sceneView.scene.rootNode.addChildNode(component!)
            }
        } catch let error as NSError {
            print(error)
        }
    }

    //funzione che ritorna i nomi delle cartelle dei nostri oggetti da riconoscere
    func getNameFolders() -> [String]{
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent("art.scnassets/")
        var contentsNames: [String] = []
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey], options: .skipsHiddenFiles)
            
            contentsNames = contents.map{ $0.deletingPathExtension().lastPathComponent}

        } catch let error as NSError {
            print(error)
        }
        return contentsNames
    }
}
