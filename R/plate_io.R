#' Import Plate Layout from File
#'
#' Imports plate layout data from CSV, TSV, or Excel files with flexible support for
#' different position format styles.
#'
#' @param file_path Character string specifying the path to the input file. Supports
#'   CSV, TSV, and Excel files.
#' @param plate_size A numeric value that specifies the plate size (number of wells).
#'   Possible values are: 6, 12, 24, 48, 96, 384 and 1536.
#' @param value_column Character string specifying the column name that contains the values
#'   to visualize. If NULL, will attempt to detect automatically.
#' @param position_format A character string specifying the output position format. Options include:
#'   - "letter_number" (default): positions like A1, B2, C3 (row = letter, column = number)
#'   - "number" (or "numeric"): positions like 1, 2, 3, ... (sequential numbering)
#'   - "row_column" (or "numeric_numeric"): positions like 1_1, 1_2, 2_1 (row_column as numbers)
#' @param position_column Character string specifying the column that contains position information.
#'   If NULL, will attempt to detect automatically.
#' @param row_column Character vector of length 2 specifying the column names for separate row and column
#'   fields. If provided, will combine these to create the position column. Example: c("plate_row", "plate_column")
#' @param row_is_numeric Logical indicating if row identifiers are numeric (TRUE) or letters (FALSE).
#'   Only needed when row_column is specified. Default is TRUE.
#' @param plate_column Character string specifying the column name for plate identification in 
#'   multi-plate datasets. Default is NULL (single plate data).
#' @param sheet Integer or character string specifying which sheet to read from an Excel file.
#'   Default is 1 (first sheet).
#' @param ... Additional parameters passed to the underlying read function.
#'
#' @return A data frame with standardized position and value columns, ready for use with plate_plot().
#'
#' @importFrom utils read.csv read.delim
#' @importFrom readxl read_excel
#' @importFrom stringr str_detect str_extract
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic import from CSV with automatic detection
#' plate_data <- import_plate_layout("path/to/data.csv")
#'
#' # Import from Excel with specific sheet and separate row/column fields
#' plate_data <- import_plate_layout(
#'   "path/to/data.xlsx", 
#'   sheet = "Experiment 1",
#'   row_column = c("plate_row", "plate_column")
#' )
#'
#' # Import multi-plate data
#' multi_plate_data <- import_plate_layout(
#'   "path/to/multi_plate.csv",
#'   plate_column = "plate_id"
#' )
#'
#' # Import data with numeric row identifiers (1, 2, 3, etc.)
#' plate_data <- import_plate_layout(
#'   "path/to/data.csv",
#'   row_column = c("row", "column"),
#'   row_is_numeric = TRUE
#' )
#' }
import_plate_layout <- function(file_path,
                               plate_size = 96,
                               value_column = NULL,
                               position_format = "letter_number",
                               position_column = NULL,
                               row_column = NULL,
                               row_is_numeric = TRUE,
                               plate_column = NULL,
                               sheet = 1,
                               ...) {
  
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
  
  # Determine file type and read accordingly
  file_ext <- tolower(tools::file_ext(file_path))
  
  if (file_ext == "csv") {
    data <- utils::read.csv(file_path, stringsAsFactors = FALSE, ...)
  } else if (file_ext == "tsv" || file_ext == "txt") {
    data <- utils::read.delim(file_path, stringsAsFactors = FALSE, ...)
  } else if (file_ext %in% c("xlsx", "xls")) {
    if (!requireNamespace("readxl", quietly = TRUE)) {
      stop("Package 'readxl' is required to read Excel files. Please install it with install.packages('readxl')")
    }
    data <- readxl::read_excel(file_path, sheet = sheet, ...)
    data <- as.data.frame(data)  # Convert tibble to data.frame for consistency
  } else {
    stop("Unsupported file type. Supported types are: CSV, TSV, TXT, XLSX, XLS")
  }
  
  # Get plate dimensions
  dimensions <- get_plate_dimensions(plate_size)
  n_rows <- dimensions$rows
  n_cols <- dimensions$cols
  
  # Define row and column names
  MORELETTERS <- c(LETTERS, "AA", "AB", "AC", "AD", "AE", "AF")
  row_names <- MORELETTERS[1:n_rows]
  col_names <- 1:n_cols
  
  # Process row_column parameter if provided
  if (!is.null(row_column)) {
    if (length(row_column) != 2) {
      stop("row_column must be a character vector of length 2 specifying row and column field names")
    }
    
    row_field <- row_column[1]
    col_field <- row_column[2]
    
    if (!row_field %in% names(data)) {
      stop(paste("Row field", row_field, "not found in data"))
    }
    if (!col_field %in% names(data)) {
      stop(paste("Column field", col_field, "not found in data"))
    }
    
    # Create position column based on row and column fields
    if (row_is_numeric) {
      # Row values are numeric (1, 2, 3)
      data$position <- ifelse(
        # Handle special case when column values are letters (rare but possible)
        is.character(data[[col_field]]) && any(grepl("[A-Za-z]", data[[col_field]])),
        paste0(MORELETTERS[data[[row_field]]], data[[col_field]]),
        paste0(MORELETTERS[data[[row_field]]], data[[col_field]])
      )
    } else {
      # Row values are letters (A, B, C)
      data$position <- paste0(data[[row_field]], data[[col_field]])
    }
    
    position_column <- "position"
  } else if (is.null(position_column)) {
    # Try to auto-detect position column
    possible_position_cols <- c(
      "position", "well", "well_id", "well_position", "wellposition",
      "pos", "location", "well_loc", "wellloc"
    )
    
    for (col in possible_position_cols) {
      if (col %in% names(data)) {
        position_column <- col
        break
      }
    }
    
    # Check if separate row/column fields exist
    if (is.null(position_column)) {
      row_col_pairs <- list(
        c("row", "col"), c("row", "column"), 
        c("plate_row", "plate_column"), 
        c("plate_row", "plate_col"),
        c("row_id", "column_id"),
        c("row_num", "col_num")
      )
      
      for (pair in row_col_pairs) {
        if (all(pair %in% names(data))) {
          # Determine if row values are letters or numbers
          row_field <- pair[1]
          col_field <- pair[2]
          
          sample_row <- data[[row_field]][1]
          row_is_letter <- is.character(sample_row) && grepl("[A-Za-z]", sample_row)
          
          if (row_is_letter) {
            # Row values are letters (A, B, C)
            data$position <- paste0(data[[row_field]], data[[col_field]])
          } else {
            # Row values are numeric (1, 2, 3)
            data$position <- paste0(MORELETTERS[as.numeric(data[[row_field]])], data[[col_field]])
          }
          
          position_column <- "position"
          break
        }
      }
    }
    
    if (is.null(position_column)) {
      stop("Could not automatically detect position column. Please specify position_column or row_column parameters.")
    }
  }
  
  # Try to detect value column if not specified
  if (is.null(value_column)) {
    # Common value column names
    possible_value_cols <- c(
      "value", "values", "intensity", "signal", "measurement", 
      "reading", "result", "response", "od", "concentration"
    )
    
    for (col in possible_value_cols) {
      if (tolower(col) %in% tolower(names(data))) {
        value_column <- names(data)[tolower(names(data)) == tolower(col)][1]
        break
      }
    }
    
    # If still not found, use the first numeric column that's not a position component
    if (is.null(value_column)) {
      # Get all numeric columns
      numeric_cols <- names(data)[sapply(data, is.numeric)]
      
      # Filter out columns that might be row or column identifiers
      position_related <- c(
        position_column, 
        if (!is.null(row_column)) row_column else NULL,
        "row", "col", "column", "plate_row", "plate_column", "row_id", "column_id"
      )
      
      candidate_cols <- setdiff(numeric_cols, position_related)
      
      if (length(candidate_cols) > 0) {
        value_column <- candidate_cols[1]
      } else {
        stop("Could not automatically detect value column. Please specify value_column parameter.")
      }
    }
  }
  
  # Standardize position format if needed
  if (position_format != "letter_number") {
    # Get plate dimensions for conversion
    dimensions <- get_plate_dimensions(plate_size)
    n_rows <- dimensions$rows
    n_cols <- dimensions$cols
    
    # Determine current position format
    first_pos <- as.character(data[[position_column]][1])
    
    # Check if current format is letter_number
    is_letter_number <- grepl("^[A-Za-z]+\\d+$", first_pos)
    
    # Check if current format is row_column (like "1_1")
    is_row_column <- grepl("^\\d+_\\d+$", first_pos)
    
    # Check if current format is numeric (sequential)
    is_numeric <- is.numeric(data[[position_column]]) || 
                  (is.character(data[[position_column]]) && 
                   all(grepl("^\\d+$", data[[position_column]])))
    
    # Convert to desired format
    if (position_format %in% c("number", "numeric")) {
      # Target: Sequential numbering
      if (is_letter_number) {
        # From letter_number to numeric
        data$converted_position <- sapply(data[[position_column]], function(pos) {
          row_letter <- stringr::str_extract(pos, pattern = "^[A-Za-z]+")
          col_num <- as.numeric(stringr::str_extract(pos, pattern = "\\d+$"))
          row_num <- match(row_letter, row_names)
          ((row_num - 1) * n_cols) + col_num
        })
        data[[position_column]] <- data$converted_position
        data$converted_position <- NULL
      } else if (is_row_column) {
        # From row_column to numeric
        data$converted_position <- sapply(data[[position_column]], function(pos) {
          parts <- strsplit(pos, "_")[[1]]
          row_num <- as.numeric(parts[1])
          col_num <- as.numeric(parts[2])
          ((row_num - 1) * n_cols) + col_num
        })
        data[[position_column]] <- data$converted_position
        data$converted_position <- NULL
      }
      # If already numeric, do nothing
    } else if (position_format %in% c("row_column", "numeric_numeric")) {
      # Target: row_column format
      if (is_letter_number) {
        # From letter_number to row_column
        data$converted_position <- sapply(data[[position_column]], function(pos) {
          row_letter <- stringr::str_extract(pos, pattern = "^[A-Za-z]+")
          col_num <- as.numeric(stringr::str_extract(pos, pattern = "\\d+$"))
          row_num <- match(row_letter, row_names)
          paste0(row_num, "_", col_num)
        })
        data[[position_column]] <- data$converted_position
        data$converted_position <- NULL
      } else if (is_numeric) {
        # From numeric to row_column
        data$converted_position <- sapply(as.numeric(data[[position_column]]), function(pos) {
          row_num <- ceiling(pos / n_cols)
          col_num <- ((pos - 1) %% n_cols) + 1
          paste0(row_num, "_", col_num)
        })
        data[[position_column]] <- data$converted_position
        data$converted_position <- NULL
      }
      # If already row_column, do nothing
    } else if (position_format == "letter_number") {
      # Target: letter_number format
      if (is_row_column) {
        # From row_column to letter_number
        data$converted_position <- sapply(data[[position_column]], function(pos) {
          parts <- strsplit(pos, "_")[[1]]
          row_num <- as.numeric(parts[1])
          col_num <- as.numeric(parts[2])
          paste0(row_names[row_num], col_num)
        })
        data[[position_column]] <- data$converted_position
        data$converted_position <- NULL
      } else if (is_numeric) {
        # From numeric to letter_number
        data$converted_position <- sapply(as.numeric(data[[position_column]]), function(pos) {
          row_num <- ceiling(pos / n_cols)
          col_num <- ((pos - 1) %% n_cols) + 1
          paste0(row_names[row_num], col_num)
        })
        data[[position_column]] <- data$converted_position
        data$converted_position <- NULL
      }
      # If already letter_number, do nothing
    }
  }
  
  # Handle multi-plate data
  if (!is.null(plate_column)) {
    if (!plate_column %in% names(data)) {
      stop(paste("Plate column", plate_column, "not found in data"))
    }
    
    # Return data frame with position, value, and plate columns
    result <- data[, c(position_column, value_column, plate_column)]
    names(result) <- c("position", "value", "plate")
  } else {
    # Return data frame with just position and value columns
    result <- data[, c(position_column, value_column)]
    names(result) <- c("position", "value")
  }
  
  return(result)
}

#' Export Plate Layout to File
#'
#' Exports plate layout data to CSV, TSV, or Excel files.
#'
#' @param data A data frame containing plate layout data.
#' @param file_path Character string specifying the path to the output file. The file
#'   extension determines the output format (csv, tsv, xlsx).
#' @param position_column Character string specifying the column containing position information.
#'   Default is "position".
#' @param value_column Character string specifying the column containing values.
#'   Default is "value".
#' @param split_position Logical indicating whether to split the position column into
#'   separate row and column fields. Default is FALSE.
#' @param position_format Character string specifying the format of the position column in the
#'   input data. Options: "letter_number", "number"/"numeric", "row_column"/"numeric_numeric".
#'   Only needed if split_position = TRUE. Default is "letter_number".
#' @param plate_size Numeric value specifying the plate size. Only needed if split_position = TRUE
#'   and position_format is "number" or "numeric". Default is 96.
#' @param ... Additional parameters passed to the underlying write function.
#'
#' @return Invisible NULL. The function is called for its side effect of creating a file.
#'
#' @importFrom utils write.csv write.table
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic export to CSV
#' export_plate_layout(plate_data, "output_data.csv")
#'
#' # Export to Excel with split position into row and column
#' export_plate_layout(
#'   plate_data, 
#'   "output_data.xlsx", 
#'   split_position = TRUE
#' )
#'
#' # Export data with numeric positions
#' export_plate_layout(
#'   plate_data, 
#'   "output_data.csv",
#'   position_format = "numeric",
#'   split_position = TRUE
#' )
#' }
export_plate_layout <- function(data,
                               file_path,
                               position_column = "position",
                               value_column = "value",
                               split_position = FALSE,
                               position_format = "letter_number",
                               plate_size = 96,
                               ...) {
  
  # Validate position_format
  valid_formats <- c("letter_number", "number", "numeric", "row_column", "numeric_numeric")
  if (!position_format %in% valid_formats) {
    stop("Invalid position_format. Valid options are: ", paste(valid_formats, collapse = ", "))
  }
  
  # Validate plate_size if needed
  if (split_position && position_format %in% c("number", "numeric")) {
    valid_plate_sizes <- c(6, 12, 24, 48, 96, 384, 1536)
    if (!plate_size %in% valid_plate_sizes) {
      stop("Selected plate_size not available! Valid options are: ",
           paste(valid_plate_sizes, collapse = ", "))
    }
  }
  
  # Check if required columns exist
  if (!position_column %in% names(data)) {
    stop(paste("Position column", position_column, "not found in data"))
  }
  if (!value_column %in% names(data)) {
    stop(paste("Value column", value_column, "not found in data"))
  }
  
  # Create a copy of the data to avoid modifying the original
  export_data <- data.frame(data)
  
  # Split position into row and column if requested
  if (split_position) {
    # Get plate dimensions if needed
    dimensions <- get_plate_dimensions(plate_size)
    n_rows <- dimensions$rows
    n_cols <- dimensions$cols
    
    # Define row names for conversion
    MORELETTERS <- c(LETTERS, "AA", "AB", "AC", "AD", "AE", "AF")
    row_names <- MORELETTERS[1:n_rows]
    
    if (position_format == "letter_number") {
      # From letter_number (A1, B2) to separate row and column
      export_data$plate_row <- sapply(export_data[[position_column]], function(pos) {
        stringr::str_extract(pos, pattern = "^[A-Za-z]+")
      })
      export_data$plate_column <- sapply(export_data[[position_column]], function(pos) {
        as.numeric(stringr::str_extract(pos, pattern = "\\d+$"))
      })
      
    } else if (position_format %in% c("number", "numeric")) {
      # From numeric (1, 2, 3...) to separate row and column
      export_data$plate_row <- sapply(as.numeric(export_data[[position_column]]), function(pos) {
        row_num <- ceiling(pos / n_cols)
        row_names[row_num]
      })
      export_data$plate_column <- sapply(as.numeric(export_data[[position_column]]), function(pos) {
        ((pos - 1) %% n_cols) + 1
      })
      
    } else if (position_format %in% c("row_column", "numeric_numeric")) {
      # From row_column (1_1, 1_2...) to separate row and column
      export_data$plate_row <- sapply(export_data[[position_column]], function(pos) {
        parts <- strsplit(pos, "_")[[1]]
        row_num <- as.numeric(parts[1])
        row_names[row_num]
      })
      export_data$plate_column <- sapply(export_data[[position_column]], function(pos) {
        parts <- strsplit(pos, "_")[[1]]
        as.numeric(parts[2])
      })
    }
  }
  
  # Determine file type and write accordingly
  file_ext <- tolower(tools::file_ext(file_path))
  
  if (file_ext == "csv") {
    utils::write.csv(export_data, file = file_path, row.names = FALSE, ...)
  } else if (file_ext == "tsv" || file_ext == "txt") {
    utils::write.table(export_data, file = file_path, sep = "\t", row.names = FALSE, ...)
  } else if (file_ext %in% c("xlsx", "xls")) {
    if (!requireNamespace("writexl", quietly = TRUE)) {
      stop("Package 'writexl' is required to write Excel files. Please install it with install.packages('writexl')")
    }
    writexl::write_xlsx(export_data, path = file_path, ...)
  } else {
    stop("Unsupported file type. Supported types are: CSV, TSV, TXT, XLSX, XLS")
  }
  
  invisible(NULL)
}