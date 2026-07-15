# Robby De Pauw — CV website

A data-driven Quarto CV that renders to **HTML** (the website) and **PDF**.
All content lives in `data/*.csv`, so updating the CV means editing a spreadsheet,
never the layout code.

## Render

```bash
quarto render                                  # HTML site -> _site/ (what Netlify runs)
quarto render index.qmd --to pdf --profile pdf # -> Robby-De-Pauw-CV.pdf
```

The `pdf` format lives in a Quarto **profile** (`_quarto-pdf.yml`), so plain
`quarto render` builds HTML only and the PDF is opt-in via `--profile pdf`.
This is deliberate: Netlify's build image has no LaTeX, so keeping the PDF out
of the default render is what lets the site deploy (see *PDF on Netlify* below).
The HTML masthead's **Download PDF** button links to `Robby-De-Pauw-CV.pdf`;
render it locally and commit it so the button resolves on the live site.

## Editing content

The easiest route is **`cv-data.xlsx`**: one tab per section, with a `Leesmij`
tab explaining the rules. Edit it in Excel, save, then regenerate the CSVs:

```r
source("tools/xlsx_to_csv.R")   # cv-data.xlsx -> data/*.csv
```

Then render as usual. The site itself always reads `data/*.csv` — the workbook
is purely an editing convenience, so the CSVs stay the committed source of
truth and remain diffable in git. Editing the CSVs directly still works fine;
just re-export the workbook (or keep editing the CSVs) so the two don't drift.
Requires `readxl` (`install.packages("readxl")`).

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
`readxl` is needed only for `tools/xlsx_to_csv.R`, not for rendering.

## PDF on Netlify

Netlify's Quarto plugin runs `quarto render`, and its build image has **no
LaTeX** — so if the `pdf` format is part of the default render, the build fails
with *"No TeX installation was detected"*. That's why `pdf` is isolated in
`_quarto-pdf.yml`: the Netlify build only ever renders HTML and deploys cleanly.

To keep the **Download PDF** button working on the live site:

1. Render locally: `quarto render index.qmd --to pdf --profile pdf`
   (needs a TeX engine locally — `quarto install tinytex` once, if you don't
   have one).
2. Commit the resulting `Robby-De-Pauw-CV.pdf`. Because `index.qmd` links to it,
   Quarto copies it into `_site/` during the HTML build, so the button resolves.

Alternatives, if you'd rather Netlify build the PDF automatically:

- **Typst** — move the `pdf:` block from `_quarto-pdf.yml` into `_quarto.yml`
  and change `pdf:` to `typst:`. Typst ships inside Quarto (no TeX), so Netlify
  builds it. Note the profile photo's rounded corners use a small LaTeX (TikZ)
  snippet; under Typst that block would need a Typst equivalent (or the photo
  falls back to a plain square).
- **Install TeX on Netlify** — replace the plugin with a build command such as
  `quarto install tinytex --no-prompt && quarto render`, and put `pdf` back in
  `_quarto.yml`. Simplest to reason about, but every build then installs TeX
  (slower, occasionally flaky).
