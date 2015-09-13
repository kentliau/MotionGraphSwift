//
//  GraphView.swift
//  MotionGraphSwift
//
//  Created by Kent Liau on 9/4/15.
//  Copyright © 2015 Kent Liau. All rights reserved.
//

import UIKit
import QuartzCore

// MARK:- APLGraphView

/*
GraphView handles the public interface as well as arranging the subviews and sublayers to produce the intended effect.
*/

class GraphView : UIView {

    var segments: [GraphViewSegment]?
    weak var current: GraphViewSegment?
    weak var textView: GraphTextView?
    
    let kSegmentInitialPosition = CGPointMake(14.0, 56.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        segments = [GraphViewSegment]()
       
        let text = GraphTextView(frame: CGRectMake(0.0, 0.0, 32.0, 112))
        addSubview(text)
        textView = text
        
        current = addSegment()
    }
    
    func addX(x: Double, y: Double, z: Double) {
        if current!.addX(x, y: y, z: z) {
            recycleSegment()
            current!.addX(x, y: y, z: z)
        }
        
        for segment: GraphViewSegment in segments! {
            var position = segment.layer.position
            position.x += 1.0
            segment.layer.position = position
        }
    }
    
    func addSegment() -> GraphViewSegment {
        let segment = GraphViewSegment()
        segments?.insert(segment, atIndex: 0)
        layer.insertSublayer(segment.layer, below: self.textView?.layer)
        segment.layer.position = kSegmentInitialPosition
        return segment
    }
    
    func recycleSegment() {
        let last = segments?.last
        if last!.isVisibleInRect(self.layer.bounds) {
            current = addSegment()
        } else {
            last?.reset()
            last?.layer.position = kSegmentInitialPosition
            segments?.insert(last!, atIndex: 0)
            segments?.removeLast()
            current = last
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext();
        // Fill in the background.
        CGContextSetFillColorWithColor(context, graphBackgroundColor());
        CGContextFillRect(context, self.bounds);
        
        // Draw the grid lines.
        let width = self.bounds.size.width;
        CGContextTranslateCTM(context, 0.0, 56.0);
        DrawGridlines(context!, x: 0.0, width: width);
    }
    
    override var accessibilityValue: String? {
        get {
            if segments?.count == 0 {
                return nil
            }
            let graphViewSegment = segments![0]
            return graphViewSegment.accessibilityValue
        }
        
        set(newValue) {
            self.accessibilityValue = newValue
        }
    }
    
}


// MARK:- GraphViewSegment

/*
The GraphViewSegment manages up to 32 values and a CALayer that it updates with the segment of the graph that those values represent.
*/

class GraphViewSegment : NSObject {
    
    let layer = CALayer()
    
    var xHistory = [Double?](count: 33, repeatedValue: 0.0)
    var yHistory = [Double?](count: 33, repeatedValue: 0.0)
    var zHistory = [Double?](count: 33, repeatedValue: 0.0)
    var index = 33
    
    override init() {
        super.init()
        
        layer.delegate = self
        layer.bounds = CGRectMake(0.0, -56.0, 32.0, 112.0)
        layer.opaque = true
    }
    
    func reset() {
        xHistory = [Double?](count: 33, repeatedValue: 0.0)
        yHistory = [Double?](count: 33, repeatedValue: 0.0)
        zHistory = [Double?](count: 33, repeatedValue: 0.0)
        index = 33;
        
        layer.setNeedsDisplay()
    }
    
    func isFull() -> Bool {
        return index == 0
    }
    
    func isVisibleInRect(r: CGRect) -> Bool {
        return CGRectIntersectsRect(r, self.layer.frame)
    }
    
    func addX(x: Double, y: Double, z: Double) -> Bool {
        if index > 0 {
            --index
            xHistory[index] = x
            yHistory[index] = y
            zHistory[index] = z
            
            layer.setNeedsDisplay()
        }
        
        return index == 0
    }
 
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        // Fill in the background.
        CGContextSetFillColorWithColor(ctx, graphBackgroundColor())
        CGContextFillRect(ctx, self.layer.bounds)
        
        // Draw the grid lines.
        DrawGridlines(ctx, x: 0.0, width: 32.0)
        
        // Draw the graph
        var lines = [CGPoint](count: 64, repeatedValue: CGPoint(x: 0.0, y: 0.0))
        var i = 0
        
        // X
        for i = 0; i < 32; ++i {
            lines[i*2].x = CGFloat(i)
            lines[i*2].y = CGFloat(-xHistory[i]! * 16)
            lines[i*2+1].x = CGFloat(i + 1)
            lines[i*2+1].y = CGFloat(-xHistory[i+1]! * 16.0);
        }
        CGContextSetStrokeColorWithColor(ctx, graphXColor());
        CGContextStrokeLineSegments(ctx, lines, 64);
        
        // Y
        for i = 0; i < 32; ++i
        {
            lines[i*2].y = CGFloat(-yHistory[i]! * 16.0)
            lines[i*2+1].y = CGFloat(-yHistory[i+1]! * 16.0)
        }
        CGContextSetStrokeColorWithColor(ctx, graphYColor())
        CGContextStrokeLineSegments(ctx, lines, 64)
        
        // Z
        for i = 0; i < 32; ++i
        {
            lines[i*2].y = CGFloat(-zHistory[i]! * 16.0)
            lines[i*2+1].y = CGFloat(-zHistory[i+1]! * 16.0)
        }
        CGContextSetStrokeColorWithColor(ctx, graphZColor())
        CGContextStrokeLineSegments(ctx, lines, 64)
    }
    
    override func actionForLayer(layer: CALayer, forKey event: String) -> CAAction? {
        return nil
    }
    
    override var accessibilityValue: String? {
        get {
            let localizedStr = NSLocalizedString("graphSegmentFormat", comment: "Format string for accessibility text for last x, y, z values added")
            let str = String(format: localizedStr, xHistory[index]!, yHistory[index]!, zHistory[index]!)
            return str
        }
        
        set(newValue) {
            self.accessibilityValue = newValue
        }
    }
    

}



// MARK:- GraphTextView
/*
We use a separate view to draw the text for the graph so that we can layer the segment layers below it which gives the illusion that the numbers are draw over the graph, and hides the fact that the graph drawing for each segment is incomplete until the segment is filled.
*/
class GraphTextView : UIView {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        // Fill in the background.
        CGContextSetFillColorWithColor(context, graphBackgroundColor())
        CGContextFillRect(context, self.bounds)
        
        CGContextTranslateCTM(context, 0.0, 56.0)
        
        // Draw the grid lines.
        DrawGridlines(context, x: 26.0, width: 6.0)
        
        // Draw the text
        let systemFont = UIFont.systemFontOfSize(10.0) // use a smaller font size, since it is sans francisco
        UIColor.whiteColor().set()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        paragraphStyle.alignment = .Right
        let stringAttributes = [NSFontAttributeName: systemFont, NSParagraphStyleAttributeName: paragraphStyle]
        
        NSString(string: "+3.0").drawInRect(CGRectMake(2.0, -56.0, 24.0, 16.0), withAttributes: stringAttributes)
        NSString(string: "+2.0").drawInRect(CGRectMake(2.0, -40.0, 24.0, 16.0), withAttributes: stringAttributes)
        NSString(string: "+1.0").drawInRect(CGRectMake(2.0, -24.0, 24.0, 16.0), withAttributes: stringAttributes)
        NSString(string: " 0.0").drawInRect(CGRectMake(2.0,  -8.0, 24.0, 16.0), withAttributes: stringAttributes)
        NSString(string: "-1.0").drawInRect(CGRectMake(2.0,   8.0, 24.0, 16.0), withAttributes: stringAttributes)
        NSString(string: "-2.0").drawInRect(CGRectMake(2.0,  24.0, 24.0, 16.0), withAttributes: stringAttributes)
        NSString(string: "-3.0").drawInRect(CGRectMake(2.0,  40.0, 24.0, 16.0), withAttributes: stringAttributes)
    }
    
}


// MARK: - Quartz Helper

// Functions used to draw all content.
func CreateDeviceGrayColor(w: CGFloat, a: CGFloat) -> CGColorRef {
    let gray = CGColorSpaceCreateDeviceGray()
    let comps: [CGFloat] = [w, a]
    let color = CGColorCreate(gray, comps)
    return color!
}

func CreateDeviceRGBColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> CGColorRef {
    let rgb = CGColorSpaceCreateDeviceRGB()
    let comps: [CGFloat] = [r, g, b, a]
    let color = CGColorCreate(rgb, comps)
    return color!
}

func graphBackgroundColor() -> CGColorRef {
    // TODO: Static local variable equivalent in swift.
    struct Holder {
        static var c: CGColorRef? = nil
    }
    
    if Holder.c == nil {
        Holder.c = CreateDeviceGrayColor(0.6, a: 1.0)
    }
    
    return Holder.c!
}

func graphLineColor() -> CGColorRef {
    struct Holder {
        static var c: CGColorRef? = nil
    }
    
    if Holder.c == nil {
        Holder.c = CreateDeviceGrayColor(0.5, a: 1.0)
    }
    
    return Holder.c!
}

func graphXColor() -> CGColorRef {
    struct Holder {
        static var c: CGColorRef? = nil
    }
    
    if Holder.c == nil {
        Holder.c = CreateDeviceRGBColor(1.0, g: 0.0, b: 0.0, a: 1.0)
    }
    return Holder.c!
}

func graphYColor() -> CGColorRef {
    struct Holder {
        static var c: CGColorRef? = nil
    }
    
    if Holder.c == nil {
        Holder.c = CreateDeviceRGBColor(0.0, g: 1.0, b: 0.0, a: 1.0)
    }
    
    return Holder.c!
}

func graphZColor() -> CGColorRef {
    struct Holder {
        static var c: CGColorRef? = nil
    }
    
    if Holder.c == nil {
        Holder.c = CreateDeviceRGBColor(0.0, g: 0.0, b: 1.0, a: 1.0)
    }
    
    return Holder.c!
}

func DrawGridlines(context: CGContextRef, x: CGFloat, width: CGFloat) {
    for var y: CGFloat = -48.5; y <= 48.5; y += 16.0 {
        CGContextMoveToPoint(context, x, y)
        CGContextAddLineToPoint(context, x + width, y)
    }
    CGContextSetStrokeColorWithColor(context, graphLineColor())
    CGContextStrokePath(context)
}
