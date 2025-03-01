/**
* Name: Cellular Automaton Based Land-Use Transition with Cluster-Based Growth and Markov Chain Matrix
* Author: Elouann Lucas, Arunima Sen
* Description: Simulates land-use transitions based on urban growth scenarios using cluster-based growth methodology.
* Tags: land cover, urban growth, GIS, grid, cellular automaton
*/
model LyonUrbanGrowth

global {
// File for the ascii grid
	file asc_grid_2012 <- grid_file("../includes/urban_growth/2018/Full_Lyon_rasterized_100m_2018.asc");
	// Shapefile for the road visualization
	file road_shapefile_2012 <- shape_file("../includes/urban_growth/2018/Full_Lyon_2018_roads_simplified.shp");
	// Shape of the environment
	geometry shape <- envelope(road_shapefile_2012);

	// Land use class codes
	list<float> urban_codes <- [11100.0, 11210.0, 11220.0, 11230.0, 11240.0];
	list<float> green_urban_codes <- [14100.0, 14200.0];
	list<float> agricultural_codes <- [21000.0, 22000.0, 23000.0, 24000.0, 25000.0];
	list<float> natural_codes <- [31000.0, 32000.0, 33000.0];
	list<float> transit_infra_codes <- [12210, 12220, 12230];
	list<float> industrial_codes <- [12100.0];

	// List of all land use types for transition matrix
	list<string> land_use_types <- ["urban", "green_urban", "agricultural", "natural", "industrial", "transit"];

	// List of scenarios
	list<string> scenarios <- ["Unrestricted Urban Growth", "Controlled Urban Growth", "Balanced Growth", "Promote Green Areas"];

	// Suitable cells list
	list<plot> suitable_plots <- plot where (each.grid_value in urban_codes or each.grid_value in green_urban_codes or each.grid_value in agricultural_codes or each.grid_value in
	natural_codes) update: shuffle(plot where (each.grid_value in urban_codes or each.grid_value in green_urban_codes or each.grid_value in agricultural_codes or each.grid_value in
	natural_codes));

	// Scenario selection parameter
	string scenario <- "Balanced Growth";

	// Neighborhood parameters
	int neighborhood_radius <- 3 min: 1 max: 5;

	// Minimum neighborhood similarity thresholds (number of similar cells needed)
	map<string, int> min_similar_neighbors <- ["urban"::5, "green_urban"::4, "agricultural"::4, "natural"::4, "industrial"::5];

	// Transition probabilities (base values for Balanced Growth scenario)
	// Format: from row -> to column [urban, green_urban, agricultural, natural, industrial, transit]
	matrix<float> transition_matrix <- matrix([[0.95, 0.05, 0.00, 0.00, 0.00, 0.00], // from urban
	[0.15, 0.85, 0.00, 0.00, 0.00, 0.00], // from green_urban
	[0.10, 0.10, 0.75, 0.05, 0.00, 0.00], // from agricultural
	[0.05, 0.10, 0.15, 0.70, 0.00, 0.00], // from natural
	[0.10, 0.05, 0.00, 0.00, 0.85, 0.00], // from industrial
	[0.00, 0.00, 0.00, 0.00, 0.00, 1.00] // from transit (fixed)
]);

	// Statistics variables
	int urban_cells <- 0 update: plot count (each.grid_value in urban_codes);
	int green_cells <- 0 update: plot count (each.grid_value in green_urban_codes);
	int agricultural_cells <- 0 update: plot count (each.grid_value in agricultural_codes);
	int natural_cells <- 0 update: plot count (each.grid_value in natural_codes);
	int industrial_cells <- 0 update: plot count (each.grid_value in industrial_codes);

	// Cumulative transition counters
	int total_urban_transitions <- 0;
	int total_green_transitions <- 0;
	int total_urban_from_agricultural <- 0;
	int total_urban_from_natural <- 0;
	int total_green_from_agricultural <- 0;
	int total_green_from_natural <- 0;
	int total_loss_artificial <- 0;
	int total_other_changes <- 0;

	// Track cycle-specific transitions
	int cycle_urban_transitions <- 0;
	int cycle_green_transitions <- 0;
	int urban_from_agricultural <- 0;
	int urban_from_natural <- 0;
	int green_from_agricultural <- 0;
	int green_from_natural <- 0;
	int loss_artificial <- 0;
	int other_changes <- 0;

	init {
	// Create roads from shapefile
		create roads from: road_shapefile_2012;
	}

	// Apply land use transitions based on the scenario
	reflex land_use_transition {
		ask suitable_plots parallel: true {
//			do compute_transition;
		}

	}

	// Update transition counts based on the current cycle's new land-use transitions
	// and accumulate since the beginning
	reflex update_transition_count {
	// Calculate cycle-specific transitions
		cycle_urban_transitions <- plot count (each.transitioned_this_cycle and each.grid_value in urban_codes);
		cycle_green_transitions <- plot count (each.transitioned_this_cycle and each.grid_value in green_urban_codes);
		urban_from_agricultural <- plot count (each.transitioned_this_cycle and each.previous_grid_value in agricultural_codes and each.grid_value in urban_codes);
		urban_from_natural <- plot count (each.transitioned_this_cycle and each.previous_grid_value in natural_codes and each.grid_value in urban_codes);
		green_from_agricultural <- plot count (each.transitioned_this_cycle and each.previous_grid_value in agricultural_codes and each.grid_value in green_urban_codes);
		green_from_natural <- plot count (each.transitioned_this_cycle and each.previous_grid_value in natural_codes and each.grid_value in green_urban_codes);

		// Calculate artificial land loss (urban or industrial areas that changed to agricultural or natural)
		loss_artificial <- plot count (each.transitioned_this_cycle and (each.previous_grid_value in urban_codes or each.previous_grid_value in industrial_codes) and (each.grid_value in
		agricultural_codes or each.grid_value in natural_codes));

		// Calculate other changes (any transition not accounted for in the categories above)
		other_changes <- plot count (each.transitioned_this_cycle) - (urban_from_agricultural + urban_from_natural + green_from_agricultural + green_from_natural + loss_artificial);

		// Update cumulative counters
		total_urban_transitions <- total_urban_transitions + cycle_urban_transitions;
		total_green_transitions <- total_green_transitions + cycle_green_transitions;
		total_urban_from_agricultural <- total_urban_from_agricultural + urban_from_agricultural;
		total_urban_from_natural <- total_urban_from_natural + urban_from_natural;
		total_green_from_agricultural <- total_green_from_agricultural + green_from_agricultural;
		total_green_from_natural <- total_green_from_natural + green_from_natural;
		total_loss_artificial <- total_loss_artificial + loss_artificial;
		total_other_changes <- total_other_changes + other_changes;

		// Reset transition flags for next cycle
		ask plot {
			transitioned_this_cycle <- false;
			previous_grid_value <- grid_value;
		}

	}

	// Adjust neighborhood similarity thresholds based on the selected scenario
	reflex adjust_scenario_parameters {
		switch (scenario) {
			match "Unrestricted Urban Growth" {
				min_similar_neighbors["urban"] <- 2; // Very low requirement for urban growth
				min_similar_neighbors["green_urban"] <- 6; // High requirement for green areas
				min_similar_neighbors["agricultural"] <- 5;
				min_similar_neighbors["natural"] <- 6; // Harder to maintain natural areas
				min_similar_neighbors["industrial"] <- 3;
			}

			match "Controlled Urban Growth" {
				min_similar_neighbors["urban"] <- 7; // High requirement for urban growth
				min_similar_neighbors["green_urban"] <- 5;
				min_similar_neighbors["agricultural"] <- 3; // Easier to maintain agricultural areas
				min_similar_neighbors["natural"] <- 3; // Easier to maintain natural areas
				min_similar_neighbors["industrial"] <- 6;
			}

			match "Balanced Growth" {
				min_similar_neighbors["urban"] <- 5; // Medium requirements for all types
				min_similar_neighbors["green_urban"] <- 4;
				min_similar_neighbors["agricultural"] <- 4;
				min_similar_neighbors["natural"] <- 4;
				min_similar_neighbors["industrial"] <- 5;
			}

			match "Promote Green Areas" {
				min_similar_neighbors["urban"] <- 6; // Higher requirement for urban growth
				min_similar_neighbors["green_urban"] <- 2; // Very low requirement for green areas
				min_similar_neighbors["agricultural"] <- 5;
				min_similar_neighbors["natural"] <- 3; // Easier to maintain/expand natural areas
				min_similar_neighbors["industrial"] <- 6;
			}

		}

	}

}

// Species representing the roads
species roads {

	aspect default {
		draw shape color: #darkgrey;
	}

}

grid plot file: asc_grid_2012 use_individual_shapes: false use_regular_agents: false parallel: true {
	float previous_grid_value <- grid_value; // Store previous grid value
	bool transitioned_this_cycle <- false; // Flag to track if the plot transitioned this cycle
	rgb color <- get_color(grid_value);

	// Get the color based on the grid value
	rgb get_color (float val) {
		switch (val) {
			match_one urban_codes {
				return #red; // Urban areas are red
			}

			match float(12100) {
				return #purple; // Industrial, commercial, public, military and private units code
			}

			match_one green_urban_codes {
				return #lime;
			}

			match_one transit_infra_codes {
				return #grey;
			}

			match_one agricultural_codes {
				return #yellow;
			}

			match_one natural_codes {
				return #green;
			}

			default {
				return #white;
			}

		}

	}

	// Compute cluster-based transition for the plot
	action compute_transition {
		string current_land_use <- get_land_use_type(self.grid_value);

		// Skip transition calculation for transit infrastructure (fixed)
		if current_land_use = "transit" {
			return;
		}

		// Calculate neighborhood composition
		list<plot> my_neighbors <- (self neighbors_at neighborhood_radius);

		// Count similar neighbors for each land use type
		map<string, int> similar_neighbors;
		loop land_type over: land_use_types {
			similar_neighbors[land_type] <- length(my_neighbors where (get_land_use_type(each.grid_value) = land_type));
		}

		// Create list of possible transitions based on neighborhood criteria
		list<string> possible_transitions <- [];

		// Filter possible transitions based on minimum neighborhood counts
		loop land_type over: land_use_types {
		// Skip transit as a possible transition
			if land_type = "transit" {
				continue;
			}

			// Only add to possible transitions if it meets the minimum neighbor requirement
			if similar_neighbors[land_type] >= min_similar_neighbors[land_type] {
				possible_transitions <+ land_type;
			}

		}

		// Always include current type as possible outcome
		if !(current_land_use in possible_transitions) {
			possible_transitions <+ current_land_use;
		}

		// Use Markov probability for transition among possible types
		if !empty(possible_transitions) and possible_transitions != [current_land_use] {
		// Get index in transition matrix
			int row_index <- land_use_types index_of current_land_use;

			// Extract probabilities only for possible transitions
			list<float> filtered_probs <- [];
			list<string> filtered_types <- [];
			loop transition_type over: possible_transitions {
				if transition_type != current_land_use {
					int col_index <- land_use_types index_of transition_type;
					filtered_probs <+ transition_matrix[row_index, col_index];
					filtered_types <+ transition_type;
				}

			}

			// Add current state with adjusted probability
			filtered_probs <+ 0.5; // Probability to stay the same
			filtered_types <+ current_land_use;

			// Normalize probabilities
			float sum_probs <- sum(filtered_probs);
			list<float> normalized_probs <- [];
			loop i from: 0 to: length(filtered_probs) - 1 {
				normalized_probs <+ filtered_probs[i] / sum_probs;
			}

			// Choose new land use based on probability
			float rand <- rnd(0.0, 1.0);
			float cumulative_prob <- 0.0;
			string new_land_use <- current_land_use;
			loop i from: 0 to: length(normalized_probs) - 1 {
				cumulative_prob <- cumulative_prob + normalized_probs[i];
				if rand <= cumulative_prob {
					new_land_use <- filtered_types[i];
					break;
				}

			}

			// Update if land use changed
			if new_land_use != current_land_use {
				previous_grid_value <- grid_value;
				grid_value <- get_representative_value(new_land_use);
				color <- get_color(grid_value);
				transitioned_this_cycle <- true;
			}

		}

	}

	// Get land use type as string from grid value
	string get_land_use_type (float value) {
		if value in urban_codes {
			return "urban";
		} else if value in green_urban_codes {
			return "green_urban";
		} else if value in agricultural_codes {
			return "agricultural";
		} else if value in natural_codes {
			return "natural";
		} else if value in industrial_codes {
			return "industrial";
		} else if value in transit_infra_codes {
			return "transit";
		} else {
			return "other";
		} }

		// Get representative grid value for a land use type
	float get_representative_value (string land_use_type) {
		switch land_use_type {
			match "urban" {
				return 11100.0;
			}

			match "green_urban" {
				return 14100.0;
			}

			match "agricultural" {
				return 21000.0;
			}

			match "natural" {
				return 31000.0;
			}

			match "industrial" {
				return 12100.0;
			}

			match "transit" {
				return 12210.0;
			}

			default {
				return 0.0;
			}

		}

	} }

experiment raster type: gui {
	parameter "Scenarios" var: scenario among: scenarios;
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
				data "Industrial" value: industrial_cells color: #purple;
			}

		}

		display "Transition Dynamics" type: 2d {
			chart "Transitions per Cycle" type: series {
				data "New Urban Areas" value: cycle_urban_transitions color: #red;
				data "New Green Areas" value: cycle_green_transitions color: #lime;
			}

		}

		display "Main changes" type: 2d {
			chart "Urban Expansion Sources" type: pie {
				data "Urban expansion : uptake of agricultural areas" value: total_urban_from_agricultural color: #darkred;
				data "Urban expansion : uptake of natural areas" value: total_urban_from_natural color: #red;
				data "Loss of artificial areas" value: total_loss_artificial color: #darkgreen;
				data "Other changes" value: total_other_changes color: #grey;
			}

		}

		monitor "Urban Areas (%)" value: (urban_cells / length(plot)) * 100;
		monitor "Green Areas (%)" value: (green_cells / length(plot)) * 100;
		monitor "Agricultural Areas (%)" value: (agricultural_cells / length(plot)) * 100;
		monitor "Natural Areas (%)" value: (natural_cells / length(plot)) * 100;
		monitor "Industrial Areas (%)" value: (industrial_cells / length(plot)) * 100;
	}

}
