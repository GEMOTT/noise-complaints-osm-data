# 03_explore_network.R
# Barcelona historical OSM network: quality and descriptive statistics

source("R/00_setup.R")

library(sf)
library(dplyr)
library(readr)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------

roads <- st_read(
  "data/barcelona_osm_roads_170101.gpkg",
  quiet = TRUE
)

stopifnot("highway" %in% names(roads))
stopifnot("osm_id" %in% names(roads))

# ------------------------------------------------------------
# 2. Geometry and identifier checks
# ------------------------------------------------------------

quality_summary <- tibble(
  n_features = nrow(roads),
  n_missing_osm_id = sum(is.na(roads$osm_id)),
  n_duplicated_osm_id = sum(duplicated(roads$osm_id) &
                              !is.na(roads$osm_id)),
  n_empty_geometry = sum(st_is_empty(roads)),
  n_invalid_geometry = sum(!st_is_valid(roads)),
  n_zero_length = sum(roads$length_m <= 0, na.rm = TRUE),
  total_length_km = sum(roads$length_m, na.rm = TRUE) / 1000
)

print(quality_summary)

write_csv(
  quality_summary,
  "outputs/quality_summary.csv"
)

# Note: repeated OSM IDs may be legitimate after clipping or
# splitting geometries. They are flagged, not removed.

# ------------------------------------------------------------
# 3. Total length by highway category
# ------------------------------------------------------------

highway_summary <- roads |>
  st_drop_geometry() |>
  group_by(highway) |>
  summarise(
    n_features = n(),
    length_km = sum(length_m, na.rm = TRUE) / 1000,
    .groups = "drop"
  ) |>
  mutate(
    pct_length = 100 * length_km / sum(length_km)
  ) |>
  arrange(desc(length_km))

print(highway_summary, n = Inf)

write_csv(
  highway_summary,
  "outputs/highway_summary.csv"
)

# ------------------------------------------------------------
# 4. Attribute completeness by highway category
# ------------------------------------------------------------

attributes <- c(
  "lanes",
  "maxspeed",
  "oneway",
  "width",
  "sidewalk",
  "lit",
  "cycleway",
  "cycleway_left",
  "cycleway_right",
  "cycleway_both",
  "surface",
  "access",
  "motor_vehicle"
)

attributes <- intersect(attributes, names(roads))

completeness <- bind_rows(
  lapply(attributes, function(attribute) {
    
    roads |>
      st_drop_geometry() |>
      group_by(highway) |>
      summarise(
        n_features = n(),
        n_available = sum(
          !is.na(.data[[attribute]]) &
            trimws(as.character(.data[[attribute]])) != ""
        ),
        total_length_km = sum(length_m, na.rm = TRUE) / 1000,
        available_length_km = sum(
          length_m[
            !is.na(.data[[attribute]]) &
              trimws(as.character(.data[[attribute]])) != ""
          ],
          na.rm = TRUE
        ) / 1000,
        .groups = "drop"
      ) |>
      mutate(
        attribute = attribute,
        pct_features = round(
          100 * n_available / n_features, 1
        ),
        pct_length = round(
          100 * available_length_km / total_length_km, 1
        )
      )
  })
) |>
  select(
    highway, attribute,
    n_features, n_available, pct_features,
    total_length_km, available_length_km, pct_length
  ) |>
  arrange(highway, attribute)

write_csv(
  completeness,
  "outputs/attribute_completeness_by_highway.csv"
)

# ------------------------------------------------------------
# 5. Overall attribute completeness
# ------------------------------------------------------------

overall_completeness <- completeness |>
  group_by(attribute) |>
  summarise(
    n_features = sum(n_features),
    n_available = sum(n_available),
    total_length_km = sum(total_length_km),
    available_length_km = sum(available_length_km),
    .groups = "drop"
  ) |>
  mutate(
    pct_features = round(
      100 * n_available / n_features, 1
    ),
    pct_length = round(
      100 * available_length_km / total_length_km, 1
    )
  ) |>
  arrange(desc(pct_features))

print(overall_completeness, n = Inf)

write_csv(
  overall_completeness,
  "outputs/attribute_completeness_overall.csv"
)

# ------------------------------------------------------------
# 6. Distribution of recorded lane counts and speed limits
# ------------------------------------------------------------

for (attribute in c("lanes", "maxspeed")) {
  
  distribution <- roads |>
    st_drop_geometry() |>
    filter(
      !is.na(.data[[attribute]]),
      trimws(as.character(.data[[attribute]])) != ""
    ) |>
    count(
      highway,
      value = .data[[attribute]],
      name = "n_features",
      sort = TRUE
    )
  
  write_csv(
    distribution,
    paste0("outputs/", attribute, "_distribution.csv")
  )
}

message("Exploratory analysis completed. CSV tables saved to outputs/")
