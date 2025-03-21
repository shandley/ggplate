test_that("plate import/export functions work", {
  # Skip if example file doesn't exist
  test_file <- "/Users/scott/gdrive/code/R/ggplateplus/2025-03-11_sequencing_plan.csv"
  skip_if_not(file.exists(test_file), "Test file not available")
  
  # Test import with separate row/column fields
  imported_data <- import_plate_layout(
    test_file,
    plate_size = 96,
    row_column = c("plate_row", "plate_column"),
    value_column = "sample_id"
  )
  
  # Basic checks
  expect_s3_class(imported_data, "data.frame")
  expect_true(all(c("position", "value") %in% names(imported_data)))
  expect_gt(nrow(imported_data), 0)
})