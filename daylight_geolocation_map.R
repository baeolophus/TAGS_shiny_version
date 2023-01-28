devtools::install_github("hrbrmstr/terminator",
                         dependencies = TRUE,
                         INSTALL_opts = c("--no-multiarch"))

library(ggplot2)
library(dplyr)
library(ggalt)
library(maps)
library(terminator)


WorldData <- map_data('world') %>% fortify()

terminator_line <- terminator(as.integer((as.POSIXct(Sys.Date()) + (60*60*(7)))), -180, 180, 0.1)

arbitrary_day <- median(terminator_line$lat)+15

ggplot() +
  geom_map(data = WorldData, map = WorldData,
           aes(group = group, map_id=region),
           fill = "white", colour = "#7f7f7f", size=0.5)+
  geom_ribbon( 
    data=terminator_line,
    aes(lon, ymin=lat, ymax=90), fill="lightslategray", alpha=1/2
  ) +
  geom_line( 
    data=terminator_line,
    aes(lon, lat), color = "blue"
  ) +
  scale_x_continuous(limits=c(-180, 180)) +
  coord_quickmap() +
  ggthemes::theme_map() +
  #solar noon line
  geom_segment(aes(x = terminator_line$lon[which.max(terminator_line$lat)], 
               xend = terminator_line$lon[which.max(terminator_line$lat)],
               y = min(terminator_line$lat),
               yend = max(terminator_line$lat))) +
  # daylength (indicates latitude)
   geom_segment(aes(y = arbitrary_day,   #arbirary chosen line
                    yend = arbitrary_day,#same
                    x = max(terminator_line$lon[terminator_line$lat>arbitrary_day]),
                xend = min(terminator_line$lon[terminator_line$lat>arbitrary_day])))
