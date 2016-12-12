//
//  MOPieChart.swift
//  MOPieChart
//
//  Created by Mark Ogley on 2016-12-12.
//  Copyright © 2016 Mark Ogley. All rights reserved.
//

import Foundation
import UIKit


//Based on SketchTech blogpost http://sketchytech.blogspot.ca/2016/02/swift-going-round-in-semicircles-with.html

extension UIBezierPath {
    
    convenience init(centerOfCircle: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, fillColor: UIColor, strokeColor: UIColor) {
        
        self.init()
        
        fillColor.setFill()
        
        self.move(to: centerOfCircle)
        
        // add arc from the center for each segment (anticlockwise is specified for the arc, but as the view flips the context, it will produce a clockwise arc)
        self.addArc(withCenter: centerOfCircle, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        strokeColor.setStroke()
        
        self.fill()
        
        self.close()
        
    }
    
}


struct Slice {
    
    //These three properties are required but you can add as many as you want
    var value: CGFloat
    
    var title: String
    
    var color: UIColor
    
    //if you add more propertires remember to add them here in the declaration with type and the self properties
    init(value: CGFloat, title: String, color: UIColor) {
        
        self.value = value
        self.title = title
        self.color = color
        
    }
    
}


//Handles when a slice of the PieChartView is selected
protocol PieChartViewDelegate: class {
    
    func slicePropertyHasChanged(newSlice: Slice?)
    
}



class PieChartView: UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: PieChartViewDelegate?
    
    var startAngle: CGFloat = 0
    var endAngle: CGFloat = 0
    var radius: CGFloat = 0
    var centerOfPieChart: CGPoint = CGPoint(x: 0, y: 0)
    var valueCount: CGFloat = 0
    
    var colorsGenerated: [UIColor] = []
    
    var slices: [Slice] = []
    var selectedSlice: Slice? {
        
        didSet{
            
            delegate?.slicePropertyHasChanged(newSlice: selectedSlice)
            
        }
        
    }
    
    var paths: [UIBezierPath] = []
    var strokeColor = UIColor.lightGray
    var selected: CAShapeLayer? = nil
    
    
    
    
    
    
    func randomColor() -> UIColor {
        
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        
        return color
        
        
    }
    
    func calculatePieChartValue(rect: CGRect) {
        
        radius = min(bounds.width * 0.5, bounds.height * 0.5) - 16
        
        centerOfPieChart = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // the starting angle is -90 degrees (top of the circle, as the context is flipped). By default, 0 is the right hand side of the circle, with the positive angle being in an anti-clockwise direction (same as a unit circle in maths).
        startAngle = 0 //-CGFloat.pi * 0.5
        
    }
    
    //Borrowed work from HamishKnight's PieChartView found at https://github.com/hamishknight/Pie-Chart-View . Added slice selection and tap gesture recognizer. Cleaned up and seperated some code as well.
    
    var showSegmentLabels = true {
        
        didSet { setNeedsDisplay() }
    }
    
    /// Defines whether the segment labels will show the value of the segment in brackets
    var showSegmentValueInLabel = false {
        
        didSet { setNeedsDisplay() }
    }
    
    /// The font to be used on the segment labels
    var segmentLabelFont = UIFont.systemFont(ofSize: 20) {
        didSet {
            
            textAttributes[NSFontAttributeName] = segmentLabelFont
            
            setNeedsDisplay()
        }
    }
    
    private let paragraphStyle : NSParagraphStyle = {
        
        var p = NSMutableParagraphStyle()
        
        p.alignment = .center
        
        return p.copy() as! NSParagraphStyle
        
    }()
    
    private lazy var textAttributes : [String : Any] = {
        
        return [NSParagraphStyleAttributeName : self.paragraphStyle, NSFontAttributeName : self.segmentLabelFont]
        
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        isOpaque = false // when overriding drawRect, you must specify this to maintain transparency.
        
        //initializes the tapGestureRecognizer
        self.initTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    override func draw(_ rect: CGRect) {
        
        
        
        // enumerate the total value of the segments by using reduce to sum them
        valueCount = slices.reduce(0, {$0 + $1.value})
        
        calculatePieChartValue(rect: rect)
        
        
        // loop through the values array
        for slice in slices {
            
            // update the end angle of the segment
            let endAngle = startAngle + .pi * 2 * (slice.value / valueCount)
            
            
            let path = UIBezierPath(centerOfCircle: centerOfPieChart, radius: radius, startAngle: startAngle, endAngle: endAngle, fillColor: slice.color, strokeColor: strokeColor)
            
            path.stroke()
            
            paths.append(path)
            
            
            if showSegmentLabels { // do text rendering
                
                // get the angle midpoint
                let halfAngle = startAngle + (endAngle - startAngle) * 0.5;
                
                // the ratio of how far away from the center of the pie chart the text will appear
                let textPositionValue : CGFloat = 0.67
                
                // get the 'center' of the segment. It's slightly biased to the outer edge, as it's wider.
                let segmentCenter = CGPoint(x: centerOfPieChart.x + radius * textPositionValue * cos(halfAngle), y: centerOfPieChart.y + radius * textPositionValue * sin(halfAngle))
                
                // text to render – the segment value is formatted to 1dp if needed to be displayed.
                let textToRender = showSegmentValueInLabel ? "\(slice.title) (\(slice.value))" : slice.title
                
                // get the color components of the segement color
                guard let colorComponents = slice.color.cgColor.components else { return }
                
                // get the average brightness of the color
                let averageRGB = (colorComponents[0] + colorComponents[1] + colorComponents[2]) / 3
                
                // if too light, use black. If too dark, use white
                textAttributes[NSForegroundColorAttributeName] = (averageRGB > 0.7) ? UIColor.black : UIColor.white
                
                // the bounds that the text will occupy
                var renderRect = CGRect(origin: .zero, size: (textToRender.size(attributes: textAttributes)))
                
                // center the origin of the rect
                renderRect.origin = CGPoint(x: segmentCenter.x - renderRect.size.width * 0.5, y: segmentCenter.y - renderRect.size.height * 0.5)
                
                // draw text in the rect, with the given attributes
                textToRender.draw(in: renderRect, withAttributes: textAttributes)
            }
            
            // update starting angle of the next segment to the ending angle of this segment
            startAngle = endAngle
        }
        
    }
    
    
    //adds the tapGestureRecognizer, could be changed to what ever recognizer you want, but make sure to change it in the init as well
    func initTapGestureRecognizer() {
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap))
        
        tapGR.numberOfTapsRequired = 1
        
        addGestureRecognizer(tapGR)
        
        
    }
    
    func didTap(tapGR: UIGestureRecognizer){
        
        //gets the point that is touched on the screen
        let touchPoint = CGPoint(x: tapGR.location(in: self).x, y: tapGR.location(in: self).y)
        
        
        var index = 0
        
        //uses the paths for the pieChart that were drawn earlier
        for path in paths {
            
            //checks the touchPoint to see if it is inside the path from above
            if path.contains(touchPoint) {
                
                //if the selected variable is nil, no previous selection this sets the selection to the new path and draws a CAShapeLayer over the path
                if (selected == nil) {
                    
                    selected = CAShapeLayer()
                    
                    selected?.path = path.cgPath
                    selected?.strokeColor = UIColor.black.cgColor
                    selected?.fillColor = UIColor.clear.cgColor
                    
                    self.layer.addSublayer(selected!)
                    
                    selectedSlice = slices[index]
                    
                //if a slice has already been selected but the user choses a new path, this switches the CAShapeLayer to the new path and removes the old layer
                }else if (selected != nil) && selected!.path != path.cgPath {
                    
                    let newSelected = CAShapeLayer()
                    newSelected.path = path.cgPath
                    newSelected.strokeColor = UIColor.black.cgColor
                    newSelected.fillColor = UIColor.clear.cgColor
                    
                    self.layer.replaceSublayer(selected!, with: newSelected)
                    
                    selected = newSelected
                    
                    selectedSlice = slices[index]
                    
                //if you select the same slice again it will remove the CAShapeLayer from that path and there will remove all layers on the view
                } else if(selected != nil) && selected!.path == path.cgPath {
                    
                    self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    selected = nil
                    selectedSlice = nil
                    
                    
                }
                
                
            }else {
                
                index = index + 1
            }
            
        }
        
    }
    
}

