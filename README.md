# sudovision
iOS app built using Swift for recognizing sudoku puzzles, then solving them and overlaying the solution onto the image.
Camera and gallery access functionality borrowed from CapturingPhotos sample app by Apple.
OCR using Apple's Vision framework.

<p>&nbsp;</p>

**Vision**

Detection of sudoku grids is done using [VNDetectRectanglesRequest](https://developer.apple.com/documentation/vision/vndetectrectanglesrequest) from Apple's [Vision](https://developer.apple.com/documentation/vision) framework.
The sudoku grid is assumed to be the largest square within an image. Values contained within the grid are obtained by evenly splitting the bounding box into a 9x9 grid, then cropping the original image using each cell and running OCR using [VNRecognizeTextRequest](https://developer.apple.com/documentation/vision/vnrecognizetextrequest). This is transformed into an array of integers that is fed into a sudoku solving algorithm.

<p>&nbsp;</p>

**Sudoku solving algorithm**

The sudoku solving algorithm, written in C++, models sudoku puzzles as [Constraint satisfaction problems](https://en.wikipedia.org/wiki/Constraint_satisfaction_problem) where the constraints are that no row, column, or block can contain more than one of each number from 1 to 9.
Each cell of the puzzle is represented by a set of possible values. Empty cells are initialized as the set {1, 2, 3, ..., 9}, and clue cells are initialized as the set containing only the clue number.
As a minor optimization, sets of numbers are represented as 16-bit unsigned integers where the inclusion of a number *n* in the set is represented by the (*n* - 1)<sup>th</sup> bit being set to 1. Set operations are done using bitwise operations (*e.g.* {1, 2, 3} - {1} = 0000000000000111 & ~0000000000000001).
Iterative DFS is used to search the state space, pruning any states that violate the constraints. This is done until a state is found where all cells contain a set containing a single number, or no more states are left to search.

<p>&nbsp;</p>

**Limitations and future directions**
1. Unable to accurately recognize puzzles that are smaller
   * Need to add additional image pre-processing before performing OCR
2. Unable to accurately recognize puzzles that are not perfectly square due to perspective distortion
   * Need to add manual adjustment of automatic recognition area
   * Need to add perspective correction for camera distortion

<p>&nbsp;</p>

**Example usage**

Image selected from gallery

<img src="https://github.com/chanjdaniel/sudovision/assets/97641190/9c00f31b-d30e-4a23-b6f8-75a321107af6" width="200">

<p>&nbsp;</p>

Automatic detection of sudoku puzzle on button press

<img src="https://github.com/chanjdaniel/sudovision/assets/97641190/d5493e7d-4883-452a-aa4f-ec2537fb17e4" width="200">

<p>&nbsp;</p>

Solution is overlaid onto image on button press

<img src="https://github.com/chanjdaniel/sudovision/assets/97641190/9f11ad1a-7730-4978-8ac9-ef6e6da693ad" width="200">
