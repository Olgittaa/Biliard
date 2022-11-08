import SpriteKit
import GameplayKit

class Ball: SKShapeNode{
    var x = 0.0
    var y = 0.0
    var vx = 0.0
    var vy = 0.0
    var m = 10.0
    
    func update_position(dt: Double){
        if check_position(){
//            vx = vx - 1
//            vy = vy - 1
            x = x + vx * dt
            y = y + vy * dt
        }
        position = CGPoint(x: x, y: y)
    }
    
    func check_position() -> Bool{
        return true
    }
}

class GameScene: SKScene {
    var lastT = TimeInterval()
    var obj = [Ball]()
    var dt = 0.0
    var moved = false
    
    var prev_mouse_pos: CGPoint!
    
    var game_frame: SKShapeNode!
    
    var arrow_path = [CGPoint(x: 10, y: 10), CGPoint(x: 100, y: 100)]
    
    func drawArrow(){
        deleteLines()
        computeArrowPosition()
        
        let dr = SKShapeNode(splinePoints: &arrow_path, count: 2)
        dr.name = "line"
        dr.lineWidth = 3
        dr.fillColor = .white
        addChild(dr)
    }
    
    
    fileprivate func computeArrowPosition() {
        arrow_path[0] = childNode(withName: "ball")!.position
        
    }
    
    fileprivate func deleteLines() {
        children.forEach{ node in
            if node.name == "line"{
                node.removeFromParent()
            }
        }
    }
    
    func createFrame(){
        game_frame = SKShapeNode(rectOf: CGSize(width: frame.width - 100, height: frame.height - 100))
        game_frame.fillColor = .black
        game_frame.strokeColor = .gray
        addChild(game_frame)
    }
    
    
    fileprivate func generate_balls() {
        let h = sqrt(28 * 28 - 14 * 14)
        createBall(pos: CGPoint(x: 100, y: 0))
        createBall(pos: CGPoint(x: 100 + h, y: 14))
        createBall(pos: CGPoint(x: 100 + h, y: -14))
        
        createBall(pos: CGPoint(x: 100 + h + h, y: 28))
        createBall(pos: CGPoint(x: 100 + h + h, y: 0))
        createBall(pos: CGPoint(x: 100 + h + h, y: -28))
        
        createBall(pos: CGPoint(x: 100 + h + h + h, y: 14))
        createBall(pos: CGPoint(x: 100 + h + h + h, y: -14))
        createBall(pos: CGPoint(x: 100 + h + h + h, y: 42))
        createBall(pos: CGPoint(x: 100 + h + h + h, y: -42))
        
        createBall(pos: CGPoint(x: 100 + h + h + h + h, y: 28))
        createBall(pos: CGPoint(x: 100 + h + h + h + h, y: 0))
        createBall(pos: CGPoint(x: 100 + h + h + h + h, y: -28))
        createBall(pos: CGPoint(x: 100 + h + h + h + h, y: 56))
        createBall(pos: CGPoint(x: 100 + h + h + h + h, y: -56))
    }
    
    override func didMove(to view: SKView) {
        createFrame()
        
        let ball = Ball(circleOfRadius: 14)
        ball.name = "ball"
        ball.x = -200
        ball.y = 0
        arrow_path[0] = CGPoint(x: ball.x, y: ball.y)
        ball.fillColor = .red
        ball.strokeColor = .red
        //        ball.position = arrow_path[0]
        obj.append(ball)
        addChild(ball)
        
        generate_balls()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        //        moved = false
        arrow_path[1] = pos
        drawArrow()
        //        prev_mouse_pos = pos
        //        touched(pos: pos)
    }
    
    func createBall(pos : CGPoint){
        let ball = Ball(circleOfRadius: 14)
        
//        let r = sqrt(pow(pos.x.distance(to: prev_mouse_pos.x), 2) + pow(pos.y.distance(to: prev_mouse_pos.y), 2)) * 2
//        ball.vx = prev_mouse_pos.x.distance(to: pos.x) * r / 1000
//        ball.vy = prev_mouse_pos.y.distance(to: pos.y) * r / 1000
        
        ball.x = pos.x
        ball.y = pos.y
        
        ball.name = "subball"
        ball.fillColor = .white
        ball.strokeColor = .white
        
        obj.append(ball)
        addChild(ball)
    }
    
    func touched(pos : CGPoint){
        createBall(pos: pos)
    }
    
    func detectCollision(el: Ball, el2: Ball) -> [CGFloat]{
        let dx = el2.x - el.x
        let dy = el2.y - el.y
        let d = sqrt(dx * dx + dy * dy)
        if d < 28{
            return [dx, dy, d]
        }else{
            return []
        }
    }
    
    func resolveCollision(el: Ball, el2: Ball, info: [CGFloat]){
        let nx = info[0] / info[2]
        let ny = info[1] / info[2]
        let s = 28 - info[2]
        el.x = el.x - nx * s / 2
        el.y = el.y - ny * s / 2
        el2.x = el2.x + nx * s / 2
        el2.y = el2.y + ny * s / 2
        
        let k = -2.0 * ((el2.vx - el.vx) * nx + (el2.vy - el.vy) * ny) / (1 / el.m + 1 / el2.m)
        el.vx = el.vx - k * nx / el.m
        el.vy = el.vy - k * ny / el.m
        el2.vx = el2.vx + k * nx / el2.m
        el2.vy = el2.vy + k * ny / el2.m
    }
    
    func checkBorders(){
        for object in obj {
            if abs(object.x) + 14 > game_frame.frame.width / 2.0 || abs(object.y) + 14 > game_frame.frame.height / 2.0 {
                object.vx = -100
                object.vy = -100
                continue
            }
            object.update_position(dt: dt)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        //        touched(pos: pos)
        arrow_path[1] = pos
        drawArrow()
    }
    
    func touchUp(atPoint pos : CGPoint) {
            deleteLines()
            shoot()
    }
    
    func drawBall(){
        
    }
    
    func shoot(){
        let r = sqrt(pow(arrow_path[0].x.distance(to: arrow_path[1].x), 2) + pow(arrow_path[0].y.distance(to: arrow_path[1].y), 2)) * 2
        obj[0].vx = arrow_path[1].x.distance(to: arrow_path[0].x) * r / 100
        obj[0].vy = arrow_path[1].y.distance(to: arrow_path[0].y) * r / 100
    }
    
    func update_ball_pos(){
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if lastT == 0{
            lastT = currentTime
        }
        dt = currentTime - lastT
        
        checkBorders()
        
        if obj.count > 1{
            var kol = [(Ball, Ball, [CGFloat])]()
            for i in 0...obj.count - 2{
                for j in i + 1...obj.count - 1{
                    let info = detectCollision(el: obj[i], el2: obj[j])
                    if info.count > 0 {
                        kol.append((obj[i], obj[j], info))
                    }
                }
            }
            
            for k in kol{
                resolveCollision(el: k.0, el2: k.1, info: k.2)
            }
        }
        
        lastT = currentTime
    }
    
    func move(){
        
    }
    
}
