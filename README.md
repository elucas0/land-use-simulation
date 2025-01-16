# Urban Growth Simulation - Lyon

Agent-based model simulating urban growth patterns in Lyon using Copernicus Urban Atlas data.

## Data Source

- **Land Use Data**: Urban Atlas 2012 (Copernicus Land Monitoring Service)

## Preprocessed Datasets

`/includes/urban_growth/2012/`
- `Lyon_rasterized_100m_2012.asc` - Rasterized land use (100m resolution)
- `Lyon_rasterized_30m_2012.asc` - Rasterized land use (30m resolution)
- `Lyon_2012_Roads_Rivers_Simplified.shp` - Simplified transportation network

### Land Use Classes

Classes implemented in simulation from the dataset codes:

- `11100`, `11210`, `11220`, `11230`, `11240`: Urban areas of diverse density
- `12100`: Industrial, commercial, public, military and private units
- `14100`, `14200`: Green urban areas
- `21000`, `22000`, `23000`, `24000`, `25000`: Arable lands, permanent crops, pastures, mixed cultivations, orchards
- `31000`, `32000`, `33000`: Forests, herbaceous vegetation, open spaces
- `0`: Empty/Available for development

## Data Preprocessing Steps

1. **Land Use Data**:
   ```
   1. Download Urban Atlas 2012 data for Lyon
   2. Convert vector to raster (100m or 30m resolution)
      - Tool: QGIS Rasterize (Vector to Raster)
      - Burn value: Land use code
      - Output format: ASCII grid (.asc)
   ```

2. **Transportation Network**:
   ```
   1. Extract roads by filtering class atribute from Urban Atlas data
   2. Simplify geometry
      - Tool: QGIS Simplify
      - Tolerance: 100m
   3. Export as shapefile
   ```

## GAMA Model Structure

- Agents:
  - Plots (grid cells)
  - Roads network
  - City center

## Usage

1. Install GAMA Platform
2. Clone repository
3. Place datasets in `/includes/`
4. Open `LyonUrbanGrowth.gaml`
5. Run experiment "raster"

## Scenarios [WIP]

- Base scenario: Current growth patterns
- No regulation: Unrestricted development
- Controlled growth: Protected green spaces
- Balanced growth: Moderate expansion

## Validation [WIP]

Compare simulated results with Urban Atlas 2018 data using:
- Mean absolute error
- Land use transition matrices
- Temporal consistency checks

## Project Structure

```
├── includes/
│   └── urban_growth/
│       └── 2012/
│           ├── Lyon_rasterized_100m_2012.asc
│           ├── Lyon_2012_Roads_Rivers_Simplified.shp
│           └── city center.shp
└── models/
    └── LyonUrbanGrowth.gaml
```
