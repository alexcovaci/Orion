import Cocoa


class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    fileprivate var isEditingOrSelecting : Bool = false
    
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let rect = super.drawingRect(forBounds: rect)
        
        if !isEditingOrSelecting {
            let size = cellSize(forBounds: rect)
            return NSRect(x: rect.minX + 5, y: rect.minY + (rect.height - size.height) / 2, width: rect.width - 10, height: size.height)
        }
        
        return rect
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let aRect = self.drawingRect(forBounds: rect)
        isEditingOrSelecting = true
        super.select(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
        isEditingOrSelecting = false
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let aRect = self.drawingRect(forBounds: rect)
        isEditingOrSelecting = true
        super.edit(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, event: event)
        isEditingOrSelecting = false
    }
}
