# Map Configuration
MAP_CONFIG <- list(
  bounds = list(
    west = 5.955902,
    south = 45.81796,
    east = 10.49206,
    north = 47.80845
  ),
  tile_layers = list(
    grau = "https://wmts20.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-grau/default/current/3857/{z}/{x}/{y}.jpeg",
    swissimage = "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.swissimage/default/current/3857/{z}/{x}/{y}.jpeg",
    farbig = "https://wmts20.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg"
  )
)

# Data Configuration
DATA_CONFIG <- list(
  gpkg_path = "appdata/vectors_resurvey.gpkg",
  csv_path = "appdata/resurvey.csv"
)

# UI Configuration
UI_CONFIG <- list(
  aggregation_options = c(
    "keine Aggregation" = "punkte",
    "Hexagone (10x10km)" = "hex10",
    "Hexagone (20x20km)" = "hex20",
    "Biogeografische Regionen" = "bgr",
    "Kantone" = "kantone"
  ),
  
  column_options = c(
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
  ),
  
  dataset_options = c(
    "Charmillot et al (2021)" = 1,
    "Schindler et al (2022)" = 2,
    "Kummli et al (2021)" = 3,
    "Hepenstrick et al (2023)" = 4,
    "Babbi et al (2023)" = 5,
    "Dengler et al (2022)" = 6,
    "Kummli et al (2021)" = 7,
    "Staubli et al (2021)" = 8
  ),
  
  habitat_groups = c("Grasland", "Zwergstrauchheide", "Wald")
)

# Color Configuration
COLOR_CONFIG <- list(
  # drawing = list(
  #   rgba_string = "rgba(0, 51, 255, 1)",
  #   hex = "#0033FF"
  # ),
  # selected_polygon = list(
  #   rgba_string = "rgba(255, 48, 0, 1)",
  #   hex = "#ff3000"
  # ),
  bivariate_palette = c("#91BFDB", "#FFFFBF", "#FC8D59")
) 