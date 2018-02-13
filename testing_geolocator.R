#Testing out geolocator analysis code to see what it does relative to the TAGS original website.

library(GeoLight)

#mentioned on github but not in geologger.py code
library(DayTripR)

#devtools::install_github("SWotherspoon/SGAT")
library(SGAT)
library(FLightR) #Takes tags input.  Does not calculate twilight.

#TAGS original website specifies using GeoLight
#https://github.com/tags/tags-docker/blob/master/geologger/geologger.py
#https://github.com/tags/pygeologger/blob/master/geologger.py

#"Base functionality"
#https://github.com/tags/pygeologger/blob/master/geolight.R
# Parse command line arguments
options <- commandArgs(trailingOnly = TRUE)
infile <- options[0]
xy <- options[1]

lig <- read.csv(infile,
                header=T)
trans <- twilightCalc(lig$datetime,
                      lig$light,
                      ask=F)
calib <- subset(trans,
                as.numeric(trans$tSecond) < as.numeric(strptime("2011-06-25 11:24:30",
                                                                "%Y-%m-%d %H:%M:%S")))

x=-98.7
y=34.77
elev <- getElevation(calib$tFirst,
                     calib$tSecond, 
                     calib$type,
                     known.coord=c(x,y) )

coord <- coord(trans$tFirst,
               trans$tSecond,
               trans$type,
               degElevation=elev)
head(coord)

#GeoLight vignette
data(hoopoe1)
head(hoopoe1)

#use ligTrans, luxTrans, or as.POSIXct to get time into correct format.
hoopoe1$datetime <- as.POSIXct(strptime(hoopoe1$datetime, format = "%Y-%m-%d %H:%M:%S", tz = "GMT"))
twl <- twilightCalc(hoopoe1$datetime, 
                    hoopoe1$light, 
                    LightThreshold = 1.5,
                    ask = F,
                    allTwilights = TRUE)
head(twl)

source("TAGS_shiny/source_TAGS_twilightCalc.R")
twl <- TAGS_twilight_calc(hoopoe1$datetime, 
                    hoopoe1$light, 
                    LightThreshold = 1.5)
head(twl)

allTwilights <- twl[[1]]
str(allTwilights[allTwilights$type >0,])
consecTwilights <- twl[[2]]
consecTwilights$timetonext <- difftime(time1 = consecTwilights$tSecond,
                                       time2 = consecTwilights$tFirst,
                                       units = "hours")
probTwilights <- consecTwilights[consecTwilights$timetonext < 10,]


  ggplot()+
    geom_line(data = hoopoe1, 
              aes(hoopoe1$datetime,
                  hoopoe1$light))+
    geom_rect(data = probTwilights,
         aes(xmin = tFirst,
             xmax = tSecond,
             ymin = -Inf,
             ymax = Inf),
         col = "red",
         fill = "red",
         alpha = 0.5)
  

  
PABU <- read.table("TAGS_shiny/data/PABU222150719.lig",
                              sep = ",",
                              header = FALSE)

PABU$datetime <- as.POSIXct(strptime(PABU$V2,
                                     format = "%d/%m/%y %H:%M:%S",
                                     tz = "GMT"))

twl <- twilightCalc(PABU$datetime, 
                    PABU$V4, 
                    LightThreshold = 1.5,
                    ask = F,
                    allTwilights = TRUE)

all <- twl$allTwilights


plot(x = all[all$type==0,"datetime"],
     y = all[all$type==0,"light"],
     type = "l",
     xlim = c(min(all$datetime), as.POSIXct("2010-08-01 12:00:00")))


abline(v = all[all$type!=0,"datetime"],
       col = "red",
       lwd = 1)


data(calib2)
calib2$tFirst <- as.POSIXct(calib2$tFirst, tz = "GMT")
calib2$tSecond <- as.POSIXct(calib2$tSecond, tz = "GMT")
swiss_elev <- getElevation(calib2, known.coord = c(8,47.01))


coord <- coord(calib2$tFirst,
               calib2$tSecond,
               calib2$type,
               degElevation=swiss_elev)
head(coord)

LANIUS <- read.table("TAGS_shiny/data/file-225388016.csv",
                   sep = ",",
                   header = TRUE)
LANIUS$datetime <- as.POSIXct(strptime(LANIUS$timestamp,
                                     format = "%Y-%m-%d %H:%M:%S",
                                     tz = "GMT"))

twl <- twilightCalc(LANIUS$datetime, 
                    LANIUS$gls.light.level,
                    ask = F,
                    allTwilights = TRUE)
allTwilights <- twl[[1]]
consecTwilights <- twl[[2]]
