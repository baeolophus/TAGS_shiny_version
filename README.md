# What is TAGS?
<a href="https://tags.shinyapps.io/tags_shiny/">TAGS, the Totally Awesome Geolocator Service</a> is a web-based service that allows you, the researcher, to edit messy geolocator data in a point-and-click format while saving excluded values for reproducible work.  TAGS automatically suggests potential problem areas based on unexpected values (and you can change the threshold for these), lets you move from problem to problem to edit, and shows a map of coordinates generated from your data given your current edits. 

# Installation instructions
TAGS can be used as a browser-based RShiny app for datasets <30 megabytes.  If you have a dataset >30 mb, please clone the code from the repository to use it on your own computer.  You can install <https://posit.co/download/rstudio-desktop//>RStudio and <https://cran.r-project.org/doc/FAQ/R-FAQ.html#How-can-R-be-installed_003f>R following these instructions.  Then install the package dependencies listed below in R.
  install.packages("shiny", "dplyr", "DT", "FLightR", "GeoLight", "ggplot2", "leaflet", "lubridate", "scales", "shiny", "shinycssloaders")

# Example usage
Need sample data.

# Functionality documentation
Input data and parameter values at each step of the TAGS web page.  Documentation for the underlying Geolight R package is at https://github.com/slisovski/GeoLight and explains how daylight changes are calculated.

# Automated tests
How can you verify that the software works?  Geolocator data is cleaned visually.  Citations explaining the GeoLight calculation methods are available at https://github.com/slisovski/GeoLight .  The map created as you edit your light-level data allow you to determine whether points are appearing where expected relative to your animal release point.

# Community guidelines
To contribute to TAGS, please create a fork, demonstrate that your changes do not cause unexpected issues in other functionality, then make a pull request on GitHub. Claire is currently seeking someone to take over managing the project, so please reach out to her and Eli if you are interested in a stronger role in expanding TAGS.

To report problems, please create an issue in this repository.

For questions, please contact <a href="https://libraries.ou.edu/users/claire-curry">Claire M. Curry</a>  or <a href="http://thebridgelab.oucreate.com/peeps/">Eli S. Bridge</a>.
