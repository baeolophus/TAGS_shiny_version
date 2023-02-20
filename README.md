# TAGS, the Totally Awesome Geolocator Service
TAGS is <a href="https://tags.shinyapps.io/tags_shiny/">a web-based service</a> that allows you to edit messy geolocator data in a point-and-click format while saving excluded values for reproducible work.  TAGS automatically suggests potential problem areas, lets you move from problem to problem to edit, and shows a map of coordinates generated from your data given your current edits.   Please clone the code from the repository to use it on your own computer for datasets >30 mb.

# What is TAGS?
<a href="https://tags.shinyapps.io/tags_shiny/">TAGS, the Totally Awesome Geolocator Service</a> is a web-based service that allows you, the researcher, to edit messy geolocator data in a point-and-click format while saving excluded values for reproducible work.  TAGS automatically suggests potential problem areas based on unexpected values (and you can change the threshold for these), lets you move from problem to problem to edit, and shows a map of coordinates generated from your data given your current edits. 

# Installation instructions
TAGS can be used as a browser-based RShiny app for datasets <30 megabytes (the <a href="https://github.com/baeolophus/TAGS_shiny_version/blob/main/README.md#example-usage">Example Use section</a> below has a sample file within this limit).  If you have a dataset >30 mb, please clone the code from the repository to use it on your own computer.

```
git clone https://github.com/baeolophus/TAGS_shiny_version.git
```

You can install <a href=https://posit.co/download/rstudio-desktop//>RStudio</a> and <a href=https://cran.r-project.org/doc/FAQ/R-FAQ.html#How-can-R-be-installed_003f>R</a> following these instructions.

Then install the package dependencies listed below in R.
```
  install.packages( 
  "devtools", # needed for GeoLight only
  "dplyr",
  "DT",
  "FLightR", 
  "ggplot2",
  "leaflet",
  "lubridate",
  "scales", 
  "shiny", 
  "shinycssloaders")
  
  devtools::install_github("SLisovski/GeoLight")

```
After the R packages are installed, you can run the R code from within RStudio by opening the file TAGS_shiny/app.R and running the code therein, including the final two lines that start the RShiny app locally.

# Example usage

The manual cleaning and annotating created by TAGS is expected to be used <a href="https://github.com/baeolophus/TAGS_shiny_version/issues/4">after non-header rows are cleaned from the start of data files</a>, and before full analysis of animal locations (see Lisovski et al. 2020 and other recent geolocator publications).  You can run this example online in the web-based <a href="https://tags.shinyapps.io/tags_shiny/">TAGS</a> or <a href="https://github.com/baeolophus/TAGS_shiny_version/blob/main/README.md#installation-instructions">locally on your own computer</a>.

## Step 1. Select your file
The example screenshots in this section are generated with the sample file <a href="/data/GL36_000.lig">GL36_000.lig</a>. Once the blue "loading" bar below the "Browse for your file" secondary header says "Upload complete", then a figure appears under <a href=https://github.com/baeolophus/TAGS_shiny_version#step-2-calibration-period-information>Step 5</a>. An error may show briefly under Step 5, but the plot is still loading as long as the loading indicator (three vertical blue bars) returns. Once the file is uploaded, the column headers are renamed to "datetime" and "light", so the appearance of TAGS column headers will be the same for any files. Then, proceed to <a href="https://github.com/baeolophus/TAGS_shiny_version#step-2-calibration-period-information">Step 2</a>.
![Step 1 completed; the "loading" bar is filled with blue stripes and text that says "upload complete" and a line graph of all the data appears under the Step 5 header.](Step1_screenshot.PNG?raw=true "ShinyApps TAGS screen after Step 1 completed.")

  
 ## Step 2. Calibration period information
For the .lig example file, enter sample values (from Cooper et al. (2015)'s <a href="https://www.datarepository.movebank.org/bitstream/handle/10255/move.584/Cooper_Annotated_R_Code.txt?sequence=1">movebank R code</a>).
- Calibration latitude 44.655523
- Calibration longitude -84.647636
- Calibration start date 2014-06-13
- Calibration end date 2014-07-29

These values result in a calculated sun angle of -3.42629187230021.  <a href="https://github.com/baeolophus/TAGS_shiny_version/issues/7">Known bug</a>: if you click "calculate sun angle from data" before entering values, the app will crash.
 
 ![Step 2 completed; values are latitude 44.655523, longitude -84.647636, and dates 2014-06-13 to 2014-07-29.  These result in a calculated sun angle of -3.42629187230021.](Step2_screenshot.PNG?raw=true "ShinyApps TAGS screen after Step 2 completed.") 
 
 ## Step 3. Light threshold entry
 The default light threshold value is 5.5.  We will leave this value as-is.  For information on editing this value, read <a href="https://github.com/baeolophus/TAGS_shiny_version#step-3-light-threshold-entry-1">the documentation for Step 3</a>.
 
 ## Step 4. Optional: change value for finding problem areas
The default threshold for detecting problem areas in light data is 5 hours.  We will leave this value as-is.  For information on editing this value, read <a href="[https://github.com/baeolophus/TAGS_shiny_version#step-3-light-threshold-entry-1](https://github.com/baeolophus/TAGS_shiny_version#step-4-optional-change-value-for-finding-problem-areas-1)">the documentation for Step 4</a>.
 
 ## Step 5. Find problem areas and edit your data
To determine if the problem highlighter "red box" is working correctly, examine the example file.  The example .lig (Cooper et al. 2017a, b; http://dx.doi.org/10.5441/001/1.h2b30454) is easier to edit if we adjust the window length to 1.

![Step 5 first change is moving Editing Window Length from default value of 2 to 1, keeping units as days.](Step5_screenshot1.PNG?raw=true "ShinyApps TAGS screen during adjusting Step 5 values; first change of setting editing window length value to 1.") 

 With default values for finding problem areas and the window length at 1, we can see a problem area exists from 2014-06-07T11:32:36Z to 2014-06-07T15:14:36Z (rows 351-462).  Using the mouse cursor to click and drag, set the area to toggle points in and out of exclusion.
![Step 5 scroll down to edit window](Step5_screenshot2.PNG?raw=true "ShinyApps TAGS screen scrolling down through Step 5 to see editing window") 

Once the points are selected (the rectangular box will stay in the plot window), click "Toggle Selected Points".  The points, previously filled with black, become empty circles.
![Step 5 editing window with problem light levels excluded (the points have become unfilled).](Step5_screenshot3.PNG?raw=true "Step 5 editing window with problem light levels excluded (the points have become unfilled).") 

Below the editing window plot, scroll down to see all of the buttons.  Clicking "Show/refresh edited values" will generate a table of points that have been excluded.
![Step 5 table (below editing window) with problem light levels excluded.](Step5_screenshot4.PNG?raw=true "Step 5 table (below editing window) with problem light levels excluded") 

## Step 6. Generate coordinates
Step 6 has two parts to examine your edited coordinates.

Step 6a generates location points from the edited light data.  At this step, it lets you see your edited and unedited points with datetime and lightlevel together.  You can use the "search" box in the upper right corner above the table to filter.  This screenshot shows "true" written in search, which pulls up the 99 excluded points, so you can spot check dates/times against the Step 5 plot if desired.
![Step 6a table (below editing window and editing table) with only excluded points shown (excluded = TRUE).](Step6_screenshot1.PNG?raw=true "Step 6a table (below editing window and editing table) with only excluded points shown (excluded = TRUE)") 

Step 6b takes the generated coordinates from Step 6a and plots them on a map.
![Step 6b creates a map with geographic locations generated from the edited light level data.](Step6_screenshot2.PNG?raw=true "Step 6b creates a map with geographic locations generated from the edited light level data.") 


## Step 7. Download data
The three download buttons will export three different file formats, prefixed with the download type and suffixed with the download date.  For the sample .lig file originally named GL36_000.lig, the downloaded file will be named as follows
- "Download TAGS format (original data with edits and twilights)" creates <a href="/data/TAGS_format_data-GL36_000.lig2023-02-20.csv">TAGS_format_data-GL36_000.lig2023-02-20.csv</a>.
- "Download edited coordinates only" creates <a href="/data/coord_data-GL36_000.lig2023-02-20.csv">coord_data-GL36_000.lig2023-02-20.csv</a>.
- "Download edited twilights only" creates <a href="/data/twilights_data-GL36_000.lig2023-02-20.csv">twilights_data-GL36_000.lig2023-02-20.csv</a>.

# Functionality documentation
Below, we explain the default and available values at each step of the TAGS process.  
## Step 1. Select your file
TAGS works with generic .csv data containing no headers or one header row, as well as two geolocator file types (.lig and .lux). Some .lux and .lig files may contain multiple pre-data, pre-header rows which must be removed before upload to TAGS.  TAGS works with generic .csv data containing two columns (datetime and lightlevel; the headers will be renamed in that order), as well as two geolocator file types (.lig and .lux).  We provide three CC0-licensed data files, one for each file type, to provide an example in the previous section. Column headers will be renamed to "datetime" and "light".
  
 ## Step 2. Calibration period information
 Enter the latitude and longitude in decimal degrees, start date, stop date, and sun angle for the calibration period in your data file.  Date can be selected from a calendar when you click on either date box, or entered in format YYYY-MM-DD.  The values default to 0 for both latitude and longitude, the current date for both stop and start dates, and 0 for sun angle.  The arrow buttons steps up latitude and longitude in 0.00001 decimal degree increments.  The sun angle can also be calculated by clicking the button "Calculate sun angle from data" and in that case, the sun angle will appear in that same box.  If you are unsure what your calibration period location or dates are, please read <a href="doi.org/10.1111/1365-2656.13036">section 4.2 in Lisovski et al. 2020 "Light‐level geolocator analyses: A user's guide"</a>.
 
 ## Step 3. Light threshold entry
 The default light threshold is 5.5 and can be changed in increments of 0.1 with the arrows on the right side of the box.
 
 ## Step 4. Optional: change value for finding problem areas
TAGS is designed to highlight potential false twilights (from shade, artificial lighting, etc).  This value is how TAGS chooses potential problem twilights to highlight visually in red in Step 5.  Thus, the problem threshold value should reflect what you view as the smallest possible time you might go from light to dark or vice versa naturally.  The default value 5 hours. The steps are in increments of 1 hour, and the values allowed are 0 hrs to 24 hrs.  Five hours is usually suitable for most regions.  Changing the value will **not** erase your previous selections for excluded points, so you can experiment if you wish to highlight further potential problems without losing existing edits.
 
 ## Step 5. Find problem areas and edit your data
This step contains two plots (generated with ggplot2).  The first plot shows shows all of your data with problem areas highlighted in red boxes and the location of the editing window shown in gray.  (An error may show briefly on the overall data view plot, but the plot is still loading as long as the loading indicator returns.)

The second plot is shown below window settings and is the interactive plot where you choose points to exclude.

The window settings are as follows:
- Default unit is days, but can be changed with the radio button to hours.
 - "Editing window length" is in days and defaults to a two-day window.
 - "What overlap with previous window" is in days and defaults to 1 hour (172800 seconds), which is 0.04 day.

The editing plot (the second plot in this section) can be moved in two ways: by editing window or by problem (as illustrated in the first plot).  Use the Previous and Next buttons to move to the next or previous editing window or problem twilight.  You can click individual points to toggle them from included (default) to excluded. Below the editing plot are three buttons.
- Toggle currently selected points: clicking this button toggles the state (excluded/included) for the currently selected point or points.
- Reset ALL EXCLUDED POINTS: this returns all excluded points to "excluded" = FALSE.
- Show/refresh edited values: this shows a table of the edited rows, returning the new (edited) light values.
 
 ## Step 6. Generate coordinates
- 6A. Generate edited twilights for coordinate calculation: this step creates lat/long coordinates in decimal degrees using the function GeoLight::coord and shows them in a table on the TAGS page.
- 6B. Generate map from edited twilights: this step takes the coordinates from Step 6A and plots them using ggplot2.

Documentation for the underlying Geolight R package is at https://github.com/slisovski/GeoLight and explains how twilights are calculated.
 
 ## Step 7. Download data
Data can be downloaded as a .csv file in three formats.  All three formats begin with a prefix for the download type and end with the download date appended.  

 - Recommended: "Download TAGS format (original data with edits and twilights)" - use this if you are taking the data to another geolocator processing software that requires a TAGS format OR if the format will be accepted by other programs.  One of the additional benefits of the TAGS format is that it documents your edits, so if the next package in your workflow will accept this format, it is a reproducible choice.  Column headers will be "datetime" (in POSIXct format in UTC), "light", "twilight", "interp" (TRUE/FALSE), and "excluded" (TRUE/FALSE)
 - "Download edited coordinates only" - use this if you only want the coordinates for your tag after editing.
 - "Download edited twilights only" - use this if you want the twilights after editing.


# Automated tests
Geolocator data is cleaned visually and manually with this tool.  A map is created in step 6 to allow you to check whether points are appearing where expected relative to your animal release point.  Citations explaining the GeoLight location calculation methods are available at https://github.com/slisovski/GeoLight .  You can compare your table and map to the screenshots in the sample .lig file from "Example Use" to determine basic functionality.

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

