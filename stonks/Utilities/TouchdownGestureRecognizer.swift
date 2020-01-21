import UIKit.UIGestureRecognizerSubclass

class TouchdownGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            self.state = .recognized
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .failed
    }
    
    func add(hairtriggerTap v:UIView, _ action:Selector) {
        let t = TouchdownGestureRecognizer(target: self, action: action)
        v.addGestureRecognizer(t)
    }
}
