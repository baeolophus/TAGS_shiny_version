---
title: 'TAGS: A RShiny App for Light-level Geolocator Data Cleaning'
tags:
  - R
  - biology
  - geolocator
  - animal tracking
  - data cleaning
authors:
  - name: Claire M. Curry^[Co-first author, corresponding author]
    orcid: 0000-0003-4649-7537
    affiliation: "1, 2" 
  - name: Eli S. Bridge^[Co-first author]
    orcid: 0000-0003-3453-2008
    affiliation: 2
affiliations:
 - name: University Libraries, University of Oklahoma, USA
   index: 1
 - name: Oklahoma Biological Survey, University of Oklahoma, USA
   index: 2

date: 10 March 2022
bibliography: paper.bib

---

# Summary

## " Summary: Has a clear description of the high-level functionality and purpose of the software for a diverse, non-specialist audience been provided?"- https://joss.readthedocs.io/en/latest/review_criteria.html

Studies of avian migration frequently entail the use of tracking devices to map the movements of birds in space and time [@Bridge:2011]. Of the several types of tracking devices available, the smallest are light-level geolocation dataloggers. These devices may weigh less than 1 gram and are used to track birds that are too small to carry devices like GPS-enabled transmitters or cellular-based trackers [@Bridge:2011]. Geolocators are also inexpensive relative to other tracking devices [@Bridge:2011], and can sometimes be deployed in large numbers (citation). By simply recording light levels at short time intervals, geolocators provide estimates of the time of sunrise and sunset, which in turn allows one to infer latitude (based on day length) and longitude (based on the time of solar noon) [@DeLong:1992; @Wilson:1992; @Hill:1994]. Although this tracking method is limited by the fact that the tracked animal must be recaptured to recover the tag, geolocators have revolutionized our understanding of avian migration [@Stutchbury:2009; @Bridge:2011]. [FIXME: More recent summary of geolocation as still useful?]

![Sunlight distribution map and simulated geologger data illustrating solar-geolocation based on daylength (indicates latitude) and the time of solar noon (indicates logitude).  The bars for solar noon and daylength are over a shaded map of the world indicating what area of the globe is currently in daylight.  The site where the two bars cross is the geolocation for that combination of solar noon and daylength.](https://github.com/baeolophus/TAGS_shiny_version/blob/main/Solar_geolocator_figure_ESB.png?raw=true)

Transforming light level data from a geolocator into geographical coordinates requires several analytical steps (citation). The first step generally involves visualizing the data and editing instances where light level values have apparently been altered by shading or other interference (citation). TAGS provides a user-friendly platform for performing this crucial first step in the analysis of geolocator data. The software provides a simple visual interface for displaying tag data and “zooming in” on problem areas. It also allows for data editing through an annotation process such that changes made to the dataset are tracked, making the entire analysis process reproducible. As the users edit their data they can perform preliminary geographical analyses to see their migratory flight paths take shape. Finally, the output from TAGS is compatible with all of the next steps in geolocator analysis: R packages such as  `FLightR` (citation), `GeoLight` [@Lisovski:2012], and `SGAT` (citation)), which  are accepted as standards for generating publishable results from geolocator data [@Lisovski:2020]. 

# Statement of need

`TAGS: Totally Awesome Geolocator Service` is an RShiny wrapper for the data cleaning functionality from the `GeoLight` R package (citation).  It provides additional functionality with its easy to use interface and data annotation for repeatability.  It is one of the six major recommended open-source tools for light-level geolocator data analysis [@Lisovski:2020].  It takes data in three common formats, .csv, .lig, and .lux (citation for this one?), then outputs data into a now-standard format called TAGS format that is compatible with the major standard geolocator packages such as `FLightR` (citation), `GeoLight` [@Lisovski:2012], and `SGAT` (citation).  The TAGS format documents the changes made to the dataset for repeatability with a new column so that users can run analyses with and without the edited points, which is a functionality not available in the original GeoLight package's data cleaning feature.  Additionally, GeoLight's interactive cleaning process also does not allow the user to move backwards in the dataset, only forwards.  TAGS uses the Threshold method of calculating twighlights, unlike the other GUI packge `TwGeos` which uses FIXME (citation), so this tool ensures there are two user-friendly data cleaning methods for geolocator analysis.

# State of the field
## "State of the field: Do the authors describe how this software compares to other commonly-used packages?"- https://joss.readthedocs.io/en/latest/review_criteria.html Mention (if applicable) a representative set of past or ongoing research projects using the software and recent scholarly publications enabled by it.

This package is designed to be used by researchers with messy light-level geolocator data.  The software is featured in has been recently featured as one of the six major tools in the analysis workflow for geolocators [@Lisovski:2020] who note TAGS can "visualize the raw light-level recordings with different zoom options, fast processing and a  user-friendly interface that does not require users to write code".  It is the only major geolocator data processing tool that does not require users to write code (Table 1, Lisovski et al. 2020).  TAGS has been cited in methods [@Contina:2013; @Rakhimberdiev:2015; @Johnson:2016; @Pierce:2017] and recommended for use [@Lisovski:2020] since its creation.

The project previously existed as a [JavaScript-based web interface debuting in 2013](https://github.com/tags/geologgerui).  The application was re-written in RShiny starting in 2018 to enable ongoing modification to use the interface with additional data cleaning packages for geolocator data in R.  Most biologists using geolocators are using the R packages and thus may be able to translate them with most efficiency to the RShiny interactive interace.  Existing GitHub issues suggest current feature requests.  The code base is commented to indicate where future contributes can extend the project with additional geolocator data cleaning packages while still maintaining the annotated (and thus reproducible), cleaned TAGS output format.  The redesigned tool was debuted to practitioners at a geolocator-specific animal tracking workshop for the International Ornithological Congress in Vancounver BC in 2018.  

Citations and needs to address in paper: https://github.com/openjournals/joss/issues/1031
Other wrappers to compare to see if we meet scope:
- https://joss.theoj.org/papers/10.21105/joss.01160
- Other wrappers: https://joss.theoj.org/papers/search?q=wrapper

# Citations

## Already in .bib collection
Bridge 2011 https://www.jstor.org/stable/10.1525/bio.2011.61.9.7?searchText=%28geolocator%29+AND+%28threshold%29+AND+%28tags%29&searchUri=%2Faction%2FdoBasicSearch%3FQuery%3D%2528geolocator%2529%2BAND%2B%2528threshold%2529%2BAND%2B%2528tags%2529%26so%3Drel&ab_segments=0%2Fbasic_search_gsv2%2Fcontrol&refreqid=fastly-default%3A6fae9abe1f5ebd0f793392e70c549308&seq=1

(Lisovski et al. 2020 - https://besjournals.onlinelibrary.wiley.com/doi/pdf/10.1111/1365-2656.13036) - see section 3 and table 1

https://github.com/slisovski/GeoLight/blob/master/vignettes/GeoLight2.0.Rmd - geolight vignette says to use TAGS and how R plots are not interactive or feasible for large datasets

Lisovski & Hahn 2012 https://besjournals.onlinelibrary.wiley.com/doi/pdf/10.1111/j.2041-210X.2012.00185.x

Rakhimberdiev et al. 2015 https://movementecologyjournal.biomedcentral.com/articles/10.1186/s40462-015-0062-5
Pierce et al. 2017:  https://www.jstor.org/stable/44994030?searchText=%28geolocator%29+AND+%28threshold%29+AND+%28totally+AND+awesome%29&searchUri=%2Faction%2FdoBasicSearch%3FQuery%3D%2528geolocator%2529%2BAND%2B%2528threshold%2529%2BAND%2B%2528totally%2BAND%2Bawesome%2529%26so%3Drel&ab_segments=0%2Fbasic_search_gsv2%2Fcontrol&refreqid=fastly-default%3A0a8b5f3c3bb790b2165df502277edb05&seq=1
Johnson et al. 2016: https://www.jstor.org/stable/44994015?searchText=%28geolocator%29+AND+%28threshold%29+AND+%28totally+AND+awesome%29&searchUri=%2Faction%2FdoBasicSearch%3FQuery%3D%2528geolocator%2529%2BAND%2B%2528threshold%2529%2BAND%2B%2528totally%2BAND%2Bawesome%2529%26so%3Drel&ab_segments=0%2Fbasic_search_gsv2%2Fcontrol&refreqid=fastly-default%3Af6ac719f66969722d396fc4eb1e791e4&seq=1
Contina et al 2013: https://www.jstor.org/stable/10.1525/auk.2013.13003?seq=1

## Formatting
Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit. FIXME for old TAGS

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Acknowledgements

We thank Simeon Lisovski for comments on TAGS and guidance in adapting the R Geolight package; Jonah Duckles and Phil Dow for contributions to a previous version of TAGS in JavaScript; Paula Cimprich for selecting example data; and Wes Honeycutt for comments on the manuscript.

# References
