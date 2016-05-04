# MIxS csv exports and script to produce MIxS as RDF

This repository is the destination for CSV file exports from the MIxS database, where the terms for the MIxS standard are managed. The exports can be used with the script ```packages/mixs_to_rdf/mixs_to_rdf.py``` to generate the latest version of file ```mixsterms.rdf```, which is a representation of MIxS as RDF, including definitions of MIxS-specific classes and owl:sameAs relationships to terms defined in Darwin Core and ENVO, but used in MIxS under distinct identifiers.

The CSV exports from the MIxS database are:

* ```mixs_core.csv```	- the latest core MIxS checklists, definitions, and requirements
* ```mixs_envpackages.csv``` - the latest environmental terms assigned to packages
* ```mixs_envparams.csv```	- the latest distinct environmental terms, not assigned to packages
* ```mixs_param_to_envpackage.csv``` - the latest association of each parameter to a package. There are only a few definitions here, because this table up to collect any “exception” definitions for various parameters, should that definition be distinct between the environmental packages (e.g., temperature is always called temperature, but it has a different definition in water package, compared to host-associated package).

# mixs_to_rdf.py

The script ```mixs_to_rdf.py``` in the folder ```packages/mixs_to_rdf``` is a self-testing script to produce a file that represents the current MIxS standard terms in RDF. The script requires workspaces for the previous and current versions of MIxS. The previous version is required in order to determine and record if changes have occurred to specific terms between that version and the new one.

The script requires a directory into which the files associated with the new version of MIxS must go. The following files are required to be in this directory and up-to-date before invoking the ```mixs_to_rdf.py``` script:

* ```class_lookup.csv``` - a file with one column for the distinct values of the ```section``` field from ```mixs_core.csv``` and one column (```organizedInClass```) for the corresponding class names to use in ```mixsterms.rdf```. This mapping is to facilitate the creation of these class terms, which are not tracked explicitly in the MIxS database.
* ```dwc_lookup.csv``` - a file with one column (```mixsterm```) for the MIxS term name and one column (```dwcterm```) for the corresponding Darwin Core term to which this term should be mapped. This mapping is used to create MIxS terms that are defined simply by an ```owl:sameAs``` relationship to the corresponding Darwin Core term to avoid duplication.
* ```envo_lookup.csv``` - a file with one column (```mixsterm```) for the MIxS term name and one column (```envoterm```) for the corresponding ENVO term to which this term should be mapped. This mapping is used to create MIxS terms that are defined simply by an ```owl:sameAs``` relationship to the corresponding ENVO term to avoid duplication.
* ```mixs_core.csv``` - a copy of the latest version of the core export file from the MIxS database. 
* ```mixs-classes.rdf``` - a file containing the RDF snippet defining the MIxS classes given in the ```class_lookup.csv``` field ```organizedInClass```. This is the only place these classes are defined. Any changes in these classes to be incorporated in the current standard must be made in this file prior to running the ```mixs_to_rdf.py``` script.
* ```mixs-header.rdf``` - a file containing the RDF snippet defining the header for the ```mixsterms.rdf``` file. This is the only place thethe header defined. Any changes in the metadata for the ```mixsterms.rdf``` file (including ```dcterms:modified```) must be made in this file prior to running the ```mixs_to_rdf.py``` script.

The script also requires a directory in which the files associated with the previous version of MIxS must go. The following files are required to be in this directory and up-to-date before invoking the ```mixs_to_rdf.py``` script:

* ```mixs_core.csv``` - a copy of the previous version of the core export file from the MIxS database. The contents of the terms in this file will be compared to the contents in the current version of the ```mix_core.csv``` file to determine which terms have changed. This is to address the fact that the dates that terms are modified are not exported from the MIxS database.
* ```mixsterms.rdf``` - a copy of the previous version of the ```mixsterms.rdf``` file. The previous version of the MIxS as RDF file is used to determine the ```dcterms:issued``` and ```dcterms:modified``` dates for the terms in the current ```mixsterms.rdf``` file. This is to address the fact that the dates that terms are issued and modified are not exported from the MIxS database.

#Step-by-Step Process to produce the latest mixsterms.rdf

## Export csv files from MIxS database
From the master branch, create a new branch for a new version in this repository. For example, 

```git checkout -b <version>```

where ```<version>``` denotes the version of the MIxS as RDF you are creating, such as ```version-2016-05-03```. In this branch, replace the MIxS database csv export files in the root of the repository and push those changes to the branch.

## Prepare the version documents
Create a new directory with a name based on the new version date under ```packages/mixs_to_rdf/versions``` (e.g., ```packages/mixs_to_rdf/versions/2016-05-03```). 
Copy the file ```mixs_core.csv``` file from the previous step into this new version directory.
Copy the files ```class_lookup.csv```, ```dwc_lookup.csv```, ```envo_lookup.csv```, ```mixs-classes.rdf```, and ```mixs-header.rdf``` from the directory for the previous version into the directory for the new version directory. 
Review each of these files and make any necessary changes. Refer to the purposes of these files given above in the section 'MIxS as RDF'.

## Run the script mixs_to_rdf.py
Invoke the ```mixs_to_rdf.py``` script from within ```packages/mixs_to_rdf``` using the following pattern:

```python mixs_to_rdf.py <new_version_directory> <previous_version_directory> [<output_file>]```

where 

* ```<new_version_directory>``` is the path to the directory containing the files prepared for the new version as described above,
* ```<previous_version_directory>``` is the path to the directory containing the files from the previous version as described above, 
* ```<output_file>``` is optional, and designates an alternate output filename rather than the default ```mixsterms.rdf```.

Example, from within the directory ```packages/mixs_to_rdf```:

```python mixs_to_rdf.py ./versions/2016-05-03/ ./versions/2013-03-26/ mixsterms-test.rdf```

The script performs tests as it runs to be sure that execution goes as normal and that the requirements to produce the new output file are met. Any problems will reported as test failures. The result of a successful run will be a message such as the following and an output file with the name given in the ```<output_file>``` parameter or ```mixsterms.rdf``` in the new version folder:

```
testing csv_file_dialect
.testing make_mixs_core_as_rdf
.testing read_headers
.testing source_files_exist
.
----------------------------------------------------------------------
Ran 4 tests in 0.013s

OK
```

## Create a release
Review the output from the previous step in the new version folder. If it is correct, make a copy of the output file to ```mixsterms.rdf``` in the root folder of the repository, replacing the file by that name. Also move the output file to ```mixsterms.rdf``` in the new version folder if the output file does not already have that name in that location. Look at the changes that have been made as a result of the efforts so far:

```git status```

The new version folder will appear as needing to be added. Do so with:

```git add <new_version_directory>``` 

where ```<new_version_directory>``` is the directory git shows as needing to be added.

Commit the changes to the version branch in which you have been working:

```git commit -a -m "Comment on the version."```

Then push the changes in the branch to the GitHub repository

```git push origin <version>```

where ```<version>``` is the name of the branch you checked out for this work in the step 'Export csv files from MIxS database' above.

On GitHub, create a pull request and merge the changes, or have someone who is authorized do so. This will bring the changes into the master branch. Then create a release in GitHub. Creating a release will create downloadable zipped packages of the files in the repository at this point in the repositories history and can be used as a published standard document. The list of releases for MIxS as RDF can be found at https://github.com/pyilmaz/mixs/releases.
