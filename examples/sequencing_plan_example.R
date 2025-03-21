# Example of using ggplateplus with a real-world sequencing plan dataset
# This example demonstrates the flexible data import functionality

library(ggplateplus)
library(dplyr)

# Import the sequencing plan data using separate row/column fields
sequencing_data <- import_plate_layout(
  "2025-03-11_sequencing_plan.csv",
  plate_size = 96,
  row_column = c("plate_row", "plate_column"),  # Specify separate row/column fields
  value_column = "sample_type",                # Use sample_type as the value to visualize
  plate_column = "plate"                       # Support multi-plate data
)

# Create a plot for the first plate only
plate1_data <- sequencing_data %>% 
  filter(plate == 1)

# Create a standard plate plot
p1 <- plate_plot(
  data = plate1_data,
  position = position,
  value = value,
  plate_size = 96,
  plate_type = "round",
  title = "Sequencing Plan - Plate 1"
)
print(p1)

# Create a multi-plate visualization
p_multi <- multi_plate_plot(
  data = sequencing_data,
  position = position,
  value = value,
  facet_by = plate,
  facet_ncol = 2,
  plate_size = 96,
  plate_type = "round",
  title = "Sequencing Plan - All Plates"
)
print(p_multi)

# Example of exporting the data in different formats
# Export as standard CSV
export_plate_layout(
  sequencing_data,
  "sequencing_data_exported.csv"
)

# Export with separate row/column fields (for lab equipment compatibility)
export_plate_layout(
  plate1_data,
  "sequencing_data_plate1_for_robot.csv",
  split_position = TRUE
)