-- 01_admin_setup_lab.sql
-- 用管理员连接执行：创建/重置 LAB 用户，并授予最小必需权限
-- 注意：RDS 上请确保存在 USERS/TEMP 表空间（默认就有）。

SET SERVEROUTPUT ON
WHENEVER SQLERROR CONTINUE

BEGIN
  -- 如已存在则删除（忽略“不存在”的错误）
  BEGIN
    EXECUTE IMMEDIATE 'DROP USER lab CASCADE';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE NOT IN (-1918 /*user does not exist*/, -1940 /*user currently connected*/) THEN
        RAISE;
      END IF;
  END;

  -- 创建用户并分配空间配额
  EXECUTE IMMEDIATE q'[
    CREATE USER lab IDENTIFIED BY "Lab#2025"
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS
  ]';

  -- 赋权（仅实验所需）
  EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW, CREATE PROCEDURE TO lab';
  EXECUTE IMMEDIATE 'GRANT SELECT_CATALOG_ROLE TO lab'; -- 便于查看执行计划等

  DBMS_OUTPUT.PUT_LINE('✅ User LAB is ready. Password = Lab#2025');
END;
/
