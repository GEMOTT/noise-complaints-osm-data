# Barcelona historical OSM street network

Historical OpenStreetMap (OSM) street-network data for Barcelona, extracted for **1 January 2017**, for research on noise complaints.

## Data and outputs

- `data/` — Barcelona municipal boundary and historical street-network dataset (`barcelona_osm_roads_170101.gpkg`).
- `outputs/` — Descriptive statistics and summary tables.
- `report.qmd` — Interactive maps and an overview of the data.
- `R/` — Scripts to reproduce the extraction and analysis.

The original OSM download is cached externally and does not need to be stored in the repository.

## Reproduce the analysis

From the repository root:

```r
install.packages(c("sf", "osmdata", "osmextract", "dplyr", "readr",
                   "ggplot2", "tidyr", "leaflet", "DT"))

source("R/01_get_boundary.R")
source("R/02_extract_roads.R")
source("R/03_explore_network.R")
```

To generate the interactive HTML report, run `quarto render report.qmd`.

## Notes

The dataset includes all OSM `highway` categories, including pedestrian streets, footways and cycleways, alongside available road attributes such as lanes, speed limits and access restrictions.

**Limitations:** Missing OSM attributes do not necessarily indicate absence. The municipal boundary comes from current OSM, while the street network uses the historical snapshot. Data accuracy has not been independently validated.

© OpenStreetMap contributors (ODbL).