-- ==============================================================
-- Bronze: 原価実績明細（原本保持レイヤー）
-- 入力: /Volumes/workspace/default/manufacturing_poc_raw/cost_actuals 配下のCSV
--      （UTF-8, ヘッダーあり。Excelは事前にCSV変換してVolumeへ配置する前提）
-- 方針: 型変換・クレンジングは一切行わず、文字列のまま原本を保持する。
-- ソース切替: 基幹システム接続確定後はこのファイルの read_files() の
--   指定のみを置き換えれば、Silver 以降への影響はない（スキーマ維持が条件）。
-- ==============================================================
CREATE OR REFRESH STREAMING TABLE workspace.bronze.bronze_cost_actuals
COMMENT 'Bronze原価実績明細: CSV原本データを文字列のまま保持し、ソースファイル名を付与'
AS SELECT
  *,
  _metadata.file_path AS _source_file
FROM STREAM(read_files(
  '/Volumes/workspace/default/manufacturing_poc_raw/cost_actuals',
  format => 'csv',
  header => true,
  inferColumnTypes => false
));
