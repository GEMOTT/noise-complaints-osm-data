# Barcelona historical OSM road network — configuration
snapshot <- "170101"  # OSM state at 2017-01-01 (UTC)
region <- "Spain"
place <- "Barcelona, Spain"
crs_metric <- 25831
dir.create("data", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs", recursive = TRUE, showWarnings = FALSE)
required <- c("sf", "osmdata", "osmextract", "dplyr", "readr")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install packages: ", paste(missing, collapse = ", "))
