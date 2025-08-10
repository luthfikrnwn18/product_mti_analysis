CREATE OR REPLACE TABLE product_mti_analysis.db_basic_analisys_sub_segment AS(
WITH 
-- STEP 1: Buat daftar semua minggu, segment, sub-segment, dan product name unik
all_weeks AS (
  SELECT DISTINCT W, CAST(SUBSTRING(W, 2) AS UNSIGNED) AS week_number, Update_at, Report_year
  FROM product_mti_analysis.db_weekly_report
  WHERE `product category` = 'Basic'
),
all_segments AS (
  SELECT DISTINCT `segment sales`, Sub_Segment_Sales, `product name`
  FROM product_mti_analysis.db_weekly_report
  WHERE `product category` = 'Basic'
),
-- STEP 2: Gabungkan semua kombinasi minggu x segment x sub-segment x product name
week_segment_grid AS (
  SELECT 
    w.W,
    w.week_number,
    w.Update_at,
    w.Report_year,
    s.`segment sales`,
    s.Sub_Segment_Sales,
    s.`product name`
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
    Sub_Segment_Sales,
    `product name`,
    CAST(SUBSTRING(W, 2) AS UNSIGNED) AS week_number,
    COUNT(*) AS growth_basic_sub -- menghitung berdasarkan jumlah product name
  FROM product_mti_analysis.db_weekly_report
  WHERE Report_year IS NOT NULL
  GROUP BY Report_year, Update_at, W, `segment sales`, Sub_Segment_Sales, `product name`
),
-- STEP 4: Gabungkan grid dengan base data
joined_data AS (
  SELECT 
    g.Report_year,
    g.Update_at,
    g.W,
    g.`segment sales`,
    g.Sub_Segment_Sales,
    g.`product name`,
    g.week_number,
    COALESCE(b.growth_basic_sub, 0) AS growth_basic_sub
  FROM week_segment_grid g
  LEFT JOIN base_data b
    ON g.Report_year = b.Report_year
    AND g.Update_at = b.Update_at
    AND g.W = b.W
    AND g.`segment sales` = b.`segment sales`
    AND g.Sub_Segment_Sales = b.Sub_Segment_Sales
    AND g.`product name` = b.`product name`
),
-- STEP 5: Hitung cumulative per segment + sub segment + product name
cumulative_data AS (
  SELECT 
    *, 
    SUM(growth_basic_sub) OVER (
      PARTITION BY Update_at, `segment sales`, Sub_Segment_Sales, `product name`
      ORDER BY week_number
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_growth_basic_sub
  FROM joined_data
),
-- STEP 6: Hitung percent growth
final_data AS (
  SELECT 
    *, 
    LAG(cumulative_growth_basic_sub) OVER (
      PARTITION BY Update_at, `segment sales`, Sub_Segment_Sales, `product name`
      ORDER BY week_number
    ) AS prev_cumulative_growth_basic_sub
  FROM cumulative_data
)
-- STEP 7: Final output
SELECT 
  Report_year,
  Update_at,
  W,
  `segment sales`,
  Sub_Segment_Sales,
  `product name`,
  growth_basic_sub,
  cumulative_growth_basic_sub,
  ROUND(
    CASE 
      WHEN prev_cumulative_growth_basic_sub IS NULL OR prev_cumulative_growth_basic_sub = 0 THEN NULL
      ELSE 100.0 * (cumulative_growth_basic_sub - prev_cumulative_growth_basic_sub) / prev_cumulative_growth_basic_sub
    END, 2
  ) AS percent_growth_sub
FROM final_data
WHERE CONCAT(`segment sales`, Sub_Segment_Sales) NOT IN (
  'EnterpriseSME', 'EnterpriseEnteprise', 'SMEN', 'SMEWIFI'
)
ORDER BY Update_at, `segment sales`, Sub_Segment_Sales, `product name`, week_number)