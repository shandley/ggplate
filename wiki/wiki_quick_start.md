# Quick Start Guide

This quick start guide will help you get up and running with ggplateplus for microplate data visualization and analysis.

## Installation

First, install the package from GitHub using devtools:

```r
# Install devtools if you don't already have it
# install.packages("devtools")

# Install ggplateplus from GitHub
devtools::install_github("shandley/ggplateplus")
```

## Loading the Package

Once installed, load the package:

```r
library(ggplateplus)

# Other useful packages for data manipulation
library(dplyr)
```

## Basic Plate Visualization

Let's create a simple visualization using one of the included example datasets:

```r
# Load example data for a 96-well plate with continuous values
data(data_continuous_96)

# Look at the data structure
head(data_continuous_96)
#>   well     Value
#> 1   A1 0.5384893
#> 2   A2 0.9347052
#> 3   A3 0.2554251
#> 4   A4 0.4820801
#> 5   A5 0.6264538
#> 6   A6 0.7176185

# Create a basic plate plot
basic_plot <- plate_plot(
  data = data_continuous_96,
  position = well,      # Column containing well positions
  value = Value,        # Column containing values to visualize
  plate_size = 96       # Size of the plate
)

# Display the plot
basic_plot
```

This creates a visualization of your plate data using the default color scale (viridis).

## Customizing Your Visualization

Add more customization to your plot:

```r
custom_plot <- plate_plot(
  data = data_continuous_96,
  position = well,
  value = Value,
  label = Value,        # Add value labels to each well
  plate_size = 96,
  plate_type = "round", # Well shape: "round" or "square"
  colour = c("blue", "white", "red"),  # Custom color scale
  size = 2.5,           # Text size for labels
  label_color = "black" # Text color for labels
)

custom_plot
```

## Working with Categorical Data

If your data has categories rather than continuous values:

```r
# Load example data with categorical values
data(data_discrete_96)

# Create a plot with discrete categories
categorical_plot <- plate_plot(
  data = data_discrete_96,
  position = well,
  value = Condition,    # Categorical variable
  plate_size = 96
)

categorical_plot
```

## Multi-Plate Comparison

Compare multiple plates or conditions side by side:

```r
# Load multi-condition dataset
data(data_multi_condition_96)

# Create faceted plot by condition
multi_plate <- plate_plot(
  data = data_multi_condition_96,
  position = well,
  value = Value,
  plate_size = 96
) +
  ggplot2::facet_wrap(~Condition, ncol = 2)

multi_plate
```

## Next Steps

Now that you have the basics, explore these other features:

1. **Different Position Formats**: Work with different well naming schemes:
   ```r
   # Using numeric positions
   data(data_numeric_position_96)
   numeric_plot <- plate_plot(
     data = data_numeric_position_96,
     position = well,
     value = Value,
     position_format = "numeric",
     plate_size = 96
   )
   ```

2. **Data Import/Export**: Import data from files:
   ```r
   # Example (replace with your file)
   my_data <- import_plate_layout("my_plate_layout.csv")
   ```

3. **Annotation**: Add annotations to highlight wells or regions:
   ```r
   p <- plate_plot(data = data_discrete_96, position = well, value = Condition, plate_size = 96)
   p <- highlight_wells(plot = p, pattern = "Sample", column = "Condition", color = "yellow")
   ```

4. **Interactive Plots**: Create interactive visualizations with plotly:
   ```r
   library(plotly)
   interactive_plate(
     data = data_continuous_96,
     position = well,
     value = Value,
     plate_size = 96,
     tooltip_vars = c("well", "Value")
   )
   ```

## Where to Go Next

- [Position Format Handling](Position-Format-Handling) - Learn about different well position formats
- [Data Import/Export](Data-Import-Export) - Import and export plate data
- [Annotation Features](Annotation-Features) - Add annotations to your visualizations
- [Gallery](Gallery) - See examples of different visualization options