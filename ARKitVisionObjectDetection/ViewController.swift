//
//  ViewController.swift
//
//  Created by Davide Garavaso on 13/06/2020.
//  Copyright © 2020 Davide Garavaso. All rights reserved.
//


import ARKit
import RealityKit


class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //View
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var ScreenView: UIView! //View per lo snapshot
    @IBOutlet weak var InfoView: UITextView! //View per le informazioni
    
    //Label per i messaggi
    @IBOutlet weak var MessageLabel: UILabel! //Label per i messaggi di controllo
    @IBOutlet weak var ObjectLabel: UILabel! //Label per il rilevamento dell'oggetto
    @IBOutlet weak var ScaleMoveLabel: UILabel! //Label per le gesture scale/move
    @IBOutlet weak var RotateLabel: UILabel! //Label per la gesture rotate
    
    
    //Variabili per le caratteristiche dell'oggetto riconosciuto
    var modelName: String = "Nessun oggetto rilevato"
    var modelNode: SCNNode?
    var modelFlattenedNode: SCNNode?
    var checkIfLastIsPositiveOrNegative: Array<Float> = []
    var arrayChildNodes: Array<SCNNode> = []
    var dictionaryForNodeExplosion: [SCNNode: SCNVector3] = [:]
    var explodeReady: Bool = true
    @IBOutlet weak var explodeResetButton: UIButton!
    var boolModel: Bool = true //Booleano che permette di riconoscere un oggetto alla volta
    var transform = simd_float4x4() //Trasformata degli oggetti
    var scaleModelX: Float = 0.0 //Larghezza dell'oggetto
    var scaleModelY: Float = 0.0 //Altezza dell'oggetto
    var scaleModelZ: Float = 0.0 //Profondità dell'oggetto
    var text = "" //Testo in cui verranno inserite le caratteristiche dell'oggetto

    
    //Contatori costruiti per le funzioni
    var infoCount: Int = 0 //Contatore che fa apparire la infoView
    var infoUpdate: String = "Nessun oggetto rilevato"//Verifica l'aggiornamento dell'info
    var infoVariableToDisplay: String = ""
    var infoValuesToDisplay: Array<String> = []
    var infoDictionary: [String: String] = [:]
    var infoBool: Bool = false
    var flashCount: Int = 0 //Contatore che gestisce la torcia
    var modelCount: Int = 0 //Contatore del modello 3d
    var NumberOfComponents: Int = 0 //Contatore che mostra il numero dei componenti
    var listOfAddedComponents: Array<SCNNode> = []
    var componentPosition: SCNVector3!
    var MessageObjectPass: Bool = false //Booleano che indica quale UILabel è attiva


    //Scena per il modello 3d.
    //Ogni oggetto rilevato ha solo un modello 3d da mostrare. Una è sufficiente poichè è generale e ogni volta viene riempita con il relativo file .usdz
    var modelScene = SCNScene(named: "")
    
    
    //Variabili per la gestione delle Gesture
    var gestureModelNode: SCNNode? //Modello 3d per le funzioni scale/move/rotate
    var lastPanPosition: SCNVector3? //Ultima posizione nel mondo di gestureModelNode
    var zPosition: CGFloat? //Verrà riempita con l'ultima coordinata z di gestureModelNode
    var newAngleX :Float = 0.0
    var currentAngleX: Float = 0.0 //Angolo x per la rotazione
    var newAngleY :Float = 0.0
    var currentAngleY: Float = 0.0 //Angolo y per la rotazione
    var press: Bool = false //Booleano che indica, se vero, che è attiva la rotazione
    var localTranslatePosition :CGPoint!
    let blackView = UIView()
    
    //Variabili per il highlight
    let highlightMaskValue: Int = 2
    let normalMaskValue: Int = 1
    
    //Create a session configuration
    //Necessaria di questo tipo per il riconoscimento di un oggetto
    let configuration = ARWorldTrackingConfiguration()
    
    //Variabili per la gestione del menu
    var componentsArray: [Setting] = []
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 70


    
    
    //Funzione che carica la scena
    override func viewDidLoad(){
        super.viewDidLoad()
        //sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = true
        
        //Set the view's delegate
        sceneView.delegate = self
        
        //Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        //Show the origin of the scene
        //sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin

        //Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        sceneView.scene = scene
        SCNScene.load()

        //Gesture
        GestureRecognizer()
        sceneView.isUserInteractionEnabled = true
        
        //MessageView
        initMessageLabel()
        //ObjectView
        initObjectLabel()
        
        //GestureView
        initScaleMoveLabel()
        initRotateLabel()
        explodeResetButton.isHidden = true

    }
    
    //Funzione che fa apparire la scena
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)

        //Object detection
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "ArObjects", bundle: Bundle.main)!
            
        //Mostra l'origine della scena e i suoi feature point
        //self .sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
            
        //Run the view's session
        sceneView.session.run(configuration)
    }
    
    //Funzione che fa stoppare la scena
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        //Pause the view's session
        sceneView.session.pause()
    }
    


    
    //Funzione responsabile del rilevamento dell'oggetto del mondo reale
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
            if(boolModel){
                //Se vedo un oggetto che è di tipo objectAnchor faccio il riconoscimento
                //In questo modo ho un riscontro con i file già salvati nella cartella Assets.xcassets
                if let objectAnchor = anchor as? ARObjectAnchor {
                    //Se l'oggetto non è stato già rilevato faccio la procedura di salvataggio delle caratteristiche altrimenti no.
                    //In questo modo tengo sempre conto dell'ultimo oggetto rilevato
                    if objectAnchor.referenceObject.name != modelName {
                        //Salvataggio dei dati dell'oggetto: nome, dimensioni, trasformata
                        modelName = objectAnchor.referenceObject.name ?? "Nessun oggetto rilevato"
                        scaleModelX = anchor.transform.columns.3.x
                        scaleModelY = anchor.transform.columns.3.y
                        scaleModelZ = anchor.transform.columns.3.z
                        transform = objectAnchor.transform

                        //Chiamata della funzione message
                        ObjectLabel.text = Message(this: "renderer")
                        //Chiamata della funzione per caricare i dati http
                        infoBool = false
                        httpRequest(obj: getMachineNameFromHTTP(name: modelName)) // da cambiare con modelName
                        //Blocco prossime rilevazioni
                        boolModel = false
                        dictionaryForNodeExplosion = [:]
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let title = "Warning"
                    let message = "You can't detect more than 1 object at the time \n Clear scene first!" 
                    self.showAlert(title: title, message: message, showCancel: false)
                }
            }
        return node
    }
    
    
    
    
    
    /*Funzione che implementa una fotocamera
     Essa richiede i permessi per accedere alla fotocamera perciò è stato necessario
     modificare i permessi dell'applicazione*/
    //Dichiarazione di una View che darà un'effetto fotografico
    @IBAction func didTouchSnapshotButton(_ sender: UIButton) {
        //Aggiunta del suono dello scatto
        if let soundURL = Bundle.main.url(forResource: "ScreenSound", withExtension: "mp3"){
            var mySound : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            AudioServicesPlayAlertSound(mySound)
        }
        
        //La ScreenView viene resa visibile
        ScreenView.alpha = 0.4
        ScreenView.isHidden = false
        //Il tempo per il quale la ScreenView sarà visibile è di 0.8 secondi
        UIView.animate(withDuration: 0.8, animations: {
            self.ScreenView.alpha = 0.0
        }) {(finished) in
            self.ScreenView.isHidden = true //ScreenView resa di nuovo invisibile
            /*Stringa di codice che effettivamente implementa il salvataggio dell'immagine nella Galleria */
            UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
            
            //Messaggio di conferma
            let title = "Snapshot created"
            let message = "Snapshot saved in gallery successfully"
            self.showAlert(title: title, message: message, showCancel: false)
        }
        print("Istantanea creata")
    }
}


