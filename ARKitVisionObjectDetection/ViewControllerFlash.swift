//
//  ViewControllerFlash.swift
//  ARKitVisionObjectDetection
//
//  Created by Davide Garavaso on 29/12/20.
//  Copyright © 2020 Rozengain. All rights reserved.
//

import ARKit
import RealityKit

extension ViewController {
    
    /*Funzione che accende la torcia dopo che si è verificato l'evento sul bottone.
     Questa funzione può risultare utile nei momenti in cui vi è poca illuminazione
     in quanto in assenza di luce, ma con la torcia accesa l'app riesce comunque a
     riconoscere loggetto*/
    func flash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
        else {return}

        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                    if on == true {
                        device.torchMode = .on
                    } else {
                        device.torchMode = .off
                    }
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used")
                }
        } else {
                print("Torch is not available")
        }
    }
    
    
    //Funzione che richiama la funzione della torcia
    @IBAction func didTouchFlashButton(_ sender: Any) {
        if flashCount % 2 == 0{
            flash(on: true)
        }
        else{
            flash(on: false)
        }
        flashCount = flashCount+1
        print(flashCount)
    }
    
}
