//
//  SolverView.swift
//
//
//  Created by Daniel Chan on 2023-08-07.
//

import Foundation
import SwiftUI
import UIKit
import Vision
import os.log

struct SolverView: View {
    
    let image: Image
    let uiImage: UIImage
    @StateObject private var solver = Solver()
    
    init(image: Image) {
        self.image = image
        self.uiImage = image.asUIImage()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                if solver.sudokuBoundingBox != nil && solver.sudokuSolution == nil{
                    boundingBoxView(geometry: geometry)
                }
                
                if solver.sudokuSolution != nil {
                    let imgHeight = (uiImage.size.height * geometry.size.width) / uiImage.size.width
                    let y_offset = (geometry.size.height - imgHeight) * 0.5
                    let x_adjust: CGFloat = geometry.size.width
                    let y_adjust: CGFloat = imgHeight
                    ForEach(0..<81) { i in
                        if solver.sudokuContentsList![i] == 0 {
                            let cell: CGRect = solver.sudokuCellsList![i]
                            let posX = (cell.minX + (cell.width * 0.5)) * x_adjust
                            let posY = ((1 - (cell.minY + (cell.height * 0.5))) * y_adjust) + y_offset
                            let num: Int32 = solver.sudokuSolution![i]
                            let numText: Text = Text(String(num))
                            let fontSize = (300 * cell.width).rounded()
                            numText
                                .foregroundColor(.black)
                                .font(.system(size: fontSize))
                                .position(x: posX, y: posY)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.black)
        .overlay(alignment: .bottom) {
            buttonsView()
                .offset(x: 0, y: -50)
        }
    }
    
    private func boundingBoxView(geometry: GeometryProxy) -> some View {
        Path { p in
            let imgHeight = (uiImage.size.height * geometry.size.width) / uiImage.size.width
            let y_offset = (geometry.size.height - imgHeight) * 0.5
            let x_adjust: CGFloat = geometry.size.width
            let y_adjust: CGFloat = imgHeight
            let cell = solver.sudokuBoundingBox!
            p.addLines([
                CGPoint(x: cell.minX * x_adjust, y: ((1 - cell.minY) * y_adjust) + y_offset),
                CGPoint(x: cell.maxX * x_adjust, y: ((1 - cell.minY) * y_adjust) + y_offset),
                CGPoint(x: cell.maxX * x_adjust, y: ((1 - cell.maxY) * y_adjust) + y_offset),
                CGPoint(x: cell.minX * x_adjust, y: ((1 - cell.maxY) * y_adjust) + y_offset)
            ])
        }
        .fill(.red)
        .opacity(0.4)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Button {
                if solver.sudokuBoundingBox != nil && solver.sudokuSolution == nil {
                    debugPrint("solve button activated")
                    solver.solveSudoku()
                }
            } label: {
                Label("Solve", systemImage: "checkmark.square.fill")
                    .font(.system(size: 24))
            }

            Button {
                if solver.sudokuBoundingBox == nil {
                    solver.initSolverImage(image: self.image)
                    solver.detectSudoku()
                }
            } label: {
                Label("Select", systemImage: "selection.pin.in.out")
                    .font(.system(size: 24))
            }
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
        .background(Color.secondary.colorInvert())
        .cornerRadius(15)
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.sudovision", category: "SolverView")
