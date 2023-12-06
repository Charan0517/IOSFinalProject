//
//  canvasView.swift
//  DrawingApp2
//
//  Created by Sri Charan Vattikonda on 11/20/23.
//

import UIKit

struct Line {
    var points: [CGPoint]
    let strokeColor: UIColor
    let strokeWidth: CGFloat
    let opacity: CGFloat
}


@objc public protocol DrawingViewDelegate: AnyObject {
    @objc optional func didBeginDrawing()
    @objc optional func didEndDrawing()
}


class CanvasView: UIView {

     var lines: [Line] = []
    private var strokeColor: UIColor = .black
    private var strokeWidth: CGFloat = 4.0
    private var strokeOpacity: CGFloat = 1.0
    
    var isErasing: Bool = false
    
    public weak var delegate: DrawingViewDelegate?
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //print(strokeOpacity)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for line in lines {
            context.setStrokeColor(line.strokeColor.withAlphaComponent(line.opacity).cgColor)
            context.setLineWidth(line.strokeWidth)
            context.setLineCap(.round)
          //  print(line)
            
            for (index, point) in line.points.enumerated() {
                if index == 0 { // starting point
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
            context.strokePath()
        }
        //print(lines)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: self) else { return }
        let newLine = Line(points: [point], strokeColor: strokeColor, strokeWidth: strokeWidth, opacity: strokeOpacity)
        lines.append(newLine)
        delegate?.didBeginDrawing?()
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard var lastLine = lines.popLast(), let point = touches.first?.location(in: self) else { return }
            lastLine.points.append(point)
            lines.append(lastLine)
            setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self){
            let newLine = Line(points: [location], strokeColor: strokeColor, strokeWidth: strokeWidth, opacity: strokeOpacity)
            lines.append(newLine)
            setNeedsDisplay()
        }
        delegate?.didEndDrawing?()
    }
    
    public func setStrokeWidth(_ width: CGFloat) {
        strokeWidth = width
    }
    public func setStrokeColor(_ color: UIColor) {
        strokeColor = color
    }
    
    public func setStrokeopacity(_ opacity: CGFloat){
        strokeOpacity = opacity
    }
    public func clearAll() {
        undoneLines.removeAll()
        lines.removeAll()
        setNeedsDisplay()
    }
    
    private var undoneLines:[Line] = []
    
    public func undo() {
        guard let lineToUndo = lines.popLast() else { return }
       //print(lineToUndo)
        undoneLines.append(lineToUndo)
       // print(undoneLines)
        setNeedsDisplay()
    }

    public func redo() {
        guard let lineToRedo = undoneLines.popLast() else { return }
        //print(lineToRedo)
        lines.append(lineToRedo)
        setNeedsDisplay()
    }

    override func layoutSubviews() {
            super.layoutSubviews()
            updateDrawingCoordinates()
            setNeedsDisplay()
        }
    
    private func updateDrawingCoordinates() {
            guard let superviewBounds = superview?.bounds else {
                return
            }

            let orientation = UIDevice.current.orientation

            switch orientation {
            case .portrait, .portraitUpsideDown:
                break
            case .landscapeLeft, .landscapeRight:
                adjustDrawingCoordinatesForLandscape(with: superviewBounds)
            default:
                break
            }
        }
    
    func adjustDrawingCoordinatesForLandscape(with superviewBounds: CGRect) {
            guard let superview = superview else {
                return
            }

        let originalWidth = bounds.width
                let newWidth = superviewBounds.width
                let scale = newWidth / originalWidth

                lines = lines.map { line in
                    let newPoints = line.points.map { point in
                        CGPoint(x: point.x * scale, y: point.y * scale)
                    }
                    return Line(points: newPoints, strokeColor: line.strokeColor, strokeWidth: line.strokeWidth, opacity: line.opacity)
                }

                setNeedsDisplay()
        }

    
}



extension CanvasView{
    
    func isCanvasEmpty() -> Bool {
            return lines.isEmpty
        }
    
    func getImage() -> UIImage?{
                UIGraphicsBeginImageContext(bounds.size)
                guard let context = UIGraphicsGetCurrentContext() else{return nil}
        
                layer.render(in: context )
        
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
        
                return image
    }

    
    func getInvertedImage() -> UIImage?{
        
        UIGraphicsBeginImageContext(frame.size)

                guard let context = UIGraphicsGetCurrentContext() else { return nil }

                context.setFillColor(UIColor.black.cgColor)
                context.fill(bounds)

                for line in lines {
                    context.setStrokeColor(UIColor.white.cgColor)
                    context.setLineWidth(16.0)
                    context.setLineCap(.round)

                    for (index, point) in line.points.enumerated() {
                        if index == 0 { // starting point
                            context.move(to: point)
                        } else {
                            context.addLine(to: point)
                        }
                    }
                    context.strokePath()
                }

                let invertedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                return invertedImage
    }
    
    func getResizedGrayScaleImage() -> UIImage? {
            guard let originalImage = getInvertedImage() else {
                return nil
            }
            let resizedImage = originalImage.resize(newSize: CGSize(width: 28, height: 28))
        guard let grayScalePixelBuffer = resizedImage.grayScalePixelBuffer() else {
                print("Couldn't create grayscale pixel buffer")
                return nil
            }
        guard UIImage(pixelBuffer: grayScalePixelBuffer) != nil else {
                print("Couldn't create grayscale image from pixel buffer")
                return nil
            }

            return UIImage(pixelBuffer: grayScalePixelBuffer)
        }
    
    func setDrawingData(_ drawingData: [Line]){
        self.lines = drawingData
        setNeedsDisplay()
    }
    
    func setDrawingData(_ drawingData: [Line], cellSize: CGSize) {
            self.lines = []

            for var line in drawingData {
                line.points = line.points.map { point in
                    let xScale = cellSize.width / self.frame.size.width
                    let yScale = cellSize.height / self.frame.size.height
                    return CGPoint(x: point.x * xScale, y: point.y * yScale)
                }

                self.lines.append(line)
            }
            self.frame.size = cellSize
        self.bounds = CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height)
            self.setNeedsDisplay()
        }
}

extension UIImage {
    
    convenience init?(pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    public func resize(newSize: CGSize) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
            draw(in: CGRect(origin: CGPoint.zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            return newImage!
        }
        
        public func grayScalePixelBuffer() -> CVPixelBuffer? {
            var optionalPixelBuffer: CVPixelBuffer?
            guard CVPixelBufferCreate(kCFAllocatorDefault, 28, 28, kCVPixelFormatType_OneComponent8, nil, &optionalPixelBuffer) == kCVReturnSuccess else {
                return nil
            }
            
            guard let pixelBuffer = optionalPixelBuffer else {
                return nil
            }
            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
            let colorSpace = CGColorSpaceCreateDeviceGray()
            let context = CGContext(data: baseAddress, width: 28, height: 28, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: colorSpace, bitmapInfo: 0)
            context!.draw(cgImage!, in: CGRect(x: 0, y: 0, width: 28, height: 28))
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
            
            return pixelBuffer
        }
    }
    
