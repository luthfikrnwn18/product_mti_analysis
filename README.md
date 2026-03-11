# Data Integration and Power BI Update Pipeline

This repository contains SQL scripts and supporting processes used to integrate data from multiple sources, perform data cleansing, and update the Power BI reporting environment.

## Overview

The purpose of this project is to streamline the data preparation workflow by extracting data from multiple databases, removing redundant information, and preparing a clean dataset for analytical reporting in Power BI.

The pipeline ensures that the data used in reporting is consistent, accurate, and ready for visualization.

## Process Workflow

The data processing workflow consists of the following steps:

### 1. Data Extraction
Data is retrieved from two different data sources:
- **Oracle Database**
- **MoraApps Database**

Both sources contain operational data required for further analysis.

### 2. Data Integration and Cleaning
Tables from both databases are joined to:
- Eliminate redundant or duplicated records
- Normalize the data structure
- Improve the accuracy of downstream analysis

This step ensures that the dataset used for reporting is reliable and consistent.

### 3. SQL Query Execution
After the data sources are connected and cleaned, the SQL scripts stored in this repository are executed.

These queries are responsible for:
- Data transformation
- Aggregation
- Preparing the final dataset required for reporting.

### 4. Local Server Upload
The processed dataset is then uploaded to the **local server environment**.  
This step allows the **Power BI dashboard** to refresh automatically using the updated data.

## Technologies Used

- SQL
- Oracle Database
- MoraApps Database
- Local Server Environment
- Power BI

## Purpose

The goal of this repository is to maintain a structured and reproducible workflow for preparing analytical datasets and ensuring that the Power BI reports always reflect the latest available data.

## Notes

Make sure database connections and credentials are properly configured before running the SQL scripts.
