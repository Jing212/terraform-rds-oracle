-- baseline_before_opt.sql
-- 目的：在未执行 03_optimize_min.sql 之前，记录“基线”执行计划与耗时
-- 用法：在 LAB 连接里按 F5 运行；日志输出到 baseline_before_opt.log

SET SERVEROUTPUT ON
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 200
SET TIMING ON
SET TRIMSPOOL ON
WHENEVER SQLERROR CONTINUE

SPOOL baseline_before_opt.log REPLACE

PROMPT === [Check] 是否已误执行过优化脚本（存在索引即代表已优化） ===
COLUMN idx_name FORMAT A35
SELECT index_name AS idx_name
FROM   user_indexes
WHERE  index_name IN ('IDX_ORDERS_CUST_DATE','IDX_CUSTOMERS_NAME_UPPER','IDX_ORDER_ITEMS_ORDER');

PROMPT 如果上面列表非空，说明已存在优化索引；如需重做基线，请先 DROP 这些索引。

PROMPT
PROMPT === [Pick] 自动选择订单最多的一个客户，确保能看到差异 ===
VAR cid NUMBER
BEGIN
  SELECT customer_id
  INTO   :cid
  FROM   (
           SELECT customer_id, COUNT(*) cnt
           FROM   orders
           GROUP  BY customer_id
           ORDER  BY cnt DESC
         )
  FETCH FIRST 1 ROWS ONLY;
  DBMS_OUTPUT.PUT_LINE('Picked customer_id = ' || :cid);
END;
/
PRINT cid

PROMPT
PROMPT === [Query A - Baseline] 某客户最近50单（预期：全表扫 + 排序） ===
EXPLAIN PLAN FOR
SELECT order_id, order_date, total_amount
FROM   orders
WHERE  customer_id = :cid
ORDER  BY order_date DESC
FETCH FIRST 50 ROWS ONLY;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +PREDICATE +ALIAS'));

PROMPT -- 实际执行（计时开启）
SELECT order_id, order_date, total_amount
FROM   orders
WHERE  customer_id = :cid
ORDER  BY order_date DESC
FETCH FIRST 50 ROWS ONLY;

PROMPT
PROMPT === [Pick] 随机取一个客户名做大小写不敏感搜索 ===
VAR nm VARCHAR2(100)
BEGIN
  SELECT name INTO :nm FROM customers
  OFFSET TRUNC(DBMS_RANDOM.VALUE(0, GREATEST(1,(SELECT COUNT(*) FROM customers)-1)))
  ROWS FETCH NEXT 1 ROWS ONLY;
  DBMS_OUTPUT.PUT_LINE('Picked name = ' || :nm);
END;
/
PRINT nm

PROMPT
PROMPT === [Query B - Baseline] UPPER(name) 精确查（预期：全表扫） ===
EXPLAIN PLAN FOR
SELECT customer_id, name, email
FROM   customers
WHERE  UPPER(name) = UPPER(:nm);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, NULL, 'BASIC +PREDICATE +ALIAS'));

PROMPT -- 实际执行（计时开启）
SELECT customer_id, name, email
FROM   customers
WHERE  UPPER(name) = UPPER(:nm);

PROMPT
PROMPT === [Counts] 记录当前行数（便于复现实验规模） ===
SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS products  FROM products;
SELECT COUNT(*) AS orders    FROM orders;
SELECT COUNT(*) AS items     FROM order_items;

SPOOL OFF

PROMPT
PROMPT === 基线记录完成。现在可以执行 @03_optimize_min.sql，然后重复上述两条查询进行对比 ===
