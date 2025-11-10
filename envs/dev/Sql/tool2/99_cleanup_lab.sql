-- 99_cleanup_lab.sql
BEGIN
  EXECUTE IMMEDIATE 'DROP USER lab CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1918 THEN RAISE; END IF; -- -1918: user does not exist
END;
/
