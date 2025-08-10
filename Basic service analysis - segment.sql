CREATE OR REPLACE TABLE product_mti_analysis.db_basic_analisys_segment
WITH 
-- STEP 1: Buat daftar semua minggu & segment unik
all_weeks AS (
  SELECT DISTINCT W, CAST(SUBSTRING(W, 2) AS UNSIGNED) AS week_number, Update_at, Report_year
  FROM product_mti_analysis.db_weekly_report
),
all_segments AS (
  SELECT DISTINCT `segment sales` FROM product_mti_analysis.db_weekly_report
),
-- STEP 2: Gabungkan semua kombinasi minggu x segment
week_segment_grid AS (
  SELECT 
    w.W,
    w.week_number,
    w.Update_at,
    w.Report_year,
    s.`segment sales`
  FROM all_weeks w
  CROSS JOIN all_segments s
),
-- STEP 3: Ambil nilai asli dari base data
base_data AS (
  SELECT 
    Report_year,
    Update_at,
    W,
    `segment sales`,
    CAST(SUBSTRING(W, 2) AS UNSIGNED) AS week_number,
    SUM(CASE WHEN `Product Category` = 'Basic' THEN 1 ELSE 0 END) AS growth_basic_all
  FROM product_mti_analysis.db_weekly_report
  WHERE Report_year IS NOT NULL
  GROUP BY Report_year, Update_at, W, `segment sales`
),
-- STEP 4: Gabungkan grid dengan base data
joined_data AS (
  SELECT 
    g.Report_year,
    g.Update_at,
    g.W,
    g.`segment sales`,
    g.week_number,
    COALESCE(b.growth_basic_all, 0) AS growth_basic_all
  FROM week_segment_grid g
  LEFT JOIN base_data b
    ON g.Report_year = b.Report_year
    AND g.Update_at = b.Update_at
    AND g.W = b.W
    AND g.`segment sales` = b.`segment sales`
),
-- STEP 5: Hitung cumulative
cumulative_data AS (
  SELECT 
    *, 
    SUM(growth_basic_all) OVER (
      PARTITION BY CONCAT(Update_at, `segment sales`)
      ORDER BY week_number
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_growth_basic
  FROM joined_data
),
-- STEP 6: Hitung percent growth
final_data AS (
  SELECT 
    *, 
    LAG(cumulative_growth_basic) OVER (
      PARTITION BY CONCAT(Update_at, `segment sales`)
      ORDER BY week_number
    ) AS prev_cumulative
  FROM cumulative_data
)
-- STEP 7: Final output
SELECT 
  Report_year,
  Update_at,
  W,
  `segment sales`,
  growth_basic_all,
  cumulative_growth_basic,
  ROUND(
    CASE 
      WHEN prev_cumulative IS NULL OR prev_cumulative = 0 THEN NULL
      ELSE 100.0 * (cumulative_growth_basic - prev_cumulative) / prev_cumulative
    END, 2
  ) AS percent_growth
FROM final_data
ORDER BY Update_at, `segment sales`, week_number;
