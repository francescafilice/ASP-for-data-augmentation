## Prerequisites ##
 - DLV2 solver
 - Python 2.7


## Cataract ##

### Input ###

This program takes in input some matrices of 960x540 pixels, represented by facts in the following form: 
```
cell(R,C,CLASS)
```
where ```CLASS``` is the class of the cell at row ```R``` and column ```C```.
For each matrix, it must exist an atom of the form ```class(FILENAME)```, where:
  - ```class``` is the name of the class this matrix represents
  - ```FILENAME``` is the name of the image file these facts represent

### Output ###
This program gives in output some facts in the form ```new_cell(R,C,CLASS)```, which represent the new matrix (thus, the new augmented image).

### How to run ###
```
<path_to_dlv2_solver> augmented_label_generator_cataract.asp external_atoms.py <path_to_input_file_1> <path_to_input_file_2> <path_to_input_file_n> --silent --filter=new_cell/3 > output.txt
```
where:
  - ```<path_to_dlv2_solver>``` is the path to the DLV2 solver
  - ```<path_to_input_file_x>``` is a file containing all or some of the input facts
  - ```output.txt``` is the file containing the output (note that, if the provided input violates one or more constraints, then output.txt will contain ```INCOHERENT```)



## Vocalfolds ##

### Input ###

This program takes in input some matrices of 512x512 pixels, represented by facts in the following form: 
```
cell(R,C,CLASS)
```
where ```CLASS``` is the class of the cell at row ```R``` and column ```C```.
For each matrix, it must exist an atom of the form ```class(FILENAME)```, where:
  - ```class``` is the name of the class this matrix represents
  - ```FILENAME``` is the name of the image file these facts represent

### Output ###
This program gives in output some facts in the form ```new_cell(R,C,CLASS)```, which represent the new matrix (thus, the new augmented image).

### How to run ###
```
<path_to_dlv2_solver> augmented_label_generator_vocalfolds.asp external_atoms.py <input_group> <input_background> <input_pathology> <input_intubation> <input_surgical_tool> --silent --filter=new_cell/3 > output.txt
```
where:
  - ```<path_to_dlv2_solver>``` is the path to the DLV2 solver
  - ```<input_group>``` (mandatory) is the path to a txt file containing only one fact of the form: ```group(X)```, where ```X``` is a number from ```1``` to ```5```. This refers to the group of the image one wants to generate.
  - ```<input_background>``` (mandatory) is the path to a ```txt``` file containing the facts which represent the background
  - ```<input_pathology>``` (optional, depends on group) is the path to a txt file containing the facts which represent the pathology
  - ```<input_intubation>``` (optional, depends on group) is the path to a txt file containing the facts rhich represent the intubation
  - ```<input_surgical_tool>``` (optional, depends on group) is the path to a txt file containing the facts rhich represent the surgical tool
  - ```output.txt``` is the file containing the output (note that, if the provided input violates one or more constraints, then output.txt will contain ```INCOHERENT```)
