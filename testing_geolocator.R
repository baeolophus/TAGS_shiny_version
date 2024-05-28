#Testing out geolocator analysis code to see what it does relative to the TAGS original website.

library(GeoLight)

#mentioned on github but not in geologger.py code
library(DayTripR)

#devtools::install_github("SWotherspoon/SGAT")
library(SGAT)
library(FLightR) #Takes tags input.  Does not calculate twilight.


tbl <- read.csv("C:/Users/curr0024/Downloads/BC089_23Feb18_233911.lux",
                header = FALSE,
                sep="\t", #.lux is tab separated not comma
                skip = 20)
#testing DM file from issue 6 2023/09/28
tbl <- read.csv("C:/Users/curr0024/Desktop/temporary/ID000418_2023Mar24T163221.csv",
               header = TRUE)

#names headers
names(tbl) <- c("datetime", "light")
#specifies date and time format.
tbl$datetime <- as.POSIXct(x=tbl$datetime,
                           tz = "GMT",
                           tryFormats = c("%d/%m/%Y %H:%M:%S",
                                          "%Y/%m/%d %H:%M:%S"))


LightThreshold <- TRUE
problem_threshold <- 5

source("TAGS_shiny/source_TAGS_twilightCalc.R") #TAGS_twilight_calc
twl <-   TAGS_twilight_calc(tbl$datetime, 
                     tbl$light, 
                     LightThreshold = light_threshold,
                     allTwilights = TRUE)


datetime <- tbl$datetime
light <- tbl$light
dt <- cut.POSIXt(datetime,"1 hour")
st <- as.POSIXct(levels(dt),"UTC")

raw <- data.frame(datetime=dt,light=light)

h  <- tapply(light,dt,max)
df1 <- data.frame(datetime=st+(30*60),light=as.numeric(h))

smooth <- i.twilightEvents(df1[,1], df1[,2], LightThreshold)
smooth <- data.frame(id=1:nrow(smooth),smooth)
raw    <- i.twilightEvents(datetime, light, LightThreshold)
raw <- data.frame(id=1:nrow(raw),raw)

ind2 <- rep(NA,nrow(smooth))
for(i in 1:nrow(smooth)){
  tmp <- subset(raw,datetime>=(smooth[i,2]-(90*60)) & datetime<=(smooth[i,2]+(90*60)))
  
  if(smooth[i,3]==1) ind3 <- tmp$id[which.min(tmp[,2])]
  if(smooth[i,3]==2) ind3 <- tmp$id[which.max(tmp[,2])]
  ind2[i] <- ind3
}


res <- data.frame(raw,mod=1)
res$mod[ind2] <- 0






  consecTwilights <- twl[[2]]
  consecTwilights$timetonext <- difftime(time1 = consecTwilights$tSecond,
                                         time2 = consecTwilights$tFirst,
                                         units = "hours")
  coord <- GeoLight::coord(tFirst = consecTwilights$tFirst,
                    tSecond = consecTwilights$tSecond,
                    type = consecTwilights$type,
                    degElevation=0)
  
  
  #Then we flag twilights with < 5 hrs time to next twilight as potential problems.
  probTwilights <- consecTwilights[consecTwilights$timetonext < problem_threshold,
                                   c("tFirst",
                                     "tSecond",
                                     "type")]
  #This final object is the one that is passed outside as the reactive object used later.
  #So if you do additional methods or change it, make sure the last object is the one that contains
  #problem twilights with columns tFirst (POSIXct), tSecond (POSIXct), and type (num)


x <- 0
time_window <- 2 #days
  
plotall <- ggplot() + 
    geom_line(data = tbl, 
              mapping = aes(tbl$datetime,
                            tbl$light))+
    #draw a line showing where you have set light threshold
    geom_hline(yintercept = light_threshold,
               col = "orange")+
    #draw red boxes around problem twilights
    geom_rect(data = probTwilights,
              mapping = aes(xmin = tFirst,
                            xmax = tSecond,
                            ymin = -Inf,
                            ymax = Inf),  #problem is here with .lux.  Why does it work with .lig?
              col = "red",
              fill = "red",
              alpha = 0.5)+
    labs(x = "datetime", 
         y = "light")+
    #draw pale gray box over editing window
    annotate("rect",
             xmin = x,
             xmax = x+time_window,
             ymin = -Inf,
             ymax = Inf,
             col = "gray",
             fill = "gray",
             alpha = 0.5)


#.lig version
tbl <- read.csv("data/GL36_000.lig",
                header = FALSE,
                sep=",",
                skip = 1)
#specifies date and time format.
tbl$datetime <- as.POSIXct(strptime(tbl$V2,
                                    format = "%d/%m/%y %H:%M:%S",
                                    tz = "GMT"))
tbl$light <- tbl$V4
tbl <- tbl[, c("datetime",
               "light")]



a<-get.tags.data('TAGS_shiny/data/sample_TAGS_format_from_lig.csv')
a<-get.tags.data('example_TAGS_format.csv')


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
twl3 <- twilightCalc(hoopoe1$datetime, 
                    hoopoe1$light, 
                    LightThreshold = 1.5,
                    ask = F,
                    allTwilights = TRUE)
head(twl)
FLightR::GeoLight2TAGS(hoopoe1,
                       twl$consecTwilights,
                       1.5)
GeoLight2TAGS

twl <- TAGS_twilight_calc(hoopoe1$datetime, 
                    hoopoe1$light, 
                    LightThreshold = TRUE)
head(twl)
tags <- FLightR::GeoLight2TAGS(hoopoe1,
                       twl$consecTwilights,
                       1.5)
twl[[2]]$tSecond

allTwilights <- twl[[1]]
consecTwilights <- twl[[2]]
TAGS_twilight_calc(datetime = raw$datetime[raw$excluded == FALSE],
                   light = raw$light[raw$excluded == FALSE],
                   LightThreshold = input$light_threshold,
                   allTwilights = FALSE)
return(edited_twilights)

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

twl <- TAGS_twilight_calc(PABU$datetime, 
                    PABU$V4, 
                    LightThreshold = 1.5)

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
