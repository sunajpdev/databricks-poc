# 製造業 原価管理PoC パイプライン

メダリオン構成（Bronze / Silver / Gold）のSQL中心SDPパイプライン。
現時点はサンプル（仮定値）で構築済み。基幹システム接続確定後にBronzeのみ入替える設計。

## データセット構成

| レイヤ | データセット | 内容 |
| --- | --- | --- |
| Bronze | `bronze_cost_actuals` | 原価実績明細CSVの原本（文字列のまま保持） |
| Bronze | `bronze_items` | 品目マスタCSVの原本 |
| Silver | `silver_cost_actuals` | 型変換・キー正規化・重複排除・品質検査済み |
| Silver | `silver_items` | 品目マスタの清洗済み |
| Gold | `gold_cost_fact` | 原価ファクト（品目結合・材料費は標準原価との差異付き） |
| Gold | `gold_dim_item` | 品目ディメンジョン |
| Gold | `gold_monthly_cost_summary` | 年月×部門×原価要素の月次集計 |

## サンプル仮定値（実データ確定時に要修正）

1. 入力: 原価実績明細（`cost_actuals/`）と品目マスタ（`items/`）の2種のみ
2. 形式: CSV・UTF-8・ヘッダーあり（Excelは事前にCSV変換してVolumeへ配置）
3. 提供頻度: フイル着地→Auto Loaderで継続取り込み（実運用では日次想定）
4. 一意キー: 製造指図番号＋品目コード＋工程コード＋原価要素（品目マスタは品目コード）
5. 重複時の優先: `updated_at` が最新のレコード（品目マスタはソースファイル）
6. 原価要素: 材料費 / 労務費 / 経費。標準原価との差異は材料費のみ算出
7. 会計期間: 暦月（`yyyy-MM`）
8. 着地場所: UC Volume `/Volumes/workspace/default/manufacturing_poc_raw/`
9. アクセス: PoCのため作成者のみ（本格化時に権限設計が必要）

## ソース切替時の影響範囲

* **変更箇所**: `transformations/bronze/` 配下のみ（read_files のソース指定を基幹システム接続の着地テーブル/パスに置換）
* **無変更**: Silver / Gold / AI/BI Dashboard / Genie（Bronzeテーブルの列構成を維持することが前提条件）
* 列追加（基幹側スキーマ拡張）はAuto Loaderのスキーマ進化でBronzeに自動反映、Silver側は`SELECT`列の追記が必要

## 検証済みサンプルデータの挙動

* 重複行（MO2026-1004）: 最新 `updated_at` の金額 25,000 が採用されることを確認
* 不正行（MO2026-1011 材料費 `N/A`）: Silver で除外され、Bronze には原本として残存
