%%% 
% Author: Francesca Filice
% 10/02/2024 - Università della Calabria
%%%



% INPUT:
% This program takes in input some matrices of 512x512 pixels, represented by facts in the following form: 
% cell(R,C,CLASS)
% where CLASS is the class of the cell at row R and column C.
% For each matrix, it must exists an atom of the form class(FILENAME), where:
% - class is the name of the class this matrix represents
% - FILENAME is the name of the image file these facts represent

% OUTPUT:
% This program gives in output some facts in the form new_cell(R,C,CLASS), which represent
% the new matrix (thus, the new augmented image).

% how to run:
% dlv2-linux-64bit-python2.7/dlv2 augmented_label_generator_vocalfolds.asp external_atoms.py <input_group> <input_background> <input_pathology> <input_intubation> <input_surgical_tool> --silent --filter=new_cell/3 > output.txt
% where:
% - <input_group> (mandatory) is the path to a txt file containing only one fact of the form: group(X), where X is a number from 1 to 5. This refers to the group of the image one wants to generate.
% - <input_background> (mandatory) is the path to a txt file containing the facts which represent the background
% - <input_pathology> (optional, depends on group) is the path to a txt file containing the facts which represent the pathology
% - <input_intubation> (optional, depends on group) is the path to a txt file containing the facts rhich represent the intubation
% - <input_surgical_tool> (optional, depends on group) is the path to a txt file containing the facts rhich represent the surgical tool
% - output.txt is the file containing the output (note that, if the provided input violates one or more constraints, then output.txt will contain 'INCOHERENT')




% exactly one background image
:- #count{FILENAME : background(FILENAME)} <> 1.

:- group(N), N<0.
:- group(N), N>5.

% exactly one group (among group 1..5) must be received in input
:- #count{N : group(N)} <> 1.

% constraints for GROUP 1 images:
%   - pathology is exactly one
%   - intubation does not appear
%   - surgical tool does not appear
:- group(1), #count{FILENAME : pathology(FILENAME)} <> 1.
:- group(1), intubation(_).
:- group(1), surgical_tool(_).

% constraints for GROUP 2 images:
%   - pathology is exactly one
%   - intubation is exactly one
%   - surgical tool is exactly one
:- group(2), #count{FILENAME : pathology(FILENAME)} <> 1.
:- group(2), #count{FILENAME : intubation(FILENAME)} <> 1.
:- group(2), #count{FILENAME : surgical_tool(FILENAME)} <> 1.

% constraints for GROUP 3 images:
%   - pathology does not appear
%   - intubation is exactly one
%   - surgical tool does not appear
:- group(3), pathology(_).
:- group(3), #count{FILENAME : intubation(FILENAME)} <> 1.
:- group(3), surgical_tool(_).

% constraints for GROUP 4 images:
%   - pathology does not appear
%   - intubation is exactly one
%   - surgical tool is exactly one
:- group(4), pathology(_).
:- group(4), #count{FILENAME : intubation(FILENAME)} <> 1.
:- group(4), #count{FILENAME : surgical_tool(FILENAME)} <> 1.

% constraints for GROUP 5 images:
%   - pathology does not appear
%   - intubation is exactly one
%   - surgical tool is exactly one
:- group(5), pathology(_).
:- group(5), #count{FILENAME : intubation(FILENAME)} <> 1.
:- group(5), #count{FILENAME : surgical_tool(FILENAME)} <> 1.


% look for the 12 pivot points of the pathology and intubation class

min_row(ROW, CLASS) :- cell(ROW, _, CLASS), ROW = #min{R : cell(R, _, CLASS)}.
min_col(COL, CLASS) :- cell(_, COL, CLASS), COL = #min{C : cell(_, C, CLASS)}.
max_row(ROW, CLASS) :- cell(ROW, _, CLASS), ROW = #max{R : cell(R, _, CLASS)}.
max_col(COL, CLASS) :- cell(_, COL, CLASS), COL = #max{C : cell(_, C, CLASS)}.

{pivot(R, C, 12, pathology) : min_row(R, pathology), cell(R, C, pathology)} = 1 :- pathology(_).
{pivot(R, C, 6, pathology) : max_row(R, pathology), cell(R, C, pathology)} = 1 :- pathology(_).
{pivot(R, C, 3, pathology) : max_col(C, pathology), cell(R, C, pathology)} = 1 :- pathology(_).
{pivot(R, C, 9, pathology) : min_col(C, pathology), cell(R, C, pathology)} = 1 :- pathology(_).

{pivot(R, C, 12, intubation) : min_row(R, intubation), cell(R, C, intubation)} = 1 :- intubation(_).
{pivot(R, C, 6, intubation) : max_row(R, intubation), cell(R, C, intubation)} = 1 :- intubation(_).
{pivot(R, C, 3, intubation) : max_col(C, intubation), cell(R, C, intubation)} = 1 :- intubation(_).
{pivot(R, C, 9, intubation) : min_col(C, intubation), cell(R, C, intubation)} = 1 :- intubation(_).

pivot(R, C, 1, CLASS) :- pivot(_, C3, 3, CLASS), pivot(_, C12, 12, CLASS), DIST=C3-C12, C=C12+DIST/2, R = #min{ROW : cell(ROW, C, CLASS)}.
pivot(R, C, 2, CLASS) :- pivot(R3, _, 3, CLASS), pivot(R12, _, 12, CLASS), DIST=R3-R12, R=R12+DIST/2, C = #max{COL : cell(R, COL, CLASS)}.
pivot(R, C, 4, CLASS) :- pivot(R3, _, 3, CLASS), pivot(R6, _, 6, CLASS), DIST=R6-R3, R=R3+DIST/2, C = #max{COL : cell(R, COL, CLASS)}.
pivot(R, C, 5, CLASS) :- pivot(_, C3, 3, CLASS), pivot(_, C6, 6, CLASS), DIST=C3-C6, C=C6+DIST/2, R = #max{ROW : cell(ROW, C, CLASS)}.
pivot(R, C, 7, CLASS) :- pivot(_, C6, 6, CLASS), pivot(_, C9, 9, CLASS), DIST=C6-C9, C=C9+DIST/2, R = #max{ROW : cell(ROW, C, CLASS)}.
pivot(R, C, 8, CLASS) :- pivot(R6, _, 6, CLASS), pivot(R9, _, 9, CLASS), DIST=R6-R9, R=R9+DIST/2, C = #min{COL : cell(R, COL, CLASS)}.
pivot(R, C, 10, CLASS) :- pivot(R9, _, 9, CLASS), pivot(R12, _, 12, CLASS), DIST=R9-R12, R=R12+DIST/2, C = #min{COL : cell(R, COL, CLASS)}.
pivot(R, C, 11, CLASS) :- pivot(_, C9, 9, CLASS), pivot(_, C12, 12, CLASS), DIST=C12-C9, C=C9+DIST/2, R = #min{ROW : cell(ROW, C, CLASS)}.


%%%%%%%% A. PLACING PATHOLOGY UPON VOCAL FOLDS OR OTHER TISSUE %%%%%%%%

% pathology pivots can lie only on vocal_folds or glottal_space cells
:- pivot(R, C, _, pathology), not cell(R, C, vocal_folds), not cell(R, C, glottal_space).

% force the majority of the pathology pivots to lie on vocal_folds cells
:- pathology(_), #sum{1, P : pivot(R,C,P,pathology), cell(R,C,vocal_folds)} <= 6.



%%%%%%%% B. PLACING INTUBATION UPON GLOTTAL SPACE %%%%%%%%

% intubation pivots can lie only on glottal_space cells
:- pivot(R, C, _, intubation), not cell(R, C, glottal_space).



%%%%%%%% C. INTUBATION AND GLOTTAL SPACE GO IN THE SAME DIRECTION %%%%%%%%

toCalculate(intubation) :- intubation(_).
toCalculate(glottal_space).     % glottal_space class is always present because it is part of the background

head_pivot(R,C,CLASS) :- toCalculate(CLASS), cell(R,C,CLASS), min_row(R,CLASS), CDX=#max{COL : cell(R,COL,CLASS)}, CSX=#min{COL : cell(R,COL,CLASS)}, OFFSET=(CDX-CSX)/2, C=CSX+OFFSET.
base_pivot(R,C,CLASS) :- toCalculate(CLASS), cell(R,C,CLASS), max_row(R,CLASS), CDX=#max{COL : cell(R,COL,CLASS)}, CSX=#min{COL : cell(R,COL,CLASS)}, OFFSET=(CDX-CSX)/2, C=CSX+OFFSET.

directed_to_right(CLASS) :- head_pivot(_,CH,CLASS), base_pivot(_,CB,CLASS), CH>=CB.
directed_to_left(CLASS) :- head_pivot(_,CH,CLASS), base_pivot(_,CB,CLASS), CH<CB.

:- intubation(_), directed_to_right(intubation), directed_to_left(glottal_space).
:- intubation(_), directed_to_right(glottal_space), directed_to_left(intubation).



%%%%%%%% D. INTUBATION AND GLOTTAL SPACE BASE DIMENSION ARE BOUNDED %%%%%%%%

base_dim(DIM,CLASS) :- toCalculate(CLASS), max_row(R,CLASS), MIN_C=#min{C : cell(R,C,CLASS)}, MAX_C=#max{C : cell(R,C,CLASS)}, DIM=MAX_C-MIN_C.

% intubation_base and glottal_space base ratio must be above 2/3
is_ratio_respected(RATIO) :- base_dim(DIM_GS,glottal_space), base_dim(DIM_I,intubation), &isRatioRespected(DIM_GS,DIM_I;RATIO).
:- is_ratio_respected("False").


%%%%%%%% E. PLACING SURGICAL TOOL %%%%%%%%


last_row(511).
first_col(0).
last_col(511).


comes_from_dx(CLASS) :- not comes_from_sx(CLASS), max_col(LC,CLASS), last_col(LC), CLASS=surgical_tool, surgical_tool(_).
comes_from_sx(CLASS) :- not comes_from_dx(CLASS), min_col(FC,CLASS), first_col(FC), CLASS=surgical_tool, surgical_tool(_).
comes_from_bottom(CLASS) :- not comes_from_dx(CLASS), not comes_from_sx(CLASS), max_row(LR,CLASS), last_row(LR), CLASS=surgical_tool, surgical_tool(_).


% look for surgical tool's pivot:
% pivot 1: head of the surgical tool.
% pivot 2: base of the surgical tool.

% if surgical tool comes from left and goes to right
pivot(R,C,1,CLASS) :- comes_from_sx(CLASS), max_col(C,CLASS), R = #min{ROW : cell(ROW,C,CLASS)}.
%pivot(R,C,2,CLASS) :- comes_from_sx(CLASS), first_col(C), R = #max{ROW : cell(ROW,C,CLASS)}.

% if surgical tool comes from right and goes to left
pivot(R,C,1,CLASS) :- comes_from_dx(CLASS), min_col(C,CLASS), R = #min{ROW : cell(ROW,C,CLASS)}.
%pivot(R,C,2,CLASS) :- comes_from_dx(CLASS), last_col(C), R = #max{ROW : cell(ROW,C,CLASS)}.

% if surgical tool comes from below and goes up
pivot(R,C,1,CLASS) :- comes_from_bottom(CLASS), min_row(R,CLASS), C = #min{COL : cell(R,COL,CLASS)}.
%pivot(R,C,2,CLASS) :- comes_from_bottom(CLASS), last_row(R), MIN_COL = #min{COL : cell(R,COL,CLASS)}, MAX_COL = #max{COL : cell(R,COL,CLASS)}, C = MIN_COL + ((MAX_COL-MIN_COL)/2).


% if image is of group 4, the sugical tool's pivot 1 must lie on vocal_folds 
:- group(4), pivot(R,C,1,surgical_tool), not cell(R,C,vocal_folds). 

% otherwise, surgical tool's pivot 1 must lie either on vocal_folds or glottal_space
:- pivot(R,C,1,surgical_tool), not cell(R,C,vocal_folds), not cell(R,C,glottal_space).


% to produce the answer set which represents the new image:

new_cell(R,C,surgical_tool) :- cell(R,C,surgical_tool).
new_cell(R,C,pathology)     :- cell(R,C,pathology).
new_cell(R,C,other_tissue)  :- cell(R,C,other_tissue).
new_cell(R,C,intubation)    :- cell(R,C,intubation).
new_cell(R,C,vocal_folds)   :- cell(R,C,vocal_folds).
new_cell(R,C,glottal_space) :- cell(R,C,glottal_space).
