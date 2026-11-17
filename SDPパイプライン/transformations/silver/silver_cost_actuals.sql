-- ==============================================================
-- Silver: 原価実績明細の清洗（型変換・重複排除・キー整備）
-- 仮定（サンプル）:
--   * 一意キー = 製造指図番号 + 品目コード + 工程コード + 原価要素
--   * 重複時は updated_at が最新のレコードを優先
--   * 原価要素 = 材料費 / 労務費 / 経費
-- 方針:
--   * TRY_CAST で型変換し、変換失敗は NULL（行は Bronze に残るため追跡可能）
--   * キー項目のトリム・大文字正規化を実施
--   * expectations でキー NULL・金額不正の行を除外（メトリクスで監視）
-- ==============================================================
CREATE OR REFRESH MATERIALIZED VIEW workspace.silver.silver_cost_actuals (
  CONSTRAINT valid_keys EXPECT (
    manufacturing_order_no IS NOT NULL
    AND item_code IS NOT NULL
    AND process_code IS NOT NULL
    AND cost_element IS NOT NULL
  ) ON VIOLATION DROP ROW,
  CONSTRAINT valid_amounts EXPECT (
    qty IS NOT NULL AND qty >= 0
    AND unit_cost IS NOT NULL AND unit_cost >= 0
    AND amount IS NOT NULL AND amount >= 0
  ) ON VIOLATION DROP ROW
)
COMMENT 'Silver原価実績明細: 型変換・キー正規化・重複排除済みの清洗データ'
AS
WITH normalized AS (
  SELECT
    trim(manufacturing_order_no) AS manufacturing_order_no,
    upper(trim(item_code)) AS item_code,
    trim(process_code) AS process_code,
    trim(department_code) AS department_code,
    trim(cost_element) AS cost_element,
    try_cast(qty AS DECIMAL(18,2)) AS qty,
    try_cast(unit_cost AS DECIMAL(18,2)) AS unit_cost,
    try_cast(amount AS DECIMAL(18,2)) AS amount,
    try_cast(actual_date AS DATE) AS actual_date,
    try_cast(updated_at AS TIMESTAMP) AS updated_at,
    _source_file
  FROM workspace.bronze.bronze_cost_actuals
)
SELECT
  manufacturing_order_no,
  item_code,
  process_code,
  department_code,
  cost_element,
  qty,
  unit_cost,
  amount,
  actual_date,
  updated_at,
  _source_file
FROM normalized
QUALIFY row_number() OVER (
  PARTITION BY manufacturing_order_no, item_code, process_code, cost_element
  ORDER BY updated_at DESC
) = 1;
