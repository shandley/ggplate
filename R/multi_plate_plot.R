#' Faceted Multi-Plate Display
#'
#' Creates a faceted plot displaying multiple plates side by side based on a faceting variable.
#' This is useful for comparing different experimental conditions, time points, or replicates.
#'
#' @param data a data frame that contains at least columns for plate position, values, and a faceting variable.
#' @param position a character column in the `data` data frame that contains plate positions.
#' @param value a character or numeric column in the `data` data frame that contains values that should be plotted as colours
#' on the plate layout. Can be the same column as `label`.
#' @param facet_by a character column in the `data` data frame that contains the variable to facet by.
#'  Each unique value will be displayed as a separate plate.
#' @param plate_size a numeric value that specifies the plate size (number of wells) used for the plot. Possible values
#' are: 6, 12, 24, 48, 96, 384 and 1536.
#' @param position_format a character string specifying the format of position values. Options include:
#'   - "letter_number" (default): positions like A1, B2, C3 (row = letter, column = number)
#'   - "number" (or "numeric"): positions like 1, 2, 3, ... (sequential numbering from top-left)
#'   - "row_column" (or "numeric_numeric"): positions like 1_1, 1_2, 2_1 (row_column as numbers)
#' @param label an optional character or numeric column in the `data` data frame that contains values
#'  that should be plotted as labels on the plate layout. Can be the same column as `value`.
#' @param facet_ncol number of columns for the facet layout. Default is NULL, which will let ggplot2 decide.
#' @param facet_scales a character string specifying the scaling for the facets. Options are "fixed" (default),
#'  "free", "free_x", or "free_y". See [ggplot2::facet_wrap()] for details.
#' @param facet_labeller a function or named vector for custom facet labels. See [ggplot2::labeller()] for details.
#' @param common_legend logical, whether to use a common legend for all facets. Default is TRUE.
#' @param ... additional arguments passed to [plate_plot()].
#'
#' @return A ggplot object with faceted plate plots.
#'
#' @importFrom rlang .data
#' @importFrom ggplot2 facet_wrap vars labeller
#' @export
#'
#' @examples
#' library(dplyr)
#' 
#' # Load example data
#' data("data_continuous_96")
#' 
#' # Create a dataset with multiple conditions
#' conditions <- c("Control", "Treatment A", "Treatment B")
#' multi_condition_data <- lapply(conditions, function(condition) {
#'   data_continuous_96 %>%
#'     mutate(
#'       Condition = condition,
#'       # Add some variation between conditions
#'       Value = Value * case_when(
#'         condition == "Control" ~ 1,
#'         condition == "Treatment A" ~ 1.5,
#'         condition == "Treatment B" ~ 0.7
#'       )
#'     )
#' }) %>%
#'   bind_rows()
#' 
#' # Create a faceted plot with the different conditions
#' multi_plate_plot(
#'   data = multi_condition_data,
#'   position = well,
#'   value = Value,
#'   facet_by = Condition,
#'   plate_size = 96,
#'   plate_type = "round"
#' )
#' 
#' # Create a faceted plot with custom layout and scales
#' multi_plate_plot(
#'   data = multi_condition_data,
#'   position = well,
#'   value = Value,
#'   facet_by = Condition,
#'   plate_size = 96,
#'   plate_type = "round",
#'   facet_ncol = 2,
#'   facet_scales = "free",
#'   label = Value
#' )
#'
multi_plate_plot <- function(data,
                            position,
                            value,
                            facet_by,
                            plate_size = 96,
                            position_format = "letter_number",
                            label,
                            facet_ncol = NULL,
                            facet_scales = "fixed",
                            facet_labeller = NULL,
                            common_legend = TRUE,
                            ...) {
  
  # Check if required arguments are provided
  if (missing(data)) stop("data argument is required")
  if (missing(position)) stop("position argument is required")
  if (missing(value)) stop("value argument is required")
  if (missing(facet_by)) stop("facet_by argument is required")
  
  # Validate facet_scales
  valid_scales <- c("fixed", "free", "free_x", "free_y")
  if (!facet_scales %in% valid_scales) {
    stop("facet_scales must be one of: ", paste(valid_scales, collapse = ", "))
  }
  
  # Capture variable provided to facet_by using rlang's enquo
  facet_var <- rlang::enquo(facet_by)
  
  # Check if facet_var exists in data
  if (!rlang::as_name(facet_var) %in% names(data)) {
    stop("facet_by variable '", rlang::as_name(facet_var), "' not found in data")
  }
  
  # Convert facet variable to factor if it's not already
  if (!is.factor(data[[rlang::as_name(facet_var)]])) {
    data[[rlang::as_name(facet_var)]] <- factor(data[[rlang::as_name(facet_var)]])
  }
  
  # Generate plate plot
  p <- plate_plot(
    data = data,
    position = {{ position }},
    value = {{ value }},
    plate_size = plate_size,
    position_format = position_format,
    ...
  )
  
  # Add facet wrap
  if (!is.null(facet_labeller)) {
    p <- p + ggplot2::facet_wrap(
      ggplot2::vars({{ facet_by }}),
      ncol = facet_ncol,
      scales = facet_scales,
      labeller = facet_labeller
    )
  } else {
    p <- p + ggplot2::facet_wrap(
      ggplot2::vars({{ facet_by }}),
      ncol = facet_ncol,
      scales = facet_scales
    )
  }
  
  # Add labels if specified
  if (!missing(label)) {
    # Check if label can be evaluated in the context of the data
    if (!rlang::as_name(rlang::enquo(label)) %in% names(data)) {
      warning("label variable '", rlang::as_name(rlang::enquo(label)), "' not found in data")
    } else {
      # We'll need to regenerate the plot with labels
      p <- plate_plot(
        data = data,
        position = {{ position }},
        value = {{ value }},
        label = {{ label }},
        plate_size = plate_size,
        position_format = position_format,
        ...
      )
      
      # Re-add faceting
      if (!is.null(facet_labeller)) {
        p <- p + ggplot2::facet_wrap(
          ggplot2::vars({{ facet_by }}),
          ncol = facet_ncol,
          scales = facet_scales,
          labeller = facet_labeller
        )
      } else {
        p <- p + ggplot2::facet_wrap(
          ggplot2::vars({{ facet_by }}),
          ncol = facet_ncol,
          scales = facet_scales
        )
      }
    }
  }
  
  # Adjust theme for common legend if requested
  if (common_legend) {
    p <- p + ggplot2::theme(
      legend.position = "bottom"
    )
  }
  
  return(p)
}