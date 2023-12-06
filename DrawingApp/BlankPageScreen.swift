//
//  BlankPageScreen.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit
import CoreML

protocol BlankPageDelegate: AnyObject{
    func updateDrawingData(_ drawingData: [Line], forDrawingWithName name: String)
}

class BlankPageScreen: UIViewController {

    @IBOutlet weak var resultLBL: UILabel!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var redo: UIButton!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var favorites: UIButton!
    @IBOutlet weak var paintBrush: UIImageView!
    @IBOutlet weak var opacity: UIImageView!
    @IBOutlet weak var canvasView: CanvasView!
    
    @IBOutlet weak var colorsCollection: UICollectionView!{
        didSet{
            colorsCollection.delegate = self
            colorsCollection.dataSource = self
        }
    }
    
    
    private var fileName: String?
    var selectedDrawing: Drawing?
    weak var delegate: BlankPageDelegate?
    var isFav: Bool = false
    
    func updateDashboard(){
        delegate?.updateDrawingData(canvasView.lines, forDrawingWithName: fileName ?? "")
    }
    
    private var drawnImageClassifier: DrawnImageClassifier = {
            do {
                let configuration = MLModelConfiguration()
                return try DrawnImageClassifier(configuration: configuration)
            } catch {
                fatalError("Error initializing DrawnImageClassifier: \(error)")
            }
        }()
    
    private var currentPrediction: DrawnImageClassifierOutput?{
        didSet{
            if let currentPrediction = currentPrediction, !canvasView.isCanvasEmpty(){
                let sorted = currentPrediction.category_softmax_scores.sorted{$0.value > $1.value}
                let top5 = sorted.prefix(5)
                resultLBL.text = top5.map{$0.key}.joined(separator: ", ")
            }
            else{
                resultLBL.text = "Waiting for drawing..."
            }
        }
    }
    
    
    @IBAction func clear(_ sender: UIButton) {
        canvasView.clearAll()
        for eachView in view.subviews where eachView is UIImageView {
            eachView.removeFromSuperview()
        }
        model()
    }
    
    @IBAction func undo(_ sender: UIButton) {
        canvasView.undo()
        //canvasView.setNeedsDisplay()
       // print("Hi")
        model()
    }
    
    @IBAction func redo(_ sender: UIButton) {
        canvasView.redo()
        model()

    }
    
    @IBAction func strokWidth(_ sender: UISlider) {
        //canvasView.setStrokeopacity(CGFloat(sender.value))
        canvasView.setStrokeWidth(CGFloat(sender.value))
       // print(CGFloat(sender.value))
    }
    
    @IBAction func strockOpacity(_ sender: UISlider) {
        canvasView.setStrokeopacity(CGFloat(sender.value))
    }
    
    @IBAction func share(_ sender: UIButton) {
        guard let canvasImage = canvasView.getImage() else{return}
        
        let items: [Any] = [canvasImage]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.popoverPresentationController?.sourceRect = sender.frame
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func saveBTN(_ sender: UIButton) {
        guard let canvasImage = canvasView.getImage() else {
                return
            }
        UIImageWriteToSavedPhotosAlbum(canvasImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        var message: String
            if let error = error {
                message = "Error saving image: \(error.localizedDescription)"
            } else {
                message = "Image saved successfully."
            }
        displayTemporaryMessage(message: message, duration: 2.0)
        }
    
    func displayTemporaryMessage(message: String, duration: TimeInterval) {
        let label = UILabel()
        label.text = message
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 200),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: duration, animations: {
            label.alpha = 0
        }) { _ in
            label.removeFromSuperview()
        }
    }
    
        private func saveImageDataToPhotoLibrary(_ imageData: Data) {
            UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData) ?? UIImage(), self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        
        if canvasView.isCanvasEmpty(){
            resultLBL.text = "Waiting for drawing...."
        }
        
        
        if let selectedDrawing = selectedDrawing {
                    fileName = selectedDrawing.name
                    canvasView.setDrawingData(selectedDrawing.drawingData)
                    canvasView.setNeedsDisplay()
                } else {
                    askForFileName()
                }
    }
    
    func updateDrawingData(_ drawingData: [Line], forDrawingWithName name: String) {
            canvasView.setDrawingData(drawingData, cellSize: canvasView.frame.size)
            adjustDrawingCoordinatesForOrientation()
        }

        private func adjustDrawingCoordinatesForOrientation() {
            guard let superviewBounds = canvasView.superview?.bounds else {
                return
            }

            let orientation = UIDevice.current.orientation

            switch orientation {
            case .portrait, .portraitUpsideDown:
                break
            case .landscapeLeft, .landscapeRight:
                canvasView.adjustDrawingCoordinatesForLandscape(with: superviewBounds)
            default:
                break
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        opacity.image = UIImage(named: "opacity")
       // print(dashBoardDrawing)
        
        share.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        undo.setImage(UIImage(systemName: "arrow.uturn.backward.square"), for: .normal)
        redo.setImage(UIImage(systemName: "arrow.uturn.forward.square"), for: .normal)
        clear.setImage(UIImage(systemName: "xmark.square"), for: .normal)
        save.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        favorites.setImage(UIImage(systemName: "star"), for: .normal)
        let index = favoritesDrawing.contains(where: {name in
            (name.name == self.fileName) && (name.isFavorite == true)})
        if index == true{
            print("yes")
            favorites.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        else{
            print("No")
            favorites.setImage(UIImage(systemName: "star"), for: .normal)
        }
        model()
        
        print(canvasView.bounds.height)
        print(canvasView.bounds.width)
        print(canvasView.frame.height)
        print(canvasView.frame.width)
        print(canvasView.bounds.origin)
        navigationItem.title = fileName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
        if let index = dashBoardDrawing.firstIndex(where: { $0.name == fileName }) {
            dashBoardDrawing[index].drawingData = canvasView.lines
            dashBoardDrawing[index].image = canvasView.getImage() ?? UIImage()
            updateDrawingInFirestore(drawing: canvasView.lines, fileName: fileName ?? "", isFav: isFav, imageData: canvasView.getImage()?.pngData() ?? Data())
        } else if fileName != nil {
            dashBoardDrawing.append(Drawing(name: fileName ?? "", image: canvasView.getImage() ?? UIImage(), drawingData: canvasView.lines))
            addDrawingToFirestore(drawing: canvasView.lines, fileName: fileName ?? "", isFav: isFav, imageData: canvasView.getImage()?.pngData() ?? Data())
        }
        
        if let index = favoritesDrawing.firstIndex(where: { $0.name == fileName }) {
            favoritesDrawing[index].drawingData = canvasView.lines
            favoritesDrawing[index].image = canvasView.getImage() ?? UIImage()
            updateDrawingInFirestore(drawing: canvasView.lines, fileName: fileName ?? "", isFav: isFav, imageData: canvasView.getImage()?.pngData() ?? Data())
        }
        }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        let filledStarImage = UIImage(systemName: "star.fill")
       // let emptyStarImage = UIImage(systemName: "star")
        if sender.currentImage == filledStarImage {
            print("non")
                sender.setImage(UIImage(systemName: "star"), for: .normal)
            updateButton(isFilled: false)
            } else {
                print("fil")
                sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
                updateButton(isFilled: true)
            }
    }
    
    
    func updateButton(isFilled: Bool){
        if let index = favoritesDrawing.firstIndex(where: {meal in
            meal.name == fileName}){
            favoritesDrawing[index].isFavorite = isFilled
            if !isFilled{
                favoritesDrawing.remove(at: index)
                deleteDrawingFromFavorites(drawingName: fileName ?? "")
            }
        }else{
            favoritesDrawing.append(Drawing(name: fileName ?? "", image: canvasView.getImage() ?? UIImage(), drawingData: canvasView.lines, isFavorite: isFilled))
            addDrawingToFavorites(drawing: canvasView.lines, fileName: fileName ?? "", isFav: false, imageData: canvasView.getImage()?.pngData() ?? Data())
        }
        isFav = isFilled
        
    }
    
    func askForFileName() {
        let alertController = UIAlertController(title: "Enter File Name", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "File Name"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let enteredFileName = alertController.textFields?.first?.text, !enteredFileName.isEmpty else {
                self?.showErrorMessage(message: "Please enter a file name."){
                    self?.askForFileName()
                }
                return
            }

            guard !dashBoardDrawing.contains(where: { $0.name == enteredFileName }) else {
                self?.showErrorMessage(message: "File name already exists. Please choose a different name."){
                    self?.askForFileName()
                }
                return
            }
            self?.fileName = enteredFileName
            self?.navigationItem.title = self?.fileName
            print(dashBoardDrawing.contains(where: { $0.name == enteredFileName }))
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

    func showErrorMessage(message: String, completion: (() -> Void)?) {
        let errorAlertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default){ _ in
            completion?()
        }
        errorAlertController.addAction(dismissAction)
        present(errorAlertController, animated: true, completion: nil)
    }
    
    public func didEndDrawing() {
        model()
        
     //   print(canvasView.getImage()?.pngData())

}

    func model(){
    let image = canvasView.getInvertedImage()
  //  let image = UIImage(invertedView: canvasView)
    let resized = image?.resize(newSize: CGSize(width: 28, height: 28))
   // let image = canvasView.getResizedGrayScaleImage()
    guard let pixelBuffer = resized?.grayScalePixelBuffer() else{
        print("couldn't create pixxel buffer")
        return
    }
    do{
        currentPrediction = try drawnImageClassifier.prediction(image: pixelBuffer)
    }
    catch{
        print("error making prediction: \(error)")
    }
}
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



extension BlankPageScreen: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorsCollection.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colo[indexPath.row]
        canvasView.setStrokeColor(color)
        //colorsLabel.textColor = color
    }
}

extension BlankPageScreen: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.cornerRadius = 10
        return cell
    }
}

