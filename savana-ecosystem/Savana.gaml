model mymodel

global {
	list<int> age_list <- [];

	init {
		create lion number: 5;
		create zebra number: 20;
	}

	reflex report_age_stats {
		write "Number of ages: " + length(age_list);
		write "Minimum age: " + min(age_list);
		write "The mean age of lions is: " + mean(age_list);
		write "Maximum age: " + max(age_list);
	}

}

species lion skills: [moving] {
	int age <- int(rnd(0, 20));
	rgb adaptative_color <- rgb(255, 255 - self.age * 10, 0);
	
	init {
		add self.age to: age_list;
	}

	reflex move {
		do wander;
	}

	//	reflex reporting {
	//		ask lion[3] {
	//			write "This is the current agent: " + self;
	//			write "This is the calling agent: " + myself;
	//		}
	//
	//	}
	reflex update_color {
		adaptative_color <- rgb(255, 255 - self.age * 10, 0);
	}

	reflex eat_zebra {
		list<zebra> zebrasInRange <- list<zebra>(agents_at_distance(3));
		zebra target <- one_of(zebrasInRange);
		if (target != nil) {
			ask target {
				do die;
			}

		}

	}
	
	reflex update_age {
		age_list[self.index] <- self.age + 1;
		self.age <- age_list[self.index];
	}
	
	reflex check_age {
		write age_list;
		if (self.age > 60) {
			write "I am doing to die";
			// remove index: self.index from: age_list;
			create lion number: 1 {
				age <- 0;
				adaptative_color <- rgb(255, 255, 0);
				write "A new baby lion has been born!";
			}
			do die;
		} else if (self.age > 2) {
			write "I am mature";
		} else {
			write "Erro: I should be dead already !";
		}

	}

	aspect default {
		draw circle(3) color: adaptative_color;
	}

}

species zebra skills: [moving] {

	reflex move {
		do wander;
	}

	aspect default {
		draw triangle(2) color: #grey;
	}

}

grid grass {
	float bio <- rnd(0.0, 10.0);
	rgb grass_color <- (rgb(0, 25 * bio, 0));

	reflex growth {
		bio <- bio + rnd(-0.5, 0.5);
		grass_color <- (rgb(0, 25 * bio, 0));
	}

	aspect firstAspect {
		draw square(1) color: grass_color;
	}

}

experiment main_experiment type: gui {
	output {
		display map {
			species grass aspect: firstAspect;
			species lion aspect: default;
			species zebra aspect: default;
		}

	}

}