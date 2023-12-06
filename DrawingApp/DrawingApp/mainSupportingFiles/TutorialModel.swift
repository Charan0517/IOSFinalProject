//
//  TutorialModel.swift
//  DrawingApp2
//
//  Created by Sri Charan Vattikonda on 11/26/23.
//

import Foundation


struct instruction{
    var instructionImage: String
    var instructionText: String
}


let instrcutions : [instruction] = [instruction(instructionImage: "fileName", instructionText: "Give a file name to save the file into the dashboard."), instruction(instructionImage: "DrawingControls", instructionText: "-> If you want to share the drawing to others click on share symbol\n-> Use the undo, redo, and clear options to remove the line or add the line, or to remove the whole drawing from the canvas.\n-> Use save button to save the drawing as an image into the device.\n-> Use favorites button to add the drawing into the favorites."), instruction(instructionImage: "colorController", instructionText: "Select the color you wish from the controller."), instruction(instructionImage: "linesControl", instructionText: "Use the first slider to adjust the width of the stroke, and second slider to set the opacity of the color."), instruction(instructionImage: "dashboard", instructionText: "The saved will be displyed on the dashboard page in a table cell"), instruction(instructionImage: "dashboardTofavorites", instructionText: "To add the file into favorites perform the leading swipe gesture."), instruction(instructionImage: "removeFavorites", instructionText: "Again do the leading swipe gesture to remove from favorites"), instruction(instructionImage: "share", instructionText: "To share the file perform the trailing swipe gesture."), instruction(instructionImage: "PlayGame", instructionText: "->This game is used to enhace your drawing it first givs you challenge to draw some thing that will be displayed on top.\n->On the white canvas start drawing.\n->Between the canvas and challenge display the predictions will be displayed on your imgae.\n->If you want to skip the current challenge click on the next challenge button in bottom right corner.\n->You can clear the canvas using clear button in bottom left corner.")]
