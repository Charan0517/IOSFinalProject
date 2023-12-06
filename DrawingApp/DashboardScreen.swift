//
//  DashboardScreen.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit



class DashboardScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, BlankPageDelegate{
    
    func updateDrawingData(_ drawingData: [Line], forDrawingWithName name: String) {
        //        if let index = dashBoardDrawing.firstIndex(where: {$0.name == name}){
        //            dashBoardDrawing[index].drawingData = drawingData
        //            dashboardTableView.reloadData()
        //        }
        dashboardTableView.reloadData()
    }
    
    
    var drawings: [Drawing] = []
    var selectedrRow = 0
    
    @IBOutlet weak var dashboardTableView: UITableView!
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dashBoardDrawing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dashboardTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DashboardCell
        cell.itemName.text = dashBoardDrawing[indexPath.row].name
        cell.img.image = dashBoardDrawing[indexPath.row].image
        cell.deleteBtn.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrRow = indexPath.row
        performSegue(withIdentifier: "dashMainSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dashMainSegue",let blankPageScreen = segue.destination as? BlankPageScreen {
            print(selectedrRow)
            let selectedDrawing = dashBoardDrawing[selectedrRow]
            
//            print(selectedDrawing.drawingData)
            //print(selectedDrawing.name)
            blankPageScreen.selectedDrawing = selectedDrawing
            //navigationItem.title = dashBoardDrawing[selectedrRow].name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem()
        backButton.title = "Home"
        navigationItem.backBarButtonItem = backButton
        dashboardTableView.delegate = self
        dashboardTableView.dataSource = self
//        fetchDrawingsFromFirestore(completion: {fetchDrawings in
//            dashBoardDrawing = fetchDrawings
//            self.dashboardTableView.reloadData()
//        })
       // fetchDrawingsFromFirestore()
        // print(dashBoardDrawing.count)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        fetchDrawingsFromFirestore(completion: {fetchDrawings in
//           dashBoardDrawing = fetchDrawings
//            //print(dashBoardDrawing)
//            //self.dashboardTableView.reloadData()
//        })
        dashboardTableView.reloadData()
        
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let name = dashBoardDrawing[indexPath.row].name
        let canvas = dashBoardDrawing[indexPath.row].drawingData
        let img = dashBoardDrawing[indexPath.row].image
        let index = favoritesDrawing.contains(where: {fileName in
            (fileName.name == name)})
        if index{
            let fav = UIContextualAction(style: .normal, title: "unfavorite", handler: {_,_,completion in
                if let index = favoritesDrawing.firstIndex(where: {meal in
                    meal.name == name}){
                    favoritesDrawing[index].isFavorite = false
                    deleteDrawingFromFavorites(drawingName: favoritesDrawing[index].name)
                    favoritesDrawing.remove(at: index)
                                    }
                completion(true)
            })
            //fav.title = "favorite"
            fav.backgroundColor = .darkGray
            let swipe = UISwipeActionsConfiguration(actions: [fav])
            return swipe
        }
        else{
            let unfav = UIContextualAction(style: .normal, title: "favorite", handler: {_,_,completion in
                favoritesDrawing.append(Drawing(name: name, image: img, drawingData: canvas, isFavorite: true))
                addDrawingToFavorites(drawing: canvas, fileName: name, isFav: false, imageData: img.pngData() ?? Data())
                completion(true)
            })
            //unfav.title = "unfavorite"
            unfav.backgroundColor = .gray
            let swipe = UISwipeActionsConfiguration(actions: [unfav])
            return swipe
            
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let share = UIContextualAction(style: .normal, title: "share", handler: {_,_,completion in
            //            let cell = self.dashboardTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DashboardCell
            //guard let canvasImage = cell.canvasView.getImage() else{return}
            guard let cell = tableView.cellForRow(at: indexPath) as? DashboardCell else {
                return
            }
            
            // Get the canvas image from the cell
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
