
source("libraries.R")
source("utils.R")

# datasets <- c("normallandschaft")

# names(datasets) <- datasets

# dataset_list <- read_csv("appdata/infoflora.csv")

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
      fitBounds(5.955902, 45.81796, 10.49206, 47.80845)

  })
  geodata_i <- reactive({
    geodata[[input$aggregation]]
  })



  observe({
    
    # browser()
    geodata_i <- geodata_i()
    
    leafletProxy("map") |> 
      clearShapes() |> 
      clearControls() |> 
      clearMarkers()
    
    
    
    if(input$aggregation == "punkte"){
      
      if(input$column_y == "n"){
        
        leafletProxy("map", data = geodata_i) |> 
          addCircleMarkers(
            fillColor = "darkgreen",
            radius = 3,
            weight = 1,
            color = "black",
            fillOpacity = .6, 
            opacity = .8) 
        
      } else{
        
        ycol <- geodata_i[[input$column_y]]
        
        qu <- quantile(ycol, probs = c(0.025, 0.975), na.rm = TRUE)
        
        ycol <- ifelse(ycol > qu[2], qu[2], ycol)
        ycol <- ifelse(ycol < qu[1], qu[1], ycol)
        
        pal <- colorNumeric(palette = "RdYlBu",domain = ycol,na.color = "#80808000")
        
        column_y <- names(col_y_options[col_y_options == input$column_y])
        
        leafletProxy("map", data = geodata_i) |>
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
        
        
        # browser()
        pal <- colorNumeric("viridis", range(geodata_i$n, na.rm = TRUE),na.color = "#80808000")
        
        
        # browser()
        geodata_i$label <- paste(
          paste("Anzahl Erhebungen", geodata_i$n, sep = ":")
        )
        
        leafletProxy("map", data = geodata_i) |>
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
        
        # browser()
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
        
        
        mypal <- c("#91BFDB", "#FFFFBF", "#FC8D59")
        
        bivariate_matrix <- bivariate_matrix_alpha(mypal, n_classes, alpha_range = c(.40, 0.95))
        
        column_y <- names(col_y_options[col_y_options == input$column_y])
      
        legend_html <- create_legend(bivariate_matrix,column_y)
        
        pal_col <- as.vector(bivariate_matrix)
        pal <- colorFactor(pal_col, levels = fac_levels, alpha = TRUE,na.color = "#80808000")
        
        leafletProxy("map", data = geodata_i) |>
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
    
      leafletProxy("map", data = geodata_i[selvec, ]) |>
        clearGroup("polygonselection") |>
        addPolygons(
          fillOpacity = 0, 
          group = "polygonselection", 
          color = mycols$selected_polygon$hex, 
          fill = FALSE,
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







  selected_object <- reactiveVal("")





  grassland_inbounds_renamed <- reactive({
    grassland_inbounds <- grassland_inbounds() |>
      rename(column_y = input$column_y)


    return(grassland_inbounds)
  })


})
