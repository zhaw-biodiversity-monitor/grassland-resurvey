
source("libraries.R")
source("utils.R")

gpkg_path <- "appdata/vectors_infoflora.gpkg"
# layers <- read_sf(gpkg_path, "layers_overview")

layers <- st_layers(gpkg_path)$name



aggregation1 <- aggregation1 <- c(
  "Hexagone (10x10km)" = "hex10",
  "Hexagone (20x20km)" = "hex20",
  "Biogeografische Regionen" = "bgr",
  "Kantone"="kantone",
  "keine Aggregation" = "punkte"
  )

# aggregation1 <- aggregation1[aggregation1 != "layers"]

# aggregation1 <- c("hex10","hex20","BGR","kantone")
datasets <- c("normallandschaft") # ,"tww","moore"





col_y_options <- c(
  "Species Richness" = "species_richness",
  "Relative Species Richness" = "relative_species_richness",
  "Datenpunkte" = "n"
)

# sfobs <- st_read(gpkg_path, layers[1])
# stopifnot(all((col_y_options) %in% colnames(sfobs)))



# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$script(src = "myjs.js"),
  # Application title
  titlePanel("Vegetationsdatenbank der Schweiz"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      # sliderInput("hoehenstufe", "Höhenstufe:", min = 0, max = 3000, value = c(0,3000)),
      # selectInput("datensatz", "Datensatz", datasets),
      
      
      selectInput(
        "aggregation",
        "Aggregation",
        aggregation1
      ),
      selectInput(
        "column_y",
        "Variable",
        col_y_options
      ),

      # plotlyOutput("scatterplot"), # removed plot, since it does not make sense in the current state (https://github.com/zhaw-biodiversity-monitor/zhaw-biodiversity-monitor.github.io/issues/10)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
            leaflet::leafletOutput("map", height = 600)

      # tabsetPanel(
      # type = "tabs",
      # tabPanel("Map", leaflet::leafletOutput("map", height = 600)),
      # tabPanel("Legend", plotOutput("legend"))
      
    # )
    )
  )
))
