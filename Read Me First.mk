#File maintenance convention
Hi, please follow these conventions to name the files, store files in branches and folders and branches, making and merging different versions.

## Naming Your File
Format: YYMMDD-fileName-Status
Example: 221127-OwenGeneralModel-P
Status categories:
* K: kick off, not started yet
* P: in progress, not completed yet
* C: completed, not necessarily ready for use cases, erorr can occur
* M: under revision & modification
* R: ready for mass use cases, use it as you want

## Branching
I will store the general modelling code in the main branch. If you want to make your own modification, please create a new branch before committing new changes. 
Name your branch by format: YYMMDD-YourName-Purpose
Example: 112227-Owen-AddBayesError
Please send a **Pull Request**  before you merge different branches!

## Folder
Under each branch, prepare your models in the below format:
* Code: for all R code, python code (in script format, no notebook)
* Notebook: all your notebooks for EDA and visuals
* Resources: contextual info about NFL, theoretical support of building the statistical model
* Data: all your csv files
* Archive: files that you don't need at the moment but not sure whether to delete it
