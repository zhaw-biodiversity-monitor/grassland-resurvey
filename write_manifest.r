

appfiles <- c(
    c("ui.R","server.R","utils.R"),
    list.files("appdata", full.names = TRUE)
)

rsconnect::writeManifest(appDir = getwd(), appfiles)
