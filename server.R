
source("libraries.R")
source("utils.R")

datasets <- c("normallandschaft")

names(datasets) <- datasets

dataset_list <- read_csv("appdata/infoflora.csv")

mycols <- list(
  drawing = list(
    rgba_string = "rgba(0, 51, 255, 1)",
    hex = "#0033FF"
  ),
  selected_polygon = list(
    rgba_string = "rgba(255, 48, 0, 1)",
    hex = "#ff3000"
  )
)

gpkg_path <- "appdata/vectors_infoflora.gpkg"
geodata <- read_all_layers(gpkg_path, "layers_overview")

shinyServer(function(input, output) {
  output$map <- renderLeaflet({
    leaflet() |>
      addTiles(
        "https://wmts20.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-grau/default/current/3857/{z}/{x}/{y}.jpeg",
        group = "Pixelkarte grau"
      ) |>
      addTiles(
        "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.swissimage/default/current/3857/{z}/{x}/{y}.jpeg",
        group = "Swissimage"
      ) |>
      addTiles(
        "https://wmts20.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg",
        group = "Pixelkarte farbig"
      ) |>
      addLayersControl(baseGroups = c("Pixelkarte grau", "Pixelkarte farbig", "Swissimage")) |>
      fitBounds(5.955902, 45.81796, 10.49206, 47.80845) #|>
      # set singleFeature = TRUE to only disaable multi-feature drawing
      # addDrawToolbar(
      #   polylineOptions = FALSE,
      #   polygonOptions = FALSE,
      #   circleOptions = FALSE,
      #   markerOptions = FALSE,
      #   circleMarkerOptions = FALSE,
      #   singleFeature = TRUE,  # turn this back on if we want to be able to draw polygons
      #   rectangleOptions = drawRectangleOptions(
      #     shapeOptions = drawShapeOptions(
      #       color = as.character(mycols$drawing$hex),
      #       fill = FALSE,
      #       weight = 2
      #     )
      #   ),
      #   editOptions = editToolbarOptions()
      # )
  })
  geodata_i <- reactive({
    # select_dataset(geodata, input$aggregation, input$datensatz)
    geodata[[input$aggregation]]
  })

  dataset_i <- reactive({
    dataset_list
  })

  observe({
    
    # browser()
    geodata_i <- geodata_i()
    
    
    
    if(input$aggregation == "punkte"){
      
      if(input$column_y == "n"){
        
        leafletProxy("map", data = geodata_i) |>
          clearShapes() |>
          clearControls() |>
          addCircleMarkers(
            fillColor = "black",
            radius = 2,
            color = "black", 
            fillOpacity = 1, 
            opacity = 1) 
        
      } else{
        
        ycol <- geodata_i[[input$column_y]]
        
        # NA's are possible (for now!)
        ycol <- ycol[!is.na(ycol)]
        
        qu <- quantile(ycol, probs = c(0.025, 0.975))
        
        ycol <- ifelse(ycol > qu[2], qu[2], ycol)
        ycol <- ifelse(ycol < qu[1], qu[1], ycol)
        
        pal <- colorNumeric(palette = "RdYlBu",domain = ycol)
        
        
        # browser()
        
        column_y <- names(col_y_options[col_y_options == input$column_y])
        
        leafletProxy("map", data = geodata_i) |>
          clearShapes() |>
          clearControls() |>
          addCircleMarkers(
            fillColor = ~pal(ycol),
            radius = 2,
            color = ~pal(ycol), 
            fillOpacity = 1, opacity = 1) |> 
          addLegend("bottomleft", pal = pal, values = ycol,
                    title = column_y,
                    opacity = 1
          )
      }
      
      
      
    } else{
      
      if(input$column_y == "n"){
        
        
        
        pal <- colorNumeric("viridis", range(geodata_i$n))
        
        
        # browser()
        geodata_i$label <- paste(
          paste("Anzahl Erhebungen", geodata_i$n, sep = ":")
        )
        
        leafletProxy("map", data = geodata_i) |>
          clearShapes() |>
          clearControls() |>
          addPolygons(
            fillColor = ~ pal(n),
            color = ~ pal(n),
            fillOpacity = 1,
            opacity = 0,
            label = ~ lapply(label, htmltools::HTML)
          ) |> 
          addLegend("bottomleft", pal = pal, values = ~n,
                    title = "Anzahl Beobachtungen",
                    labFormat = labelFormat(big.mark = "'"),
                    opacity = 1
          )
        
      } else{
        
        ycol <- geodata_i[[input$column_y]]
        
        n_obs <- geodata_i[["n"]]
        
        
        
        column_y <- names(col_y_options[col_y_options == input$column_y])
        
       
        
        geodata_i$label <- paste(
          paste(column_y, round(ycol, 2), sep = ":"),
          paste("Anzahl Erhebungen", n_obs, sep = ":"),
          sep = "<br>"
        )
        
        n_classes <- 3
        # anticipate all *possible* factor levels
        fac_levels <- expand_grid(seq_len(n_classes), seq_len(n_classes)) |>
          apply(1, paste, collapse = "-")
        
        n_obs_interval <- classIntervals(n_obs, n_classes, "jenks")
        ycol_interval <- classIntervals(ycol, n_classes, "jenks")
        
        
        n_obs_grp <- findCols(n_obs_interval)
        ycol_grp <- findCols(ycol_interval)
        
        geodata_i$grp <- factor(paste(n_obs_grp, ycol_grp, sep = "-"), levels = fac_levels)
        
        
        # mypal <- rev(RColorBrewer::brewer.pal(n_classes, "RdYlBu"))
        mypal <- c("#91BFDB", "#FFFFBF", "#FC8D59")
        
        bivariate_matrix <- bivariate_matrix_alpha(mypal, n_classes, alpha_range = c(.40, 0.95))
        
        
        column_y <- names(col_y_options[col_y_options == input$column_y])
        
        
        legend_html <- create_legend(bivariate_matrix,column_y)
        
        pal_col <- as.vector(bivariate_matrix)
        pal <- colorFactor(pal_col, levels = fac_levels, alpha = TRUE)
        
        leafletProxy("map", data = geodata_i) |>
          clearShapes() |>
          clearControls() |>
          addControl(legend_html, position = "bottomleft", className = "") |>
          addPolygons(
            fillColor = ~ pal(grp),
            color = ~ pal(grp),
            fillOpacity = 1,
            opacity = 0,
            label = ~ lapply(label, htmltools::HTML)
          ) 
      }
      
       
    }
    
    
  })

  observe({
    
    
    geodata_i <- geodata_i()
    
    if(input$aggregation == "punkte"){
      # print("wow")
    } else{
    
      selvec <- as.vector(geodata_i[, input$aggregation, drop = TRUE]) == selected_object()
      
      
      # browser()
      leafletProxy("map", data = geodata_i[selvec, ]) |>
        clearGroup("polygonselection") |>
        addPolygons(
          fillOpacity = 0, 
          group = "polygonselection", 
          color = mycols$selected_polygon$hex, 
          fill = FALSE,
          # label = n
          )  
    }
    
  })





  ranges <- reactive({
    all_features <- input$map_draw_all_features
    features <- all_features$features
    coords <- map(features, \(x)x$geometry$coordinates[[1]])
    # print(coords)
    map(coords, \(x) {
      x |>
        map(\(y)c(y[[1]], y[[2]])) |>
        do.call(rbind, args = _) |>
        apply(2, range)
    })
  })

  grassland_inbounds <- reactive({
    if (length(ranges()) > 0) {
      ranges <- ranges()[[1]]
      lat <- ranges[, 2]
      lng <- ranges[, 1]
      dataset_i() |>
        filter(
          lange > min(lng),
          lange < max(lng),
          breite > min(lat),
          breite < max(lat)
        )
    } else {
      dataset_i()[FALSE, ]
    }
  })




  # observeEvent(input$map_shape_click,{browser()})

  # Makes sure that this object exists even before the first clicking event
  selected_object <- reactiveVal("")
  # Reactivate the next lines if clicking on a shape should highlight points in the plot 
  # observeEvent(input$map_shape_click, {
  #   loc_list <- input$map_shape_click
  #   loc_list <- input$map_shape_click
  #   geodata_i <-
  #     select_dataset(geodata, input$aggregation, input$datensatz)
  #   loc <- st_point(c(loc_list$lng, loc_list$lat)) |>
  #     st_sfc(crs = 4326)
  # 
  #   selected_object_str <-
  #     as.vector(geodata_i[loc, input$aggregation, drop = TRUE])
  #   selected_object(selected_object_str) # sets the value of this reactiveValue
  # })


  grassland_renamed <- reactive({
    dataset_i() |>
      rename(column_y = input$column_y) #|>
      # rename(agg = input$aggregation)
  })

  grassland_inbounds_renamed <- reactive({
    grassland_inbounds <- grassland_inbounds() |>
      rename(column_y = input$column_y)
    # grassland_inbounds <-
      # grassland_inbounds |> rename(agg = input$aggregation)

    return(grassland_inbounds)
  })


  # Removed plot for now, since it does not make sense in the current state:
  # https://github.com/zhaw-biodiversity-monitor/zhaw-biodiversity-monitor.github.io/issues/10
  # output$scatterplot <- renderPlotly({
  #   fig <-
  #     plot_ly(
  #       grassland_renamed(),
  #       x = ~jahr,
  #       y = ~column_y,
  #       type = "scatter",
  #       mode = "markers",
  #       marker = list(color = "rgba(255, 182, 193, 1)"),
  #       name = "all"
  #     ) |>
  #     add_trace(
  #       data = grassland_inbounds_renamed(),
  #       color = "",
  #       marker = list(
  #         color = "rgba(255,255,255,0)",
  #         line = list(color = mycols$drawing$rgba_string, width = 2)
  #       ),
  #       name = "in bounds"
  #     )
  #   if (selected_object() != "") {
  #     grassland_inpolygon <- grassland_renamed()[grassland_renamed()$agg == selected_object(), ]
  # 
  #     fig <-
  #       fig |>
  #       add_trace(
  #         data = grassland_inpolygon,
  #         color = "",
  #         marker = list(
  #           color = "rgba(255,255,255,0)",
  #           line = list(color = mycols$selected_polygon$rgba_string, width = 2)
  #         ),
  #         name = "in polygon"
  #       )
  #   }
  # 
  #   fig |>
  #     layout(
  #       hovermode = FALSE,
  #       clickmode = "none",
  #       # yaxis = list(title = paste0(clean_names(input$column_y), add_unit(input$column_y))),
  #       yaxis = list(title = paste0(clean_names(input$column_y))),
  #       xaxis = list(title = "Erhebungszeitpunkt"),
  #       modebar = list(
  #         remove = c(
  #           "autoScale2d",
  #           "autoscale",
  #           "editInChartStudio",
  #           "editinchartstudio",
  #           "hoverCompareCartesian",
  #           "hovercompare",
  #           "lasso",
  #           "lasso2d",
  #           "orbitRotation",
  #           "orbitrotation",
  #           "pan",
  #           "pan2d",
  #           "pan3d",
  #           "reset",
  #           "resetCameraDefault3d",
  #           "resetCameraLastSave3d",
  #           "resetGeo",
  #           "resetSankeyGroup",
  #           "resetScale2d",
  #           "resetViewMapbox",
  #           "resetViews",
  #           "resetcameradefault",
  #           "resetcameralastsave",
  #           "resetsankeygroup",
  #           "resetscale",
  #           "resetview",
  #           "resetviews",
  #           "select",
  #           "select2d",
  #           "sendDataToCloud",
  #           "senddatatocloud",
  #           "tableRotation",
  #           "tablerotation",
  #           "toImage",
  #           "toggleHover",
  #           "toggleSpikelines",
  #           "togglehover",
  #           "togglespikelines",
  #           "toimage",
  #           "zoom",
  #           "zoom2d",
  #           "zoom3d",
  #           "zoomIn2d",
  #           "zoomInGeo",
  #           "zoomInMapbox",
  #           "zoomOut2d",
  #           "zoomOutGeo",
  #           "zoomOutMapbox",
  #           "zoomin",
  #           "zoomout",
  #           "displaylogo"
  #         )
  #       )
  #     )
  # })
  # 
  
  
})
