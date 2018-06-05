//
//  GameScene.swift
//  StucomBird
//
//  Created by DAM on 10/4/18.
//  Copyright © 2018 DAM. All rights reserved.
//

import SpriteKit
import GameplayKit

// Necesario para tratar con colisiones SKPhysicsContactDelegate
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Un poco de documentación...
    /* Página de donde he sacado los sprites:
       https://www.spriters-resource.com
     
       Página donde descargué los sonidos de efecto:
       http://noproblo.dayjo.org/ZeldaSounds/
     
    */
    
    // Nodo de tipo SpriteKit para link
    var link = SKSpriteNode()
    // Nodo para el fondo de la pantalla
    var fondo = SKSpriteNode()
    
    // Nodo label para la puntuacion
    var labelPuntuacion = SKLabelNode()
    var puntuacion = 0
    
    // Nodos para los tubos
    var tubo1 = SKSpriteNode()
    var tubo2 = SKSpriteNode()
    
    // Aquí tengo mis sonidos
    let sound_salto = SKAction.playSoundFileNamed("MC_Link_Jump.wav", waitForCompletion: true)
    let sound_die = SKAction.playSoundFileNamed("LTTP_Link_Dying.wav", waitForCompletion: true)
    
    // Texturas de la link
    var texturaLink1 = SKTexture()
    var texturaLink2 = SKTexture()
    var texturaLink3 = SKTexture()
    var texturaLink4 = SKTexture()
    var texturaLink5 = SKTexture()
    var texturaLink6 = SKTexture()
    var texturaLink7 = SKTexture()
    var texturaLink8 = SKTexture()
    
    var texturaLinkSaltando1 = SKTexture()
    var texturaLinkSaltando2 = SKTexture()
    var texturaLinkSaltando3 = SKTexture()
    var texturaLinkSaltando4 = SKTexture()
    var texturaLinkSaltando5 = SKTexture()
    var texturaLinkSaltando6 = SKTexture()
    
    var texturaLinkMuriendo1 = SKTexture()
    var texturaLinkMuriendo2 = SKTexture()
    var texturaLinkMuriendo3 = SKTexture()
    var texturaLinkMuriendo4 = SKTexture()
    var texturaLinkMuriendo5 = SKTexture()
    
    // Textura de los tubos
    var texturaTubo1 = SKTexture()
    var texturaTubo2 = SKTexture()
    
    // altura de los huecos
    var alturaHueco = CGFloat()
    
    // timer para crear tubos y huecos
    var timer = Timer()
    
    // timer para el... timer, valga la redundancia
    var timerTiempo = Timer()
    
    // boolean para saber si el juego está activo o finalizado
    var gameOver = false
    
    // Enumeración de los nodos que pueden colisionar
    // se les debe representar con números potencia de 2
    enum tipoNodo: UInt32 {
        case link = 1       // Link colisiona
        case suelo = 16          // Colisión con el suelo
        case huecoTubos = 4     // Si pasa entre las tuberías subirá la puntuación
    }
    
    // Función equivalente a viewDidLoad
    override func didMove(to view: SKView) {
        
        // Nos encargamos de las colisiones de nuestros nodos
        self.physicsWorld.contactDelegate = self
        reiniciar()
        
        
    }
    
    func reiniciar() {
        // Creamos los tubos de manera constante e indefinidamente
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.ponerTubosYHuecos), userInfo: nil, repeats: true)
        
        // Ponemos la etiqueta con la puntuacion
        ponerPuntuacion()
        
        
        // El orden al poner los elementos es importante, el último tapa al anterior
        // Se puede gestionar también con la posición z de los sprite
        
        crearLinkConAnimacion()
        // Definimos la altura de los huecos
        alturaHueco = link.size.height * 1.2
        crearFondoConAnimacion()
        crearSuelo()
        ponerTubosYHuecos()
        startGameTimer()
        timerTiempo = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.startGameTimer), userInfo: nil, repeats: true)
    }
    
    func ponerPuntuacion() {
        labelPuntuacion.fontName = "Arial"
        labelPuntuacion.fontSize = 80
        labelPuntuacion.text = "0"
        labelPuntuacion.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 500)
        labelPuntuacion.zPosition = 2
        self.addChild(labelPuntuacion)
    }

    @objc func ponerTubosYHuecos() {
        
        // Acción para mover los tubos
        let moverTubos = SKAction.move(by: CGVector(dx: -3 * self.frame.width, dy: 0), duration: 1.9)
        
        // Acción para borrar los tubos cuando desaparecen de la pantalla para no tener infinitos nodos en la aplicación
        let borrarTubos = SKAction.removeFromParent()
        
        
        // Acción que enlaza las dos acciones (la que pone tubos y la que los borra)
        let moverBorrarTubos = SKAction.sequence([moverTubos, borrarTubos])
        
        texturaTubo1 = SKTexture(imageNamed: "cactuss.png")
        tubo1 = SKSpriteNode(texture: texturaTubo1)
        tubo1.position = CGPoint(x: 500.0, y: -530.0)
        tubo1.zPosition = 0
        
        // Le damos cuerpo físico al tubo
        tubo1.physicsBody = SKPhysicsBody(rectangleOf: texturaTubo1.size())
        // Para que no caiga
        tubo1.physicsBody!.isDynamic = false
        
        
        // con quien colisiona
        tubo1.physicsBody!.collisionBitMask = tipoNodo.link.rawValue
        
        // Hace contacto con
        tubo1.physicsBody!.contactTestBitMask = tipoNodo.link.rawValue
        
        tubo1.run(moverBorrarTubos)
        
        self.addChild(tubo1)
        
        /*
        
        texturaTubo2 = SKTexture(imageNamed: "cactuss.png")
        tubo2 = SKSpriteNode(texture: texturaTubo2)
        tubo2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - texturaTubo2.size().height / 2 - alturaHueco + compensacionTubos)
        tubo2.zPosition = 0
        tubo2.run(moverBorrarTubos)
        tubo2.physicsBody = SKPhysicsBody(rectangleOf: texturaTubo2.size())
        tubo2.physicsBody!.isDynamic = false
        tubo2.physicsBody!.collisionBitMask = tipoNodo.link.rawValue
        tubo2.physicsBody!.contactTestBitMask = tipoNodo.link.rawValue
        self.addChild(tubo2)
        
        // Hueco entre los tubos
        let nodoHueco = SKSpriteNode()
        
        nodoHueco.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + compensacionTubos)
        nodoHueco.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: texturaTubo1.size().width, height: alturaHueco))
        nodoHueco.physicsBody!.isDynamic = false
        
        // Asignamos su categoría
        nodoHueco.physicsBody!.categoryBitMask = tipoNodo.huecoTubos.rawValue
        // no queremos que colisione para que la mosca pueda pasar
        nodoHueco.physicsBody!.collisionBitMask = 0
        // Hace contacto con Link
        nodoHueco.physicsBody!.contactTestBitMask = tipoNodo.link.rawValue
        
        nodoHueco.zPosition = 1
        nodoHueco.run(moverBorrarTubos)
        
        self.addChild(nodoHueco)
        
        */
        
    }
    
    @objc func startGameTimer(){
        puntuacion += 1
        labelPuntuacion.text = String(puntuacion)
    }

    
    func crearSuelo() {
        let suelo = SKNode()
        suelo.position = CGPoint(x: 0.0, y: -600.0)
        suelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        // el suelo se tiene que estar quieto
        suelo.physicsBody!.isDynamic = false
        
        self.addChild(suelo)
    }
    
    func crearFondoConAnimacion() {
        // Textura para el fondo
        let texturaFondo = SKTexture(imageNamed: "pink_desert.png")
        
        // Acciones del fondo (para hacer ilusión de movimiento)
        // Desplazamos en el eje de las x cada 0.3s
        let movimientoFondo = SKAction.move(by: CGVector(dx: -texturaFondo.size().width, dy: 0), duration: 1.5)
        
        let movimientoFondoOrigen = SKAction.move(by: CGVector(dx: texturaFondo.size().width, dy: 0), duration: 0)
        
        // repetimos hasta el infinito
        let movimientoInfinitoFondo = SKAction.repeatForever(SKAction.sequence([movimientoFondo, movimientoFondoOrigen]))
        
        // Necesitamos más de un fondo para que no se vea la pantalla en negro
        
        // contador de fondos
        var i: CGFloat = 0
        
        while i < 2 {
            // Le ponemos la textura al fondo
            fondo = SKSpriteNode(texture: texturaFondo)
            
            // Indicamos la posición inicial del fondo
            fondo.position = CGPoint(x: texturaFondo.size().width * i, y: self.frame.midY)
            
            // Estiramos la altura de la imagen para que se adapte al alto de la pantalla
            fondo.size.height = self.frame.height
            
            // Indicamos zPosition para que quede detrás de todo
            fondo.zPosition = -1
            
            // Aplicamos la acción
            fondo.run(movimientoInfinitoFondo)
            // Ponemos el fondo en la escena
            self.addChild(fondo)
            
            // Incrementamos contador
            i += 1
        }
        
    }
    


    func crearLinkConAnimacion() {
        
        // Asignamos las texturas de Link
        texturaLink1 = SKTexture(imageNamed: "link1.png")
        texturaLink2 = SKTexture(imageNamed: "link2.png")
        texturaLink3 = SKTexture(imageNamed: "link3.png")
        texturaLink4 = SKTexture(imageNamed: "link4.png")
        texturaLink5 = SKTexture(imageNamed: "link5.png")
        texturaLink6 = SKTexture(imageNamed: "link6.png")
        texturaLink7 = SKTexture(imageNamed: "link7.png")
        texturaLink8 = SKTexture(imageNamed: "link8.png")
        
        // Creamos la animación que va intercambiando las texturas
        // para que parezca que la mosca va volando
        
        // Acción que indica las texturas y el tiempo de cada uno
        let animacion = SKAction.animate(with: [texturaLink1, texturaLink2, texturaLink3, texturaLink4, texturaLink5, texturaLink6, texturaLink7, texturaLink8], timePerFrame: 0.07)
        
        // Creamos la acción que hace que se vaya cambiando de textura
        // infinitamente
        let animacionInfinita = SKAction.repeatForever(animacion)
        
        // Le ponemos la textura inicial al nodo
        link = SKSpriteNode(texture: texturaLink1)
        // Posición inicial en la que ponemos a Link
        // (0.0, 0.0) es el medio de la pantalla
        // Se puede poner 0.0, 0.0 o bien con referencia a la pantalla
        link.position = CGPoint(x:-250.0, y:-520.0)
        
        // Le damos propiedades físicas a Link
        // Le damos un cuerpo circular
        link.physicsBody = SKPhysicsBody(circleOfRadius: texturaLink1.size().height / 2)
        
        // Al iniciar, Link estará quieto
        link.physicsBody?.isDynamic = false
        
        // Añadimos su categoría
        link.physicsBody!.categoryBitMask = tipoNodo.link.rawValue
        
        // Aplicamos la animación a Link
        link.run(animacionInfinita)
        
        link.zPosition = 0
        
        // Ponemos a Link en la escena
        self.addChild(link)
    }
    
    
    // Función para cargar los sprites cuando Link está saltando
    func linkJumps() {
        texturaLinkSaltando1 = SKTexture(imageNamed: "linkJump1.png")
        texturaLinkSaltando2 = SKTexture(imageNamed: "linkJump2.png")
        texturaLinkSaltando3 = SKTexture(imageNamed: "linkJump3.png")
        texturaLinkSaltando4 = SKTexture(imageNamed: "linkJump4.png")
        texturaLinkSaltando5 = SKTexture(imageNamed: "linkJump5.png")
        texturaLinkSaltando6 = SKTexture(imageNamed: "linkJump6.png")
        
        let animacion_salto = SKAction.animate(with: [texturaLinkSaltando1,texturaLinkSaltando2,texturaLinkSaltando3,texturaLinkSaltando4,texturaLinkSaltando5,texturaLinkSaltando6], timePerFrame: 0.5)
        let animacionSaltoInfinita = SKAction.repeatForever(animacion_salto)
        link.run(animacionSaltoInfinita)
    }
    
    // Función para cargar los sprites de Link muriendo
    func linkIsKill() {
        texturaLinkMuriendo1 = SKTexture(imageNamed: "linkDie1.png")
        texturaLinkMuriendo2 = SKTexture(imageNamed: "linkDie2.png")
        texturaLinkMuriendo3 = SKTexture(imageNamed: "linkDie3.png")
        texturaLinkMuriendo4 = SKTexture(imageNamed: "linkDie4.png")
        texturaLinkMuriendo5 = SKTexture(imageNamed: "linkDie5.png")
        
        let animacion_muerte = SKAction.animate(with: [texturaLinkMuriendo1,texturaLinkMuriendo2,texturaLinkMuriendo3,texturaLinkMuriendo4,texturaLinkMuriendo5], timePerFrame: 0.5)
        let animacionMuerteInfinita = SKAction.repeatForever(animacion_muerte)
        link.run(animacionMuerteInfinita)
    }
    
    var maxJump = 2
    var countJump = 0
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        
        
        if gameOver == false {
            // En cuanto el usuario toque la pantalla le damos dinámica a Link (caerá)
            link.physicsBody!.isDynamic = true
            
            // Le damos una velocidad a Link para que la velocidad al caer sea constante
            link.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            
            if (countJump < maxJump) {
                countJump += 1
                print("Suma +1")
            }
            
            if link.action(forKey: "jump") == nil { // check that there's no jump action running
                let jumpUp = SKAction.moveBy(x: 0, y: 0, duration: 0.61)
                let fallBack = SKAction.moveBy(x: 0, y: -110, duration: 0.3)
                
                link.run(SKAction.sequence([jumpUp, fallBack]), withKey:"jump")
            }
            
            // Le aplicamos un impulso a Link para que suba cada vez que pulsemos la pantalla
            // Y así poder evitar que se caiga para abajo
            link.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 610))
            run(sound_salto)
        } else {
            // si toca la pantalla cuando el juego ha acabado, lo reiniciamos para volver a jugar
            gameOver = false
            puntuacion = 0
            self.speed = 1
            self.removeAllChildren()
            reiniciar()
        }
        
    }
    
    // Función para tratar las colisiones o contactos de nuestros nodos
    func didBegin(_ contact: SKPhysicsContact) {
        
        // en contact tenemos bodyA y bodyB que son los cuerpos que hicieron contacto
        let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB
        
        // Si colisiona el player con el suelo se restablece el contador de saltos
        if (cuerpoA.categoryBitMask == tipoNodo.suelo.rawValue && cuerpoB.categoryBitMask == tipoNodo.link.rawValue || cuerpoA.categoryBitMask == tipoNodo.link.rawValue && cuerpoB.categoryBitMask == tipoNodo.suelo.rawValue) {
            countJump = 0
            print("Resta -1")
        }
        
        // Miramos si la mosca ha pasado por el hueco
        if (cuerpoA.categoryBitMask == tipoNodo.link.rawValue && cuerpoB.categoryBitMask == tipoNodo.huecoTubos.rawValue) || (cuerpoA.categoryBitMask == tipoNodo.huecoTubos.rawValue && cuerpoB.categoryBitMask == tipoNodo.link.rawValue) {
            print("SAS")
        } else {
            // si no pasa por el hueco es porque ha tocado el suelo o una tubería
            // deberemos acabar el juego
            gameOver = true
            linkIsKill()
            // Frenamos todo
            self.speed = 0
            // Paramos el timer
            timer.invalidate()
            timerTiempo.invalidate()
            labelPuntuacion.text = "YOU DIED"
            
            
        }
        
        // Aquí puedo definir parámetros si Link muere
        if (labelPuntuacion.text == "YOU DIED") {
            run(sound_die)
            
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
