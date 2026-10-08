# Barcelona historical OSM road-network data

Exploratory, reproducible R extraction of the Barcelona municipality's OpenStreetMap street network as mapped on **1 January 2017** for research on noise complaints.

## Run

From the repository root:

```r
install.packages(c("sf", "osmdata", "osmextract", "dplyr", "readr"))
source("R/01_get_boundary.R")
source("R/02_extract_roads.R")
```

Output: `outputs/barcelona_osm_roads_170101.gpkg` (GeoPackage).

The extraction preserves original `highway`, lane, speed, one-way and access tags where present. All OSM highway types are retained initially, including footways, pedestrian streets and paths. These **are not all motor-vehicle roads**. Missing lane tags do not imply one lane; OSM road classes do not measure traffic counts.

**Limitations:** The municipal boundary is obtained from current OSM, whereas road attributes are requested from the historical snapshot. OSM data completeness and positional accuracy have not been validated. Inspect output and historical availability before research use.

OpenStreetMap contributors ©; ODbL attribution required. Data products are not committed automatically.
