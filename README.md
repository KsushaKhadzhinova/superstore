# Superstore — BI Sales Analysis Project

## Project Overview

This project is based on the Superstore dataset and demonstrates how to build a complete business intelligence solution — from data extraction and transformation to visualization in Power BI. The goal was to design an end-to-end analytical pipeline that includes data staging, loading into a core model, creating marts, and preparing dashboards for business analysis.

The project reproduces the main steps of a BI process: loading and cleaning data, handling slowly changing dimensions (SCD), building a data warehouse structure, and creating analytical reports with DAX measures.

## Project Structure

| File | Description |
|------|-------------|
| `01_create_schemas_tables.sql` | Creates database schemas and base tables |
| `02_load_core_from_stage.sql` | Loads data from staging into the core layer |
| `03_deduplicate_stage_orders_raw.sql` | Removes duplicate records |
| `04_transform_load_mart.sql` | Creates data marts and applies transformations |
| `05_handle_scd_changes.sql` | Implements Slowly Changing Dimensions (SCD) |
| `etl_Initial_Load,_Secondary_Load_.ipynb` | Notebook with ETL logic for initial and secondary loads |
| `Sample - Superstore.csv` | Source dataset |
| `processed_*.csv` | Processed and cleaned data files |
| `superstore.pbix` | Power BI report |
| `dax.txt` | List of DAX measures used in the report |

## How to Use

To reproduce the workflow, prepare a database (for example, PostgreSQL or SQL Server) and execute the SQL scripts in the following order:

```
01_create_schemas_tables.sql
02_load_core_from_stage.sql
03_deduplicate_stage_orders_raw.sql
04_transform_load_mart.sql
05_handle_scd_changes.sql
```

Then open the notebook `etl_Initial_Load,_Secondary_Load_.ipynb` to perform data loading and validation.  
After processing, open the Power BI file `superstore.pbix` to explore the analytical dashboards and metrics.

## Key Insights

The Power BI report provides an overview of total sales, profit, and margin. It shows the distribution of sales by category, subcategory, and region, highlights top-performing products, and visualizes monthly and yearly sales dynamics. The dashboard also includes insights into returns and their effect on profitability.

## Technologies

SQL is used for data modeling, transformation, and SCD logic.  
Python and Jupyter Notebook are applied for data processing and validation.  
Power BI is used for visualization and analytical modeling with DAX.  
Data is stored in CSV format.  
Git and GitHub are used for version control.

## How to Download the Project

Check that Git is installed:

```
git --version
```

If it is not installed, download it from [https://git-scm.com/](https://git-scm.com/)

Open the terminal and go to the folder where you want to save the project:

```
cd path/to/your/folder
```

Clone the repository:

```
git clone https://github.com/KsushaKhadzhinova/superstore.git
```

After cloning, a folder named `superstore` will appear containing all project files.  
You can open the files in your preferred editor, run the scripts, and explore the Power BI dashboard.

## Author

Ksusha Khadzhinova  
GitHub: [github.com/KsushaKhadzhinova/superstore](https://github.com/KsushaKhadzhinova/superstore)
