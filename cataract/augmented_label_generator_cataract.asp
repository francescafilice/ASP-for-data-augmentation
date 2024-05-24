%%% 
% Author: Francesca Filice
% 01/12/2023 - Università della Calabria
%%%



% INPUT:
% This program takes in input some matrices of 960x540 pixels, represented by facts in the following form: 
% cell(R,C,CLASS)
% where CLASS is the class of the cell at row R and column C.
% For each matrix, it must exists an atom of the form class(FILENAME), where:
% - class is the name of the class this matrix represents
% - FILENAME is the name of the image file these facts represent

% OUTPUT:
% This program gives in output some facts in the form new_cell(R,C,CLASS), which represent
% the new matrix (thus, the new augmented image).

% how to run:
% dlv2-linux-64bit-python2.7/dlv2 augmented_label_generator_cataract.asp external_atoms.py <path_to_input_file_1> <path_to_input_file_2> <path_to_input_file_n> --silent --filter=new_cell/3 > output.txt
% where:
% - <path_to_input_file_x> is a file containing all or some of the input facts
% - output.txt is the file containing the output (note that, if the provided input violates one or more constraints, then output.txt will contain 'INCOHERENT')



% config
to_calculate(iris). 
to_calculate(pupil).
%

min_row(ROW, CLASS) :- cell(ROW, _, CLASS), ROW = #min{R : cell(R, _, CLASS)}.
min_col(COL, CLASS) :- cell(_, COL, CLASS), COL = #min{C : cell(_, C, CLASS)}.
max_row(ROW, CLASS) :- cell(ROW, _, CLASS), ROW = #max{R : cell(R, _, CLASS)}.
max_col(COL, CLASS) :- cell(_, COL, CLASS), COL = #max{C : cell(_, C, CLASS)}.

% vertices of the square that circumscribes a CLASS object"
upper_left(R, C, CLASS) :- min_row(R, CLASS), min_col(C, CLASS), to_calculate(CLASS).
upper_right(R, C, CLASS) :- min_row(R, CLASS), max_col(C, CLASS), to_calculate(CLASS).
lower_right(R, C, CLASS) :- max_row(R, CLASS), max_col(C, CLASS), to_calculate(CLASS).
lower_left(R, C, CLASS) :- max_row(R, CLASS), min_col(C, CLASS), to_calculate(CLASS).

% width and height of the previously calculated squares
width(W, CLASS) :- min_col(C1, CLASS), max_col(C2, CLASS), W = C2-C1, to_calculate(CLASS).
height(H, CLASS) :- min_row(R1, CLASS), max_row(R2, CLASS), H = R2-R1, to_calculate(CLASS).

% centers of the previously calculated squares
center(R, C, CLASS) :- width(W, CLASS), height(H, CLASS), min_row(R1, CLASS), min_col(C1, CLASS), R=R1+H/2, C=C1+W/2, to_calculate(CLASS). 


%%%%%%%% A. CONSTRAINTS REGARDING IRIS AND PUPIL POSITION W.R.T. CORNEA %%%%%%%%
% 12 pivot points for the iris class
{pivot(R, C, 12, iris) : min_row(R, iris), cell(R, C, iris)} = 1.
{pivot(R, C, 6, iris) : max_row(R, iris), cell(R, C, iris)} = 1.
{pivot(R, C, 3, iris) : max_col(C, iris), cell(R, C, iris)} = 1.
{pivot(R, C, 9, iris) : min_col(C, iris), cell(R, C, iris)} = 1.

{pivot(R, C, 12, pupil) : min_row(R, pupil), cell(R, C, pupil)} = 1.
{pivot(R, C, 6, pupil) : max_row(R, pupil), cell(R, C, pupil)} = 1.
{pivot(R, C, 3, pupil) : max_col(C, pupil), cell(R, C, pupil)} = 1.
{pivot(R, C, 9, pupil) : min_col(C, pupil), cell(R, C, pupil)} = 1.

pivot(R, C, 1, CLASS) :- pivot(_, C3, 3, CLASS), pivot(_, C12, 12, CLASS), DIST=C3-C12, C=C12+DIST/2, R = #min{ROW : cell(ROW, C, CLASS)}.
pivot(R, C, 2, CLASS) :- pivot(R3, _, 3, CLASS), pivot(R12, _, 12, CLASS), DIST=R3-R12, R=R12+DIST/2, C = #max{COL : cell(R, COL, CLASS)}.
pivot(R, C, 4, CLASS) :- pivot(R3, _, 3, CLASS), pivot(R6, _, 6, CLASS), DIST=R6-R3, R=R3+DIST/2, C = #max{COL : cell(R, COL, CLASS)}.
pivot(R, C, 5, CLASS) :- pivot(_, C3, 3, CLASS), pivot(_, C6, 6, CLASS), DIST=C3-C6, C=C6+DIST/2, R = #max{ROW : cell(ROW, C, CLASS)}.
pivot(R, C, 7, CLASS) :- pivot(_, C6, 6, CLASS), pivot(_, C9, 9, CLASS), DIST=C6-C9, C=C9+DIST/2, R = #max{ROW : cell(ROW, C, CLASS)}.
pivot(R, C, 8, CLASS) :- pivot(R6, _, 6, CLASS), pivot(R9, _, 9, CLASS), DIST=R6-R9, R=R9+DIST/2, C = #min{COL : cell(R, COL, CLASS)}.
pivot(R, C, 10, CLASS) :- pivot(R9, _, 9, CLASS), pivot(R12, _, 12, CLASS), DIST=R9-R12, R=R12+DIST/2, C = #min{COL : cell(R, COL, CLASS)}.
pivot(R, C, 11, CLASS) :- pivot(_, C9, 9, CLASS), pivot(_, C12, 12, CLASS), DIST=C12-C9, C=C9+DIST/2, R = #min{ROW : cell(ROW, C, CLASS)}.

% all the 12 pivot points must lie on cornea
:- pivot(R, C, _, iris), not cell(R, C, cornea).

% all the 12 pivot points must lie on iris
:- pivot(R, C, _, pupil), not cell(R, C, iris).



%%%%%%%% B. CONSTRAINTS FOR CENTERING IRIS AND PUPIL
centers_distance(D) :- center(RI, CI, iris), center(RP, CP, pupil), R = RP-RI, C = CP-CI, R1=R*R, C1=C*C, &sqrt(R1+C1;D). 
:- centers_distance(D), D > 70.



%%%%%%%% C. CONSTRAINTS FOR IRIS-PUPIL PROPORTIONS 
% WP cannot exceed or fall short of the expected proportion by more than 80 pixels 
:- width(WP, pupil), width(WI, iris), height(HP, pupil), height(HI, iris), WP > HP*WI/HI + 80.
:- width(WP, pupil), width(WI, iris), height(HP, pupil), height(HI, iris), WP < HP*WI/HI - 80.




%%%%%%%% D. CONSTRAINTS FOR IRIS-CORNEA PROPORTIONS
% create and hexagone to represent the cornea
possible_pivot_sx(ROW, COL) :- cell(ROW, COL, CLASS), min_row(ROW, CLASS), CLASS = cornea.
possible_pivot_sx(ROW, COL) :- cell(ROW, COL, CLASS), max_row(ROW, CLASS), CLASS = cornea.
pivot_sx(ROW, COL) :- COL = #min{C: possible_pivot_sx(_, C)}, possible_pivot_sx(ROW, COL).

possible_pivot_dx(ROW, COL) :- cell(ROW, COL, CLASS), min_row(ROW, CLASS), CLASS = cornea.
possible_pivot_dx(ROW, COL) :- cell(ROW, COL, CLASS), max_row(ROW, CLASS), CLASS = cornea.
pivot_dx(ROW, COL) :- COL = #max{C: possible_pivot_sx(_, C)}, possible_pivot_dx(ROW, COL).

height_triangle_sx(H) :- min_col(C1, cornea), pivot_sx(_, C2), H = C2-C1.
height_triangle_dx(H) :- max_col(C1, cornea), pivot_dx(_, C2), H = C1-C2.
height_rectangle(H) :- min_row(R1, CLASS), max_row(R2, CLASS), H = R2-R1, CLASS = cornea.
width_reactangle(W) :- pivot_sx(_, C1), pivot_dx(_, C2), W = C2-C1.

% iris and pupil area (approximated to rectangles)
area(A, CLASS) :- width(W, CLASS), height(H, CLASS), A=W*H, to_calculate(CLASS).
% cornea area (rectangle + left triangle + right triangle)
area(A, cornea) :- height_triangle_sx(HTSX), height_triangle_dx(HTDX), height_rectangle(HR), width_reactangle(WR), A = HTSX*HR + HTDX*HR + HR*WR.

% Adjusting the proportion between iris and cornea, excluding irises that are too small
:- area(AI, iris), area(AC, cornea), R = AC/AI, R > 4.




%%%%%%%% E. INSTRUMENTS CONSTRAINTS

last_row(539).
first_col(0).
last_col(959).



% type 1 instruments: instrumnets that must not go beyond the pupil
% 7, 8, 9, 10, 14

instrument(viscoelastic_cannula, 1) :- cell(_, _, viscoelastic_cannula).

instrument(hydrodissection_cannula, 1) :- cell(_, _, hydrodissection_cannula).
handle(hydrodissection_cannula_handle, hydrodissection_cannula) :- cell(_, _, hydrodissection_cannula_handle).

instrument(capsulorhexis_cystotome, 1) :- cell(_, _, capsulorhexis_cystotome).
handle(capsulorhexis_cystotome_handle, capsulorhexis_cystotome) :- cell(_, _, capsulorhexis_cystotome_handle).

instrument(rycroft_cannula, 1) :- cell(_, _, rycroft_cannula).
handle(rycroft_cannula_handle, rycroft_cannula) :- cell(_, _, rycroft_cannula_handle).

instrument(lens_injector, 1) :- cell(_, _, lens_injector).
handle(lens_injector_handle, lens_injector) :- cell(_, _, lens_injector_handle).



% type 2 instruments: instruments that must not go beyond the iris
% 17, 29, 19

instrument(micromanipulator, 2) :- cell(_, _, micromanipulator).

instrument(vitrectomy_handpiece, 2) :- cell(_, _, vitrectomy_handpiece).

instrument(capsulorhexis_forceps, 2) :- cell(_, _, capsulorhexis_forceps).



% type 3 instruments: their pivot 1 must lie on iris
% 13, 15, 27, 25

instrument(phacoemulsifier_handpiece, 3) :- cell(_, _, phacoemulsifier_handpiece).
handle(phacoemulsifier_handpiece_handle, phacoemulsifier_handpiece) :- cell(_, _, phacoemulsifier_handpiece_handle).

instrument(i_a_handpiece, 3) :- cell(_, _, i_a_handpiece).
handle(i_a_handpiece_handle, i_a_handpiece) :- cell(_, _, i_a_handpiece_handle).

instrument(charleux_cannula, 3) :- cell(_, _, charleux_cannula).

instrument(suture_needle, 3) :- cell(_, _, suture_needle).
% we are considering needle holder (26) and troutman_forceps (33) classes as they were suture needle's (25) handles:
handle(needle_holder, suture_needle) :- cell(_, _, needle_holder). 
% we consider routman forceps as suture needle's handle iff the latter is present
handle(troutman_forceps, suture_needle) :- cell(_, _, troutman_forceps), cell(_, _, suture_needle). 



% type 4 instruments:  
%   pivot 1 must:
%   lie between leftmost and rightmost pupil's cell;
%   have row < row of pupil's center;
%   be max 10 pixels away from iris iff it does not lie on pupil
% 12
instrument(primary_knife, 4) :- cell(_, _, primary_knife).
handle(primary_knife_handle, primary_knife) :- cell(_, _, primary_knife_handle).



% type 5 instruments: pivot 1 must lie on the cornea, iris or pupil
% 33, 34, 11
instrument(troutman_forceps, 5) :- cell(_, _, troutman_forceps).

instrument(cotton, 5) :- cell(_, _, cotton).

instrument(bonn_forceps, 5) :- cell(_, _, bonn_forceps).



% type 6 instruments: pivot 1 lies either on cornea or iris
% if it lies on the iris, it must be at most 20 pixels away from its outline
% 16
instrument(secondary_knife, 6) :- cell(_, _, secondary_knife).
handle(secondary_knife_handle, secondary_knife) :- cell(_, _, secondary_knife_handle).



% type 7 instruments: mendez ring (30)
instrument(mendez_ring, 7) :- cell(_, _, mendez_ring).



with_handle(S) :- handle(_, S), instrument(S, _).




comes_from_dx(S) :- not comes_from_sx(S), max_col(LC, S), last_col(LC), instrument(S, _), not with_handle(S).   % without handle
comes_from_dx(S) :- not comes_from_sx(S), max_col(LC, H), last_col(LC), handle(H, S), instrument(S, _).         % with handle

comes_from_sx(S) :- not comes_from_dx(S), min_col(FC, S), first_col(FC), instrument(S, _), not with_handle(S).  % without handle
comes_from_sx(S) :- not comes_from_dx(S), min_col(FC, H), first_col(FC), handle(H, S), instrument(S, _).        % with handle

comes_from_bottom(S) :- not comes_from_dx(S), not comes_from_sx(S), max_row(LR, S), last_row(LR), instrument(S, _), not with_handle(S).     % without handle
comes_from_bottom(S) :- not comes_from_dx(S), not comes_from_sx(S), max_row(LR, H), last_row(LR), handle(H, S), instrument(S, _).           % with handle


% looking for the pivot points:
% pivot 1: instrument's "head".
% pivot 2: insturment's base.

% for the intruments coming from left and directed to right
pivot(R, C, 1, S) :- comes_from_sx(S), max_col(C, S), R = #min{ROW : cell(ROW, C, S)}, instrument(S, _).
pivot(R, C, 2, S) :- comes_from_sx(S), first_col(C), R = #max{ROW : cell(ROW, C, S)}, instrument(S, _), not with_handle(S).     % without handle
pivot(R, C, 2, S) :- comes_from_sx(S), first_col(C), R = #max{ROW : cell(ROW, C, H)}, handle(H, S), instrument(S, _).           % with handle

% for the intruments coming from right and directed to left
pivot(R, C, 1, S) :- comes_from_dx(S), min_col(C, S), R = #min{ROW : cell(ROW, C, S)}, instrument(S, _).
pivot(R, C, 2, S) :- comes_from_dx(S), last_col(C), R = #max{ROW : cell(ROW, C, S)}, instrument(S, _), not with_handle(S).      % without handle
pivot(R, C, 2, S) :- comes_from_dx(S), last_col(C), R = #max{ROW : cell(ROW, C, H)}, handle(H, S), instrument(S, _).            % with handle


% for the intruments coming from the bottom and directed to either right or left
pivot(R, C, 1, S) :- comes_from_bottom(S), min_row(R, S), C = #min{COL : cell(R, COL, S)}, instrument(S, _).
pivot(R, C, 2, S) :- comes_from_bottom(S), last_row(R), MIN_COL = #min{COL : cell(R, COL, S)}, MAX_COL = #max{COL : cell(R, COL, S)},
     C = MIN_COL + ((MAX_COL-MIN_COL)/2), instrument(S, _), not with_handle(S).     % without handle
pivot(R, C, 2, S) :- comes_from_bottom(S), last_row(R), MIN_COL = #min{COL : cell(R, COL, H)}, MAX_COL = #max{COL : cell(R, COL, H)},
     C = MIN_COL + ((MAX_COL-MIN_COL)/2), handle(H, S), instrument(S, _).           % with handle


directed_to_dx(S) :- comes_from_sx(S).
directed_to_dx(S) :- comes_from_bottom(S), pivot(R1, C1, 1, S), pivot(R2, C2, 2, S), C1>=C2, instrument(S, _).
directed_to_sx(S) :- comes_from_dx(S).
directed_to_sx(S) :- comes_from_bottom(S), pivot(R1, C1, 1, S), pivot(R2, C2, 2, S), C1<C2, instrument(S, _).


% IRIS HOOKS PIVOTS
% we redefine the concept of pivot specifically for iris hooks

% upper iris hooks
pivot(R, C, 1, CLASS) :- max_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_NW.
pivot(R, C, 2, CLASS) :- min_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_NW.

pivot(R, C, 1, CLASS) :- max_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_NE.
pivot(R, C, 2, CLASS) :- min_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_NE.

% lower iris hooks
pivot(R, C, 1, CLASS) :- min_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_SW.
pivot(R, C, 2, CLASS) :- max_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_SW.

pivot(R, C, 1, CLASS) :- min_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_SE.
pivot(R, C, 2, CLASS) :- max_row(R, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = iris_hooks_SE.



% PIVOT MARKER (only pivot 1 is necessary)
% left marker (class = marker_SX)
pivot(R, C, 1, CLASS) :- max_col(C, CLASS), R = #min{ROW : cell(ROW, C, CLASS)}, CLASS = marker_SX.

% right marker (class = marker_DX)
pivot(R, C, 1, CLASS) :- min_col(C, CLASS), R = #min{ROW : cell(ROW, C, CLASS)}, CLASS = marker_DX.

% upper marker (class = marker_UP)
pivot(R, C, 1, CLASS) :- max_row(R, CLASS), C = #min{COL : cell(R, COL, CLASS)}, CLASS = marker_UP.

% lower marker (class = marker_DOWN)
pivot(R, C, 1, CLASS) :- min_row(R, CLASS), C = #min{COL : cell(R, COL, CLASS)}, CLASS = marker_DOWN.



%%% type 1 instruments constraints: 7, 8, 9, 10, 14

lies_on_pupil(S) :- pivot(R, C, 1, S), instrument(S, _), cell(R, C, pupil).
% if directed to left, the instrument cannot overcome the column of pupil's pivot 7
in_range(S) :- instrument(S, 1), directed_to_sx(S), pivot(_, CS, 1, S), pivot(_, CP, 7, pupil), CS>CP.
% if directed to right, the instrument cannot overcome the column of pupil's pivot 5
in_range(S) :- instrument(S, 1), directed_to_dx(S), pivot(_, CS, 1, S), pivot(_, CP, 5, pupil), CS<CP.

% in order to be valid, the instrument must either lie on pupil or be in range
:- instrument(S, 1), not lies_on_pupil(S), not in_range(S).

% the instrument must not overcome the pupil's lowest indexed row
:- instrument(S, 1), pivot(R, _, 1, S), min_row(RP, pupil), R<RP.
% if the instrument's pivot 1 ("head") is facing down, it cannot overcome the pupil's highest indexed row
:- instrument(S, 1), pivot(R1, _, 1, S), pivot(R2, _, 2, S), R1>R2, max_row(RP, pupil), R1>RP.



%%% type 2 instruments constraints: 17, 29

lies_on_iris(S) :- pivot(R, C, 1, S), instrument(S, _), cell(R, C, iris).
% if directed to left, the instrument cannot overcome the column of pupil's pivot 7
in_range(S) :- instrument(S, 2), directed_to_sx(S), pivot(_, CS, 1, S), pivot(_, CI, 7, iris), CS>CI.
% if directed to right, the instrument cannot overcome the column of pupil's pivot 5
in_range(S) :- instrument(S, 2), directed_to_dx(S), pivot(_, CS, 1, S), pivot(_, CI, 5, iris), CS<CI.

% in order to be valid, the instrument must either lie on iris or be in range
:- instrument(S, 2), not lies_on_iris(S), not in_range(S).

% the instrument must not overcome the iris' lowest indexed row
:- instrument(S, 2), pivot(R, _, 1, S), min_row(RP, iris), R<RP.
% if the instrument's pivot 1 ("head") is facing down, it cannot overcome the iris' highest indexed row
:- instrument(S, 2), pivot(R1, _, 1, S), pivot(R2, _, 2, S), R1>R2, max_row(RI, iris), R1>RI.



%%% type 3 instruments constraints
:- instrument(S, 3), not lies_on_iris(S).



%%% type 4 instruments constraints
% if pivot 1 lies on cornea -> the distance between iris' outline and pivot 1 must be <= 15
knife_iris_distance(D) :- instrument(S, _), pivot(RS, C, 1, S), cell(RI, C, iris), RI = #max{ROW : cell(ROW, C, iris)}, &abs(RI-RS;D).
:- instrument(S, 4), not lies_on_iris(S), not lies_on_pupil(S), knife_iris_distance(D), D > 15.

% pivot 1 must not overcome pupil's center
:- instrument(S, 4), pivot(RS, _, 1, S), center(RP, _, pupil), RP > RS.

% pivot 1 must be between the max and min columns of pupil
:- instrument(S, 4), pivot(RS, CS, 1, S), min_col(CP, pupil), CS<CP.
:- instrument(S, 4), pivot(RS, CS, 1, S), max_col(CP, pupil), CS>=CP.




%%% type 5 instruments constraints
:- instrument(S, 5), pivot(R, C, 1, S), cell(R, C, CLASS), CLASS <> cornea, CLASS <> void, CLASS <> S, CLASS <> pupil, CLASS <> iris.




%%% type 6 instruments constraints

% if pivot 1 lies on iris and the instrument comes from left, pivot 1 must be at most 20 pixels far from iris' outline
:- instrument(S, 6), lies_on_iris(S), comes_from_sx(S), pivot(RP, CP, 1, S), CI = #min{C : cell(RP, C, iris)}, &abs(CP-CI;DIST_COL), DIST_COL>20.

% if pivot 1 lies on iris and the instrument comes from right, pivot 1 must be at most 20 pixels far from iris' outline
:- instrument(S, 6), lies_on_iris(S), comes_from_dx(S), pivot(RP, CP, 1, S), CI = #max{C : cell(RP, C, iris)}, &abs(CP-CI;DIST_COL), DIST_COL>20.

% if pivot 1 lies on iris and the instrument comes from down, pivot 1 must be at most 20 pixels far from iris' outline
:- instrument(S, 6), lies_on_iris(S), comes_from_bottom(S), pivot(RP, CP, 1, S), RI = #max{R : cell(R, CP, iris)}, &abs(RP-RI;DIST_ROW), DIST_ROW>20.

% if instrument is directed to right, it cannot overcome iris' highest indexed column
:- instrument(S, 6), directed_to_dx(S), pivot(_, CS, 1, S), max_col(MAX_COL, iris), CS>MAX_COL.
% if instrument is directed to left, it cannot overcome iris' lowest indexed column
:- instrument(S, 6), directed_to_sx(S), pivot(_, CS, 1, S), min_col(MIN_COL, iris), CS<MIN_COL.

% pivot 1 must not lie on pupil
:- instrument(S, 6), pivot(R, C, 1, S), cell(R, C, pupil).

% pivot 1 must not overcome pupil's lowest indexed row
:- instrument(S, 6), pivot(R, C, 1, S), min_row(MIN_ROW, pupil), R<MIN_ROW.







%%% type 7 instruments constraints: mendez ring
min_col(C, CLASS) :- C = #min{COL : cell(_, COL, CLASS)}, CLASS = mendez_ring_hole.

pivot(R, C, 1, CLASS) :- min_col(C, CLASS), R = #min{ROW : cell(ROW, C, CLASS)}, CLASS = mendez_ring_hole.
pivot(R, C, 2, CLASS) :- pivot(R, _, 1, CLASS), C = #max{COL : cell(R, COL, CLASS)}, CLASS = mendez_ring_hole.
center(R, C, CLASS) :- pivot(R, CSX, 1, CLASS), pivot(R, CDX, 2, CLASS), C = (CSX + (CDX-CSX) / 2), CLASS = mendez_ring_hole.

% mendez ring must be centered w.r.t. pupil
:- center(RMR, CMR, mendez_ring_hole), center(RP, CP, pupil), &dist(RMR, CMR, RP, CP; DIST), DIST>40.

% mendez ring can appear iff pupiils are not compressed
:- instrument(mendez_ring, 7), width(WP, pupil), height(HP, pupil), &abs(WP-HP;DIFF), DIFF>70.

% if se mendez ring is not the only instrument appearing, then it must appear with markers
:- instrument(mendez_ring, 7), instrument(S, _), S<>marker, S<>mendez_ring.





%%% iris hooks constraints:
%   NE must lie on the first quarter of pupill, SE non the second, SW on the third, NW on the fourth;
%   the distance between pivot 1 and the nearest pupil's outline row must be <= 15 px
%   pivot 1 must lie on pupil

% iris hooks NE
ne_in_first_quarter() :- pivot(R, C, 1, iris_hooks_NE), pivot(_, C12, 12, pupil), C>C12, pivot(R3, _, 3, pupil), R<R3.
:- cell(_, _, iris_hooks_NE), not ne_in_first_quarter().
:- pivot(RH, C, 1, iris_hooks_NE), RP = #min{ROW : cell(ROW, C, pupil)}, &abs(RH-RP;DIFF), DIFF>15.
:- pivot(R, C, 1, iris_hooks_NE), not cell(R, C, pupil).

% iris hooks SE
se_in_second_quarter() :- pivot(R, C, 1, iris_hooks_SE), pivot(_, C6, 6, pupil), C>C6, pivot(R3, _, 3, pupil), R>R3.
:- cell(_, _, iris_hooks_SE), not se_in_second_quarter().
:- pivot(RH, C, 1, iris_hooks_SE), RP = #max{ROW : cell(ROW, C, pupil)}, &abs(RH-RP;DIFF), DIFF>15.
:- pivot(R, C, 1, iris_hooks_SE), not cell(R, C, pupil).

% iris hooks SW
sw_in_third_quarter() :- pivot(R, C, 1, iris_hooks_SW), pivot(_, C6, 6, pupil), C<C6, pivot(R9, _, 9, pupil), R>R9.
:- cell(_, _, iris_hooks_SW), not sw_in_third_quarter().
:- pivot(RH, C, 1, iris_hooks_SW), RP = #max{ROW : cell(ROW, C, pupil)}, &abs(RH-RP;DIFF), DIFF>15.
:- pivot(R, C, 1, iris_hooks_SW), not cell(R, C, pupil).

% iris hooks NW
nw_in_fourth_quarter() :- pivot(R, C, 1, iris_hooks_NW), pivot(_, C12, 12, pupil), C<C12, pivot(R9, _, 9, pupil), R<R9.
:- cell(_, _, iris_hooks_NW), not nw_in_fourth_quarter().
:- pivot(RH, C, 1, iris_hooks_NW), RP = #min{ROW : cell(ROW, C, pupil)}, &abs(RH-RP;DIFF), DIFF>15.
:- pivot(R, C, 1, iris_hooks_NW), not cell(R, C, pupil).


% whichever iris hook's pivot 2 must lie on cornea
:- pivot(R, C, 2, iris_hooks_NW), not cell(R, C, cornea).
:- pivot(R, C, 2, iris_hooks_NE), not cell(R, C, cornea).
:- pivot(R, C, 2, iris_hooks_SE), not cell(R, C, cornea).
:- pivot(R, C, 2, iris_hooks_SW), not cell(R, C, cornea).


% only one iris hook for each type can appear
:- #count{FILENAME : iris_hooks_NW(FILENAME)} > 1.
:- #count{FILENAME : iris_hooks_NE(FILENAME)} > 1.
:- #count{FILENAME : iris_hooks_SE(FILENAME)} > 1.
:- #count{FILENAME : iris_hooks_SW(FILENAME)} > 1.




%%% marker

% distance between iris and marker contraints
:- pivot(R, C, 1, CLASS), CI = #min{COL : cell(R, COL, iris)}, &abs(C-CI; DIST), DIST>20, CLASS = marker_SX.
:- pivot(R, C, 1, CLASS), CI = #max{COL : cell(R, COL, iris)}, &abs(C-CI; DIST), DIST>20, CLASS = marker_DX.
:- pivot(R, C, 1, CLASS), RI = #min{ROW : cell(ROW, C, iris)}, &abs(R-RI; DIST), DIST>20, CLASS = marker_UP.
:- pivot(R, C, 1, CLASS), RI = #max{ROW : cell(ROW, C, iris)}, &abs(R-RI; DIST), DIST>20, CLASS = marker_DOWN.

% there can be at most one marker for each type
:- #count{FILENAME : marker_DX(FILENAME)} > 1.
:- #count{FILENAME : marker_SX(FILENAME)} > 1.
:- #count{FILENAME : marker_UP(FILENAME)} > 1.
:- #count{FILENAME : marker_DOWN(FILENAME)} > 1.








% to avoid having the bases of two instruments that appear together be too close:
:- instrument(S1, _), instrument(S2, _), S1<>S2, not handle(S1, S2), not handle(S2, S1),
    pivot(R1, C1, 2, S1), pivot(R2, C2, 2, S2), &dist(R1, C1, R2, C2; DIST), DIST < 200.



% two instruments which appear together and intersect must not have their respective pivots 1 too cloose to one another
% NB: this constraint does not (correctly) apply to marker and iris hooks
:- instrument(S1, _), instrument(S2, _), S1<>S2, not handle(S1, S2), not handle(S2, S1),
    crossed(S1, S2),
    pivot(R1, C1, 1, S1), pivot(R2, C2, 1, S2), &dist(R1, C1, R2, C2; DIST), DIST > 70.

crossed(S1, S2) :- instrument(S1, _), instrument(S2, _), S1<>S2,
    pivot(_, C1_DOWN, 2, S1), pivot(_, C2_DOWN, 2, S2), 
    pivot(_, C1_UP, 1, S1), pivot(_, C2_UP, 1, S2),
    C1_DOWN < C2_DOWN, C1_UP > C2_UP.



% At most one intrumnet for each class can appear (apart from marker and iris hooks classes)
:- #count{FILENAME : hydrodissection_cannula(FILENAME)} > 1.
:- #count{FILENAME : viscoelastic_cannula(FILENAME)} > 1.
:- #count{FILENAME : capsulorhexis_cystotome(FILENAME)} > 1.
:- #count{FILENAME : rycroft_cannula(FILENAME)} > 1.
:- #count{FILENAME : bonn_forceps(FILENAME)} > 1.
:- #count{FILENAME : primary_knife(FILENAME)} > 1.
:- #count{FILENAME : phacoemulsifier_handpiece(FILENAME)} > 1.
:- #count{FILENAME : lens_injector(FILENAME)} > 1.
:- #count{FILENAME : i_a_handpiece(FILENAME)} > 1.
:- #count{FILENAME : secondary_knife(FILENAME)} > 1.
:- #count{FILENAME : micromanipulator(FILENAME)} > 1.
:- #count{FILENAME : capsulorhexis_forceps(FILENAME)} > 1.
:- #count{FILENAME : suture_needle(FILENAME)} > 1.
:- #count{FILENAME : charleux_cannula(FILENAME)} > 1.
:- #count{FILENAME : vitrectomy_handpiece(FILENAME)} > 1.
:- #count{FILENAME : mendez_ring(FILENAME)} > 1.
:- #count{FILENAME : troutman_forceps(FILENAME)} > 1.
:- #count{FILENAME : cotton(FILENAME)} > 1.


% Exaclty one iris, one pupil and one background must appear
:- #count{FILENAME : iris(FILENAME)} <> 1.
:- #count{FILENAME : pupil(FILENAME)} <> 1.
:- #count{FILENAME : background(FILENAME)} <> 1.


% There can be at most 2 instruments at the same time (apart from iris hooks and marker)
:- #count{S : instrument(S, _)} > 2.





%%% INDENTATIONS

% the instruments causing indetation:
indentation_instrument(S) :- instrument(S, _), S = lens_injector.
indentation_instrument(S) :- instrument(S, _), S = i_a_handpiece.
indentation_instrument(S) :- instrument(S, _), S = vitrectomy_handpiece.
indentation_instrument(S) :- instrument(S, _), S = capsulorhexis_cystotome.

indentation_instrument_exists() :- indentation_instrument(S), instrument(S, _).


chord(RA, CA, PIVOT_A, RB, CB, PIVOT_B) :- pivot(RA, CA, PIVOT_A, pupil), pivot(RB, CB, PIVOT_B, pupil), 
   PIVOT_A <> PIVOT_B, &abs(PIVOT_A-PIVOT_B;DIFF), DIFF <= 3.
% to include the chords 1-10, 1-11, 1-12, 2-11, 2-12, 3-12, too:
chord(RA, CA, PIVOT_A, RB, CB, PIVOT_B) :- pivot(RA, CA, PIVOT_A, pupil), pivot(RB, CB, PIVOT_B, pupil), 
   PIVOT_A <> PIVOT_B, &abs(PIVOT_A-PIVOT_B;DIFF), DIFF >= 9, DIFF <= 11.
third_chord_column(TERZO, PIVOT_A, PIVOT_B) :- chord(_, CA, PIVOT_A, _, CB, PIVOT_B), PIVOT_A<>PIVOT_B, &abs(CA-CB;DIST_COL), TERZO = DIST_COL/3.
third_chord_row(TERZO, PIVOT_A, PIVOT_B) :- chord(RA, _, PIVOT_A, RB, _, PIVOT_B), PIVOT_A<>PIVOT_B, &abs(RA-RB;DIST_ROW), TERZO = DIST_ROW/3.


%                           pivot B
%                   -
%           x
% pivot A
chord_pivot(R, C, PIVOT_A, PIVOT_B) :- chord(RA, CA, PIVOT_A, RB, CB, PIVOT_B), PIVOT_A<>PIVOT_B, RA >= RB, CA < CB,
    R = RA - TERZO_ROW, third_chord_row(TERZO_ROW, PIVOT_A, PIVOT_B), C = CA + TERZO_COL, third_chord_column(TERZO_COL, PIVOT_A, PIVOT_B),
    RA<>0, RB<>0.  
    

%                           pivot B
%                   x
%           -
% pivot A
chord_pivot(R, C, PIVOT_A, PIVOT_B) :- chord(RA, CA, PIVOT_A, RB, CB, PIVOT_B), PIVOT_A<>PIVOT_B, RA >= RB, CA < CB,
    R = RB + TERZO_ROW, third_chord_row(TERZO_ROW, PIVOT_A, PIVOT_B), C = CB - TERZO_COL, third_chord_column(TERZO_COL, PIVOT_A, PIVOT_B),
    RA<>0, RB<>0.


% pivot B
%           x
%                   -
%                           pivot A
chord_pivot(R, C, PIVOT_A, PIVOT_B) :- chord(RA, CA, PIVOT_A, RB, CB, PIVOT_B), PIVOT_A<>PIVOT_B, RA >= RB, CA >= CB,
    R = RB + TERZO_ROW, third_chord_row(TERZO_ROW, PIVOT_A, PIVOT_B), C = CB + TERZO_COL, third_chord_column(TERZO_COL, PIVOT_A, PIVOT_B),
    RA<>0, RB<>0.


% pivot B
%           -
%                   x
%                           pivot A
chord_pivot(R, C, PIVOT_A, PIVOT_B) :- chord(RA, CA, PIVOT_A, RB, CB, PIVOT_B), PIVOT_A<>PIVOT_B, RA >= RB, CA >= CB,
    R = RA - TERZO_ROW, third_chord_row(TERZO_ROW, PIVOT_A, PIVOT_B), C = CA - TERZO_COL, third_chord_column(TERZO_COL, PIVOT_A, PIVOT_B),
    RA<>0, RB<>0.


chord_pivot_outside(R, C) :- chord_pivot(R, C, _, _), not cell(R, C, pupil).
indentation_exists() :- chord_pivot_outside(_, _).

% to find the indentation's edge
indentation_sx_endpoint(R, C) :- C = #min{COL : chord_pivot_outside(_, COL)}, chord_pivot_outside(R, C).
indentation_dx_endpoint(R, C) :- C = #max{COL : chord_pivot_outside(_, COL)}, chord_pivot_outside(R, C).
indentation_dx() :- indentation_sx_endpoint(RSX, CSX), indentation_dx_endpoint(RDX, CDX), RDX<=RSX.
indentation_sx() :- indentation_sx_endpoint(RSX, CSX), indentation_dx_endpoint(RDX, CDX), RDX>RSX.
instrument_below_indentation(S) :- indentation_instrument(S), pivot(RP, _, 1, S), indentation_sx_endpoint(RSX, _), RP >= RSX.
instrument_below_indentation(S) :- indentation_instrument(S), pivot(RP, _, 1, S), indentation_dx_endpoint(RDX, _), RP >= RDX.
instrument_above_indentation(S) :- not instrument_below_indentation(S), indentation_instrument(S).



% If there exists an indentation, there must be the instrument causing it, too
:- indentation_exists(), not indentation_instrument_exists().


% If the instrument's pivot 1 lies below the indentation, then it must be between the indentation's edges
:- instrument_below_indentation(S), indentation_sx_endpoint(_, CSX), pivot(_, CP, 1, S), indentation_instrument(S), CP < C, C = CSX-30.
:- instrument_below_indentation(S), indentation_dx_endpoint(_, CDX), pivot(_, CP, 1, S), indentation_instrument(S), CP > C, C = CDX+30.



% Ifthe instrument's pivot 1 lies above the indentation:

% ...there must be at least 1 px to the right of the left column of the indentation
instrument_crosses_indentation_sx(S) :- indentation_sx_endpoint(RSX, CSX), cell(RSX, C, S), C >= CSX - 30.
:- indentation_exists(), instrument_above_indentation(S), not instrument_crosses_indentation_sx(S).

% ...there must not be any pixel to the left of the left column of the indentation
instrument_outside_indentation_sx(S) :- indentation_sx_endpoint(RSX, CSX), cell(RSX, C, S), C < CSX - 30.
:- indentation_exists(), instrument_above_indentation(S), instrument_outside_indentation_sx(S).

% ...there must be at least one pixel to the left of the right column of the indentation 
instrument_crosses_indentation_dx(S) :- indentation_dx_endpoint(RDX, CDX), cell(RDX, C, S), C <= CDX + 30.
:- indentation_exists(), instrument_above_indentation(S), not instrument_crosses_indentation_dx(S).

% ...there must not be any pixel to the right of the right column of the indentation
instrument_outside_indentation_dx(S) :- indentation_dx_endpoint(RDX, CDX), cell(RDX, C, S), C > CDX + 30.
:- indentation_exists(), instrument_above_indentation(S), instrument_outside_indentation_dx(S).



% if the indentation lies on the left, then the instrument causing it must be directed to the right and viceversa
:- indentation_dx(), not directed_to_sx(S), indentation_instrument(S).
:- indentation_sx(), not directed_to_dx(S), indentation_instrument(S).


% LENS-INJECTOR-CAUSED INDENTATIONS (14)
% if there exists an indentation, then lens injector's pivot 1 must not lie on pupil
:- indentation_exists(), indentation_instrument(S), pivot(R, C, 1, S), S = lens_injector, cell(R, C, pupil).
% if lens injector lies neither on pupil nor on iris, then it must be (vertically) at most 100 pixels away from the indentation's edges
:- indentation_sx_endpoint(RSX, _), pivot(RP, CP, 1, S), instrument(S, _), S = lens_injector,
    RP > RSX, DIST_ROW = RP - RSX, DIST_ROW > 100.
:- indentation_dx_endpoint(RDX, _), pivot(RP, CP, 1, S), instrument(S, _), S = lens_injector,
    RP > RDX, DIST_ROW = RP - RDX, DIST_ROW > 100.



% I/A-HANDPIECE-CAUSED (15) INDENTATION -> generic indentation constraints are enaugh 

% PRIMARY-KNIFE-CAUSED (12) INDENTATION -> generic indentation constraints are enaugh 

% VITRECTOMY-HANDPIECE (29) INDENTATION -> generic indentation constraints are enaugh 

% CAPSULORHEXIS-CYSTOTOME (9) INDENTATION -> generic indentation constraints are enaugh 





% GENERATING THE NEW LABELLED IMAGE
new_cell(R, C, viscoelastic_cannula) :- cell(R, C, viscoelastic_cannula).                       
new_cell(R, C, hydrodissection_cannula) :- cell(R, C, hydrodissection_cannula).
new_cell(R, C, hydrodissection_cannula_handle) :- cell(R, C, hydrodissection_cannula_handle).
new_cell(R, C, capsulorhexis_cystotome) :- cell(R, C, capsulorhexis_cystotome).
new_cell(R, C, capsulorhexis_cystotome_handle) :- cell(R, C, capsulorhexis_cystotome_handle).
new_cell(R, C, rycroft_cannula) :- cell(R, C, rycroft_cannula).
new_cell(R, C, rycroft_cannula_handle) :- cell(R, C, rycroft_cannula_handle).
new_cell(R, C, phacoemulsifier_handpiece) :- cell(R, C, phacoemulsifier_handpiece).
new_cell(R, C, phacoemulsifier_handpiece_handle) :- cell(R, C, phacoemulsifier_handpiece_handle).
new_cell(R, C, i_a_handpiece) :- cell(R, C, i_a_handpiece).
new_cell(R, C, i_a_handpiece_handle) :- cell(R, C, i_a_handpiece_handle).
new_cell(R, C, micromanipulator) :- cell(R, C, micromanipulator).
new_cell(R, C, primary_knife) :- cell(R, C, primary_knife).
new_cell(R, C, primary_knife_handle) :- cell(R, C, primary_knife_handle).
new_cell(R, C, bonn_forceps) :- cell(R, C, bonn_forceps).
new_cell(R, C, capsulorhexis_forceps) :- cell(R, C, capsulorhexis_forceps).
new_cell(R, C, suture_needle) :- cell(R, C, suture_needle).
new_cell(R, C, needle_holder) :- cell(R, C, needle_holder).
new_cell(R, C, troutman_forceps) :- cell(R, C, troutman_forceps).
new_cell(R, C, cotton) :- cell(R, C, cotton).
new_cell(R, C, lens_injector) :- cell(R, C, lens_injector).
new_cell(R, C, lens_injector_handle) :- cell(R, C, lens_injector_handle).
new_cell(R, C, secondary_knife) :- cell(R, C, secondary_knife).
new_cell(R, C, secondary_knife_handle) :- cell(R, C, secondary_knife_handle).
new_cell(R, C, vitrectomy_handpiece) :- cell(R, C, vitrectomy_handpiece).
new_cell(R, C, charleux_cannula) :- cell(R, C, charleux_cannula).
new_cell(R, C, mendez_ring) :- cell(R, C, mendez_ring).
new_cell(R, C, eye_retractors) :- cell(R, C, eye_retractors).
new_cell(R, C, surgical_tape) :- cell(R, C, surgical_tape).
new_cell(R, C, skin) :- cell(R, C, skin).
new_cell(R, C, iris_hooks) :- cell(R, C, iris_hooks_NW).
new_cell(R, C, iris_hooks) :- cell(R, C, iris_hooks_NE).
new_cell(R, C, iris_hooks) :- cell(R, C, iris_hooks_SW).
new_cell(R, C, iris_hooks) :- cell(R, C, iris_hooks_SE).
new_cell(R, C, marker) :- cell(R, C, marker_DX).
new_cell(R, C, marker) :- cell(R, C, marker_SX).
new_cell(R, C, marker) :- cell(R, C, marker_UP).
new_cell(R, C, marker) :- cell(R, C, marker_DOWN).
new_cell(R, C, pupil):- cell(R, C, pupil).
new_cell(R, C, iris) :- cell(R, C, iris), not cell(R, C, pupil).
new_cell(R, C, cornea) :- cell(R, C, cornea), not cell(R, C, iris), not cell(R, C, pupil).
new_cell(R, C, void) :- cell(R, C, void), not cell(R, C, iris), not cell(R, C, pupil).

