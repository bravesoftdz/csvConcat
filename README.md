### csvConcat

This is just a quick hack that concatenates all the `*.csv.` files that are found in the folder this program is called from.  The destination file name should be passed as the first parameter to the program.  If no file name is passed then the working folder will be the file name.

Working folder `c:\some\folder\name\imadeup` becomes file name `imadeup.csv`.


This program was written solely to combine a few hundred `.csv` files into several groups.  Each file ends up representing a column in the new combined file.  This could be done in Excel by hand, but would take hours to complete.

Written using Delphi 10.2 Tokyo.  Utilizing `IList` from Spring4D version 1.2 
