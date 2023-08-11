# sudovision
iOS app built using Swift for recognizing sudoku puzzles, then solving them and overlaying the solution onto the image.
Camera and gallery access functionality taken from CapturingPhotos sample app by Apple.
OCR using Apple's Vision framework.

**Current functionality**
- Able to reliably detect sudoku puzzles in screenshots and semi-accurately display the solution as an overlay.

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

Solution is overlayed onto image on button press

<img src="https://github.com/chanjdaniel/sudovision/assets/97641190/9f11ad1a-7730-4978-8ac9-ef6e6da693ad" width="200">
