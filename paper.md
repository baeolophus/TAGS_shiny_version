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

# Summary " Summary: Has a clear description of the high-level functionality and purpose of the software for a diverse, non-specialist audience been provided?"- https://joss.readthedocs.io/en/latest/review_criteria.html

What are geolocators here in 2-4 sentences.  @Eli-S-Bridge

Geolocator data has XYZ problems.  @Eli-S-Bridge


# Statement of need

`TAGS: Totally Awesome Geolocator Service` is an RShiny wrapper for the data cleaning functionality in the `Geolight` R package.  It provides additional functionality with its easy to use interface.  It takes data in two common formats (@cmc fill in).  `TAGS` outputs data into a now-standard format called TAGS format that is requested by other standard geolocator packages (citations here cmc fill in, @eli-s-bridge suggestions welcome).  The application was written in RShiny to enable ongoing modification to use the interface with additional data cleaning packages for geolocator data in R.  Most biologists using geolocators are using the R packages and thus may be able to translate them with most efficiency to the RShiny interactive interace.  Existing GitHub issues suggest current feature requests.

#"State of the field: Do the authors describe how this software compares to other commonly-used packages?"- https://joss.readthedocs.io/en/latest/review_criteria.html
This package is designed to be used by researchers with messy light-level geolocator data.  The software is featured in has been recently featured as one of the major tool in the workflow for geolocators (Lisovski et al. 2020 - https://besjournals.onlinelibrary.wiley.com/doi/pdf/10.1111/1365-2656.13036) - see section 3 and table 1.    The redesigned RShiny code base was created in 2018, but the project previously existed in JavaScript since 2013 (citations??).  The code base is commented to indicate where future contributes can extend the project with additional geolocator data cleaning packages.  The redesigned tool was debuted to practitioners at a geolocator-specific animal tracking workshop for the International Ornithological Congress in Vancounver BC in 2018.

Citations and needs to address in paper: https://github.com/openjournals/joss/issues/1031
Other wrappers to compare to see if we meet scope:
- https://joss.theoj.org/papers/10.21105/joss.01160
- Other wrappers: https://joss.theoj.org/papers/search?q=wrapper

# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Acknowledgements

We thank Simeon Lisovski for comments on TAGS and guidance in adapting the R Geolight package; and Jonah Duckles and Phil Dow for contributions to a previous version of TAGS in JavaScript.

# References
