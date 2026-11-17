-- ==============================================================
-- Bronze: 品目マスタ（原本保持レイヤー）
-- 入力: /Volumes/workspace/default/manufacturing_poc_raw/items 配下のCSV
-- 方針: 型変換・クレンジングは一切行わず、文字列のまま原本を保持する。
-- ソース切替: bronze_cost_actuals と同様、このファイルのみの置換で対応可能。
-- ==============================================================
CREATE OR REFRESH STREAMING TABLE workspace.bronze.bronze_items
COMMENT 'Bronze品目マスタ: CSV原本データを文字列のまま保持し、ソースファイル名を付与'
AS SELECT
  *,
  _metadata.file_path AS _source_file
FROM STREAM(read_files(
  '/Volumes/workspace/default/manufacturing_poc_raw/items',
  format => 'csv',
  header => true,
  inferColumnTypes => false
));
