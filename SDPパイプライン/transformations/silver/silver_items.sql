-- ==============================================================
-- Silver: 品目マスタの清洗（型変換・キー整備）
-- 仮定（サンプル）:
--   * 一意キー = 品目コード
--   * 品目区分 = 製品 / 部品 / 材料
-- 方針:
--   * TRY_CAST で標準単価を型変換（失敗は NULL）
--   * 品目コードのトリム・大文字正規化を実施
--   * 品目区分の妥当性は警告（warn）で監視のみ
-- ==============================================================
CREATE OR REFRESH MATERIALIZED VIEW workspace.silver.silver_items (
  CONSTRAINT valid_item_code EXPECT (item_code IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_item_type EXPECT (item_type IN ('製品', '部品', '材料'))
)
COMMENT 'Silver品目マスタ: キー正規化・型変換済みの品目マスタ'
AS
WITH normalized AS (
  SELECT
    upper(trim(item_code)) AS item_code,
    trim(item_name) AS item_name,
    trim(item_type) AS item_type,
    trim(unit_of_measure) AS unit_of_measure,
    try_cast(standard_unit_cost AS DECIMAL(18,2)) AS standard_unit_cost,
    _source_file
  FROM workspace.bronze.bronze_items
)
SELECT * FROM normalized
QUALIFY row_number() OVER (PARTITION BY item_code ORDER BY _source_file DESC) = 1;
