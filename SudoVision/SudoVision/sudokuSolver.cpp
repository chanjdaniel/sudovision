//
//  sudokuSolver.cpp
//  SudoVision
//
//  Created by Daniel Chan on 2023-08-09.
//

#include "sudokuSolver.hpp"

// return bitmask with all zeros and a 1 at the position at num + 1
unsigned short sudokuSolver::get_mask(int num) {

    unsigned short mask = 0b000000001;
    for (int i = 1; i < num; i++) {
        mask = mask << 1;
    }

    return mask;
}

// init sudoku state from input
vector<vector<unsigned short> > sudokuSolver::init_sudoku_state(const array<int, 81>& input) {

    unsigned short full_set = 0b111111111;
    vector<unsigned short> row (9, full_set);
    vector< vector<unsigned short> > state (9, row);

    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {

            int pos = (r * 9) + c;
            if (input[pos] == 0) { continue; }

            state[r][c] = get_mask(input[pos]);
        }
    }

    return state;
}

// check if set contains one value
bool sudokuSolver::isConstrained(unsigned short set) {

    unsigned short num = 0b000000001;

    for (int i = 0; i < 9; i++) {
        if (set == num) { return true; }
        num = num << 1;
    }

    return false;
}

// check if state is violating
bool sudokuSolver::isViolating(const vector<vector<unsigned short> >& state) {

    // iterate over rows
    for (int r = 0; r < 9; r++) {
        vector<int> constrained_sets = vector<int>();
        for (int c = 0; c < 9; c++) {

            // check for any empty sets
            if (state[r][c] == 0) { return true; }

            if (!isConstrained(state[r][c])) { continue; }
            if (find(constrained_sets.begin(), constrained_sets.end(), state[r][c]) != constrained_sets.end()) { return true; }
            constrained_sets.push_back(state[r][c]);
        }
    }

    // iterate over columns
    for (int c = 0; c < 9; c++) {
        vector<int> constrained_sets = vector<int>();
        for (int r = 0; r < 9; r++) {
            if (!isConstrained(state[r][c])) { continue; }
            if (find(constrained_sets.begin(), constrained_sets.end(), state[r][c]) != constrained_sets.end()) { return true; }
            constrained_sets.push_back(state[r][c]);
        }
    }

    // iterate over 3x3 sections
    for (int r_o = 0; r_o < 9; r_o += 3) {
        for (int c_o = 0; c_o < 9; c_o += 3) {
            vector<int> constrained_sets = vector<int>();
            for (int r = 0; r < 3; r++) {
                for (int c = 0; c < 3; c++) {
                    if (!isConstrained(state[r + r_o][c + c_o])) { continue; }
                    if (find(constrained_sets.begin(), constrained_sets.end(), state[r + r_o][c + c_o]) != constrained_sets.end()) { return true; }
                    constrained_sets.push_back(state[r + r_o][c + c_o]);
                }
            }
        }
    }

    return false;
}

// check if state is solution
bool sudokuSolver::isSolution(const vector<vector<unsigned short> >& state) {

    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            if (!isConstrained(state[r][c])) { return false; }
        }
    }

    return true;
}

// propogate constraints when new set is constrained
void sudokuSolver::propogate_constraint(vector<vector<unsigned short> >& state, int pos_r, int pos_c) {

    // propogate over row
    for (int c = 0; c < 9; c++) {
        if (c == pos_c) { continue; }
        state[pos_r][c] = state[pos_r][c] & ~state[pos_r][pos_c];
    }

    // propogate over column
    for (int r = 0; r < 9; r++) {
        if (r == pos_r) { continue; }
        state[r][pos_c] = state[r][pos_c] & ~state[pos_r][pos_c];
    }

    // propogate over 3x3 section
    int start_r = pos_r;
    int start_c = pos_c;

    while (start_r % 3 != 0) { start_r--; }
    while (start_c % 3 != 0) { start_c--; }

    for (int r = start_r; r < start_r + 3; r++) {
        for (int c = start_c; c < start_c + 3; c++) {
            if (r == pos_r || c == pos_c) { continue; }
            state[r][c] = state[r][c] & ~state[pos_r][pos_c];
        }
    }
}

// propogate constraints for state
void sudokuSolver::propogate_constraints(vector<vector<unsigned short> >& state) {

    vector<int> row (9,0);
    vector<vector<int> > visited (9, row);
    
    start:
    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            if (isConstrained(state[r][c]) && !visited[r][c]) {
                propogate_constraint(state, r, c);
                visited[r][c] = 1;
                goto start;
            }
        }
    }
}

// gets child nodes for use in dfs
vector<vector<vector<unsigned short> > > sudokuSolver::get_children(vector<vector<unsigned short> >& state) {

    vector<vector<vector<unsigned short> > > result = vector<vector<vector<unsigned short> > >();
    unsigned short selection = 0;
    int selection_r;
    int selection_c;

    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            if (!isConstrained(state[r][c])) {
                selection = state[r][c];
                selection_r = r;
                selection_c = c;
                goto next;
            }
        }
    }

    return result;

    next:
    unsigned short mask = 0b000000001;
    for (int i = 0; i < 9; i++) {
        if ((selection & mask) != 0) {
            vector<vector<unsigned short> > state_copy = state;
            state_copy[selection_r][selection_c] = mask;
            propogate_constraints(state_copy);
            if (!isViolating(state_copy)) {
                result.push_back(state_copy);
            }
        }
        mask = mask << 1;
    }

    return result;
}

// converts binary set to int
int sudokuSolver::set_to_int(unsigned short set) {

    if (!isConstrained(set)) { return 0; }

    unsigned short curr = set;
    for (int i = 0; i <= 9; i++) {
        if (curr == 0) { return i; }
        curr = curr >> 1;
    }

    return -1;
}

// converts vector<vector<unsigned short> > vector to array<int, 81>
array<int, 81> sudokuSolver::vector_2d_to_array(vector<vector<unsigned short> >& toConvert) {
    array<int, 81> result = array<int, 81>();
    int pos = 0;
    for (size_t r = 0; r < 9; r++) {
        for (size_t c = 0; c < 9; c++) {
            result[pos] = toConvert[r][c];
            pos++;
        }
    }
    
    return result;
}

// prints state to console
void sudokuSolver::print_state(vector<vector<unsigned short> >& state) {

    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            cout << set_to_int(state[r][c]) << " ";
        }
        cout << endl;
    }
}

// prints state to console from array
void sudokuSolver::print_state_array(array<int, 81>& state) {

    int pos = 0;
    for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
            cout << set_to_int(state[pos]) << " ";
            pos++;
        }
        cout << endl;
    }
}

// dfs with pruning
array<int, 81> sudokuSolver::solve() {

    int iterations = 0;

    // dfs with pruning
    vector<vector<vector<unsigned short> > > stack = vector<vector<vector<unsigned short> > >();
    stack.push_back(state);

    while (stack.size() > 0) {
        iterations++;
        cout << stack.size() << endl;
        vector<vector<unsigned short> > curr = stack[stack.size() - 1];
        stack.pop_back();

        // exit if solution
        if (isSolution(curr)) {
            cout << "iterations: " << iterations << endl;
            array<int, 81> solution = vector_2d_to_array(curr);
            print_state_array(solution);
            array<int, 81> convertedSolution;
            for (int i = 0; i < solution.size(); i++) {
                convertedSolution[i] = set_to_int(solution[i]);
            }
            return convertedSolution;
        }

        // add children to stack
        vector<vector<vector<unsigned short> > > children = get_children(curr);
        for (int i = 0; i < children.size(); i++) {
            stack.push_back(children[i]);
        }
    }

    // no solution
    return array<int, 81>();
}
