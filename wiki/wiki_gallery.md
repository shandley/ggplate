# Gallery

This gallery showcases various visualizations possible with ggplateplus. Each example includes sample code to help you create similar visualizations with your own data.

## Basic Visualizations

### Continuous Data Visualization

```r
library(ggplateplus)
data(data_continuous_96)

plate_plot(
  data = data_continuous_96,
  position = well,
  value = Value,
  plate_size = 96
)
```

![Continuous Data Visualization](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/continuous_data.png)

### Discrete/Categorical Data

```r
data(data_discrete_96)

plate_plot(
  data = data_discrete_96,
  position = well,
  value = Condition,
  plate_size = 96
)
```

![Discrete Data Visualization](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/discrete_data.png)

## Enhanced Visualizations

### Custom Color Scales

```r
plate_plot(
  data = data_continuous_96,
  position = well,
  value = Value,
  plate_size = 96,
  colour = c("blue", "white", "red")  # Custom color gradient
)
```

![Custom Color Scale](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/custom_colors.png)

### Adding Labels

```r
plate_plot(
  data = data_continuous_96,
  position = well,
  value = Value,
  label = Value,  # Add value labels to wells
  plate_size = 96,
  size = 2.5,     # Text size
  label_color = "white"  # Text color
)
```

![Labeled Wells](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/labeled_wells.png)

## Annotations

### Highlighting Wells

```r
# Create basic plot
p <- plate_plot(
  data = plate_layout_96,
  position = well,
  value = Condition,
  plate_size = 96
)

# Highlight negative control wells
p <- highlight_wells(
  plot = p,
  pattern = "Negative Control",  # Regex pattern to match
  column = "Condition",
  label = "Negative Controls",
  color = "yellow"
)

# Display the highlighted plot
p
```

![Highlighted Wells](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/highlighted_wells.png)

### Region Annotations

```r
# Create a basic plot
p <- plate_plot(
  data = plate_layout_96,
  position = well,
  value = Value,
  plate_size = 96
)

# Add region annotation
p <- add_plate_annotations(
  plot = p,
  regions = list(plate_layout_96$well[plate_layout_96$col <= 3]),
  labels = "Dilution Series",
  colors = "purple",
  shapes = "rect",
  alpha = 0.2
)

# Display the annotated plot
p
```

![Region Annotation](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/region_annotation.png)

## Multi-Plate Comparisons

### Faceted by Condition

```r
data(data_multi_condition_96)

plate_plot(
  data = data_multi_condition_96,
  position = well,
  value = Value,
  plate_size = 96
) +
  ggplot2::facet_wrap(~Condition, ncol = 2)
```

![Faceted by Condition](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/faceted_condition.png)

### Faceted by Multiple Variables

```r
plate_plot(
  data = data_multi_condition_96,
  position = well,
  value = Value,
  plate_size = 96
) +
  ggplot2::facet_grid(Condition ~ Replicate)
```

![Faceted Grid](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/faceted_grid.png)

## Interactive Visualizations

### Basic Interactive Plot

```r
library(ggplateplus)
library(plotly)

data(plate_layout_96)

interactive_plate(
  data = plate_layout_96,
  position = well,
  value = Value,
  plate_size = 96,
  tooltip_vars = c("well", "Value", "Condition")
)
```

![Interactive Plot](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/interactive_basic.png)

### Interactive Multi-Plate Visualization

```r
data(data_multi_condition_96)

interactive_multi_plate(
  data = data_multi_condition_96,
  position = well,
  value = Value,
  facet_by = Condition,
  plate_size = 96
)
```

![Interactive Multi-Plate](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/interactive_multi.png)

## Different Well Position Formats

### Numeric Position Format

```r
data(data_numeric_position_96)

plate_plot(
  data = data_numeric_position_96,
  position = well,
  value = Value,
  position_format = "numeric",
  plate_size = 96
)
```

![Numeric Position Format](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/numeric_position.png)

### Row-Column Position Format

```r
data(data_row_column_position_96)

plate_plot(
  data = data_row_column_position_96,
  position = well,
  value = Value,
  position_format = "row_column",
  plate_size = 96
)
```

![Row-Column Position Format](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/row_column_position.png)

## Different Plate Sizes

### 384-Well Plate

```r
data(data_continuous_384)

plate_plot(
  data = data_continuous_384,
  position = well,
  value = Value,
  plate_size = 384
)
```

![384-Well Plate](https://raw.githubusercontent.com/wiki/shandley/ggplateplus/images/384well_plate.png)

Note: The image links are placeholders. You'll need to add actual screenshots of these visualizations to your wiki's images folder.