source("R/00_setup.R")
boundary_path <- "data/barcelona_boundary.gpkg"
if (!file.exists(boundary_path)) stop("Run R/01_get_boundary.R first")
boundary <- sf::st_read(boundary_path, quiet = TRUE)
# Extract historical OSM ways; bbox limits source download, polygon clips output.
tags <- c(
  "highway",
  "lanes", "lanes:forward", "lanes:backward",
  "maxspeed", "oneway",
  "access", "motor_vehicle", "vehicle",
  "junction", "name", "surface",
  "width", "sidewalk", "lit",
  "cycleway", "cycleway:left",
  "cycleway:right", "cycleway:both"
)
lines <- osmextract::oe_get(
  place = region, layer = "lines", version = snapshot,
  boundary = sf::st_bbox(boundary), boundary_type = "clipsrc",
  extra_tags = tags, force_vectortranslate = TRUE, quiet = FALSE
)
if (!"highway" %in% names(lines)) stop("highway tag missing")
roads <- lines |>
  dplyr::filter(!is.na(.data$highway), .data$highway != "") |>
  sf::st_transform(crs_metric)
b <- sf::st_transform(sf::st_make_valid(boundary), crs_metric)
roads <- suppressWarnings(sf::st_intersection(roads, sf::st_geometry(b)))
roads <- roads[!sf::st_is_empty(roads), , drop = FALSE]
roads <- suppressWarnings(sf::st_collection_extract(roads, "LINESTRING"))
roads$length_m <- as.numeric(sf::st_length(roads))
roads <- roads[roads$length_m > 0, , drop = FALSE]
roads$snapshot <- "2017-01-01"
out <- "data/barcelona_osm_roads_170101.gpkg"
if (file.exists(out)) file.remove(out)
sf::st_write(roads, out, layer = "roads", quiet = TRUE)
message("Saved ", nrow(roads), " road/path features to ", out)
