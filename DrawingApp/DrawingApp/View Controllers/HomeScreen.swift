//
//  HomeScreen.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit
import Lottie

class HomeScreen: UIViewController {

    @IBOutlet weak var blankPage: UIButton!
    
    @IBOutlet weak var dashboardPage: UIButton!
    
    @IBOutlet weak var favoritesPage: UIButton!
    
    @IBOutlet weak var tutorialPage: UIButton!
    
    @IBOutlet weak var playGameBtn: UIButton!
    
    @IBOutlet weak var initialView: LottieAnimationView!
    
    @IBAction func BlankPage(_ sender: UIButton) {
        self.performSegue(withIdentifier: "BlankPage", sender: self)
    }
   
    @IBAction func Dashboard(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Dashboard", sender: self)
    }
    
    @IBAction func Favorites(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Favorites", sender: self)
    }
    
    @IBAction func Tutorial(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Tutorial", sender: self)
    }
    
    
    @IBAction func PlayGameBtnAction(_ sender: UIButton) {
        performSegue(withIdentifier: "playGameSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        switch identifier {
        case "BlankPage":
            guard let blankPage = segue.destination as? BlankPageScreen else{return}
            blankPage.navigationItem.title = "Blank Page"
        case "Dashboard":
            guard let dashboard = segue.destination as? DashboardScreen else{return}
            dashboard.navigationItem.title = "Dashboard"
        case "Favorites":
            guard let favorites = segue.destination as? FavoritesScreen else{return}
            favorites.navigationItem.title = "Favorites"
        case "Tutorial":
            guard let tutorial = segue.destination as? TutorialScreen else{return}
            tutorial.navigationItem.title = "Instructions"
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView.animation = .named("Initial")
        initialView.play(){ _ in
            self.initialView.isHidden = true
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blankPage.layer.cornerRadius = 20
        dashboard.layer.cornerRadius = 20
        favorites.layer.cornerRadius = 20
        tutorial.layer.cornerRadius = 20
        playGameBtn.layer.cornerRadius = 20
        fetchDrawingsFromFirestore(completion: {fetchDrawings in
           dashBoardDrawing = fetchDrawings
            //print(dashBoardDrawing)
            //self.dashboardTableView.reloadData()
        })
        
        fetchDrawingsFromFavorites(completion: {fetchDrawings in
            favoritesDrawing = fetchDrawings
             //print(dashBoardDrawing)
             //self.dashboardTableView.reloadData()
         })
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
