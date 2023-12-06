//
//  DashboardCell.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit

class DashboardCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var itemName: UILabel!
    
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBAction func deleteDrawing(_ sender: UIButton) {
        guard let indexPath = getIndexPathForCellButton(sender) else {
            return
        }
        let drawingToDelete = dashBoardDrawing[indexPath.row]
        dashBoardDrawing.remove(at: indexPath.row)
        deleteDrawingFromFirestore(drawingName: drawingToDelete.name)
        if let favoriteIndex = favoritesDrawing.firstIndex(where: { $0.name == drawingToDelete.name }) {
            favoritesDrawing.remove(at: favoriteIndex)
        }
        if let tableView = superview as? UITableView {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    private func getIndexPathForCellButton(_ button: UIButton) -> IndexPath? {
        let point = button.convert(CGPoint.zero, to: superview)
        return (superview as? UITableView)?.indexPathForRow(at: point)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        canvasView.isUserInteractionEnabled = false
//        print(canvasView.frame.size)
//        print(canvasView.bounds.size)
        
    }
    
    }
