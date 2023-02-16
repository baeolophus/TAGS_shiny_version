# devtools::install_github("hrbrmstr/terminator",
#                          dependencies = TRUE,
#                          INSTALL_opts = c("--no-multiarch"))

library(ggplot2)
library(dplyr)
library(ggalt)
library(maps)
library(terminator)


WorldData <- map_data('world') %>% fortify()

terminator_line <- terminator(as.integer((as.POSIXct(Sys.Date()) + (60*60*(7)))), -180, 180, 0.1)

arbitrary_day <- median(terminator_line$lat)+15

locator_map <- ggplot() +
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
  #solar noon line (indicates longitude)
  geom_segment(mapping = aes(x = terminator_line$lon[which.max(terminator_line$lat)], 
               xend = terminator_line$lon[which.max(terminator_line$lat)],
               y = min(terminator_line$lat),
               yend = max(terminator_line$lat)),
               arrow = arrow (ends = "both"),
               linewidth = 3) +
  # daylength (indicates latitude)
   geom_segment(mapping = aes(y = arbitrary_day,   #arbirary chosen line
                    yend = arbitrary_day,#same
                    x = max(terminator_line$lon[terminator_line$lat>arbitrary_day]),
                xend = min(terminator_line$lon[terminator_line$lat>arbitrary_day])),
                arrow = arrow (ends = "both"),
                linewidth = 2)+
  # lines to connect light_plot to locator_plot
  geom_segment(mapping = aes(y = arbitrary_day,   #arbirary chosen line
                             yend = min(terminator_line$lat)-50,            # base of plot
                             x = max(terminator_line$lon[terminator_line$lat>arbitrary_day]),
                             xend = max(terminator_line$lon[terminator_line$lat>arbitrary_day])),
               color = "gray",
               linewidth = 0.6,
               arrow = arrow(ends = "last"))+
  geom_segment(mapping = aes(y = arbitrary_day,   #arbirary chosen line
                             yend = min(terminator_line$lat)-50,            # base of plot
                             x = min(terminator_line$lon[terminator_line$lat>arbitrary_day]),
                             xend = min(terminator_line$lon[terminator_line$lat>arbitrary_day])),
               color = "gray",
               linewidth = 0.6,
               arrow = arrow(ends = "last"))
locator_map


#Create data frame with 24 rows to scale to latitude/daylength (x)
sun_df <- data.frame("Time24hr" = seq(0:23),
                     "Light" = 1,
                     "scaled_longitude" = seq(from= -180, to = 180, length.out = 24))

# Show light for daylight
sun_df$Light[sun_df$scaled_longitude >= min(terminator_line$lon[terminator_line$lat>arbitrary_day])&
               sun_df$scaled_longitude <= max(terminator_line$lon[terminator_line$lat>arbitrary_day])] <- 5

# Add in noisy points for demo in rows 5, 15, 18, and 20 
sun_df$Light[c(5)] <- 1.5
sun_df$Light[c(13)] <- 2
sun_df$Light[c(15, 20)] <- 4.9
sun_df$Light[18] <- 4.75


# create light plot (lower panel)
light_plot <- ggplot(data = sun_df,
                     mapping = aes(x = scaled_longitude,
                                   y = Light))+
  geom_line()+
  
  scale_x_continuous(limits=c(-180, 180)) +

  
  theme(
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        #panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())+  theme(axis.line = element_line())

light_plot

library(ggpubr)

ggarrange(locator_map,
          light_plot,
          ncol = 1,
          nrow = 2,
          align = "v")

library(cowplot)

plot_grid(locator_map,
light_plot,
nrow = 2,
align = "v")

library(gridExtra)

g<- arrangeGrob(locator_map,
            light_plot,
            ncol = 1)

grid::grid.newpage() ; grid::grid.draw(g)
