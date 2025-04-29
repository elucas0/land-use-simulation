# Working with lists

## Introduction

Building upon last week's savanna ecosystem simulation, this study implements new demographic tracking features to analyze lion population dynamics. The original model, which simulated basic predator-prey interactions between lions and zebras in a grass environment, has been extended to include age-based population analysis and visualization.

## Methods

The simulation extends the previous GAMA platform implementation with these key additions:

1.Demographic Tracking System:

```java
global {
    list<int> age_list <- [];
}

species lion skills: [moving] {
    int age <- int(rnd(0, 20));
    
    init {
        add self.age to: age_list;    // Decentralized age registration
    }
    
    reflex update_age {
        age_list[self.index] <- self.age + 1;
        self.age <- age_list[self.index];
    }
}
```

2.Individual Visual Representation

```java
rgb adaptative_color <- rgb(255, 255 - self.age * 10, 0);

reflex update_color {
    adaptative_color <- rgb(255, 255 - self.age * 10, 0);
}
```

3.Population Monitoring:

```java
reflex report_age_stats {
    write "Number of ages: " + length(age_list);
    write "Minimum age: " + min(age_list);
    write "The mean age of lions is: " + mean(age_list);
    write "Maximum age: " + max(age_list);
}
```

## Results & Analysis

The enhanced model successfully implements:

- Real-time tracking of population demographics through a dynamic age list
- Individual-based color representation varying from yellow (young) to red (old)
- Automatic population renewal with 60-year lifespan and immediate replacement
- Maintenance of original predator-prey dynamics while adding demographic features

Key implementation decisions include:

1. Decentralized age list population through agent initialization rather than global setup
2. Individual adaptive coloring instead of population-wide color schemes
3. Integration with existing movement and predation behaviors

## Discussion & Conclusion

The enhancements successfully add demographic analysis capabilities while maintaining the original ecosystem simulation functionality. The decentralized approach to age tracking and individual color management improves model flexibility and visual feedback. Future improvements could include variable death ages, multiple offspring possibilities, and environmental influences on aging.

Limitations:

- Fixed death age (60 years)
- Simplified aging process
- Basic 1:1 replacement ratio

The implementation provides a solid foundation for studying population dynamics while preserving the essential predator-prey interactions from the original model.
