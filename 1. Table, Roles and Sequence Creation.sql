purge recyclebin;
SET SERVEROUTPUT on;

DECLARE

BEGIN
   
    EXECUTE IMMEDIATE 'DROP USER ADMINUSER CASCADE';
    EXECUTE IMMEDIATE 'DROP USER APPLICANTUSER CASCADE';
    EXECUTE IMMEDIATE 'DROP USER OFFICERUSER CASCADE';

    EXECUTE IMMEDIATE 'DROP ROLE APP_ADMIN';
    EXECUTE IMMEDIATE 'DROP ROLE APP_APPLICANT';
    EXECUTE IMMEDIATE 'DROP ROLE APP_OFFICER';
  
  EXCEPTION
   WHEN OTHERS THEN
   IF SQLCODE != -1918
   THEN RAISE;
   END IF;
END;
/
CREATE role APP_ADMIN;
CREATE role APP_APPLICANT;
CREATE role APP_OFFICER;


CREATE USER ADMINUSER IDENTIFIED BY "Loandmdd12345";
GRANT APP_ADMIN TO ADMINUSER;

CREATE USER APPLICANTUSER IDENTIFIED BY "Loandmdd12345";
GRANT APP_APPLICANT TO APPLICANTUSER;

CREATE USER OFFICERUSER IDENTIFIED BY "Loandmdd12345";
GRANT APP_OFFICER TO OFFICERUSER;

GRANT CONNECT TO APP_ADMIN;
GRANT CONNECT TO APP_APPLICANT;
GRANT CONNECT TO APP_OFFICER;


--CLEANUP SCRIPT
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (   select 'LOAN_REPAYMENTS' table_name from dual union all
                select 'LOAN_DISBURSEMENTS' table_name from dual union all
                select 'LOAN_APPLICATIONS' table_name from dual union all
                select 'LOAN_OFFICERS' table_name from dual union all
                select 'LOAN_APPLICANTS' table_name from dual
   )
   loop
   dbms_output.put_line('....Drop table '||i.table_name);
   begin
       select 'Y' into v_table_exists
       from USER_TABLES
       where TABLE_NAME=i.table_name;

       v_sql := 'drop table '||i.table_name;
       execute immediate v_sql;
       dbms_output.put_line('........Table '||i.table_name||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........Table already dropped');
   end;
   end loop;
   dbms_output.put_line('Schema cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;
/

--Cleanup for SEQ
DECLARE
applicant_id_seq_count number;
   officer_id_seq_count number;
   application_id_seq_count number;
   disbursement_id_seq_count number;
   repayment_id_seq_count number;
BEGIN

--Count for SEQ
select count(*)
  into applicant_id_seq_count from user_sequences
  where sequence_name = 'APPLICANT_ID_SEQ';
  
  select count(*)
  into officer_id_seq_count from user_sequences
  where sequence_name = 'OFFICER_ID_SEQ';
  
  select count(*)
  into application_id_seq_count from user_sequences
  where sequence_name = 'APPLICATION_ID_SEQ';
  
  select count(*)
  into disbursement_id_seq_count from user_sequences
  where sequence_name = 'DISBURSEMENT_ID_SEQ';
  
  select count(*)
  into repayment_id_seq_count from user_sequences
  where sequence_name = 'REPAYMENT_ID_SEQ';
  
  if(applicant_id_seq_count > 0) THEN EXECUTE IMMEDIATE 'DROP SEQUENCE APPLICANT_ID_SEQ'; END IF;
  
  if(officer_id_seq_count > 0) THEN EXECUTE IMMEDIATE 'DROP SEQUENCE OFFICER_ID_SEQ'; END IF;
  
  if(application_id_seq_count > 0) THEN EXECUTE IMMEDIATE 'DROP SEQUENCE APPLICATION_ID_SEQ'; END IF;
  
  if(disbursement_id_seq_count > 0) THEN EXECUTE IMMEDIATE 'DROP SEQUENCE DISBURSEMENT_ID_SEQ'; END IF;
  
  if(repayment_id_seq_count > 0) THEN EXECUTE IMMEDIATE 'DROP SEQUENCE REPAYMENT_ID_SEQ'; END IF;
  
      
END;
/
--CREATE TABLES AS PER DATA MODEL
CREATE TABLE loan_applicants (
    applicant_id INT PRIMARY KEY,
    user_name VARCHAR(30) NOT NULL UNIQUE,
    password RAW(100) NOT NULL,
    first_name varchar(30) NOT NULL,
    last_name varchar(30) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    phone_number varchar(12) NOT NULL UNIQUE,
    address varchar(300) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT applicant_email_check CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
    CONSTRAINT applicant_phone_check CHECK (REGEXP_LIKE(phone_number, '^[0-9]{10}$'))
);
/
CREATE TABLE loan_officers (
    officer_id INT PRIMARY KEY,
    user_name VARCHAR(30) NOT NULL UNIQUE,
    password RAW(100) NOT NULL,
    first_name varchar(30) NOT NULL,
    last_name varchar(30) NOT NULL,
    email varchar(255) NOT NULL UNIQUE,
    phone_number varchar(12) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT officer_email_check CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')),
    CONSTRAINT officer_phone_check CHECK (REGEXP_LIKE(phone_number, '^[0-9]{10}$'))
);
/
CREATE TABLE loan_applications (
    application_id INT PRIMARY KEY,
    applicant_id INT NOT NULL REFERENCES loan_applicants,
    officer_id INT NOT NULL REFERENCES loan_officers,
    amount_requested INT NOT NULL,
    status varchar(30) NOT NULL,
    amount_approved INT NOT NULL,
    loan_term INT NOT NULL,
    interest_rate float NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT amount_check CHECK(amount_requested<100000)
);
/

CREATE TABLE loan_disbursements (
    disbursement_id INT PRIMARY KEY,
    application_id INT NOT NULL REFERENCES loan_applications(application_id),
    date_disbursed DATE NOT NULL,
    amount_disbursed INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT amount_check_two CHECK(amount_disbursed>0)
);

/
CREATE TABLE loan_repayments (
    repayment_id INT PRIMARY KEY,
    application_id INT NOT NULL REFERENCES loan_applications,
    payment_date DATE NOT NULL,
    amount_paid INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT amount_check_three CHECK(amount_paid>0)
);

CREATE SEQUENCE APPLICANT_ID_SEQ
START WITH 100001
INCREMENT BY 1
NOCACHE
NOCYCLE
ORDER;

CREATE SEQUENCE OFFICER_ID_SEQ
START WITH 200001
INCREMENT BY 1
NOCACHE
NOCYCLE
ORDER;

CREATE SEQUENCE APPLICATION_ID_SEQ
START WITH 300001
INCREMENT BY 1
NOCACHE
NOCYCLE
ORDER;

CREATE SEQUENCE DISBURSEMENT_ID_SEQ
START WITH 400001
INCREMENT BY 1
NOCACHE
NOCYCLE
ORDER;

CREATE SEQUENCE REPAYMENT_ID_SEQ
START WITH 500001
INCREMENT BY 1
NOCACHE
NOCYCLE
ORDER;

CREATE OR REPLACE FUNCTION STANDARD_HASH_OUTPUT(str IN VARCHAR2)
  RETURN RAW
  AS
  rawVal RAW(100);
  BEGIN
  SELECT standard_hash(str, 'SHA256') INTO rawVal FROM dual;
  RETURN rawVal;
END;
/

GRANT EXECUTE ON STANDARD_HASH_OUTPUT to APP_ADMIN;

grant SELECT ON APPLICANT_ID_SEQ to APP_ADMIN;
grant SELECT ON OFFICER_ID_SEQ to APP_ADMIN;
grant SELECT ON APPLICATION_ID_SEQ to APP_ADMIN;
grant SELECT ON DISBURSEMENT_ID_SEQ to APP_ADMIN;
grant SELECT ON REPAYMENT_ID_SEQ to APP_ADMIN;

--permissions for Admin Role
GRANT ALL ON LOAN_APPLICANTS TO APP_ADMIN;
GRANT ALL ON LOAN_OFFICERS TO APP_ADMIN;
GRANT ALL ON LOAN_APPLICATIONS TO APP_ADMIN;
GRANT ALL ON LOAN_DISBURSEMENTS TO APP_ADMIN;
GRANT ALL ON LOAN_REPAYMENTS TO APP_ADMIN;

--permissions for Applicant Role
GRANT SELECT, UPDATE ON LOAN_APPLICANTS TO APP_APPLICANT;
GRANT SELECT, UPDATE ON LOAN_APPLICATIONS TO APP_APPLICANT;
GRANT SELECT ON LOAN_DISBURSEMENTS TO APP_APPLICANT;
GRANT SELECT ON LOAN_REPAYMENTS TO APP_APPLICANT; 

--permissions for Officer Role
GRANT SELECT ON LOAN_APPLICANTS TO APP_OFFICER;
GRANT SELECT, UPDATE ON LOAN_OFFICERS TO APP_OFFICER;
GRANT SELECT, UPDATE ON LOAN_APPLICATIONS TO APP_OFFICER;
GRANT SELECT ON LOAN_DISBURSEMENTS TO APP_OFFICER;
GRANT SELECT ON LOAN_REPAYMENTS TO APP_OFFICER; 

-- SELECT * FROM LOAN_APPLICANTS;
-- SELECT * FROM LOAN_OFFICERS;
-- SELECT * FROM LOAN_APPLICATIONS;
-- SELECT * FROM LOAN_DISBURSEMENTS;
-- SELECT * FROM LOAN_REPAYMENTS;