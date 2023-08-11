//
//  sudokuSolver.hpp
//  SudoVision
//
//  Created by Daniel Chan on 2023-08-09.
//

#ifndef sudokuSolver_hpp
#define sudokuSolver_hpp

#include <stdio.h>
#include <iostream>
#include <bitset>
#include <algorithm>
#include <iterator>
#include <vector>
#include <array>

using std::cout;
using std::endl;
using std::fill;
using std::array;
using std::vector;

class sudokuSolver {

public:
    array<int, 81> input;
    vector<vector<unsigned short> > state;
    int * sudokuSolution;

    sudokuSolver(array<int, 81> input_array) {
        input = input_array;
        state = init_sudoku_state(input_array);
    }

    // dfs with prunin
    array<int, 81> solve();

    // prints state to console
    void print_state(vector<vector<unsigned short> >& state);

    // prints state to console from array
    void print_state_array(array<int, 81>& state);

private:
    // return bitmask with all zeros and a 1 at the position at num + 1
    unsigned short get_mask(int num);

    // init sudoku state from input
    vector<vector<unsigned short> > init_sudoku_state(const array<int, 81>& input);

    // check if set contains one value
    bool isConstrained(unsigned short);

    // check if state is violating
    bool isViolating(const vector<vector<unsigned short> >& state);

    // check if state is solution
    bool isSolution(const vector<vector<unsigned short> >& state);

    // propogate constraints when new set is constrained
    void propogate_constraint(vector<vector<unsigned short> >& state, int pos_x, int pos_y);

    // propogate constraints for state
    void propogate_constraints(vector<vector<unsigned short> >& state);

    // gets child nodes for use in dfs
    vector<vector<vector<unsigned short> > > get_children(vector<vector<unsigned short> >& state);

    // converts binary set to int
    int set_to_int(unsigned short set);

    // converts vector<vector<vector<unsigned short> > > vector to array<int, 81>
    array<int, 81> vector_2d_to_array(vector<vector<unsigned short> >& toConvert);
};

#endif /* sudokuSolver_hpp */
