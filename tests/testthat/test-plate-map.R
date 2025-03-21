library(dplyr)

test_that("create_plate_map basic functionality works", {
  # Test 96-well plate with default settings
  plate_map_96 <- create_plate_map(96)
  
  # Should return a dataframe with correct number of wells
  expect_s3_class(plate_map_96, "data.frame")
  expect_equal(nrow(plate_map_96), 96)
  expect_equal(names(plate_map_96), "position")
  
  # First position should be A1
  expect_equal(plate_map_96$position[1], "A1")
  
  # Last position for 96-well plate should be H12
  expect_equal(plate_map_96$position[96], "H12")
})

test_that("create_plate_map works with different position formats", {
  # Test numeric positions
  plate_map_24_num <- create_plate_map(24, position_format = "numeric")
  expect_equal(nrow(plate_map_24_num), 24)
  expect_equal(as.numeric(plate_map_24_num$position[1]), 1)
  expect_equal(as.numeric(plate_map_24_num$position[24]), 24)
  
  # Test row_column format
  plate_map_6_rc <- create_plate_map(6, position_format = "row_column")
  expect_equal(nrow(plate_map_6_rc), 6)
  expect_equal(plate_map_6_rc$position[1], "1_1")
  expect_equal(plate_map_6_rc$position[6], "2_3")
})

test_that("create_plate_map validates input correctly", {
  # Invalid plate size
  expect_error(create_plate_map(42))
  
  # Invalid position format
  expect_error(create_plate_map(96, position_format = "invalid"))
  
  # Invalid start position
  expect_error(create_plate_map(96, start_position = "Z99"))
})

test_that("create_plate_map works with different starting positions", {
  # Start from top-right (A12 in 96-well plate)
  plate_map_96_tr <- create_plate_map(96, start_position = "A12")
  expect_equal(plate_map_96_tr$position[1], "A12")
  
  # Start from bottom-left (H1 in 96-well plate)
  plate_map_96_bl <- create_plate_map(96, start_position = "H1")
  expect_equal(plate_map_96_bl$position[1], "H1")
})

test_that("create_plate_map include_all parameter works", {
  # Start from middle and include all
  plate_map_all <- create_plate_map(24, start_position = "C3", include_all = TRUE)
  expect_equal(nrow(plate_map_all), 24)
  expect_equal(plate_map_all$position[1], "C3")
  
  # Start from middle and exclude wells before starting position
  plate_map_subset <- create_plate_map(24, start_position = "C3", include_all = FALSE)
  expect_true(nrow(plate_map_subset) < 24)
  expect_equal(plate_map_subset$position[1], "C3")
})