//
//  ViewControllerComponents.swift
//  ARKitVisionObjectDetection
//
//  Created by Davide Garavaso on 22/12/20.
//  Copyright © 2020 Rozengain. All rights reserved.
//

import ARKit
import RealityKit

extension ViewController {
    //Funzione che prende il nome dell'oggetto riconosciuto e chiama la relativa funzione
    
    @IBAction func didTouchAddComponentsButton(_ sender: Any) {
        
        if (getNameFolders().contains(modelName)) {
            addComponentNamesToArray(modelName: modelName)
            
            if(!componentsArray.isEmpty){
                collectionView.dataSource = self
                collectionView.delegate = self
                collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
                
                //creazione del menù con animazione
                if let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) {
                    
                    blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
                    
                    blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
                    
                    window.addSubview(blackView)
                    window.addSubview(collectionView)
                    
                    let height: CGFloat = CGFloat(componentsArray.count) * cellHeight
                    let y = window.frame.height - height
                    collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
                    blackView.frame = window.frame
                    blackView.alpha = 0
                    
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.blackView.alpha = 1
                        self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                    }, completion: nil)
                }
            } else {
                let title = "Warning"
                let message = "No components detected for " + modelName
                self.showAlert(title: title, message: message, showCancel: false)
            }
        } else {
            //Controllo che indica che non è ancora stato rilevato alcun oggetto
            let title = "Warning: No object detected"
            let message = "Detect a real world object to add its components"
            self.showAlert(title: title, message: message, showCancel: false)
        }
    }
    
    //funzione che si occupa della sparizione del menù
    @objc func handleDismiss(){
        UIView.animate(withDuration: 0.5, animations: {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        })
    }
    
    //funzione che si prende il numero dei componenti e crea le celle del menù
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return componentsArray.count
    }
    
    //funzione che crea il contenuto delle celle del menù
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingCell

            let setting = componentsArray[indexPath.item]
            cell.setting = setting
            return cell
    }
    
    //funzione fissa l'altezza delle celle
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //funzione che da azioni alle rispettive celle del menù
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = componentsArray[indexPath.item]
        addComponent(componentName: setting.name)
    }
}
