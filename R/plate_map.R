#' Create a Plate Map Template
#'
#' Generates an empty plate map with well positions in the specified format.
#' Useful for setting up experiments or generating templates for data collection.
#'
#' @param plate_size a numeric value that specifies the plate size (number of wells).
#'   Possible values are: 6, 12, 24, 48, 96, 384 and 1536.
#' @param start_position a character value that specifies the starting position for well
#'   numbering. Default is "A1" (top-left corner). Other options could be "A12" (top-right),
#'   "H1" (bottom-left), or "H12" (bottom-right) for a 96-well plate. Must be in
#'   letter_number format.
#' @param position_format a character string specifying the format of position values in the
#'   returned data frame. Options include:
#'   - "letter_number" (default): positions like A1, B2, C3 (row = letter, column = number)
#'   - "number" (or "numeric"): positions like 1, 2, 3, ... (sequential numbering)
#'   - "row_column" (or "numeric_numeric"): positions like 1_1, 1_2, 2_1 (row_column as numbers)
#' @param include_all a logical value that specifies whether to include all wells in the plate (TRUE)
#'   or only a subset (FALSE) when using non-default start positions.
#'
#' @return A data frame with well positions in the specified format.
#'
#' @importFrom stringr str_extract
#' @export
#'
#' @examples
#' # Create a 96-well plate map with default settings
#' plate_map_96 <- create_plate_map(96)
#'
#' # Create a 24-well plate map with numeric positions
#' plate_map_24_numeric <- create_plate_map(24, position_format = "number")
#'
#' # Create a 6-well plate map with row_column positions
#' plate_map_6_rc <- create_plate_map(6, position_format = "row_column")
#'
#' # Create a 96-well plate map starting from the top-right position (A12)
#' plate_map_96_topright <- create_plate_map(96, start_position = "A12")
#'
create_plate_map <- function(plate_size,
                            start_position = "A1",
                            position_format = "letter_number",
                            include_all = TRUE) {
  
  # Validate plate_size
  valid_plate_sizes <- c(6, 12, 24, 48, 96, 384, 1536)
  if (!plate_size %in% valid_plate_sizes) {
    stop("Selected plate_size not available! Valid options are: ",
         paste(valid_plate_sizes, collapse = ", "))
  }
  
  # Validate position_format
  valid_formats <- c("letter_number", "number", "numeric", "row_column", "numeric_numeric")
  if (!position_format %in% valid_formats) {
    stop("Invalid position_format. Valid options are: ", paste(valid_formats, collapse = ", "))
  }
  
  # Get plate dimensions
  dimensions <- get_plate_dimensions(plate_size)
  n_rows <- dimensions$rows
  n_cols <- dimensions$cols
  
  # Define row and column names
  MORELETTERS <- c(LETTERS, "AA", "AB", "AC", "AD", "AE", "AF")
  row_names <- MORELETTERS[1:n_rows]
  col_names <- 1:n_cols
  
  # Parse start position (should be in letter_number format)
  start_row_letter <- stringr::str_extract(start_position, pattern = "[:upper:]+")
  start_col_num <- as.numeric(stringr::str_extract(start_position, pattern = "\\d+"))
  
  # Validate start position
  if (is.na(start_row_letter) || is.na(start_col_num) || 
      !start_row_letter %in% row_names || start_col_num < 1 || start_col_num > n_cols) {
    stop("Invalid start_position. Must be in letter_number format and within plate bounds.")
  }
  
  # Create all possible well positions in letter_number format
  wells_letter_number <- expand.grid(row = row_names, col = col_names, stringsAsFactors = FALSE) |>
    dplyr::arrange(row, col) |>
    dplyr::mutate(well = paste0(row, col))
  
  # Determine if we need special ordering based on start_position
  if (start_position != "A1") {
    # Get the row and col index of start position
    start_row_idx <- match(start_row_letter, row_names)
    
    # Reorder based on start position
    if (start_col_num != 1) {
      # Handle horizontal direction
      wells_letter_number <- wells_letter_number |>
        dplyr::mutate(col_grp = ifelse(col >= start_col_num, 0, 1))
      
      if (include_all) {
        wells_letter_number <- wells_letter_number |>
          dplyr::arrange(col_grp, row, col)
      } else {
        wells_letter_number <- wells_letter_number |>
          dplyr::filter(col_grp == 0) |>
          dplyr::arrange(row, col)
      }
    }
    
    if (start_row_idx != 1) {
      # Handle vertical direction
      wells_letter_number <- wells_letter_number |>
        dplyr::mutate(row_grp = ifelse(match(row, row_names) >= start_row_idx, 0, 1))
      
      if (include_all) {
        wells_letter_number <- wells_letter_number |>
          dplyr::arrange(row_grp, row, col)
      } else {
        wells_letter_number <- wells_letter_number |>
          dplyr::filter(row_grp == 0) |>
          dplyr::arrange(row, col)
      }
    }
  }
  
  # Create a clean data frame with just the wells
  wells_letter_number <- wells_letter_number |>
    dplyr::select(well) |>
    dplyr::rename(position = well)
  
  # Create output in the requested format
  if (position_format == "letter_number") {
    # Already in letter_number format
    return(wells_letter_number)
  } else if (position_format %in% c("number", "numeric")) {
    # Sequential numbering (1, 2, 3, ...)
    wells_letter_number |>
      dplyr::mutate(position_num = seq_len(nrow(wells_letter_number))) |>
      dplyr::select(position = position_num)
  } else if (position_format %in% c("row_column", "numeric_numeric")) {
    # Row_column format (1_1, 1_2, etc.)
    wells_letter_number |>
      dplyr::mutate(
        row_letter = stringr::str_extract(position, pattern = "[:upper:]+"),
        col_num = as.numeric(stringr::str_extract(position, pattern = "\\d+")),
        row_num = match(row_letter, row_names),
        position_rc = paste0(row_num, "_", col_num)
      ) |>
      dplyr::select(position = position_rc)
  }
}

#' Get Plate Dimensions
#'
#' Helper function to get the number of rows and columns for a given plate size.
#' 
#' @param plate_size a numeric value that specifies the plate size (number of wells).
#'   Possible values are: 6, 12, 24, 48, 96, 384 and 1536.
#'
#' @return A list with rows and cols elements.
#' 
#' @keywords internal
get_plate_dimensions <- function(plate_size) {
  if (plate_size == 6) {
    return(list(rows = 2, cols = 3))
  } else if (plate_size == 12) {
    return(list(rows = 3, cols = 4))
  } else if (plate_size == 24) {
    return(list(rows = 4, cols = 6))
  } else if (plate_size == 48) {
    return(list(rows = 6, cols = 8))
  } else if (plate_size == 96) {
    return(list(rows = 8, cols = 12))
  } else if (plate_size == 384) {
    return(list(rows = 16, cols = 24))
  } else if (plate_size == 1536) {
    return(list(rows = 32, cols = 48))
  } else {
    stop("Selected plate_size not available!")
  }
}