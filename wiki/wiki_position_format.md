# Position Format Handling

ggplateplus provides flexible support for different well position naming conventions, making it compatible with various lab instruments and data formats.

## Supported Position Formats

The package supports three different well position formats:

### 1. Letter-Number Format (`letter_number`)

This is the traditional and most common format used in laboratories:
- Format: `A1`, `B2`, `C3`, etc.
- Rows are designated by letters (A, B, C...)
- Columns are designated by numbers (1, 2, 3...)
- Examples: `A1`, `B12`, `H6`

This is the default format in ggplateplus and is compatible with most laboratory equipment and software.

### 2. Numeric Format (`numeric`)

Sequential numbering of wells from 1 to the total number of wells:
- Format: `1`, `2`, `3`, etc.
- Wells are numbered sequentially, typically starting from the top left
- Often used in some automated systems and data exports
- Examples: `1`, `24`, `96`

This format is common in certain laboratory automation systems and high-throughput screening equipment.

### 3. Row-Column Format (`row_column`)

Position described by numeric row and column indices:
- Format: `1_1`, `2_3`, `8_12`, etc.
- Rows are numbered (1, 2, 3...)
- Columns are numbered (1, 2, 3...)
- Connected by an underscore
- Examples: `1_1` (top-left), `8_12` (bottom-right in a 96-well plate)

This format is sometimes used in computational tools and certain data analysis pipelines.

## Converting Between Formats

ggplateplus provides a convenient function for converting between position formats:

```r
# Load the package
library(ggplateplus)

# Example data with letter-number format
data(plate_layout_96)  # Contains positions like A1, B2, etc.

# Convert to numeric format
numeric_wells <- standardize_position_format(
  plate_layout_96,
  position_col = "well", 
  target_format = "numeric"
)

# Convert to row_column format
rowcol_wells <- standardize_position_format(
  plate_layout_96,
  position_col = "well", 
  target_format = "row_column"
)
```

## Working with Different Formats in Plots

When creating visualizations, you can specify the format of your input data:

```r
# Example with numeric positions
data(data_numeric_position_96)

plate_plot(
  data = data_numeric_position_96,
  position = well,
  value = Value,
  position_format = "numeric",  # Specify the format
  plate_size = 96
)
```

## Best Practices

- **Consistent Format**: Use a consistent position format throughout your analysis workflow
- **Format Documentation**: When sharing data, document which position format is used
- **Conversion**: Convert to your preferred format early in the analysis pipeline
- **Validation**: After conversion, validate that positions are correct by visualizing the data

## Related Functions

- `standardize_position_format()`: Convert between position formats
- `plate_plot()`: Create plate visualizations with position format specification
- `import_plate_layout()`: Import plate data with automatic or specified format detection