## ggplateplus

<!-- badges: start -->
<!-- badges: end -->

The **ggplateplus** package enables users to create simple plots of biological culture plates as well as microplates with support for multiple well position naming formats. Both continuous and discrete values can be plotted onto the plate layout. It includes enhanced functionality for importing, exporting, and visualizing plate data.

## New Features

The key features in ggplateplus include:

* **Multiple Well Position Formats**: Support for different types of well naming schemes:
  - Traditional letter-number format (A1, B2, etc.)
  - Sequential numbering (1, 2, 3, etc.)
  - Row-column notation (1_1, 1_2, etc.)

* **Flexible Data Import/Export**: Read and write plate layouts in various formats:
  - Import from CSV, TSV, and Excel files
  - Support for separate row/column fields (common in lab data)
  - Automatic format detection
  - Multi-plate dataset handling
  - Export to various file formats with optional position splitting

* **Plate Map Creation**: Generate plate layout templates for experiment setup:
  - Create empty plate maps for any plate size
  - Support for all position formats
  - Custom starting positions
  - Options to include specific subsets of wells

* **Faceted Multi-Plate Display**: Compare multiple plates side by side:
  - Create faceted plots for different conditions, timepoints, or replicates
  - Customize facet layout and scales
  - Common or separate legends
  - Full compatibility with all plate_plot options

This makes the package more compatible with various lab automation systems and data formats and provides tools for both experiment planning and data visualization.

Currently the package supports the following plate sizes:

* 6-well plate
* 12-well plate
* 24-well plate
* 48-well plate
* 96-well plate
* 384-well plate
* 1536-well plate


## Installation

**ggplateplus** is currently only available from GitHub. You can install it using the [`devtools`](https://github.com/r-lib/devtools) package:

Note: If you do not have `devtools` installed make sure to do so by removing the comment sign (#).

``` r
# install.packages("devtools")
devtools::install_github("shandley/ggplateplus")
```

## Usage

In order to use **ggplateplus** you have to load the package in your R environment by simply calling the `library()` function as shown below.

```r
# Load ggplateplus package
library(ggplateplus)
```

There are multiple example datasets provided that can be used to create plots of each plate type. You can access these datasets using the `data()` function.

```r
# Load a dataset of continuous values for a 96-well plate
data(data_continuous_96)

# Check the structure of the dataset
str(data_continuous_96)
```

When calling the `str()` function you can see that the data frame of a continuous 96-well plate dataset only contains two columns. The `Value` column contains values associated with each of the plate wells, while the `well` column contains the corresponding well positions using a combination of **alphabetic row names** and **numeric column names**.

### Well Position Formats

The package supports multiple well position naming schemes through the `position_format` parameter:

1. **letter_number** (default): positions like A1, B2, C3 (row = letter, column = number)
2. **number** (or **numeric**): positions like 1, 2, 3, ... (sequential numbering from top-left)
3. **row_column** (or **numeric_numeric**): positions like 1_1, 1_2, 2_1 (row_column as numbers)

For example, if your data uses sequential numbering:

```r
# Example with numeric positions (1, 2, 3, etc.)
data_numeric <- data.frame(
  position = 1:96,  # Sequential numbers 1-96
  Value = rnorm(96, mean = 1, sd = 0.5)
)

plate_plot(
  data = data_numeric,
  position = position,
  value = Value,
  plate_size = 96,
  position_format = "number"  # Specify the position format
)
```

Or if your data uses row_column format:

```r
# Example with row_column positions (1_1, 1_2, etc.)
# Generate row_column positions for a 96-well plate (8 rows, 12 columns)
row_col_positions <- c()
for(r in 1:8) {
  for(c in 1:12) {
    row_col_positions <- c(row_col_positions, paste0(r, "_", c))
  }
}

data_row_col <- data.frame(
  position = row_col_positions,
  Value = rnorm(96, mean = 1, sd = 0.5)
)

plate_plot(
  data = data_row_col,
  position = position,
  value = Value,
  plate_size = 96,
  position_format = "row_column"  # Specify the position format
)
```

### Creating Plate Maps

The `create_plate_map()` function allows you to generate empty plate templates with well positions in any of the supported formats. This is useful for experiment planning and setting up data collection templates.

```r
# Create a standard 96-well plate map with letter-number positions
plate_map_96 <- create_plate_map(plate_size = 96)
head(plate_map_96)
#>   position
#> 1       A1
#> 2       A2
#> 3       A3
#> 4       A4
#> 5       A5
#> 6       A6

# Create a 24-well plate map with numeric positions
plate_map_24_num <- create_plate_map(
  plate_size = 24, 
  position_format = "number"
)
head(plate_map_24_num)
#>   position
#> 1        1
#> 2        2
#> 3        3
#> 4        4
#> 5        5
#> 6        6

# Create a 6-well plate with row_column positions
plate_map_6_rc <- create_plate_map(
  plate_size = 6, 
  position_format = "row_column"
)
plate_map_6_rc
#>   position
#> 1      1_1
#> 2      1_2
#> 3      1_3
#> 4      2_1
#> 5      2_2
#> 6      2_3

# Create a partial plate map starting from position C3
plate_map_subset <- create_plate_map(
  plate_size = 24, 
  start_position = "C3",
  include_all = FALSE
)
head(plate_map_subset)
#>   position
#> 1       C3
#> 2       C4
#> 3       C5
#> 4       C6
#> 5       D3
#> 6       D4
```

The generated plate maps can be used:
- As templates for data collection
- To create experiment layouts and pipetting schemes
- As inputs for the `plate_plot()` function when combined with your experimental data

You can use this example data frame to create a 96-well plate layout plot using the `plate_plot()` function and setting the `plate_size` argument to `96`. There are currently two options for the plate well type. These can be either `"round"` or `"square"`. In the plot below we specify `"round"`, while `"square"` is the default value when the `plate_type` argument is not provided.

The data frame is provided to the `data` argument and the column name of the column containing the well positions is provided to the `position` argument. The column name of the column containing the values is provided to the `value` argument.

_Note: For an R markdown file set the chunk options to `dpi=300` for an optimal result._

```r
# Create a 96-well plot with round wells
plate_plot(
  data = data_continuous_96,
  position = well,
  value = Value,
  plate_size = 96,
  plate_type = "round"
)
```

It is also possible to label each well in the plate with a corresponding label. For the plate above it would be interesting to display the exact value on each of the wells in addition to the colouring. For that we use the `label` argument which takes the name of the column containing the label as an input. In this example case this column is the same that is also provided to the `value` argument.

```r
# Create a 96-well plot with labels
plate_plot(
  data = data_continuous_96,
  position = well,
  value = Value,
  label = Value,
  plate_size = 96,
  plate_type = "round"
)
```

Try providing the `well` column to the `label` argument instead of the `Value` column. This will label each will with its position, which might make it easier to find specific positions.

```r
# Create a 96-well plot with labels
plate_plot(
  data = data_continuous_96,
  position = well,
  value = Value,
  label = well,
  plate_size = 96,
  plate_type = "round"
)
```

### Legend Limit Adjustment

The legend for continuous values will only cover a range from the minimal measured to the maximal measured value. If the theoretically expected range of values is however bigger than the measured range you can adjust the legend limits. This can be done using the `limits` arguments. You provide a vector with the new minimum and maximum to the argument. Use NA to refer to the existing minimum or maximum if you only want to adjust one. Below we show this for an example dataset of a 384-well plate. 

```r
# Load a dataset of continuous values for a 384-well plate
data(data_continuous_384)

# Check the structure of the dataset
str(data_continuous_384)

# Create a 384-well plot with adjusted legend limits
plate_plot(
  data = data_continuous_384,
  position = well,
  value = Value,
  plate_size = 384,
  limits = c(0, 4)
)
```

If your new range will be smaller than the measured range, values outside of the range are coloured gray.

```r
# Create a 384-well plot with adjusted legend limits and outliers
plate_plot(
  data = data_continuous_384,
  position = well,
  value = Value,
  plate_size = 384,
  limits = c(0, 3)
)
```

### Gradient Colour Adjustment

When plotting continuous variables it is possible to to change the gradient colours by providing new colours to the `colour` argument. The colours will be used to create a new colour gradient for the plot. 

```r
# Create a 384-well plot with a new colour gradient
plate_plot(
  data = data_continuous_384,
  position = well,
  value = Value,
  plate_size = 384,
  colour = c(
    "#000004FF",
    "#51127CFF",
    "#B63679FF",
    "#FB8861FF",
    "#FCFDBFFF"
  )
)
```

### Incomplete datasets

If you have a dataset that does not contain a value for each well, empty wells will be uncoloured. Empty wells can either contain `NA` as their `value` argument or they can be completely omitted from the input data frame.

```r
# Load a continuous of discrete values for a 48-well plate
data(data_continuous_48_incomplete)

# Check the structure of the dataset
str(data_continuous_48_incomplete)

# Create a 48-well plot with adjusted legend limits
plate_plot(
  data = data_continuous_48_incomplete,
  position = well,
  value = Value,
  plate_type = "round",
  plate_size = 48
)
```

### Faceted Multi-Plate Display

The `multi_plate_plot()` function allows you to create faceted displays of multiple plates, making it easy to compare different conditions, time points, or replicates side by side.

```r
library(dplyr)

# Create a dataset with multiple conditions
data(data_continuous_96)

# Create a multi-condition dataset
conditions <- c("Control", "Treatment A", "Treatment B")
multi_condition_data <- lapply(conditions, function(condition) {
  data_continuous_96 %>%
    mutate(
      Condition = condition,
      # Add some variation between conditions
      Value = Value * case_when(
        condition == "Control" ~ 1,
        condition == "Treatment A" ~ 1.5,
        condition == "Treatment B" ~ 0.7
      )
    )
}) %>%
  bind_rows()

# Create a faceted plot with the different conditions
multi_plate_plot(
  data = multi_condition_data,
  position = well,
  value = Value,
  facet_by = Condition,  # This is the column to facet by
  plate_size = 96,
  plate_type = "round"
)
```

This creates a display with three plates side by side, each showing a different condition. You can customize the facet layout:

```r
# Create a faceted plot with custom layout and scales
multi_plate_plot(
  data = multi_condition_data,
  position = well,
  value = Value,
  facet_by = Condition,
  plate_size = 96,
  plate_type = "round",
  facet_ncol = 2,           # Arrange facets in 2 columns
  facet_scales = "free",    # Allow scales to vary between facets
  label = Value,            # Add value labels to wells
  common_legend = TRUE      # Use a single legend for all facets
)
```

The faceted display is particularly useful for:
- Comparing treatments or conditions
- Visualizing time course experiments
- Displaying multiple replicates
- Comparing different normalization methods

All options available in `plate_plot()` can be used with `multi_plate_plot()`, giving you complete flexibility in how you visualize your plate data.

## Plot Customisation

You can further customise your plot in various ways. Lets take a discrete 6-well plate dataset as an example. This dataset only contains three categories assigned to the six wells of the plate. This could be for example a pipetting scheme of an experiment.

You can change the title of the plot using the `title` argument. In addition the size of the title can be adjusted using the `title_size` argument.

_Note: Using the R markdown chunk options `out.width` and `fig.align` you can reduce the size of the figure in the R markdown document and align it for example to the center._

```r
# Load a dataset of discrete values for a 6-well plate
data(data_discrete_6)

# Check the structure of the dataset
str(data_discrete_6)

# Create a 6-well plot with new title
plate_plot(
  data = data_discrete_6,
  position = well,
  value = Condition,
  plate_size = 6,
  plate_type = "round",
  title = "Drug Treatment",
  title_size = 23
)
```

In addition it is possible to change the colours of the plot by providing new colours to the `colour` argument. As mentioned earlier this does not only work for discrete values but also for gradients that will be created based on the provided colours.

```r
# Create a 6-well plot
plate_plot(
  data = data_discrete_6,
  position = well,
  value = Condition,
  plate_size = 6,
  plate_type = "round",
  title = "Drug Treatment",
  title_size = 23,
  colour = c("#3a1c71", "#d76d77", "#ffaf7b")
)
```

Also for this plot we can provide a column name to the `label` argument to directly label the wells in the plot. At the same time we can disable the legend setting the `show_legend` argument to `FALSE`. In this case the labels for each well are too large and we should also resize the label so that it fits perfectly into each well using the `label_size` argument.

```r
# Create a 6-well plot
plate_plot(
  data = data_discrete_6,
  position = well,
  value = Condition,
  label = Condition,
  plate_size = 6,
  plate_type = "round",
  title = "Drug Treatment",
  title_size = 23,
  colour = c("#3a1c71", "#d76d77", "#ffaf7b"),
  show_legend = FALSE,
  label_size = 4
)
```

### Plate Data Import and Export

ggplateplus provides functions for importing and exporting plate layout data in various formats, making it compatible with data generated by different lab equipment and software systems.

#### Importing Plate Data

The `import_plate_layout()` function can read data from CSV, TSV, and Excel files with flexible position format handling:

```r
# Basic import from CSV with automatic detection
plate_data <- import_plate_layout("path/to/data.csv")

# Import with explicit columns
plate_data <- import_plate_layout(
  "path/to/data.csv", 
  value_column = "signal_intensity",
  position_column = "well_id"
)

# Import from Excel with specific sheet
plate_data <- import_plate_layout(
  "path/to/experiment.xlsx", 
  sheet = "Day1"
)
```

The function supports data with separate row and column fields (common in lab-generated files):

```r
# Import with separate row and column fields (e.g., from lab equipment)
# Example: data with 'plate_row' (A, B, C...) and 'plate_column' (1, 2, 3...) columns
plate_data <- import_plate_layout(
  "path/to/lab_data.csv",
  row_column = c("plate_row", "plate_column"),
  row_is_numeric = FALSE  # rows are letters in this example
)

# Example: data with numeric rows (1, 2, 3...) and columns (1, 2, 3...)
plate_data <- import_plate_layout(
  "path/to/robot_data.csv",
  row_column = c("row", "column"),
  row_is_numeric = TRUE  # rows are numbers in this example
)
```

It also handles multi-plate datasets:

```r
# Import data with multiple plates
multi_plate_data <- import_plate_layout(
  "path/to/experiment_series.csv",
  plate_column = "plate_id"
)
```

You can convert between position formats during import:

```r
# Import data with letter-number positions (A1, B2...) but convert to numeric
numeric_data <- import_plate_layout(
  "path/to/standard_data.csv",
  position_format = "number"  # Convert to sequential numbers
)

# Import data with numeric positions but convert to row_column
rc_data <- import_plate_layout(
  "path/to/numeric_data.csv",
  position_format = "row_column"  # Convert to row_column format (1_1, 1_2...)
)
```

#### Exporting Plate Data

The `export_plate_layout()` function allows you to save plate data to various file formats:

```r
# Basic export to CSV
export_plate_layout(plate_data, "output_data.csv")

# Export to Excel
export_plate_layout(plate_data, "output_data.xlsx")

# Export with position splitting (creates separate row/column fields)
export_plate_layout(
  plate_data, 
  "output_for_robot.csv", 
  split_position = TRUE
)

# Export with specific column names
export_plate_layout(
  plate_data, 
  "custom_output.csv",
  position_column = "well_position",
  value_column = "measurement"
)
```

This import/export functionality makes ggplateplus compatible with data from various sources, including:
- Laboratory information management systems (LIMS)
- Plate readers and liquid handling robots
- Custom laboratory software
- Manual data collection templates

## Potential Issues

In order to have the same proportions independent on the output screen and size, each plate plot is scaled according to the specific graphics device size. In order to see the currently used graphics device size and scaling factor the `silent` argument of the function can be set to `FALSE`. 

As you can see for the bellow example the graphics device size is `width: 7 height: 4` and the scaling factor is `1.256`. 

```r
# Load a dataset of discrete values for a 24-well plate
data(data_discrete_24)

# Check the structure of the dataset
str(data_discrete_24)

# Create a 24-well plot
plate_plot(
  data = data_discrete_24,
  position = well,
  value = Condition,
  plate_size = 24,
  plate_type = "round",
  silent = FALSE
)
```

It is possible that the generated plot has overlapping or too spaced out wells. This can be corrected by resizing the output graphics device size until the plot has the desired proportions. If a specific output size is required and the plot does not have the desired proportions you can use the `scale` argument to adjust it as shown below. 

_Note: If you run the package directly in the command line, the function opens a new graphics device since it is not already opened like it would be the case in RStudio. If this is not desired you can avoid this by setting the `scale` argument._

```r
# Create a 24-well plot
plate_plot(
  data = data_discrete_24,
  position = well,
  value = Condition,
  plate_size = 24,
  plate_type = "round",
  silent = FALSE,
  scale = 1.45
)
```

As you can see, however, now we are running into the problem that the legend is larger than the screen size. With the `legend_n_row` argument you can manually determine the number of rows that should be used for the legend. In this case it is ideal to split the legend into 2 columns by setting `legend_n_row` to 6 rows. In addition we should adjust the `scale` parameter to `1.2` in order to space out wells properly.

```r
# Create a 24-well plot with 2 row legend
plate_plot(
  data = data_discrete_24,
  position = well,
  value = Condition,
  plate_size = 24,
  plate_type = "round",
  silent = FALSE,
  scale = 1.2,
  legend_n_row = 6
)
```

If your dataset has a lot of labels it can become difficult to impossible to distinguish them just by colour as you can see for the dataset below.

```r
# Load a dataset of discrete values for a 96-well plate
data(data_discrete_96)

# Check the structure of the dataset
str(data_discrete_96)

# Create a 96-well plot
plate_plot(
  data = data_discrete_96,
  position = well,
  value = Compound,
  plate_size = 96,
  scale = 0.95,
  plate_type = "round"
)
```

This is an example where it is likely better to directly label wells instead of displaying a legend. 

```r
# Create a 96-well plot with labels
plate_plot(
  data = data_discrete_96,
  position = well,
  value = Compound,
  label = Compound_multiline, # using a column that contains line brakes for labeling
  plate_size = 96,
  show_legend = FALSE, # hiding legend
  label_size = 1.1, # setting label size
  plate_type = "round"
)
```

## Figure Export

Since the plot function checks the size of the graphics device in order to apply the appropriate scaling to the plot, it is important to first generate an output graphics device with the correct size. There are several functions that can accomplish this. These include e.g. `png()`, `pdf()`, `svg()` and many more.

```r
# Generate a new graphics device with a defined size
png("plate_plot_384_well_plate.png", width = 10, height = 6, unit = "in", res = 300)

# Create a plot
plate_plot(
  data = data_continuous_384,
  position = well,
  value = Value,
  label = Value,
  plate_size = 384,
  colour = c(
    "#000004FF",
    "#51127CFF",
    "#B63679FF",
    "#FB8861FF",
    "#FCFDBFFF"
  )
)

# Close graphics device
dev.off()
```

