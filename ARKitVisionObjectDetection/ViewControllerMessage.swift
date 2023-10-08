//
//  Messagge.swift
//  ARKitVisionObjectDetection
//
//  Created by Davide Garavaso on 13/01/21.
//  Copyright © 2021 Rozengain. All rights reserved.
//

import ARKit
import RealityKit

extension ViewController {
    
    //Inizializzazione MessageLabel
    func initMessageLabel(){
        MessageLabel.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.MessageLabel.isHidden = false
        }
        
        MessageLabel.alpha = 0.8
        MessageLabel.layer.cornerRadius = 10
        MessageLabel.layer.masksToBounds = true
        text = "        " + "Searching a real world object..."
        MessageLabel.text = text
        MessageLabel.font = UIFont.systemFont(ofSize: 17)
        MessageLabel.textAlignment = .left
        MessageLabel.textColor = .white
        MessageLabel.numberOfLines = 0
        MessageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping

        MessageLabel.frame = CGRect(x:sceneView.center.x+55, y:44, width:306,
                                   height: dynamicHeight(text: MessageLabel.text,
                                                         font: MessageLabel.font,
                                                         width: 306))
    }
    
    
    //Inizializzazione ObjectLabel
    //Visibile solo quando viene riconosciuto un oggetto
    //Creata separatamente in quanto chiamando la funzione dynamicHeight all'interno di Messagge, che era stata a sua volta chiamata all'interno della funzione renderer del file principale, avrei avuto problemi con le thread (la main thread è già occupata per il riconoscimento dell'oggetto)
    func initObjectLabel(){
        ObjectLabel.isHidden = true
        ObjectLabel.alpha = 0.8
        ObjectLabel.layer.cornerRadius = 10
        ObjectLabel.layer.masksToBounds = true
        
        text = ""
        ObjectLabel.text = text
        ObjectLabel.font = UIFont.systemFont(ofSize: 17)
        ObjectLabel.textAlignment = .left
        ObjectLabel.textColor = .white
        ObjectLabel.numberOfLines = 0
        ObjectLabel.lineBreakMode = NSLineBreakMode.byWordWrapping

        ObjectLabel.frame=CGRect(x:sceneView.center.x+55,y:44,width:306, height:61)
    }
    
    //ScaleMoveLabel e RotateLabel sono praticamente la stessa Label solo che con testo differente. Sono però create in modo separato perchè fare la modifica del testo in modo dinamico risultava problematico in certe situazioni. Per un utente standard esso non crea alcun problema, ma per un utente che utilizza in modo molto rapido l'app si sarebbe trovato di fronte a un inconveniente. La ScaleMoveLabel è pensata per scomparire dopo 2 secondi dalla sua attivazione mentre la RotateLabel è pensata per rimanere visibile fino a quando il movimento di rotazione non sia completamente concluso. Nel caso in cui le 2 UILabel fossero una sola e l'utente attivasse la rotazione nei primi 2 secondi in cui è apparso il modello 3d il testo della rotazione scomparirebbe rispettando il fatto che la ScaleMoveLabel dopo 2 secondi scompare. Per questo motivo sono state fatte 2 UILabel.
    //Inizializzazione ScaleMoveLabel
    func initScaleMoveLabel(){
        ScaleMoveLabel.isHidden = true
        ScaleMoveLabel.alpha = 0.8
        
        ScaleMoveLabel.text = "Scale/Move enabled..."
        ScaleMoveLabel.font = UIFont.systemFont(ofSize: 17)
        ScaleMoveLabel.textAlignment = .center
        ScaleMoveLabel.textColor = .white
        ScaleMoveLabel.layer.cornerRadius = ScaleMoveLabel.bounds.width / 2
        ScaleMoveLabel.numberOfLines = 0
    }
    
    
    //Inizializzazione RotateLabel
    func initRotateLabel(){
        RotateLabel.isHidden = true
        RotateLabel.alpha = 0.8
        
        RotateLabel.text = "Rotation enabled..."
        RotateLabel.font = UIFont.systemFont(ofSize: 17)
        RotateLabel.textAlignment = .center
        RotateLabel.textColor = .white
        RotateLabel.layer.cornerRadius = RotateLabel.bounds.width / 2
        RotateLabel.numberOfLines = 0
    }
    
    
    //Funzione che calcola l'altezza dinamica della MessageLabel
    func dynamicHeight(text: String?, font: UIFont, width: CGFloat) -> CGFloat{
        
        let label = UILabel(frame: CGRect(x:0, y:0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.text = text
        label.font = font
        label.numberOfLines = 0
        label.sizeToFit()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping

        return (label.frame.height + 20)
    }
    

    //Funzione Messagge che ritorna il testo corretto 
    func Message(this: String) -> String{
        switch this{
        case "renderer":
            MessageObjectPass = true
            ObjectLabel.isHidden = false
            MessageLabel.isHidden = true
            text = " Object detection was succesfully\n Object detected: \(modelName)"
            break
            
            case "model":
                MessageObjectPass = false
                ObjectLabel.isHidden = true
                MessageLabel.isHidden = false
                
                text = " Model loaded: \(modelName)\n\n 3d model features:\n   • Width: \(scaleModelX*10) cm\n   • Height: \(scaleModelY*10) cm\n   • Depth: \(scaleModelZ*10) cm"
                break
                
            case "clear":
                MessageObjectPass = false
                ObjectLabel.isHidden = true
                MessageLabel.isHidden = false
                
                if(modelName != "Nessun oggetto rilevato"){
                    text = " Searching a real world object...\n\n" +  " Last object stored: \(modelName)\n   • Width: \(scaleModelX*10) cm\n   • Height: \(scaleModelY*10) cm\n   • Depth: \(scaleModelZ*10) cm"
                }
                else{ text = "Searching a real world object..." }
                break
                
            default:
                break
        }
        
        if(this != "renderer"){
            //Alla fine dello switch ho il testo da mostrare all'utente corretto e a questo punto posso calcolare l'altezza della MessageLabel
            MessageLabel.frame = CGRect(x:sceneView.center.x - 153, y:44, width:306,height: dynamicHeight(text: text,
                                                font: MessageLabel.font,
                                                width: 306))
        }
        //Ritorno il testo
        return text
    }
    
    
    //Funzione che segnala all'utente l'attivazione di scale/move/rotate
    func showMessageGesture(message: String){
        switch message{
            case "s/m":
                ScaleMoveLabel.isHidden = false
                RotateLabel.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.ScaleMoveLabel.isHidden = true
                }
            case "r":
                ScaleMoveLabel.isHidden = true
                RotateLabel.isHidden = false

        default:
            break
        }
    }
}
