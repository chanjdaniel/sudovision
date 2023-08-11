//
//  Solver.swift
//  SudoVision
//
//  Created by Daniel Chan on 2023-08-08.
//

import Foundation
import SwiftUI
import Vision
import CoreGraphics
import os.log

class Solver: ObservableObject {
    

    var uiImage: UIImage?
    @Published var sudokuBoundingBox: CGRect?
    @Published var sudokuCellsList: [CGRect]?
    @Published var sudokuContentsList: [Int32]?
    @Published var sudokuSolution: [Int32]?
    var recognitionResults: [String] = []
    
    func initSolverImage(image: Image) {
        self.uiImage = image.asUIImage()
    }
    
    func detectSudoku() {
        guard self.uiImage != nil else { return }
        detectSudoku(in: uiImage!)
    }
    
    func detectSudoku(in image: UIImage) {
        
        var sudokuBoundingBox: CGRect?
        
        let group = DispatchGroup()
        
        let request = VNDetectRectanglesRequest { (request, error) in
            guard let observations = request.results as? [VNRectangleObservation] else {
                return
            }
            group.enter()
            DispatchQueue.global(qos: .default).async {
                guard let sudokuBoardObservation = observations.first else {
                    logger.debug("failed to observe rectangle")
                    group.leave()
                    return
                }
                sudokuBoundingBox = sudokuBoardObservation.boundingBox
                group.leave()
            }
        }
        
        // Convert the image to a CIImage
        let ciImage = CIImage(image: image)
        
        group.wait()
        
        // Create a Vision request handler
        let handler = VNImageRequestHandler(ciImage: ciImage!)
        
        // Perform the rectangle detection request
        request.maximumObservations = 1
        request.minimumAspectRatio = 0.99
        request.maximumAspectRatio = 1.01
        try? handler.perform([request])
        
        group.wait()
        self.sudokuBoundingBox = sudokuBoundingBox
    }
    
    func solveSudoku() {
        guard sudokuBoundingBox != nil else { return }
        self.sudokuCellsList = getSudokuCells(in: sudokuBoundingBox!)
        var sudokuIntArray: [Int32]?
        getSudokuContents()
        
        do {
            sudokuIntArray = try processStrToIntArray(strArray: recognitionResults)
            
            let solution: UnsafeMutablePointer<Int32> = sudokuSolver_Wrapper().solve_Wrapper(&sudokuIntArray!)
            
            let unWrappedSolution: [Int32] = Array(UnsafeBufferPointer(start: solution, count: 81))
            
            self.sudokuSolution = unWrappedSolution
        } catch {
            logger.debug("image does not contain a sudoku board")
            return
        }
        
        guard sudokuIntArray != nil else { return }
        self.sudokuContentsList = sudokuIntArray
    }
    
    func getSudokuCells(in sudokuBoardRect: CGRect) -> [CGRect] {
        var sudokuCells: [CGRect] = []
        let cellWidth = sudokuBoardRect.width / 9
        let cellHeight = sudokuBoardRect.height / 9
        
        for i in (0...8).reversed() {
            for j in 0...8 {
                let currX = sudokuBoardRect.minX + (CGFloat(j) * cellWidth)
                let currY = sudokuBoardRect.minY + (CGFloat(i) * cellHeight)
                let newCell = CGRect(x: currX, y: currY, width: cellWidth, height: cellHeight)
                sudokuCells.append(newCell)
            }
        }
        
        return sudokuCells
    }
    
    func getSudokuContents() {
        guard self.sudokuCellsList != nil else { return }
        let cgImage = uiImage!.cgImage
        debugPrint(self.sudokuCellsList![0].width)
        for cell in self.sudokuCellsList! {
            let imageWidth = CGFloat(cgImage!.width)
            let imageHeight = CGFloat(cgImage!.height)
            let resizedRect = CGRect(x: cell.minX * imageWidth, y: (1 - cell.maxY) * imageHeight, width: cell.width * imageWidth, height: cell.height * imageHeight)
            let cellImage = cgImage!.cropping(to: resizedRect)
            recognizeText(uiImage: UIImage(cgImage: cellImage!))
        }
    }
    
    // https://developer.apple.com/documentation/vision/recognizing_text_in_images
    func recognizeText(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLevel = .fast
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let results = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        // Process the recognized strings.
        let recognizedText = results.first ?? ""
        self.recognitionResults.append(recognizedText)
    }
    
    func processStrToIntArray(strArray: [String]) throws -> [Int32] {
        var result: [Int32] = []
        for str in strArray {
            if str == "" {
                result.append(0)
            } else if isValidSudokuCellRegex(string: str) && str != nil {
                result.append(Int32(str)!)
            } else {
                throw SudokuError.invalidImage
            }
        }
        return result
    }
    
    // https://www.codespeedy.com/check-if-a-string-is-a-valid-number-in-swift/
    func isValidSudokuCellRegex(string: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: "[1-9]")
        return regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) != nil
    }
    
    // https://developer.apple.com/documentation/coregraphics/cgimage/1454683-cropping
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)


        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)


        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }


        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    // https://stackoverflow.com/questions/49478678/set-image-contrast-swift
    func increaseContrast(_ image: UIImage) -> UIImage {
        let inputImage = CIImage(image: image)!
        let parameters = [
            "inputContrast": NSNumber(value: 2)
        ]
        let outputImage = inputImage.applyingFilter("CIColorControls", parameters: parameters)

        let context = CIContext(options: nil)
        let img = context.createCGImage(outputImage, from: outputImage.extent)!
        return UIImage(cgImage: img)
    }
    
    // https://gist.github.com/ntnmrndn/045abc4875291a50018b
    private func convertToGrayScale(image: CGImage) -> CGImage {
        let height = image.height
        let width = image.width
        let colorSpace = CGColorSpaceCreateDeviceGray();
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext.init(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(image, in: rect)
        return context.makeImage()!
    }
    
    enum SudokuError: Error {
        case invalidImage
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.sudovision", category: "Solver")
