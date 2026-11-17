-- ==============================================================
-- Gold: 月次原価サマリ（AI/BI Dashboard の主要データソース）
-- 方針: 年月 × 部門 × 原価要素 ごとの金額合計と件数を事前集計
-- 仮定（サンプル）: 会計期間は暦月。4月始まり会計年度へ切り替える場合は
--   cost_year_month の算出式のみを修正する。
-- ==============================================================
CREATE OR REFRESH MATERIALIZED VIEW workspace.gold.gold_monthly_cost_summary
COMMENT 'Gold月次原価サマリ: 年月・部門・原価要素別の金額合計と件数'
CLUSTER BY (cost_year_month, department_code)
AS
SELECT
  cost_year_month,
  department_code,
  cost_element,
  sum(amount) AS total_amount,
  count(*) AS record_count
FROM workspace.gold.gold_cost_fact
GROUP BY ALL;
