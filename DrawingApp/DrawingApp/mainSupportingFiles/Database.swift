//
//  File.swift
//  DrawingApp2
//
//  Created by Sri Charan Vattikonda on 11/28/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage


class utilityConstants{
    static let db = Firestore.firestore()
    static let dbScoresRef = db.collection("game").document("score")
    static let dbdrawingRef = db.collection("drawings")
    static let dbfavoritesRef = db.collection("favorites")
}

func addDrawingToFirestore(drawing: [Line], fileName: String, isFav: Bool, imageData: Data) {
    let collectionRef = utilityConstants.dbdrawingRef
    
    let drawingDocumentRef = collectionRef.document(fileName)
    
    drawingDocumentRef.setData([
        "name": fileName,
        "drawingData": convertDrawingDataToDictionary(drawing),
        "image": imageData,
        "isFavorite": isFav
    ]) { error in
        if let error = error {
            print("Error adding drawing to Firestore: \(error.localizedDescription)")
        } else {
            print("Drawing added to Firestore successfully!")        }
    }
}


func fetchDrawingsFromFirestore(completion: @escaping ([Drawing]) -> Void) {
    let drawingsCollection = utilityConstants.dbdrawingRef
    

    drawingsCollection.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error fetching drawings from Firestore: \(error)")
            completion([])
        } else {
            var fetchedDrawings: [Drawing] = []

            for document in querySnapshot?.documents ?? [] {
                let drawingData = document.data()
                let name = drawingData["name"] as? String ?? ""
               // let draw = drawingData["drawingData"] as? [String:Any]
                let drawingLines = parseDrawingData(drawingData)
               // print(draw)
                if let imageData = drawingData["image"] as? Data,
                                   let image = UIImage(data: imageData) {
                                    let drawing = Drawing(name: name, image: image, drawingData: drawingLines, isFavorite: (drawingData["isFavorite"] != nil))
                                    fetchedDrawings.append(drawing)
                                }
            }

            completion(fetchedDrawings)
        }
    }
}

func updateDrawingInFirestore(drawing: [Line], fileName: String, isFav: Bool, imageData: Data) {
    let drawingsCollection = utilityConstants.dbdrawingRef
    let favoritesCollection = utilityConstants.dbfavoritesRef

    let drawingData: [String: Any] = [
        "name": fileName,
        "drawingData": convertDrawingDataToDictionary(drawing),
        "isFavorite": isFav,
        "image": imageData
    ]

    drawingsCollection.document(fileName).updateData(drawingData) { error in
        if let error = error {
            print("Error updating drawing in Firestore: \(error)")
        } else {
            print("Drawing updated in Firestore successfully!")
        }
    }
    
    favoritesCollection.document(fileName).updateData(drawingData) { error in
        if let error = error {
            print("Error updating drawing in favorites Firestore: \(error)")
        } else {
            print("Drawing updated in favorites Firestore successfully!")
        }
    }
}


func deleteDrawingFromFirestore(drawingName: String) {
    let drawingsCollection = utilityConstants.dbdrawingRef
    let favoriteCollection = utilityConstants.dbfavoritesRef

    drawingsCollection.document(drawingName).delete { error in
        if let error = error {
            print("Error deleting drawing from Firestore: \(error)")
        } else {
            print("Drawing deleted from Firestore successfully!")
        }
    }
    
    favoriteCollection.document(drawingName).delete { error in
        if let error = error {
            print("Error deleting drawing from Firestore: \(error)")
        } else {
            print("Drawing deleted from Firestore successfully!")
        }
    }
}

func addDrawingToFavorites(drawing: [Line], fileName: String, isFav: Bool, imageData: Data) {
    let collectionRef = utilityConstants.dbfavoritesRef
    let drawingDocumentRef = collectionRef.document(fileName)
    
    drawingDocumentRef.setData([
        "name": fileName,
        "drawingData": convertDrawingDataToDictionary(drawing),
        "image": imageData,
        "isFavorite": isFav
    ]) { error in
        if let error = error {
            print("Error adding drawing to Firestore: \(error.localizedDescription)")
        } else {
            print("Drawing added to Firestore successfully!")
        }
    }
}

func fetchDrawingsFromFavorites(completion: @escaping ([Drawing]) -> Void) {
    let drawingsCollection = utilityConstants.dbfavoritesRef

    drawingsCollection.getDocuments { (querySnapshot, error) in
        if let error = error {
            print("Error fetching drawings from Firestore: \(error)")
            completion([])
        } else {
            var fetchedDrawings: [Drawing] = []

            for document in querySnapshot?.documents ?? [] {
                let drawingData = document.data()
                let name = drawingData["name"] as? String ?? ""
               // let draw = drawingData["drawingData"] as? [String:Any]
                let drawingLines = parseDrawingData(drawingData)
               // print(draw)
                if let imageData = drawingData["image"] as? Data,
                                   let image = UIImage(data: imageData) {
                                    let drawing = Drawing(name: name, image: image, drawingData: drawingLines, isFavorite: (drawingData["isFavorite"] != nil))
                                    fetchedDrawings.append(drawing)
                                }
            }

            completion(fetchedDrawings)
        }
    }
}

func deleteDrawingFromFavorites(drawingName: String) {
    let favoriteCollection = utilityConstants.dbfavoritesRef

    favoriteCollection.document(drawingName).delete { error in
        if let error = error {
            print("Error deleting drawing from Firestore: \(error)")
        } else {
            print("Drawing deleted from Firestore successfully!")
        }
    }
}
func convertDrawingDataToDictionary(_ drawingData: [Line]) -> [[String: Any]] {
    return drawingData.map { line in
        [
            "points": line.points.map { point in
                ["x": point.x, "y": point.y]
            },
            "strokeColor": line.strokeColor.hexString(), // You may need to implement this conversion
            "strokeWidth": line.strokeWidth,
            "opacity": line.opacity
        ]
    }
}

func parseDrawingData(_ drawingData: [String: Any]) -> [Line] {
    guard let draw = drawingData["drawingData"] as? [[String: Any]] else {
        return []
    }

    return draw.compactMap { drawItem in
        guard
            let pointsArray = drawItem["points"] as? [[String: CGFloat]],
            let strokeColorHex = drawItem["strokeColor"] as? String,
            let strokeWidth = drawItem["strokeWidth"] as? CGFloat,
            let opacity = drawItem["opacity"] as? CGFloat,
            let strokeColor = UIColor(hexString: strokeColorHex)
        else {
            return nil
        }

        let points = pointsArray.map { pointDict in
            return CGPoint(x: pointDict["x"] ?? 0, y: pointDict["y"] ?? 0)
        }

        return Line(points: points, strokeColor: strokeColor, strokeWidth: strokeWidth, opacity: opacity)
    }
}



extension UIColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}


extension UIColor {
    func hexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255.0)
        let greenInt = Int(green * 255.0)
        let blueInt = Int(blue * 255.0)

        return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
    }
}


