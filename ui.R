
source("libraries.R")
source("utils.R")

gpkg_path <- "appdata/vectors_resurvey.gpkg"
# layers <- read_sf(gpkg_path, "layers_overview")

layers <- st_layers(gpkg_path)$name

sfobs <- st_read(gpkg_path, layers[1])


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

stopifnot(all((col_y_options) %in% colnames(sfobs)))



# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$script(src = "myjs.js"),
  # Application title
  titlePanel("Zeitreihen von Vegetationsaufnahmen der Schweiz"),
  
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
        "Jährlicher Trend von",
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
