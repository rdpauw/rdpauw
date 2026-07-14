# Robby De Pauw — CV website

A data-driven Quarto CV that renders to **HTML** (the website) and **PDF**.
All content lives in `data/*.csv`, so updating the CV means editing a spreadsheet,
never the layout code.

## Render

```bash
quarto render            # builds the HTML site into _site/
quarto render index.qmd --to pdf   # builds Robby-De-Pauw-CV.pdf
```

`quarto render` (no arguments) builds both formats. The HTML masthead has a
**Download PDF** button linking to `Robby-De-Pauw-CV.pdf`.

## Editing content

Each section is backed by one CSV in `data/`:

| Section              | File                     | Columns |
|----------------------|--------------------------|---------|
| Experience           | `appointments.csv`       | role, institution, period |
| Education            | `education.csv`          | qualification, institution, year |
| Competitive funding  | `funding.csv`            | project, funder, amount, period |
| Projects             | `projects.csv`           | name, description, organisation, link |
| Publications         | `publications.bib`       | Zotero BibTeX export (see below) |
| Shiny apps           | `shiny_apps.csv`         | name, description, url, github |
| Teaching             | `teaching.csv`           | course, role, institution, ects |
| Doctoral supervision | `phd_theses.csv`         | title, candidate, institution, period, role |
| Master's theses      | `masters_theses.csv`     | title, candidate, institution, year, note |
| Invited talks        | `invited_talks.csv`      | year, title, venue, location, invited |
| Prizes & awards      | `awards.csv`             | award |
| Additional training  | `training.csv`           | item, institution, year |

**Publications** are driven by `data/publications.bib` (your Zotero BibTeX
export) via `bib2df`, sorted newest-first, with your own name bolded and a
DOI/Link added automatically. To update the list, re-export from Zotero and
overwrite the file — no code changes needed. The narrative sections (Profile,
Selected research achievements, Academic service, Societal impact) are plain
text in `index.qmd`.

R packages used: `dplyr`, `readr`, `purrr`, `stringr`, `bib2df`
(`install.packages(c("dplyr","readr","purrr","stringr","bib2df"))`).

## PDF on Netlify

The Netlify build renders HTML fine out of the box. Building the **PDF** on
Netlify needs a TeX engine, which the base image lacks. Two options:

1. **Simplest** — render the PDF locally and commit `Robby-De-Pauw-CV.pdf` to the
   repo root. Netlify then just serves the committed file (no TeX needed).
2. **Auto-build** — add `quarto install tinytex` to the Netlify build, or switch
   the `pdf` format in `_quarto.yml` to `typst`, which ships inside Quarto and
   needs no LaTeX. The CSV-driven layout works unchanged with either engine.
