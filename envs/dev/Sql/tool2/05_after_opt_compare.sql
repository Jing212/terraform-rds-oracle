-- after_opt_compare.sql
DEFINE LOG_PATH = "C:\Users\Admin\Desktop\DBA\tool\after_opt_compare.log"
SPOOL &LOG_PATH REPLACE

SET TIMING ON
SET LINESIZE 200
SET PAGESIZE 200
SET ECHO ON
WHENEVER SQLERROR CONTINUE

PROMPT >>> Logging to: &LOG_PATH

-- 取订单最多的客户
VAR cid NUMBER
BEGIN
  SELECT customer_id INTO :cid
  FROM (SELECT customer_id, COUNT(*) cnt FROM orders GROUP BY customer_id ORDER BY cnt DESC)
  WHERE ROWNUM = 1;
END;
/
PRINT cid

-- Q2：最近50单（期望命中 IDX_ORDERS_CUST_DATE 且无 SORT）
EXPLAIN PLAN FOR
SELECT order_id, order_date, total_amount
FROM orders
WHERE customer_id = :cid
ORDER BY order_date DESC
FETCH FIRST 50 ROWS ONLY;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,NULL,'BASIC +PREDICATE +ALIAS'));

SELECT order_id, order_date, total_amount
FROM orders
WHERE customer_id = :cid
ORDER BY order_date DESC
FETCH FIRST 50 ROWS ONLY;

-- Q3：大小写不敏感查（期望命中 IDX_CUSTOMERS_NAME_UPPER）
VAR nm VARCHAR2(100)
BEGIN
  SELECT name INTO :nm
  FROM (SELECT name FROM customers ORDER BY DBMS_RANDOM.VALUE)
  WHERE ROWNUM = 1;
END;
/
PRINT nm

EXPLAIN PLAN FOR
SELECT customer_id, name, email
FROM customers
WHERE UPPER(name) = UPPER(:nm);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL,NULL,'BASIC +PREDICATE +ALIAS'));

SELECT customer_id, name, email
FROM customers
WHERE UPPER(name) = UPPER(:nm);

SPOOL OFF
PROMPT >>> Compare done. See: &LOG_PATH
