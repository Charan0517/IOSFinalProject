//
//  FavoritesCell.swift
//  DrawingApp
//
//  Created by Sri Charan Vattikonda on 12/5/23.
//

import UIKit

class FavoritesCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBAction func deleteDrawing(_ sender: UIButton) {
        guard let indexPath = getIndexPathForCellButton(sender) else {
                return
            }
            let drawingToDelete = favoritesDrawing[indexPath.row]
        favoritesDrawing.remove(at: indexPath.row)

            if let favoriteIndex = dashBoardDrawing.firstIndex(where: { $0.name == drawingToDelete.name }) {
                dashBoardDrawing.remove(at: favoriteIndex)
                deleteDrawingFromFavorites(drawingName: drawingToDelete.name)
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
