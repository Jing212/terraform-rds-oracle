-- 03_optimize_min.sql  (with explicit log path)
-- 最小改动可见提速：收统计 + 常用索引
-- 日志固定输出到指定文件，避免被全局 Spool 干扰

DEFINE LOG_PATH = "C:\Users\Admin\Desktop\DBA\tool\optimize_min.log"

SPOOL &LOG_PATH REPLACE

SET SERVEROUTPUT ON
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 200
WHENEVER SQLERROR CONTINUE

PROMPT >>> Logging to: &LOG_PATH

PROMPT === [Step 1] 收集统计信息 ===
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS(
    ownname          => USER,
    estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
    method_opt       => 'FOR ALL COLUMNS SIZE AUTO',
    cascade          => TRUE
  );
  DBMS_OUTPUT.PUT_LINE('统计信息已收集完成');
END;
/

PROMPT === [Step 2] 创建索引 (orders.customer_id + order_date DESC) ===
CREATE INDEX idx_orders_cust_date ON orders(customer_id, order_date DESC);

PROMPT === [Step 3] 创建索引 (customers.UPPER(name)) ===
CREATE INDEX idx_customers_name_upper ON customers(UPPER(name));

PROMPT === [Step 4] 创建索引 (order_items.order_id) ===
CREATE INDEX idx_order_items_order ON order_items(order_id);

PROMPT === [验证] 索引清单 ===
COLUMN idx_name FORMAT A35
SELECT index_name AS idx_name, table_name
FROM   user_indexes
WHERE  index_name IN ('IDX_ORDERS_CUST_DATE','IDX_CUSTOMERS_NAME_UPPER','IDX_ORDER_ITEMS_ORDER');

SPOOL OFF

PROMPT === 优化脚本执行完毕。日志已写入: &LOG_PATH ===
