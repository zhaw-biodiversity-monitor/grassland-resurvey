# Map Module Functions

#' Initialize the base map
#' @return A leaflet map object
init_map <- function() {
  leaflet() |>
    addTiles(
      MAP_CONFIG$tile_layers$grau,
      group = "Pixelkarte grau"
    ) |>
    addTiles(
      MAP_CONFIG$tile_layers$swissimage,
      group = "Swissimage"
    ) |>
    addTiles(
      MAP_CONFIG$tile_layers$farbig,
      group = "Pixelkarte farbig"
    ) |>
    addLayersControl(baseGroups = c("Pixelkarte grau", "Pixelkarte farbig", "Swissimage")) |>
    fitBounds(
      MAP_CONFIG$bounds$west,
      MAP_CONFIG$bounds$south,
      MAP_CONFIG$bounds$east,
      MAP_CONFIG$bounds$north
    )
}

#' Update map with point data
#' @param map_proxy The leaflet proxy object
#' @param data The data to display
#' @param ycol The column to use for coloring
#' @param column_y The name of the column for the legend
update_map_points <- function(map_proxy, data, ycol, column_y) {
  qu <- quantile(ycol, probs = c(0.025, 0.975))
  ycol <- pmin(pmax(ycol, qu[1]), qu[2])
  
  pal <- colorNumeric(palette = "RdYlBu", domain = ycol)
  
  # Create popup content
  popup_content <- paste0(
    "<strong>Dataset ID:</strong> ", data$dataset_id, "<br>",
    "<strong>Lebensraumgruppe:</strong> ", data$lebensraumgruppe, "<br>"
  )
  
  map_proxy |>
    clearShapes() |>
    clearMarkers() |> 
    clearControls() |>
    # Add main points layer
    addCircleMarkers(
      data = data,
      fillColor = ~pal(ycol),
      radius = 8, 
      color = ~pal(ycol), 
      fillOpacity = 1, 
      opacity = 1,
      popup = popup_content,
      group = "main_points"
    ) |>
    # Add highlight layer (initially invisible)
    addCircleMarkers(
      data = data,
      fillColor = ~pal(ycol),
      radius = 12,
      color = ~pal(ycol),
      fillOpacity = 0,
      opacity = 0,
      group = "highlight_points"
    ) |>
    addLegend(
      "bottomright",
      pal = pal,
      values = ycol,
      title = clean_names(column_y),
      opacity = 1
    )
}

#' Update map with polygon data
#' @param map_proxy The leaflet proxy object
#' @param data The data to display
#' @param ycol The column to use for coloring
#' @param n_obs The number of observations
#' @param column_y The name of the column for the legend
update_map_polygons <- function(map_proxy, data, ycol, n_obs, column_y) {
  n_classes <- 3
  fac_levels <- expand_grid(seq_len(n_classes), seq_len(n_classes)) |>
    apply(1, paste, collapse = "-")
  
  n_obs_interval <- classIntervals(n_obs, n_classes, "jenks")
  ycol_interval <- classIntervals(ycol, n_classes, "jenks")
  
  n_obs_grp <- findCols(n_obs_interval)
  ycol_grp <- findCols(ycol_interval)
  
  data$grp <- factor(paste(n_obs_grp, ycol_grp, sep = "-"), levels = fac_levels)
  
  bivariate_matrix <- bivariate_matrix_alpha(
    COLOR_CONFIG$bivariate_palette,
    n_classes,
    alpha_range = c(.40, 0.95)
  )
  
  legend_html <- create_legend(bivariate_matrix, column_y)
  pal_col <- as.vector(bivariate_matrix)
  pal <- colorFactor(pal_col, levels = fac_levels, alpha = TRUE)
  
  data$label <- paste(
    paste(str_to_title(column_y), round(ycol, 2), sep = ":"),
    paste("Anzahl Erhebungen", n_obs, sep = ":"),
    sep = "<br>"
  )
  
  map_proxy |>
    clearShapes() |>
    clearControls() |>
    addControl(legend_html, position = "bottomleft", className = "") |>
    addPolygons(
      data = data,
      fillColor = ~pal(grp),
      color = ~pal(grp),
      fillOpacity = 1,
      opacity = 0,
      label = ~lapply(label, htmltools::HTML)
    )
} 