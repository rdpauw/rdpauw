# Robby De Pauw — CV website

A data-driven Quarto CV that renders to **HTML** (the website) and **PDF**.
All list content is edited in **`cv-data.xlsx`** (one sheet per section, see the
`Leesmij` tab); publications come from `data/publications.bib` (Zotero export).
Both outputs are plain lists with a table of contents under the header.

## How it updates (GitHub Actions)

```
cv-data.xlsx --(R: tools/xlsx_to_csv.R)--> data/*.csv --(Quarto)--> PDF + site
```

`.github/workflows/update-cv.yml` runs this pipeline on GitHub:

- **on every push** that changes `cv-data.xlsx` (or the bib, photo, layout or
  config files),
- **daily** at 05:00 UTC,
- **on demand** via *Actions → Update CV → Run workflow*.

When the CSVs or the rendered content changed, it commits the regenerated
`data/*.csv`, `_freeze/` and `Robby-De-Pauw-CV.pdf` back to `main`, and Netlify
deploys that commit. So updating the CV = edit the workbook, save, commit and
push it (e.g. with GitHub Desktop). Pull before your next edit to get the bot's
commit.

GitHub pauses scheduled workflows after 60 days without repository activity;
re-enable it in the Actions tab if that happens.

## Render locally

```bash
Rscript tools/xlsx_to_csv.R                      # Excel -> data/*.csv
quarto render index.qmd --to pdf --profile pdf   # PDF first: this resets _site/
cp _site/Robby-De-Pauw-CV.pdf .
quarto render index.qmd                          # HTML -> _site/
```

Render `index.qmd` explicitly (not the whole project) so the R code re-runs;
project renders reuse the frozen results in `_freeze/`, which is what Netlify
does (it has no R).

## Sheets and columns

| Section              | Sheet → `data/<sheet>.csv` | Columns |
|----------------------|------------------|---------|
| Experience           | `appointments`   | role, institution, period |
| Education            | `education`      | qualification, institution, year |
| Competitive funding  | `funding`        | project, funder, amount, period |
| Projects             | `projects`       | name, description, organisation, link |
| Shiny apps           | `shiny_apps`     | name, description, url, github |
| Teaching             | `teaching`       | course, role, institution, ects |
| Doctoral supervision | `phd_theses`     | title, candidate, institution, period, role |
| Master's theses      | `masters_theses` | title, candidate, institution, year, note |
| Invited talks        | `invited_talks`  | year, title, venue, location, invited |
| Prizes & awards      | `awards`         | award |
| Additional training  | `training`       | item, institution, year |

The narrative sections (Profile, Selected research achievements, Academic
service, Societal impact) are plain text in `index.qmd`.

R packages: `readxl`, `dplyr`, `readr`, `purrr`, `stringr`, `bib2df`.

## Why the PDF is built on GitHub, not Netlify

Netlify's build image has no R and no LaTeX. The `pdf` format therefore lives
in a Quarto profile (`_quarto-pdf.yml`) that only the workflow uses, and
Netlify just renders the HTML from the committed `_freeze/` results and copies
the committed PDF into the site for the **Download PDF** button.
