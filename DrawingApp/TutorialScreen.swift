//
//  TutorialScreen.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit

class TutorialScreen: UIViewController {

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var instDescription: UITextView!
    
    @IBOutlet weak var instructionImage: UIImageView!
    
    var index = 0
    
    @IBAction func leftBTNAction(_ sender: UIButton) {
        if index > 0 && index < 9{
            index = index - 1
        }
        display()
    }
    
    @IBAction func rightBTNAction(_ sender: UIButton) {
        if index >= 0 && index < 8{

            index = index + 1
        }
        display()
    }
    
    func display(){
        
        instructionImage.image = UIImage(named: instrcutions[index].instructionImage)
        instDescription.text = instrcutions[index].instructionText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem()
           backButton.title = "Home" // Set your desired back button text here
           navigationItem.backBarButtonItem = backButton
        instructionImage.isUserInteractionEnabled = true
        instructionImage.image = UIImage(named: instrcutions[index].instructionImage)
        instDescription.text = instrcutions[index].instructionText
        gestures()
        
        leftButton.setImage(UIImage(systemName: "arrow.right.circle"), for: .normal)
        rightButton.setImage(UIImage(systemName: "arrow.left.circle"), for: .normal)
        // Do any additional setup after loading the view.
    }
    
    func gestures(){
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeImages))
                instructionImage.addGestureRecognizer(swipeLeft)
                swipeLeft.direction = .left
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeImages))
                instructionImage.addGestureRecognizer(swipeRight)
                swipeRight.direction = .right
    }
    
    @objc func swipeImages(_ imageSwipe: UISwipeGestureRecognizer){
        
        if imageSwipe.direction == .left{
            if index >= 0 && index < 8{

                index = index + 1
            }
        }
        else if imageSwipe.direction == .right{
            if index > 0 && index < 9{
                index = index - 1
            }
        }
        display()
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
