library(dplyr)

# Create test data
create_test_data <- function() {
  data("data_continuous_96")
  
  # Create a dataset with multiple conditions
  conditions <- c("Control", "Treatment A", "Treatment B")
  multi_condition_data <- lapply(conditions, function(condition) {
    data_continuous_96 %>%
      dplyr::mutate(
        Condition = condition,
        # Add some variation between conditions
        Value = Value * dplyr::case_when(
          condition == "Control" ~ 1,
          condition == "Treatment A" ~ 1.5,
          condition == "Treatment B" ~ 0.7
        )
      )
  }) %>%
    dplyr::bind_rows()
  
  return(multi_condition_data)
}

test_that("multi_plate_plot basic functionality works", {
  # Skip if we're not in an interactive session
  skip_if(!interactive())
  
  # Create test data
  multi_condition_data <- create_test_data()
  
  # Test basic functionality
  p <- multi_plate_plot(
    data = multi_condition_data,
    position = well,
    value = Value,
    facet_by = Condition,
    plate_size = 96
  )
  
  # Check that the plot is a ggplot object
  expect_s3_class(p, "ggplot")
  
  # Check that it has facets
  expect_true("facet" %in% names(p$facet))
  
  # Should have 3 facets (one for each condition)
  facet_data <- ggplot2::ggplot_build(p)$layout$facet$params$facets
  expect_equal(length(facet_data), 1) # One faceting variable
})

test_that("multi_plate_plot works with different position formats", {
  # Skip if we're not in an interactive session
  skip_if(!interactive())
  
  # Create test data with numeric positions
  multi_condition_data <- create_test_data() %>%
    dplyr::mutate(position_num = as.numeric(row_number()))
  
  # Test with numeric positions
  p_num <- multi_plate_plot(
    data = multi_condition_data,
    position = position_num,
    value = Value,
    facet_by = Condition,
    plate_size = 96,
    position_format = "numeric"
  )
  
  expect_s3_class(p_num, "ggplot")
})

test_that("multi_plate_plot validates input correctly", {
  # Test missing arguments
  expect_error(multi_plate_plot(), "data argument is required")
  
  multi_condition_data <- create_test_data()
  
  # Test missing position
  expect_error(
    multi_plate_plot(
      data = multi_condition_data,
      value = Value,
      facet_by = Condition
    ),
    "position argument is required"
  )
  
  # Test missing value
  expect_error(
    multi_plate_plot(
      data = multi_condition_data,
      position = well,
      facet_by = Condition
    ),
    "value argument is required"
  )
  
  # Test missing facet_by
  expect_error(
    multi_plate_plot(
      data = multi_condition_data,
      position = well,
      value = Value
    ),
    "facet_by argument is required"
  )
  
  # Test invalid facet_scales
  expect_error(
    multi_plate_plot(
      data = multi_condition_data,
      position = well,
      value = Value,
      facet_by = Condition,
      facet_scales = "invalid"
    ),
    "facet_scales must be one of: "
  )
  
  # Test non-existent facet_by variable
  expect_error(
    multi_plate_plot(
      data = multi_condition_data,
      position = well,
      value = Value,
      facet_by = NonExistentVariable
    ),
    "facet_by variable 'NonExistentVariable' not found in data"
  )
})

test_that("multi_plate_plot works with custom faceting options", {
  # Skip if we're not in an interactive session
  skip_if(!interactive())
  
  multi_condition_data <- create_test_data()
  
  # Test custom ncol
  p_ncol <- multi_plate_plot(
    data = multi_condition_data,
    position = well,
    value = Value,
    facet_by = Condition,
    plate_size = 96,
    facet_ncol = 2
  )
  
  expect_s3_class(p_ncol, "ggplot")
  expect_equal(p_ncol$facet$params$ncol, 2)
  
  # Test free scales
  p_free <- multi_plate_plot(
    data = multi_condition_data,
    position = well,
    value = Value,
    facet_by = Condition,
    plate_size = 96,
    facet_scales = "free"
  )
  
  expect_s3_class(p_free, "ggplot")
  expect_equal(p_free$facet$params$free$x, TRUE)
  expect_equal(p_free$facet$params$free$y, TRUE)
})

test_that("multi_plate_plot works with labels", {
  # Skip if we're not in an interactive session
  skip_if(!interactive())
  
  multi_condition_data <- create_test_data()
  
  # Test with labels
  p_label <- multi_plate_plot(
    data = multi_condition_data,
    position = well,
    value = Value,
    facet_by = Condition,
    plate_size = 96,
    label = Value
  )
  
  expect_s3_class(p_label, "ggplot")
  
  # Test non-existent label
  expect_warning(
    multi_plate_plot(
      data = multi_condition_data,
      position = well,
      value = Value,
      facet_by = Condition,
      plate_size = 96,
      label = NonExistentLabel
    ),
    "label variable 'NonExistentLabel' not found in data"
  )
})