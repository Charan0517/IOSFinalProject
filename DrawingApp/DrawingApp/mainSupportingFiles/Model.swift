//
//  Model.swift
//  DrawingApp2
//
//  Created by Sri Charan Vattikonda on 11/20/23.
//

import Foundation
import UIKit

struct Drawing {
    var name: String
    var image: UIImage
    var drawingData: [Line]
    var isFavorite = false
}



var favoritesDrawing:[Drawing] = []
var dashBoardDrawing:[Drawing] = []
