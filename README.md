# What is TAGS?
<a href="https://tags.shinyapps.io/tags_shiny/">TAGS, the Totally Awesome Geolocator Service</a> is a web-based service that allows you, the researcher, to edit messy geolocator data in a point-and-click format while saving excluded values for reproducible work.  TAGS automatically suggests potential problem areas based on unexpected values (and you can change the threshold for these), lets you move from problem to problem to edit, and shows a map of coordinates generated from your data given your current edits. 

# Installation instructions
TAGS can be used as a browser-based RShiny app for datasets <30 megabytes.  If you have a dataset >30 mb, please clone the code from the repository to use it on your own computer.

```
git clone https://github.com/baeolophus/TAGS_shiny_version.git
```

You can install <a href=https://posit.co/download/rstudio-desktop//>RStudio</a> and <a href=https://cran.r-project.org/doc/FAQ/R-FAQ.html#How-can-R-be-installed_003f>R</a> following these instructions.

Then install the package dependencies listed below in R.
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
After the R packages are installed, you can run the R code from within RStudio by opening the file TAGS_shiny/app.R and running the code therein, including the final two lines that start the RShiny app locally.

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
TAGS works with generic .csv data containing two columns (datetime and lightlevel; the headers will be renamed in that order), as well as two geolocator file types (.lig and .lux).  We provide three CC0-licensed data files, one for each file type, to provide an example in the previous section. Column headers will be renamed to "datetime" and "light".
  
 ## Step 2. Calibration period information
 Enter the latitude and longitude in decimal degrees, start date, stop date, and sun angle for the calibration period in your data file.  Date can be selected from a calendar when you click on either date box, or entered in format YYYY-MM-DD.  The values default to 0 for both latitude and longitude, the current date for both stop and start dates, and 0 for sun angle.  The arrow buttons steps up latitude and longitude in 0.00001 decimal degree increments.  The sun angle can also be calculated by clicking the button "Calculate sun angle from data" and in that case, the sun angle will appear in that same box.
 
 ## Step 3. Light threshold entry
 The default light threshold is 5.5 and can be changed in increments of 0.1 with the arrows on the right side of the box.
 
 ## Step 4. Optional: change value for finding problem areas
TAGS is designed to highlight potential false twilights (from shade, artificial lighting, etc).  This value is how TAGS chooses potential problem twilights to highlight visually in red in Step 5.  Thus, the problem threshold value should reflect what you view as the smallest possible time you might go from light to dark or vice versa naturally.  The default value 5 hours. The steps are in increments of 1 hour, and the values allowed are 0 hrs to 24 hrs.  Five hours is usually suitable for most regions.  Changing the value will **not** erase your previous selections for excluded points, so you can experiment if you wish to highlight further potential problems without losing existing edits.
 
 ## Step 5. Find problem areas and edit your data
This step contains two plots.  The first plot shows shows all of your data with problem areas highlighted in red boxes and the location of the editing window shown in gray.  (An error may show briefly on the overall data view plot, but the plot is still loading as long as the loading indicator returns.)

The second plot is shown below window settings and is the interactive plot where you choose points to exclude.

The window settings are as follows:
- Default unit is days, but can be changed with the radio button to hours.
 - "Editing window length" is in days and defaults to a two-day window.
 - "What overlap with previous window" is in days and defaults to 1 hour (172800 seconds), which is 0.04 day.

The editing plot (the second plot in this section) can be moved in two ways: by editing window or by problem (as illustrated in the first plot).  Use the Previous and Next buttons to move to the next or previous editing window or problem twilight.  You can click individual points to toggle them from included (default) to excluded. Below the editing plot are three buttons.
- Toggle currently selected points: clicking this button toggles the state (excluded/included) for the currently selected point or points.
- Reset ALL EXCLUDED POINTS: FIXME
- Show/refresh edited values: FIXME
 
 ## Step 6. Generate coordinates
- 6A. Generate edited twilights for coordinate calculation
- 6B. Generate map from edited twilights
  - Documentation for the underlying Geolight R package is at https://github.com/slisovski/GeoLight and explains how daylight changes are calculated.
 
 ## Step 7. Download data
Data can be downloaded as a .csv file in three formats.
 - Recommended: "Download TAGS format (original data with edits and twilights)" - use this if you are taking the data to another geolocator processing software that requires a TAGS format OR if the format will be accepted by other programs.  One of the additional benefits of the TAGS format is that it documents your edits, so if the next package in your workflow will accept this format, it is a reproducible choice.  Column headers will be "datetime" (in POSIXct format in UTC), "light", "twilight", "interp" (TRUE/FALSE), and "excluded" (TRUE/FALSE)
 - "Download edited coordinates only" - use this if you only want the coordinates for your tag after editing.
 - "Download edited twilights only" - use this if you want the twilights after editing.


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
