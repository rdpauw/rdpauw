# Regenerate data/*.csv from cv-data.xlsx
#
#   source("tools/xlsx_to_csv.R")
#
# Run this after editing cv-data.xlsx, then render as usual. Publications are
# not part of the workbook: they come from data/publications.bib (Zotero export).

if (!requireNamespace("readxl", quietly = TRUE)) {
  stop("Package 'readxl' is required: install.packages('readxl')")
}

xlsx_to_csv <- function(xlsx = "cv-data.xlsx", out_dir = "data") {
  if (!file.exists(xlsx)) stop("Workbook not found: ", xlsx)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

  # Column order the site's index.qmd expects. Sheets are written in this
  # order; any other sheet in the workbook (e.g. Leesmij) is ignored.
  schema <- list(
    appointments   = c("role", "institution", "period"),
    education      = c("qualification", "institution", "year"),
    funding        = c("project", "funder", "amount", "period"),
    projects       = c("name", "description", "organisation", "link"),
    shiny_apps     = c("name", "description", "url", "github"),
    teaching       = c("course", "role", "institution", "ects"),
    phd_theses     = c("title", "candidate", "institution", "period", "role"),
    masters_theses = c("title", "candidate", "institution", "year", "note"),
    invited_talks  = c("year", "title", "venue", "location", "invited"),
    awards         = c("award"),
    training       = c("item", "institution", "year")
  )

  sheets <- readxl::excel_sheets(xlsx)
  for (nm in names(schema)) {
    if (!nm %in% sheets) {
      warning("Sheet missing from workbook, skipped: ", nm, call. = FALSE)
      next
    }

    # col_types = "text" keeps "2013–2019" and "2024" exactly as typed.
    df <- readxl::read_excel(xlsx, sheet = nm, col_types = "text")
    df <- as.data.frame(df, stringsAsFactors = FALSE)

    missing <- setdiff(schema[[nm]], names(df))
    if (length(missing)) {
      stop("Sheet '", nm, "' is missing column(s): ", paste(missing, collapse = ", "),
           ". Restore the header row exactly as it was.")
    }
    df <- df[, schema[[nm]], drop = FALSE]

    # NA -> "" so empty optional fields stay empty, not the text "NA".
    df[] <- lapply(df, function(x) { x <- as.character(x); x[is.na(x)] <- ""; trimws(x) })
    # Drop fully blank rows left behind by deleting content in Excel.
    keep <- rowSums(df != "") > 0
    df <- df[keep, , drop = FALSE]

    path <- file.path(out_dir, paste0(nm, ".csv"))
    utils::write.csv(df, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
    message(sprintf("  %-16s %3d rows -> %s", nm, nrow(df), path))
  }
  invisible(TRUE)
}

xlsx_to_csv()
