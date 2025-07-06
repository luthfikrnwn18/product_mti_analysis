CREATE OR REPLACE TABLE product_mti_analysis.db_basic_analisys AS(
WITH Realesedata AS(
WITH base_data AS (
  SELECT 
    Report_year,
    Update_at,
    W,
    CAST(SUBSTRING(W, 2) AS UNSIGNED) AS week_number,
    SUM(
      CASE
        WHEN `Product Category` = 'Basic' THEN 1
        ELSE 0
      END
    ) AS growth_basic_all
  FROM product_mti_analysis.db_weekly_report
  WHERE Report_year IS NOT NULL
  GROUP BY Report_year, Update_at, W
),
cumulative_data AS (
  SELECT 
    *,
    SUM(growth_basic_all) OVER (
      PARTITION BY Update_at
      ORDER BY week_number
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_growth_basic
  FROM base_data
),
final_data AS (
  SELECT 
    *,
    LAG(cumulative_growth_basic) OVER (
      PARTITION BY Update_at
      ORDER BY week_number
    ) AS prev_cumulative
  FROM cumulative_data
)
SELECT 
  Report_year,
  Update_at,
  W,
  growth_basic_all,
  cumulative_growth_basic,
  ROUND(
    CASE 
      WHEN prev_cumulative IS NULL OR prev_cumulative = 0 THEN NULL
      ELSE 100.0 * (cumulative_growth_basic - prev_cumulative) / prev_cumulative
    END, 2
  ) AS percent_growth
FROM final_data
ORDER BY 
  Update_at,
  week_number)
  
  SELECT
  Report_year,
  Update_at,
  W,
  CASE 
	WHEN W = 'S/d 2024' THEN	null
	ELSE growth_basic_all
END as growth_basic_all,
  cumulative_growth_basic,
  percent_growth
  FROM Realesedata)