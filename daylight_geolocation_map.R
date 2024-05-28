# devtools::install_github("hrbrmstr/terminator",
#                          dependencies = TRUE,
#                          INSTALL_opts = c("--no-multiarch"))


library(dplyr)
library(ggalt)
library(ggplot2)
library(ggpubr)
library(maps)
library(terminator)

#########
# Data
#########

## Map
WorldData <- map_data('world') %>% fortify()

## Sunlight terminator line
arbitrary_time <- 12
terminator_line <- terminator(as.integer((as.POSIXct(Sys.Date()) + (60*60*(arbitrary_time)))), -180, 180, 0.1)

arbitrary_day <- median(terminator_line$lat)+15

## second panel data for light intensity 
#Create data frame with 24 rows to scale to latitude/daylength (x)
sun_df <- data.frame("Time24hr" = seq(0:239),
                     "Light" = -90,
                     "scaled_longitude" = seq(from= min(terminator_line$lon),
                                              to = max(terminator_line$lon), 
                                              length.out = 240))

# Show light for daylight
sun_df$Light[sun_df$scaled_longitude >= min(terminator_line$lon[terminator_line$lat>arbitrary_day])&
               sun_df$scaled_longitude <= max(terminator_line$lon[terminator_line$lat>arbitrary_day])] <- 90

# Add in noisy points for demo in rows 50, 100-101, 130, 145, 150
sun_df$Light[c(50)] <- -50
sun_df$Light[c(100:101)] <- -30
sun_df$Light[c(145)] <- 68
sun_df$Light[c(130, 150)] <- 65

sun_df$daylight <- "night"
sun_df$daylight[sun_df$scaled_longitude >= min(terminator_line$lon[terminator_line$lat>arbitrary_day])&
                  sun_df$scaled_longitude <= max(terminator_line$lon[terminator_line$lat>arbitrary_day])] <- "day"

#########
# PLOTS
#########

## top panel (terminator line map and sample geolocator location)
locator_map <- ggplot() +
  geom_map(data = WorldData, map = WorldData,
           aes(group = group, map_id=region),
           fill = "beige", colour = "#7f7f7f", size=0.5)+
  geom_ribbon( 
    data=terminator_line,
    aes(lon, ymin=lat, ymax=90), fill="black", alpha=1.5/2
  ) +
  geom_line( 
    data=terminator_line,
    aes(lon, lat), color = "yellow"
  ) +
  scale_x_continuous(limits=c(-180, 190)) +
  coord_quickmap()+
  theme(axis.line = element_line(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())+
  ggthemes::theme_map() +
  #solar noon line (indicates longitude, vertical line on plot)
  geom_segment(mapping = aes(x = terminator_line$lon[which.max(terminator_line$lat)], 
                             xend = terminator_line$lon[which.max(terminator_line$lat)],
                             y = min(terminator_line$lat),
                             yend = max(terminator_line$lat)),
               arrow = arrow (ends = "both"),
               linewidth = 1) +
# daylength (indicates latitude, horizontal line on plot)
  geom_segment(mapping = aes(y = arbitrary_day,   
                             yend = arbitrary_day,
                             x = max(terminator_line$lon[terminator_line$lat>arbitrary_day]),
                             xend = min(terminator_line$lon[terminator_line$lat>arbitrary_day])),
               arrow = arrow (ends = "both"),
               linewidth = 1)+
  # lines to connect light_plot to locator_plot
  # Then extend these lines in inkscape to touch lower plot twilights,
  # as coded solution too complex for what I want to do right now
  # https://stackoverflow.com/questions/57730069/how-to-add-lines-on-combined-ggplots-from-points-on-one-plot-to-points-on-the-o
  geom_segment(mapping = aes(y = arbitrary_day,    
                             yend = min(terminator_line$lat)-5,            # base of plot
                             x = max(terminator_line$lon[terminator_line$lat>arbitrary_day]),
                             xend = max(terminator_line$lon[terminator_line$lat>arbitrary_day])),
               color = "black",
               linewidth = 0.6,
               arrow = arrow(ends = "last",
                             length = unit(0.25,
                                           "cm")))+
  geom_segment(mapping = aes(y = arbitrary_day,   
                             yend = min(terminator_line$lat)-5,            # base of plot
                             x = min(terminator_line$lon[terminator_line$lat>arbitrary_day]),
                             xend = min(terminator_line$lon[terminator_line$lat>arbitrary_day])),
               color = "black",
               linewidth = 0.6,
               arrow = arrow(ends = "last",
                             length = unit(0.25,
                                           "cm"))) +
    # label for solar noon line
    annotate("label", 
             x = sun_df$scaled_longitude[sun_df$Time24hr==115],
             y = max(terminator_line$lat), 
             label = "Solar noon (longitude)",
             fill = "gray",
             hjust = 1,
             size = 2) +
    # label for daylength line
    annotate("label",
             x = 0,
             y = 0, 
             label = "Daylength (latitude)",
             fill = "gray",
             hjust = 0.5,
             size = 2)
locator_map


## create light plot (lower panel) showing light intensity in relation to geolocator location
light_plot <- ggplot(data = sun_df,
                     mapping = aes(x = scaled_longitude,
                                   y = Light))+
  geom_line()+
  scale_x_continuous(limits=c(-180, 190)) +
  coord_quickmap()+ #needed to get horizontal axes to align in ggarrange plot
  theme(axis.line = element_line(),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks=element_blank(),
    legend.position="none",
    panel.background=element_blank(),
    panel.grid.minor=element_blank(),
    plot.background=element_blank())+ 
  labs(x = "Time (24 hrs)",
       y = "Light intensity")+
  geom_tile(mapping = aes(x = scaled_longitude,
                          y = 0,
                          height = 180,
                          fill = daylight),
            alpha = 0.5)+
  scale_fill_manual(values = c("yellow", "black"))+
  # label and point for example low light intensity during presumed daylight
  # annotate("label",
  #          x = sun_df$scaled_longitude[sun_df$Time24hr==130],
  #          y = min(sun_df[sun_df$daylight=="day","Light"])-0.5, 
  #          label = "Deviation example: Potential shading",
  #          color = "black",
  #          size = 2)+
  geom_point(
    x = sun_df$scaled_longitude[101],
    y = sun_df$Light[101],
    color = "red",
    size = 2)+
# label and point for high light intensity during presumed night
# annotate("label",
#          x = sun_df$scaled_longitude[sun_df$Time24hr==50],
#          y = max(sun_df[sun_df$daylight=="night","Light"], na.rm = TRUE)+0.5, 
#          label = "Deviation example: Potential artifical light",
#          color = "black",
#          size = 2,
#         hjust = 1)+
  geom_point(
    x = sun_df$scaled_longitude[50],
    y = sun_df$Light[50],
    color = "red",
    size = 2)#+
  # # label for calculated twilights (sunrise)
  # annotate("text",
  #          x = sun_df$scaled_longitude[sun_df$Time24hr==70],
  #          y = 0, 
  #          label = "Calculated twilight (sunrise)",
  #          angle = 90)+
  # 
  # # label for calculated twilights (sunset)
  # annotate("text",
  #          x = sun_df$scaled_longitude[sun_df$Time24hr==180],
  #          y = 0, 
  #          label = "Calculated twilight (sunset)",
  #          angle = 90)


light_plot


# Combine both plots into final Figure 1 for manuscript.

ggarrange(locator_map,
          light_plot,
          ncol = 1,
          nrow = 2,
          align = "hv"
          )

ggsave("Figure1.svg",
       height = 4,
       width = 4,
       units = c("in"))

# After saving, open in inkscape
# and move the lower figure up closer to top figure.
# Then pull the arrows from the map 
# to touch the top of the lower panel light intensity.
# Save as "Figure1-polished_arrangement.svg".