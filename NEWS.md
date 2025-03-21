# ggplateplus 0.1.0

* Initial release as a fork of ggplate 0.1.5
* Added support for alternative well position naming schemes through the new `position_format` parameter:
  - "letter_number" (default): positions like A1, B2, C3 (row = letter, column = number)
  - "number" (or "numeric"): positions like 1, 2, 3, ... (sequential numbering from top-left)
  - "row_column" (or "numeric_numeric"): positions like 1_1, 1_2, 2_1 (row_column as numbers)
* Added new `create_plate_map()` function to generate plate layout templates with:
  - Support for all plate sizes (6 to 1536 wells)
  - All position formats (letter-number, numeric, row-column)
  - Custom starting positions
  - Options to include all wells or a subset
* Added new `multi_plate_plot()` function for faceted plate visualizations:
  - Side-by-side comparison of different conditions, timepoints, or replicates
  - Customizable facet layout with options for columns and scales
  - Flexible labeling and legend options
  - Full compatibility with all plate_plot features
* Added new plate import/export functionality:
  - `import_plate_layout()`: Read plate data from CSV, TSV, and Excel files
  - Support for separate row and column fields (common in lab data output)
  - Automatic format detection and column identification
  - Position format conversion during import
  - Multi-plate dataset handling
  - `export_plate_layout()`: Write plate data to various file formats
  - Optional position splitting for compatibility with lab equipment
* Comprehensive documentation update with examples for all new features
* Additional unit tests for the new functionality

# Original ggplate Features

This package is based on ggplate 0.1.5, which includes:

* Support for plates from 6-well to 1536-well formats
* Visualization of both continuous and discrete values
* Custom color schemes
* Well labels
* And more
