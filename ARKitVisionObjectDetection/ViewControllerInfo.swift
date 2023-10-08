//
//  ViewControllerInfo.swift
//  ARKitVisionObjectDetection
//
//  Created by Davide Garavaso on 19/01/21.
//  Copyright © 2021 Rozengain. All rights reserved.
//

import ARKit
import RealityKit

extension ViewController: URLSessionDelegate {

    /*Nel momento in cui il tasto infoButton viene cliccato esce una pagina che riporta tutte le informazioni che ha disponibili l'applicazione sull'oggetto rilevato*/
    @IBAction func didTouchInfoButton(_ sender: UIButton) {
        if(modelName == "Nessun oggetto rilevato"){
            InfoView.text = "Detect a real world object to see his information..."
        }
        else{
            //Chiamata della funzione info
            loadInfo()
        }

        InfoView.alpha = 0.9
        if infoCount % 2 == 0{
            InfoView.isHidden = false
            MessageLabel.isHidden = true
            ObjectLabel.isHidden = true
        }
        else{
            InfoView.isHidden = true
            //A seconda di quale UiLabel è attiva decido quale mostrare
            if(MessageObjectPass == false){
                MessageLabel.isHidden = false
            }
            else{ ObjectLabel.isHidden = false }
        }
        infoCount = infoCount+1
    }


    //Funzione che quando chiamata riempie la view
    //Questa funzione viene chiamata quando l'utente si interfaccia con l'infoView e non quando l'oggetto viene riconosciuto nella funzione renderer perchè questo causerebbe un errore a run time. Dato che la funzione renderer si sta già occupando di interfacciarsi con il mondo reale tiene occupato la main thread che non può anche allo stesso tempo effettuare una modifica grafica alla InfoView. La view viene quindi modificata successivamente quando l'utente ne ha bisogno.
    func loadInfo(){
        if(infoBool){
            var result = infoVariableToDisplay + ":\n\n"
            for (variable, values) in infoDictionary {
                result += variable + ": " + values + "\n\n"
            }
            InfoView.text =  result
        } else {
            InfoView.text = "No info available for this object"
        }
        
    }
    
    public func httpRequest(obj: String){
        if(obj != "No info available for this object"){
            
            let authentification = "?auth=ab03af819ac648d1bc7e2bb3b40c6e14&values=1"
            let baseURL = "https://157.27.102.66:32767/" + obj
            //create the url
            let url = URL(string:  baseURL + authentification)! //change the url

            //create the session object
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            
            //now create the URLRequest object using the url object
            let request = URLRequest(url: url)

            //create dataTask using the session object to send data to the server
            let task = session.dataTask(with: request as URLRequest, completionHandler: { [self] data, response, error in

               guard error == nil else {
                   return
               }

               guard let data = data else {
                   return
               }
                
            do {
                 //creazione dell'oggetto json [String: [String: [[String: Any]]]]
                if let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: [String: [[String: Any]]]] {
                    infoVariableToDisplay = ""
                    infoDictionary = [:]
                    for item in json{
                        infoVariableToDisplay = item.key
                        for item2 in item.value{
                            for item3 in item2.value{
                                for item4 in item3{
                                    if(item4.key == "value"){
                                        infoDictionary[item2.key] = String(describing: item4.value)
                                    }
                                }
                            }
                        }
                    }
                }

                infoBool = true //booleano che ci dice quando la task finisce il suo lavoro
              } catch let error {
                print(error.localizedDescription)
              }
           })
            
            task.resume()
            } else {
                print("No info available for this object")
                DispatchQueue.main.async {
                    self.infoBool = false
                    self.infoVariableToDisplay = ""
                    self.infoValuesToDisplay = []
                    self.infoDictionary = [:]
                    self.loadInfo()
                }
            }
    }
    
    //funzione che ci permete di oltrepassare il certificato di sicurezza
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           //Trust the certificate even if not valid
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)

           completionHandler(.useCredential, urlCredential)
    }
    
    //funzione temporanea che ci permette di accedere ai dati http facendo l'equivalenza dei nomi dato che sono diversi
    public func getMachineNameFromHTTP(name: String) -> String{
        var result: String = ""
        switch(name){
            case "KUKA": result = "Cell%204"
            break
            case "CELL6": result = "Cell%206"
            break
            
            default: result = "No info available for this object"
            break
        }
        
        return result
    }
}
