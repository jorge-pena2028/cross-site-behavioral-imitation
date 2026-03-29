# Cross-Site Behavioral Imitation Analysis

## Project Overview

This project analyzes behavioral imitation patterns across four international field sites: the United States, Mexico, Japan, and Australia. The study examines how imitation behavior varies across cultural and geographic contexts, and explores the relationship between participant age and imitation performance. The analysis combines statistical modeling in R with structured data querying in SQL to provide a comprehensive understanding of cross-site behavioral differences.

## Data Description

The dataset (`case_study_data.csv`) contains 400 observations collected across four field sites, with 100 observations per site.

| Variable    | Type      | Description                                      |
|-------------|-----------|--------------------------------------------------|
| Fieldsite   | Character | Field site location (USA, Mexico, Japan, Australia) |
| Imitation   | Numeric   | Behavioral imitation score (approximately 4-10)  |
| Age         | Numeric   | Participant age in years (approximately 5-10)    |

## Methodology

### R Statistical Analysis (`analysis.R`)

The R script performs a full analytical pipeline:

- **Data quality audit**: Checks for missing values, verifies variable ranges, and confirms balanced sample sizes across sites.
- **Descriptive statistics**: Computes mean, standard deviation, median, and sample size for both Imitation and Age, grouped by field site.
- **Confidence intervals**: Calculates 95% confidence intervals for mean imitation scores at each site using t-distribution critical values.
- **Cross-group comparisons**: Runs a one-way ANOVA to test for overall differences among sites, followed by Bonferroni-corrected pairwise t-tests.
- **Effect sizes**: Computes Cohen's d for all six pairwise site comparisons to quantify the practical significance of differences.
- **Correlation analysis**: Evaluates the Pearson correlation between age and imitation score, both overall and within each field site.
- **Visualizations**: Produces five publication-ready plots saved to the `output/` directory:
  1. Bar chart with 95% CI error bars
  2. Boxplot of imitation score distributions
  3. Scatter plot of age vs. imitation colored by site
  4. Density plot of imitation distributions
  5. Violin plot with embedded boxplots

Required R packages: `dplyr`, `ggplot2`, `readr`

### SQL Data Analysis (`sql/`)

SQL plays a prominent role in this project, providing an alternative analytical layer for data management and querying:

- **Schema design** (`create_tables.sql`): Defines the table structure with appropriate data types and constraints for the behavioral data.
- **Data loading** (`load_data.sql`): Provides COPY commands to ingest the CSV data into PostgreSQL.
- **Analytical queries** (`analysis_queries.sql`): Contains 10 structured queries that mirror and extend the R analysis:
  1. Descriptive statistics (mean, standard deviation, count) by field site
  2. 95% confidence interval estimation using the z-approximation
  3. Pivoted cross-site comparison summary
  4. Pearson correlation computed directly in SQL using the mathematical formula
  5. Field site ranking by mean imitation score
  6. Distribution analysis with score buckets and percentage breakdowns
  7. Window functions to rank observations within each site and compute deviations from site means
  8. Pairwise mean difference comparisons across all site combinations
  9. Missing data audit query
  10. Comprehensive summary table combining all key metrics

## How to Run

### R Analysis

```bash
# Ensure R and required packages are installed
Rscript -e "install.packages(c('dplyr', 'ggplot2', 'readr'), repos='https://cran.r-project.org')"

# Run the analysis
cd cross-site-behavioral-imitation
Rscript analysis.R
```

Output plots and tables will be saved to the `output/` directory.

### SQL Queries

```bash
# Create the table
psql -d your_database -f sql/create_tables.sql

# Load data (edit the file path in load_data.sql first)
psql -d your_database -f sql/load_data.sql

# Run analytical queries
psql -d your_database -f sql/analysis_queries.sql
```

## Key Findings

- **Cross-site variation**: Imitation scores differ across the four international field sites, with the analysis quantifying both statistical significance (ANOVA) and practical significance (Cohen's d).
- **Age-imitation relationship**: Correlation analysis reveals the strength and direction of the association between participant age and imitation performance, both overall and within each site.
- **Balanced design**: Each site contributes exactly 100 observations, ensuring that group comparisons are not confounded by unequal sample sizes.
- **Data quality**: The dataset is complete with no missing values and all scores fall within expected ranges.

## Project Structure

```
cross-site-behavioral-imitation/
  analysis.R              # Main R analysis script
  case_study_data.csv     # Observational dataset (400 rows)
  README.md
  .gitignore
  sql/                    # SQL analysis pipeline
    create_tables.sql     #   Database schema (DDL)
    load_data.sql         #   CSV import statements
    analysis_queries.sql  #   10 analytical queries
  output/                 # Generated figures and tables (after running analysis.R)
    01_bar_chart_ci.png
    02_boxplot.png
    03_scatter_age_imitation.png
    04_density_plot.png
    05_violin_plot.png
    summary_table.csv
    results_interpretation.txt
```

## Skills Demonstrated

- Executed an end-to-end data analysis workflow in R on a real observational dataset, from quality auditing to visualization.
- Quantified cross-cultural behavioral patterns using descriptive statistics, ANOVA, effect sizes, and confidence interval estimation.
- Designed a SQL schema and wrote analytical queries including CI estimation, cross-site comparisons, Pearson correlation in SQL, distribution analysis, and window functions.
- Translated quantitative results into clear visual and written insights.
