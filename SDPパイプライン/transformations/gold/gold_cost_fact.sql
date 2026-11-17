-- ==============================================================
-- Gold: 原価実績ファクト（AI/BI Dashboard / Genie の主要参照対象）
-- 方針:
--   * Silver の清洗済みデータを品目マスタと結合したスタースキーマのファクト
--   * 材料費は品目マスタの標準単価から標準金額と原価差異を算出
--     （労務費・経費は対象外＝NULL。標準原価マスタ整備後に拡張）
--   * 月次集計用に年月列を付与
-- ==============================================================
CREATE OR REFRESH MATERIALIZED VIEW workspace.gold.gold_cost_fact
COMMENT 'Gold原価ファクト: 品目マスタ結合済みの原価実績明細。材料費は標準原価との差異を含む'
CLUSTER BY (actual_date, item_code)
AS
SELECT
  c.manufacturing_order_no,
  c.item_code,
  i.item_name,
  i.item_type,
  c.process_code,
  c.department_code,
  c.cost_element,
  c.qty,
  c.unit_cost,
  c.amount,
  CASE WHEN c.cost_element = '材料費' THEN i.standard_unit_cost * c.qty END AS standard_amount,
  CASE WHEN c.cost_element = '材料費' THEN c.amount - (i.standard_unit_cost * c.qty) END AS cost_variance,
  c.actual_date,
  date_format(c.actual_date, 'yyyy-MM') AS cost_year_month
FROM workspace.silver.silver_cost_actuals c
LEFT JOIN workspace.silver.silver_items i
  ON c.item_code = i.item_code;
