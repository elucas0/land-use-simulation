/**
* Name: LyonUrbanGrowth
* Based on the internal empty template. 
* Author: elouann
* Tags: land cover, urban development
*/
model LyonUrbanGrowth

global {
	//File for the ascii grid
	file asc_grid <- grid_file("../includes/urban_growth/2012/Full_Lyon_rasterized_100m_2012.asc");
	//Shapefile for the road
	file road_shapefile <- shape_file("../includes/urban_growth/2012/Full_Lyon_2012_roads_simplified.shp");
	//Shape of the environment
	geometry shape <- envelope(asc_grid);
	//Graph of the roads
	graph roads_network;

	// Lists of class codes
	list<float> urban_codes <- [11100.0, 11210.0, 11220.0, 11230.0, 11240.0];
	list<float> green_urban_codes <- [14100.0, 14200.0];
	list<float> agricultural_codes <- [21000.0, 22000.0, 23000.0, 24000.0, 25000.0];
	list<float> natural_codes <- [31000.0, 32000.0, 33000.0];

	//Suitable cells list
	list<plot> suitable_plots <- plot where (each.grid_value in green_urban_codes or each.grid_value in agricultural_codes or each.grid_value in natural_codes);

	// Transition probabilities
	float urban_expansion_rate <- 0.2;
	float road_influence_distance <- 100.0;
	int neighborhood_radius <- 1;

	// Statistics variables
	int urban_cells <- 0 update: plot count (each.grid_value in urban_codes);
	int green_cells <- 0 update: plot count (each.grid_value in green_urban_codes);
	int agricultural_cells <- 0 update: plot count (each.grid_value in agricultural_codes);
	int natural_cells <- 0 update: plot count (each.grid_value in natural_codes);

	// Track transitions
	int cycle_urban_transitions <- 0 update: 0;

	init {
	//Creation of the roads using the shapefile of the road
		create roads from: road_shapefile;
		//Creation of the city center using the city center shapefile
		//Creation of the graph of the road network
		roads_network <- as_edge_graph(roads);
	}

	reflex update_transition_count {
		cycle_urban_transitions <- plot count (each.transitioned_this_cycle);
	}

	reflex land_use_transition {
		ask suitable_plots {
			do compute_transition;
		}

	}

}

//Species representing the roads
species roads {

	aspect default {
		draw shape color: #black;
	}

}

grid plot file: asc_grid use_individual_shapes: false use_regular_agents: false {
	float transition_probability <- 0.0;
	bool transitioned_this_cycle <- false;
	rgb color <- get_color(grid_value);
	rgb get_color (float val) {
		switch (val) {
			match_one urban_codes {
				return #red;
			}

			match float(12100) {
				return #purple;
			}

			match_one green_urban_codes {
				return #lime;
			}

			match_one [float(12210), float(12220), float(12230)] {
				return #grey;
			}

			match_one agricultural_codes {
				return #yellow;
			}

			match_one natural_codes {
				return #green;
			}

			default {
				return #darkgrey;
			}

		}

	}

	action compute_transition {
		transitioned_this_cycle <- false;
		// Only consider non-urban, non-road cells for transition
		list<plot> my_neighbors <- (self neighbors_at neighborhood_radius);

		// Calculate urban pressure from neighbors
		float urban_neighbors <- length(my_neighbors where (each.grid_value in urban_codes)) / length(my_neighbors);
		//		float road_influence <- 0.0;
		//		if (urban_neighbors > 0) {
		//			float min_road_dist <- self distance_to (roads closest_to self);
		//			road_influence <- exp(-min_road_dist / road_influence_distance);
		//		}

		// Combine factors for transition probability
		//		transition_probability <- (urban_neighbors * 0.6 + road_influence * 0.4);
		transition_probability <- (urban_neighbors * 0.6);
		// Apply transition based on probability
		if flip(transition_probability) {
			grid_value <- 11100.0; // Convert to urban
			color <- get_color(grid_value);
			transitioned_this_cycle <- true;
		}

	}

}

experiment raster type: gui {
	parameter "Urban expansion rate" var: urban_expansion_rate min: 0.0 max: 0.2 step: 0.01;
	parameter "Road influence distance" var: road_influence_distance min: 50.0 max: 500.0 step: 50.0;
	parameter "Neighborhood radius" var: neighborhood_radius min: 1 max: 5 step: 1;
	output {
		display map type: 3d axes: false antialias: false {
			grid plot;
			species roads;
		}

		display "Land Use Statistics" type: 2d {
			chart "Land Use Distribution" type: pie {
				data "Urban" value: urban_cells color: #red;
				data "Green Spaces" value: green_cells color: #lime;
				data "Agricultural" value: agricultural_cells color: #yellow;
				data "Natural" value: natural_cells color: #green;
			}

		}

		display "Transition Dynamics" type: 2d {
			chart "Urban Transitions per Cycle" type: series {
				data "New Urban Areas" value: cycle_urban_transitions color: #red;
			}

		}

		monitor "Urban Areas (%)" value: (urban_cells / length(plot)) * 100;
		monitor "Green Areas (%)" value: (green_cells / length(plot)) * 100;
		monitor "Agricultural Areas (%)" value: (agricultural_cells / length(plot)) * 100;
		monitor "Natural Areas (%)" value: (natural_cells / length(plot)) * 100;
	}

}