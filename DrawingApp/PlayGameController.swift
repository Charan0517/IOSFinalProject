//
//  PlayGameController.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit

class PlayGameController: UIViewController, DrawingViewDelegate{

    @IBOutlet weak var randomcategory: UILabel!
    
    @IBOutlet weak var results: UILabel!
    
    @IBOutlet weak var canvasView: CanvasView!
    
    @IBOutlet weak var ScoreLBL: UILabel!
    @IBOutlet weak var highestScoreLBL: UILabel!
    var score = 0
    
    private var drawnImageClassifier: DrawnImageClassifier = {
            do {
                let configuration = MLModelConfiguration()
                return try DrawnImageClassifier(configuration: configuration)
            } catch {
                fatalError("Error initializing DrawnImageClassifier: \(error)")
            }
        }()
    
    private var labelNames: [String] = []
    private var currentChallenge: String? {
        didSet {
            if let currentChallenge = currentChallenge {
                randomcategory.text = "Try drawing: \(currentChallenge)"
            }
            else {
                randomcategory.text = "Freeplay"
            }
        }
    }
    
    private var currentPrediction: DrawnImageClassifierOutput? {
        didSet {
            if let currentPrediction = currentPrediction {
                let sorted = currentPrediction.category_softmax_scores.sorted { $0.value > $1.value }
                print(currentPrediction.category_softmax_scores.sorted { $0.value > $1.value })
                let top5 = sorted.prefix(5)
                results.text = top5.map { $0.key }.joined(separator: ", ")
                
                checkChallenge()
            }
            else {
                results.text = "Waiting for drawing..."
            }
        }
    }
    
    
    @IBAction func clear(_ sender: UIButton) {
        clearDrawingView()
    }
    
    @IBAction func nextChallenge(_ sender: UIButton) {
        newChallenge()
    }
    
    private func newChallenge() {
        clearDrawingView()
        currentChallenge = labelNames[Int(arc4random()) % labelNames.count]
    }
    
    private func clearDrawingView() {
        canvasView.clearAll()
        currentPrediction = nil
    }
    
    public func didEndDrawing() {
        // get image and resize it
        let image = canvasView.getInvertedImage()
        let resized = image?.resize(newSize: CGSize(width: 28, height: 28))
        
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

    
    private func checkChallenge() {
        guard let currentChallenge = currentChallenge,
            let currentPrediction = currentPrediction else {
            return
        }
        
        if currentPrediction.category == currentChallenge {
            score += 1
            ScoreLBL.text = "\(score)"
            storeScore(score: score)
            newChallenge()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "labels", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let labelNames = data.components(separatedBy: .newlines).filter { $0.count > 0 }
                self.labelNames.append(contentsOf: labelNames)
            } catch {
                print("error loading labels: \(error)")
            }
        }
        ScoreLBL.text = "\(score)"
        fetchScore()
        canvasView.delegate = self
        newChallenge()

        // Do any additional setup after loading the view.
    }
    
    private var highestScore = 0
    private func storeScore(score: Int) {
        let docRef = utilityConstants.dbScoresRef
        docRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            let batch = utilityConstants.db.batch()
            
            if let document = documentSnapshot, let data = document.data(), let highScore = data["highestScore"] as? Int {
                if score > highScore{
                    self.highestScore = score
                    self.highestScoreLBL.text = "\(self.highestScore)"
                    batch.updateData(["score": score, "highestScore": self.highestScore], forDocument: docRef)
                }
                else{
                    batch.updateData(["score": score], forDocument: docRef)
                }
            }
            batch.commit { error in
                if let error = error {
                    print("Error updating/adding score document: \(error.localizedDescription)")
                } else {
                    print("Score document updated/added in Firestore")
                }
            }
        }
        
       
    }

    private func fetchScore() {
        
        utilityConstants.dbScoresRef.getDocument { (documentSnapshot, error: Error?) in
            if let error = error {
                print("Error fetching scores: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, let data = document.data(), let storedScore = data["score"] as? Int, let highScore = data["highestScore"] as? Int {
                // Update UI or handle the fetched score as needed
               // self.previousScoreLBL.text = "Previous Score: \(storedScore)"
                self.highestScoreLBL.text = "\(highScore)"
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

}

