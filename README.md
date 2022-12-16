# What is TAGS?
<a href="https://tags.shinyapps.io/tags_shiny/">TAGS, the Totally Awesome Geolocator Service</a> is a web-based service that allows you, the researcher, to edit messy geolocator data in a point-and-click format while saving excluded values for reproducible work.  TAGS automatically suggests potential problem areas based on unexpected values (and you can change the threshold for these), lets you move from problem to problem to edit, and shows a map of coordinates generated from your data given your current edits. 

# Installation instructions
TAGS can be used as a browser-based RShiny app for datasets <30 megabytes.  If you have a dataset >30 mb, please clone the code from the repository to use it on your own computer.  You can install <a href=https://posit.co/download/rstudio-desktop//>RStudio</a> and <a href=https://cran.r-project.org/doc/FAQ/R-FAQ.html#How-can-R-be-installed_003f>R</a> following these instructions.  Then install the package dependencies listed below in R.
```
  install.packages("shiny", 
  "dplyr",
  "DT",
  "FLightR", 
  "GeoLight",
  "ggplot2",
  "leaflet",
  "lubridate",
  "scales", 
  "shiny", 
  "shinycssloaders")
```
# Example usage

## Step 1. Select your file
TAGS works with generic .csv data containing suitable headers, as well as two geolocator file types (.lig and .lux).  We provide three CC0-licensed data files, one for each file type, to provide an example.  Choose the sample file that has an extension or format matching yours (.csv, .lig, or .lux).  
  
 ## Step 2. Calibration period information
 
 ## Step 3. Light threshold entry
 
 ## Step 4. Optional: change value for finding problem areas

 
 ## Step 5. Find problem areas and edit your data
- .lux (Hill and Renfrew 2019a, b; http://dx.doi.org/10.5441/001/1.c6b47s0r)
  - With default values for finding problem areas, problem points exist at times YYYY-MM-DD HH:MM:SS in this dataset.
- .lig (Cooper et al. 2017a, b; http://dx.doi.org/10.5441/001/1.h2b30454)
  - With default values for finding problem areas, problem points exist at times YYYY-MM-DD HH:MM:SS in this dataset.
- .csv (Bridge 2015; available at https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study78970444)
  - With default values for finding problem areas, problem points exist at times YYYY-MM-DD HH:MM:SS in this dataset.
 
 ## Step 6. Generate coordinates
 
 ## Step 7. Download data
 FIXME: link to sample files in github repo.

# Functionality documentation
Below, we explain the default and available values at each step of the TAGS process.  
## Step 1. Select your file
TAGS works with generic .csv data containing suitable headers, as well as two geolocator file types (.lig and .lux).  We provide three CC0-licensed data files, one for each file type, to provide an example in the previous section.  Required headers for each file type are FIXME.
  
 ## Step 2. Calibration period information
 FIXME
 
 ## Step 3. Light threshold entry
 FIXME
 
 ## Step 4. Optional: change value for finding problem areas
 FIXME - range of values tested
 
 ## Step 5. Find problem areas and edit your data
 FIXME
 
 ## Step 6. Generate coordinates
 FIXME
 Documentation for the underlying Geolight R package is at https://github.com/slisovski/GeoLight and explains how daylight changes are calculated.
 
 ## Step 7. Download data
FIXME

# Automated tests
Geolocator data is cleaned visually and manually with this tool.  A map is created in step 6 to allow you to check whether points are appearing where expected relative to your animal release point.  Citations explaining the GeoLight location calculation methods are available at https://github.com/slisovski/GeoLight .  The manual cleaning and annotating created by TAGS is expected to be used before FIXME additional steps (citation).

# Community guidelines
To contribute to TAGS, please create a fork, demonstrate that your changes do not cause unexpected issues in other functionality, then make a pull request on GitHub. Claire is currently seeking someone to take over managing the project, so please reach out to her and Eli if you are interested in a stronger role in expanding TAGS.

To report problems, please create an issue in this repository.

For questions, please contact <a href="https://libraries.ou.edu/users/claire-curry">Claire M. Curry</a>  or <a href="http://thebridgelab.oucreate.com/peeps/">Eli S. Bridge</a>.

# Datasets cited
- Cooper NW, Hallworth MT, Marra PP (2017a) Light-level geolocation reveals wintering distribution, migration routes, and primary stopover locations of an endangered long-distance migratory songbird. Journal of Avian Biology. doi:10.1111/jav.01096 
- Cooper NW, Hallworth MT, Marra PP (2017b) Data from: Light-level geolocation reveals wintering distribution, migration routes, and primary stopover locations of an endangered long-distance migratory songbird. Movebank Data Repository. doi:10.5441/001/1.h2b30454 
- Hill JM, Renfrew RB (2019a) Migratory patterns and connectivity of two North American grassland bird species. Ecology and Evolution. doi:10.1002/ece3.4795 
- Hill JM, Renfrew RB (2019b) Data from: Migratory patterns and connectivity of two North American grassland bird species [grasshopper sparrows]. Movebank Data Repository. doi:10.5441/001/1.c6b47s0r 
- Bridge ES (2015) Painted Bunting ABM 2015. Accessed 16 Dec. 2022.  Availabile at: https://www.movebank.org/cms/webapp?gwt_fragment=page=studies,path=study78970444
