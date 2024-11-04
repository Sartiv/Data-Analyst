# LinkedIn Job Postings Analysis 2023-2024

## Project Overview
This project analyzes LinkedIn job postings data for 2023-2024 to uncover trends, demands, and key insights about the job market. The data used in this analysis was sourced from [Kaggle](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings), which provides a comprehensive view of job listings, including job titles, locations, salaries, skills, and more.

## Goals of the Analysis
The objective of this analysis is to:
1. Identify the most viewed and applied-for job titles.
2. Examine the most requested skills and their relevance across roles.
3. Analyze salary ranges for popular job titles and across U.S. states.
4. Understand trends in remote work offerings by company size and job type.
5. Assess if application type or company reputation (follower count) influences applicant engagement.

## Datasets
The project uses multiple `.csv` files from the Kaggle dataset:
- **postings.csv**: Contains core job posting information such as job titles, salaries, locations, and remote work availability.
- **benefits.csv, companies.csv, employee_counts.csv**: Supplementary files used to enrich analysis with company size, employee count, and company benefits.

## Key Questions & Insights
1. **Top 15 Most Viewed Job Titles**: Popular roles include Executive Assistant, Data Analyst, Software Engineer, and Project Manager.
2. **Top 20 Most Requested Skills**: Essential skills include Management, Communication, Data, Sales, and Engineering.
3. **Salary Range by Job Title and State**: Positions like Chief Operating Officer and Software Engineer show wide salary ranges.
4. **Remote Job Demand by Company Size**: Smaller companies tend to offer more remote opportunities compared to larger firms.
5. **Application Type Impact**: Positions with 'complex onsite' applications see a higher average of applications than others.

## Code and Execution
All analysis was conducted in R, using R Markdown to document code and visualizations. The primary analysis file, `Markdown_job_postings.Rmd`, and supplementary results file, `comparison_results.csv`, are included in this repository.

## Project Report

The full project report, including detailed analysis, data cleaning steps, visualizations, and conclusions, is available as a PDF document. This report provides insights into job market trends, skill demand, and factors influencing job posting engagement on LinkedIn for 2023-2024.

You can view or download the complete report here:
- [Job Postings Report (PDF)](report/Job_Postings_Report.pdf)

The report covers:
1. **Overview of Data Cleaning and Preparation**: Steps taken to preprocess the data and create a clean dataset for analysis.
2. **Key Questions and Findings**: Analysis of the top job titles, skills in demand, salary ranges, and trends in remote work.
3. **Visualizations and Insights**: Charts and graphs illustrating job posting metrics and patterns across various dimensions.
4. **Conclusions**: Summary of insights on job trends, skill requirements, and company practices based on LinkedIn data.

Refer to this report for an in-depth view of the findings and to understand the methodologies used throughout the analysis.


### Repository Structure
```
Linkedin-job-postings-2023-2024/
├── README.md
├── R
│   └── data/
    │   └── comparison_results.csv
    ├── Markdown_job_postings.Rmd
    ├── Job Posting.R
    ├── Readme.md
├── report/
│   └── JOB POSTING AT LINKEDIN 2023-2024.pdf
```

## How to Use
1. Download or clone this repository.
2. Open and execute `Markdown_job_postings.Rmd` in RStudio to reproduce the analysis. Ensure that `comparison_results.csv` is in the `data` folder.

## Results and Next Steps
This analysis highlights critical trends in job postings, salary expectations, and skill demands. Future work could explore time-series analysis or expand the dataset to include job postings from other years.
