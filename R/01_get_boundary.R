source("R/00_setup.R")
path <- "data/barcelona_boundary.gpkg"
if (!file.exists(path)) {
  # OSM boundary is obtained now, not historically reconstructed.
  bb <- osmdata::getbb(place, format_out = "polygon")
  q <- osmdata::opq(bbox = bb) |>
    osmdata::add_osm_feature(key = "boundary", value = "administrative") |>
    osmdata::add_osm_feature(key = "admin_level", value = "8")
  mp <- osmdata::osmdata_sf(q)$osm_multipolygons
  if (is.null(mp) || !nrow(mp)) stop("No administrative boundary returned")
  matches <- !is.na(mp$name) & tolower(mp$name) == "barcelona"
  if (sum(matches) != 1L) stop("Expected one Barcelona municipality; found ", sum(matches))
  boundary <- mp[matches, , drop = FALSE] |>
    sf::st_make_valid() |>
    sf::st_transform(4326)
  sf::st_write(boundary, path, layer = "boundary", quiet = TRUE)
}
message("Boundary: ", path)
