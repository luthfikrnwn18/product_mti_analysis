CREATE OR REPLACE TABLE product_mti_analysis.db_weekly_report AS(
WITH rankeddata AS(
SELECT 
  a.*, 
  ROW_NUMBER() OVER (
    PARTITION BY CONCAT(update_at, `Product Category`) 
    ORDER BY 
      CAST(SUBSTRING(update_at, 6) AS UNSIGNED) ASC,  -- Week number as number
      update_at ASC,
      YEAR ASC,
      MONTH ASC,
      DAY ASC,
      LINE_ID ASC
  ) AS row_numbers_all,
 ROW_NUMBER() OVER (
    PARTITION BY CONCAT(update_at, `Product Category`,`segment sales`) 
    ORDER BY 
      CAST(SUBSTRING(update_at, 6) AS UNSIGNED) ASC,  -- Week number as number
      update_at ASC,
      YEAR ASC,
      MONTH ASC,
      DAY ASC,
      LINE_ID ASC
  ) AS row_numbers_segment,
   ROW_NUMBER() OVER (
    PARTITION BY CONCAT(update_at, `Product Category`,sub_segment_sales) 
    ORDER BY 
      CAST(SUBSTRING(update_at, 6) AS UNSIGNED) ASC,  -- Week number as number
      update_at ASC,
      YEAR ASC,
      MONTH ASC,
      DAY ASC,
      LINE_ID ASC
  ) AS row_numbers_sub_segment_sales

FROM product_mti_analysis.db_weekly_report_master a
WHERE Report_year IS NOT NULL
  AND DAY IS NOT NULL)
  SELECT
  *
  FROM rankeddata)