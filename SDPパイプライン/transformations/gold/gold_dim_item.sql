-- ==============================================================
-- Gold: 品目ディメンジョン（AI/BI Dashboard / Genie の参照対象）
-- Genie での検索性を高めるため列コメントを付与
-- ==============================================================
CREATE OR REFRESH MATERIALIZED VIEW workspace.gold.gold_dim_item (
  item_code STRING COMMENT '品目コード（正規化済み・大文字）',
  item_name STRING COMMENT '品目名',
  item_type STRING COMMENT '品目区分: 製品 / 部品 / 材料',
  unit_of_measure STRING COMMENT '管理単位（個・枚・式・台など）',
  standard_unit_cost DECIMAL(18,2) COMMENT '標準単価'
)
COMMENT 'Gold品目ディメンジョン: 原価分析の品目軸'
AS
SELECT
  item_code,
  item_name,
  item_type,
  unit_of_measure,
  standard_unit_cost
FROM workspace.silver.silver_items;
