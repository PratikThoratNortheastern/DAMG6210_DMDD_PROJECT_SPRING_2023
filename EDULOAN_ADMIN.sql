purge recyclebin;
SET SERVEROUTPUT on;

DECLARE
   ADMINUSER_COUNT NUMBER;
   APPLICANTUSER_COUNT NUMBER;
   OFFICERUSER_COUNT NUMBER;
   APP_ADMIN_ROLE_COUNT NUMBER;
   APP_APPLICANT_ROLE_COUNT NUMBER;
   APP_OFFICER_ROLE_COUNT NUMBER;

BEGIN
   select count(*) into ADMINUSER_COUNT from all_users where USERNAME = 'ADMINUSER';
   select count(*) into APPLICANTUSER_COUNT from all_users where USERNAME = 'APPLICANTUSER';
   select count(*) into OFFICERUSER_COUNT from all_users where USERNAME = 'OFFICERUSER';

   SELECT COUNT(*) INTO APP_OFFICER_ROLE_COUNT FROM DBA_ROLES WHERE ROLE = 'APP_OFFICER';
   SELECT COUNT(*) INTO APP_APPLICANT_ROLE_COUNT FROM DBA_ROLES WHERE ROLE = 'APP_APPLICANT';
   SELECT COUNT(*) INTO APP_ADMIN_ROLE_COUNT FROM DBA_ROLES WHERE ROLE = 'APP_ADMIN';
   
  IF(ADMINUSER_COUNT > 0) THEN EXECUTE IMMEDIATE 'DROP USER ADMINUSER CASCADE'; END IF;
  IF(APPLICANTUSER_COUNT > 0) THEN EXECUTE IMMEDIATE 'DROP USER APPLICANTUSER CASCADE'; END IF;
  IF(OFFICERUSER_COUNT > 0) THEN EXECUTE IMMEDIATE 'DROP USER OFFICERUSER CASCADE'; END IF;

  IF(APP_ADMIN_ROLE_COUNT > 0) THEN EXECUTE IMMEDIATE 'DROP ROLE APP_ADMIN'; END IF;
  IF(APP_APPLICANT_ROLE_COUNT > 0) THEN EXECUTE IMMEDIATE 'DROP ROLE APP_APPLICANT'; END IF;
  IF(APP_OFFICER_ROLE_COUNT > 0) THEN EXECUTE IMMEDIATE 'DROP ROLE APP_OFFICER'; END IF;
  
  EXCEPTION
   WHEN OTHERS THEN
   IF SQLCODE != -1918
   THEN RAISE;
   END IF;
END;
/