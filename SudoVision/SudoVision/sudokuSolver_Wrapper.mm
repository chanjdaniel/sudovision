//
//  sudokuSolver_Wrapper.mm
//  SudoVision
//
//  Created by Daniel Chan on 2023-08-09.
//

#import "sudokuSolver_Wrapper.h"
#import "sudokuSolver.hpp"

@implementation sudokuSolver_Wrapper

std::unique_ptr<sudokuSolver> solver;

-(int *) solve_Wrapper: (int *) input
{
    std::array<int, 81> convertedInput = std::array<int, 81>();
    int i;
    for (i = 0; i < 81; i++) {
        convertedInput[i] = *(input + i);
    }
    
    solver.reset(new sudokuSolver(convertedInput));
    array<int, 81> output = solver->solve();
    
    static int convertedOutput[81];
    int j;
    for (j = 0; j < 81; j++) {
        convertedOutput[j] = output[j];
    }
    
    return convertedOutput;
}

@end
