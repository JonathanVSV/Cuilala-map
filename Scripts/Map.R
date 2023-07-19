# library(shiny)
library(raster)
library(leaflet)
library(dplyr)
library(sf)
library(RColorBrewer)
library(htmlwidgets)

# Load the raster and vector data
# raster_data <- raster("path/to/raster/file")
sitios <- st_read("Data/SitiosPtsAll.gpkg") |>
  st_transform(4326)
barrancas <- st_read("Data/BarrancasAll.gpkg") |>
  st_transform(4326)
DEM <- raster("Data/DEM.tif")

mypal <- gray(seq(0,1,length.out = 10))

myIcons <- icons(
  iconUrl = case_when(sitios$Geositio == "Localidad" ~ "imgs/house.png",
                      sitios$Geositio == "Templo" ~ "imgs/iglesia.png",
                      sitios$Geositio == "Arbol" ~ "imgs/tree.png",
                      sitios$Geositio == "Cerro" ~ "imgs/peak.png",
                      sitios$Geositio == "Paraje" ~ "imgs/walker.png",
                      sitios$Geositio == "Ranchería" ~ "imgs/hostel.png",
                      sitios$Geositio == "Crucero" ~ "imgs/crossroad.png",
                      TRUE ~ "imgs/circle.png"),
  iconWidth = 15, 
  iconHeight = 15,
  iconAnchorX = 7,
  iconAnchorY = 7,
  className = "Sitios"
  # shadowWidth = 50, shadowHeight = 64,
  # shadowAnchorX = 4, shadowAnchorY = 62
)

html_legend <- '<img src="imgs/house.png" height="15" width="15">Localidad<br>
                <img src="imgs/iglesia.png" height="15" width="15">Templo<br>
                <img src="imgs/tree.png" height="15" width="15">Árbol<br>
                <img src="imgs/peak.png" height="15" width="15">Cerro<br>
                <img src="imgs/walker.png" height="15" width="15">Paraje<br>
                <img src="imgs/hostel.png" height="15" width="15">Ranchería<br>
                <img src="imgs/crossroad.png" height="15" width="15">Crucero<br>
                <img src="imgs/circle.png" height="15" width="15">Otro<br>'

    # Create the leaflet map
map <-  leaflet(data = sitios) %>%
      #addTiles(group = 'Esri.WorldImagery') %>%
      addProviderTiles('Esri.WorldImagery') %>% 
      # Add the vector layer
      # addCircleMarkers(data = sitios,
      addMarkers(data = sitios,
                 # color = ~pal(Geositio),
                 popup = ~Nombre,
                 group = "Sitios",
                 # radius = 5,
                 icon = myIcons,
                 # fillColor = "blue"#,
                 # iconColor = "white"#,
                 #weight = 1,
                 #opacity = 1,
                 #fillOpacity = 0.7
      ) %>%
      # Add the raster layer
      addRasterImage(x = DEM,
                     colors = mypal,
                     method = "ngb",
                     group = "MDE",
                     opacity = 70) %>%
      # Add polylines layer
      addPolylines(data = barrancas,
                   color = "royalblue",
                   group = "Barrancas",
                   popup = ~Nombre
      ) %>%
      addLayersControl(
        # overlayGroups = c("Sitios"),
        baseGroups = c("ESRI Imagery"),
        overlayGroups = c("Sitios", "Barrancas", "MDE"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      addControl(
        html = html_legend,
        # layerID = "Sitios",
        position = "bottomleft"
      ) |>
      addScaleBar(position = "bottomright",
                  options = scaleBarOptions(
                    maxWidth = 100,
                    metric = TRUE,
                    imperial = FALSE,
                    updateWhenIdle = TRUE
                  ))
    # addLegend(
    #   pal = pal,
    #   values = ~Geositio,
    #   position = "bottomleft"
    # # #   opacity = 0.7,
    # # #   title = NULL
    # )      addLegend(
    # pal = pal,
    # values = ~Geositio,
    # position = "bottomleft"
    # #   opacity = 0.7,
    # #   title = NULL
    # )
    # Add labels if checkbox is checked
    # if (input$show_labels) {
    #   addPolygons(data = sitios[[input$vector_layer]], label = ~name)
    # }


saveWidget(map, file="index.html")