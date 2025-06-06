source("libraries.R")
source("config.R")
source("utils.R")

gpkg_path <- "appdata/vectors_resurvey.gpkg"
# layers <- read_sf(gpkg_path, "layers_overview")

layers <- st_layers(gpkg_path)$name






aggregation1 <- aggregation1 <- c(
  "keine Aggregation" = "punkte",
  "Hexagone (10x10km)" = "hex10",
  "Hexagone (20x20km)" = "hex20",
  "Biogeografische Regionen" = "bgr",
  "Kantone"="kantone"
  )

# aggregation1 <- aggregation1[aggregation1 != "layers"]

# aggregation1 <- c("hex10","hex20","BGR","kantone")
# datasets <- c("normallandschaft") # ,"tww","moore"


datasets2 <- c(
  "Charmillot et al (2021)" = 1	,
  "Schindler et al (2022)" = 2	,
  "Kummli et al (2021)" = 3	,
  "Hepenstrick et al (2023)" = 4	,
  "Babbi et al (2023)" = 5	,
  "Dengler et al (2022)" = 6	,
  "Kummli et al (2021)" = 7	,
  "Staubli et al (2021)" = 8	
)

lebensraumgruppen <- c("Grasland","Zwergstrauchheide","Wald")







col_y_options <- c(
"Artenreichtum (absolut)" = "artenzahl",
"Artenreichtum (relativ)" = "relative_artenzahl",
"Shannon-Index" = "shannon_index",
"Shannon-Evenness" = "shannon_evenness",
"Mittleren Temperaturzahl (1–5)" = "temperaturzahl",
"Mittler Kontinentalitätszahl (1–5)" = "kontinentalitatszahl",
"Mittlere Lichtzahl (1–5)" = "lichtzahl",
"Mittlerer Feuchtezahl (1–5)" = "feuchtezahl",
"Mittlerer Reaktionszahl (1–5)" = "reaktionszahl",
"Mittlerer Nährstoffzahl (1–5)" = "nahrstoffzahl",
"Mittlerer Humuszahl (1–5)" = "humuszahl",
"Mittlerer Konkurrenzstrategie (0–3)" = "konkurrenzzahl",
"Mittlerer Ruderalstrategie (0–3)" = "ruderalzahl",
"Mittlerer Stresszahl (0–3)" = "stresszahl",
"Mittlerer Mahdverträglichkeitszahl (1–5)" = "mahdvertraglichkeit"
)

# sfobs <- st_read(gpkg_path, layers[1])
# stopifnot(all((col_y_options) %in% colnames(sfobs)))

# sfobs <- st_read(gpkg_path, layers[1])
# stopifnot(all((col_y_options) %in% colnames(sfobs)))



# Define UI for application
shinyUI(fluidPage(
  tags$script(src = "myjs.js"),
  titlePanel("Zeitreihen von Vegetationsaufnahmen der Schweiz"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "aggregation",
        "Aggregation",
        UI_CONFIG$aggregation_options
      ),
      
      selectInput(
        "column_y",
        "Jährlicher Trend von",
        UI_CONFIG$column_options
      ),
      
      conditionalPanel(
        condition = "input.aggregation == 'punkte'",
        shinyWidgets::pickerInput(
          "dataset",
          "Datenset",
          choices = UI_CONFIG$dataset_options,
          selected = UI_CONFIG$dataset_options,
          options = pickerOptions(actionsBox = TRUE),
          multiple = TRUE
        ),
        
        shinyWidgets::pickerInput(
          "lebensraumgruppen",
          "Lebensraumgruppen",
          choices = UI_CONFIG$habitat_groups,
          selected = UI_CONFIG$habitat_groups,
          multiple = TRUE
        ),

        sliderInput(
          "flaeche",
          "Plotgrösse",
          min = 0,
          max = 500,
          step = 50,
          value = c(0,500)
        ),
        plotly::plotlyOutput("scatterplot")
      ),
      
      
    ),
    
    mainPanel(
      leaflet::leafletOutput("map", height = 600)
    )
  )
))
