# Warehouse_planning

This project is aimed to compare the performances of the Answer Set Programming and MiniZinc languages.
The planning problem used for the comparison is a warehouse planning problem, where we need to move boxes out of a warehouse. 📦

### Constraints

The boxes can only be moved, and not pushed (in a similar fashion to the "Sokoban" game); the worker's movement is not taken into account.  
Multiple aligned boxes can all be pushed with a single move. ➡️📦📦  
The warehouse also contains drawers that act as obstacles (they cannot be moved). 🚫

### Goal

The goal is to push all boxes out of a door, trying to find the plan with the minimum number of moves.

Project realized for the Automated Reasoning course for the M.S. degree "Artificial Intelligence & Cybersecurity" @ University of Udine, 2023
