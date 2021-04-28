# Facsimile

Actions available for facsimiles

## Create MEI Facsimile Tree from image folder

In order to use this task perform the following operations in terminal

1. If you're not already in the facsimile folder, cd to the facsimile folder, e.g. from the repository root folder:

   ```sh
   cd facsimile
   ```
   
2. Get Saxon-9HE and build the image-size-report.jar file in the submodule by running:
   
    ```sh
    ant prepare
    ```
3. Create MEI facsimile tree` in `output/facsimile.xml:

   ```sh
   ant facsimile -DimageSet.uri=PATH-TO-FOLD`ER-CONTAINING-IMAGES
   ```   
