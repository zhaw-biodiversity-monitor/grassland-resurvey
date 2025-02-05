
source("libraries.R")
source("utils.R")

gpkg_path <- "appdata/vectors_infoflora.gpkg"
# layers <- read_sf(gpkg_path, "layers_overview")

layers <- st_layers(gpkg_path)$name



aggregation1 <- aggregation1 <- c(
  "Hexagone (5x5km)" = "hex5",
  "Hexagone (10x10km)" = "hex10",
  "Hexagone (20x20km)" = "hex20",
  "Biogeografische Regionen" = "bgr",
  "Kantone"="kantone",
  "keine Aggregation" = "punkte"
  )

# aggregation1 <- aggregation1[aggregation1 != "layers"]

# aggregation1 <- c("hex10","hex20","BGR","kantone")
# datasets <- c("normallandschaft") # ,"tww","moore"








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
      shiny::p("
               «Relativer Artenreichtum» macht die Artenzahlen von unterschiedlich grossen Aufnahmeflächen vergleichbar. Dafür wurde eine mittlere Artenzahl-Areal-Funktion für alle Vegetationsaufnahmen in der Datenbank im doppellogarithmischen Raum gerechnet (entsprechend einer Potenzfunktion). Dargestellt sind die Abweichungen vom erwarteten Wert auf einer log10-Skala. Mithin bedeutet ein Wert von +0.3, dass die Artenzahl doppelt so hoch ist wie für die Flächengrösse zu erwarten, bei -0.3 dagegen ist der Wert nur halb so hoch wie erwartet.
               ")
      
      

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
