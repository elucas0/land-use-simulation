# Spatial Simulation Projects  

This repository contains various agent-based models and simulations developed during the Spatial Simulation course of the Copernicus master's degree. Each project explores different aspects of spatial dynamics, ranging from urban growth to ecosystem interactions.  

## Table of Contents  

1. [Urban Growth Simulation - Lyon](#urban-growth-simulation---lyon)  
2. [Savanna Ecosystem Simulation](#savanna-ecosystem-simulation)  
3. [Grazing Cows Simulation](#grazing-cows-simulation)  

---

## Urban Growth Simulation - Lyon  

### Description  

This agent-based model simulates urban growth patterns in Lyon using Copernicus Urban Atlas data. It incorporates land-use transitions, cluster-based growth, and Markov chain matrices to explore different urban growth scenarios.  

### Features  

- Land-use transitions based on predefined probabilities.  
- Scenarios: Unrestricted Urban Growth, Controlled Urban Growth, Balanced Growth, Promote Green Areas.  
- Visualization of land-use dynamics and transition statistics.  

### Data  

- **Land Use Data**: Urban Atlas 2018 (100m resolution raster).  

### Usage  

1. Place datasets in the `/includes/` folder.  
2. Open `LyonUrbanGrowth.gaml` in GAMA.  
3. Run the `raster` experiment.  

For more details, see the [README](./land-use-simulation/README.md).  

---

## Savanna Ecosystem Simulation  

### Description  

This model simulates predator-prey interactions in a savanna ecosystem, focusing on lions and zebras. It includes demographic tracking and age-based visualization for lions.  

### Features  

- Real-time tracking of lion population demographics.  
- Adaptive coloring of lions based on age.  
- Predator-prey dynamics with grazing zebras and aging lions.  

### Key Additions  

- **Demographic Tracking**: Centralized age list for lions.  
- **Population Monitoring**: Reflexes to report age statistics.  
- **Visual Representation**: Color changes from yellow (young) to red (old).  

For more details, see the [README](./savana-ecosystem/README.md).  

---

## Grazing Cows Simulation  

### Description  

This model simulates the grazing behavior of cows on the Vierkaser pasture. It incorporates spatial dynamics of grass regrowth and cow movement.  

### Features  

- Grass regrowth based on location-specific biomass limits.  
- Cows move to the best grazing spots within their action radius.  
- Dynamic interaction between cows and grass biomass.  

### Usage  

1. Load GIS data for pasture areas.  
2. Run the simulation to observe grazing patterns and grass regrowth.  

For more details, see the [README](./grazing-cows/README.md).  

---

## Conclusion  

These projects demonstrate the versatility of agent-based modeling in simulating complex spatial dynamics. Each model provides insights into different systems, from urban development to ecological interactions.  

Feel free to explore the individual project folders for more details and instructions.  
