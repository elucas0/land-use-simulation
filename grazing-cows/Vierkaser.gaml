/**
* Name: Vierkaser
* Based on the internal empty template. 
* Author: elouann
* Tags: 
*/
model Vierkaser

global {
	file vierkaser <- file("../includes/Vierkaser.geojson");
	file hirschanger <- file("../includes/Hirschanger.geojson");
	file meadow <- file("../includes/Meadow.geojson");
	file cutback0 <- file("../includes/cleaned_2020.geojson");
	file cutback1 <- file("../includes/cleaned_2021.geojson");
	file cutback2 <- file("../includes/cleaned_2022.geojson");
	file cutback3 <- file("../includes/cleaned_2023.geojson");

	//set meters as the unit of the cow‘s action radius
	float action_radius <- 15.0 #m;
	geometry vierkaser_polygon <- geometry(vierkaser);
	geometry hirschanger_polygon <- geometry(hirschanger);
	geometry meadow_polygon <- geometry(meadow);
	geometry cutback0_polygon <- geometry(cutback0);
	geometry cutback1_polygon <- geometry(cutback1);
	geometry cutback2_polygon <- geometry(cutback2);
	geometry cutback3_polygon <- geometry(cutback3);
	geometry shape <- envelope(vierkaser);
	// 4) Create the agents
	init {
		create vierkaser_geo number: 1 {
		}

		create hirschanger_geo number: 1 {
		}

		create meadow_geo number: 1 {
		}

		create cutback0_geo number: 1 {
		}

		create cutback1_geo number: 1 {
		}

		create cutback2_geo number: 1 {
		}

		create cutback3_geo number: 1 {
		}

		create cow number: 6 {
			location <- any_location_in(hirschanger_polygon + meadow_polygon + cutback0_polygon + cutback1_polygon + cutback2_polygon + cutback3_polygon);
		}

	}

}

species cow skills: [moving] {
	int size <- 5;
	geometry action_area;
	grass best_spot;
	float speed <- 1.5;

	//Graze reflex for the cows
	reflex graze {
	// Find the best spot for grazing within the cow's action radius
		best_spot <- one_of(grass at_distance (action_radius) where (each.biomass >= 10 and each.max_biomass != 0));
		if (best_spot != nil) {
		// Move the cow to the best grazing spot
			do goto target: best_spot speed: speed;
			// Graze the grass at the current location
			grass grazing_spot <- one_of(grass intersecting (action_area));
			if (grazing_spot != nil) {
				ask grazing_spot {
					biomass <- biomass - 10; // Reduce the biomass of the grass
					color <- rgb(255 - biomass, 255, 255 - biomass); // Update the color to reflect the reduced biomass
				}

			}

		}

	}

	reflex update_actionArea {
		action_area <- circle(action_radius);
	}

	aspect default {
		draw circle(size) color: #black;
	}

	aspect action_neighbourhood {
		draw action_area color: #goldenrod;
	}

}

grid grass {
// Base biomass
	float biomass <- 0.0;
	int max_biomass <- 0;
	// Flags to indicate the location of the grass
	bool in_hirschanger <- self intersects hirschanger_polygon;
	bool in_cutback_2020 <- self intersects cutback0_polygon;
	bool in_cutback_2021 <- self intersects cutback1_polygon;
	bool in_cutback_2022 <- self intersects cutback2_polygon;
	bool in_cutback_2023 <- self intersects cutback3_polygon;
	bool in_lower_pasture <- self intersects (meadow_polygon);

	// Initialize the grass properties based on its location
	init {
		if (in_hirschanger) {
			max_biomass <- 40;
			biomass <- 40.0;
		} else if (in_cutback_2020) {
			max_biomass <- 70;
			biomass <- 70.0;
		} else if (in_cutback_2021 or in_cutback_2022 or in_cutback_2023 or in_lower_pasture) {
			max_biomass <- 60;
			biomass <- 60.0;
		} else {
			max_biomass <- 0;
		} }

		// Reflex to grow the grass over time
	reflex grow {
		if (biomass <= max_biomass and max_biomass != 0) {
			biomass <- biomass + 0.5; // Increase the biomass of the grass
			color <- rgb(255 - biomass, 255, 255 - biomass); // Update the color to reflect the increased biomass
		}

	} }

species vierkaser_geo skills: [] {

	aspect default {
		draw vierkaser_polygon color: #black;
	}

}

species hirschanger_geo skills: [] {

	aspect default {
		draw hirschanger_polygon color: #black;
	}

}

species meadow_geo skills: [] {

	aspect default {
		draw meadow_polygon color: #black;
	}

}

species cutback0_geo skills: [] {

	aspect default {
		draw cutback0_polygon color: #black;
	}

}

species cutback1_geo skills: [] {

	aspect default {
		draw cutback1_polygon color: #black;
	}

}

species cutback2_geo skills: [] {

	aspect default {
		draw cutback2_polygon color: #black;
	}

}

species cutback3_geo skills: [] {

	aspect default {
		draw cutback3_polygon color: #black;
	}

}

experiment main_experiment {
	output {
		display map {
			grid grass border: #white;
			species cow aspect: default;
			species cow aspect: action_neighbourhood transparency: 0.5;
			species vierkaser_geo aspect: default transparency: 0.9;
			species hirschanger_geo aspect: default transparency: 0.9;
			species meadow_geo aspect: default transparency: 0.9;
			species cutback0_geo aspect: default transparency: 0.9;
			species cutback1_geo aspect: default transparency: 0.9;
			species cutback2_geo aspect: default transparency: 0.9;
			species cutback3_geo aspect: default transparency: 0.9;
		}

	}

}