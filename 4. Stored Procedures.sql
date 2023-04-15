CREATE OR REPLACE PROCEDURE reset_data(table_name varchar)
AS
BEGIN
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || table_name;
END;
/

CREATE OR REPLACE PROCEDURE reset_seq(seq_name IN VARCHAR2, start_val IN NUMBER) AS
BEGIN
  EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || seq_name || ' RESTART START WITH ' || start_val;
END;
/

grant EXECUTE ON reset_data to APP_ADMIN;
grant EXECUTE ON reset_seq to APP_ADMIN;