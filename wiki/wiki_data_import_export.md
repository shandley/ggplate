# Data Import/Export

ggplateplus provides flexible tools for importing and exporting plate layout data in various formats. This page covers the key functions and their usage for data handling.

## Import Plate Layouts

The `import_plate_layout()` function allows you to import plate data from various file formats.

### Supported File Formats

- **CSV**: Comma-separated values
- **TSV**: Tab-separated values 
- **Excel**: .xls and .xlsx files

### Supported Layout Types

1. **Long Format**: One row per well with columns for position and values
   ```
   well,Value,Condition
   A1,1.2,Sample
   A2,0.8,Control
   ```

2. **Wide Format**: Matrix-like layout with rows representing plate rows and columns representing plate columns
   ```
      1    2    3
   A  1.2  0.8  1.5
   B  0.9  1.1  0.7
   ```

### Basic Usage

```r
# Import from CSV (long format)
plate_data <- import_plate_layout("plate_layout.csv")

# Import from Excel
plate_data_excel <- import_plate_layout("plate_layout.xlsx")

# Import wide format with specific plate size
plate_data_wide <- import_plate_layout(
  "plate_layout_wide.csv", 
  plate_size = 96, 
  position_format = "letter_number"
)

# Import with a different position format for output
plate_data_numeric <- import_plate_layout(
  "plate_layout.csv",
  position_format = "numeric"
)
```

### Key Parameters

- `file_path`: Path to the file
- `position_format`: Target position format ("letter_number", "numeric", "row_column")
- `plate_size`: Size of the plate (6, 12, 24, 48, 96, 384, 1536)
- `header`: Whether the file has a header row
- `sheet`: For Excel files, which sheet to import

### Format Detection

The function automatically detects:
- File format based on extension
- Layout type (long vs. wide)
- Position format

## Export Plate Layouts

The `export_plate_layout()` function allows you to export plate data to various file formats.

### Basic Usage

```r
# Load example dataset
data(plate_layout_96)

# Export to CSV in long format (default)
export_plate_layout(plate_layout_96, "plate_export_long.csv")

# Export to CSV in wide format
export_plate_layout(
  plate_layout_96, 
  "plate_export_wide.csv", 
  layout = "wide"
)

# Export only specific columns
export_plate_layout(
  plate_layout_96 %>% select(well, Condition), 
  "plate_conditions.csv",
  position = "well",
  value = "Condition"
)

# Export with different position format
export_plate_layout(
  plate_layout_96, 
  "plate_numeric_positions.csv",
  position_format = "numeric"
)
```

### Key Parameters

- `data`: Data frame containing plate data
- `file_path`: Path for the output file
- `position`: Column name containing well positions
- `value`: Column name containing values to export
- `layout`: "long" or "wide" format
- `position_format`: Position format to use in the export

## Tips for Data Management

- **Standardize Early**: Convert position formats early in your workflow
- **Long Format**: Prefer long format for most analyses and visualizations
- **Metadata**: Include sample metadata in your plate layout files
- **Validation**: Visualize imported data to ensure correct import
- **Common Format**: Establish a common format for your lab or project

## Related Functions

- `standardize_position_format()`: Convert between position formats
- `plate_plot()`: Visualize plate data
- `create_plate_map()`: Generate empty plate layouts