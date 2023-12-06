//
//  FavoritesScreen.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit

class FavoritesScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, BlankPageDelegate {
    
    func updateDrawingData(_ drawingData: [Line], forDrawingWithName name: String) {
        favoritesTableView.reloadData()
    }

    @IBOutlet weak var favoritesTableView: UITableView!
    
    var selectedrRow = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(favoritesDrawing.count)
        return favoritesDrawing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoritesTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FavoritesCell
        cell.itemName.text = favoritesDrawing[indexPath.row].name
        cell.img.image = favoritesDrawing[indexPath.row].image
        cell.deleteBtn.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let name = favoritesDrawing[indexPath.row].name
        let draw = favoritesDrawing[indexPath.row].drawingData
        let fav = UIContextualAction(style: .normal, title: "unfavorite", handler: {_,_,completion in
            if let index = favoritesDrawing.firstIndex(where: {meal in
                meal.name == name}){
               // print("Hi")
                favoritesDrawing[index].isFavorite = false
                //addDrawingToFavorites(drawing: draw, fileName: name, isFav: false, imageData: <#T##Data#>)
                deleteDrawingFromFavorites(drawingName: favoritesDrawing[index].name)
                favoritesDrawing.remove(at: index)
                self.favoritesTableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completion(true)
        })
        //fav.title = "favorite"
        fav.backgroundColor = .darkGray
        let swipe = UISwipeActionsConfiguration(actions: [fav])
        return swipe
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = UIContextualAction(style: .normal, title: "share", handler: {_,_,completion in
            guard let cell = tableView.cellForRow(at: indexPath) as? favoritesCell else {
                return
            }
            guard let canvasImage = cell.img else {
                return
            }
            
            
            
            let items: [Any] = [canvasImage.image ?? UIImage()]
            
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: cell.bounds.midX, y: cell.bounds.midY, width: 0, height: 0)
            
            self.present(activityViewController, animated: true, completion: nil)
            
            completion(true)
        })
        share.backgroundColor = .blue
        let swipe = UISwipeActionsConfiguration(actions: [share])
        return swipe
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem()
        backButton.title = "Home"
        navigationItem.backBarButtonItem = backButton
        
        print(favoritesDrawing)
        
        // print(dashBoardDrawing)
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoritesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrRow = indexPath.row
        performSegue(withIdentifier: "favMainSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favMainSegue",let favPageScreen = segue.destination as? BlankPageScreen {
            // print(selectedrRow)
            let selectedDrawing = favoritesDrawing[selectedrRow]
            
            favPageScreen.selectedDrawing = selectedDrawing
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
