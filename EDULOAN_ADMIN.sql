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
    loan_term varchar(30) NOT NULL,
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
ORDER;

CREATE SEQUENCE OFFICER_ID_SEQ
ORDER;

CREATE SEQUENCE APPLICATION_ID_SEQ
ORDER;

CREATE SEQUENCE DISBURSEMENT_ID_SEQ
ORDER;

CREATE SEQUENCE REPAYMENT_ID_SEQ
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

-- grant EXECUTE ON STANDARD_HASH_OUTPUT to APP_ADMIN;


-----INSERTING DATA INTO TABLES

-- loan applicants insertion into table

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'johndoe', STANDARD_HASH_OUTPUT('password7871'), 'John', 'Doe', 'johndoe@email.com', '1234567890', '123 Main St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'janedoe', STANDARD_HASH_OUTPUT('password2908'), 'Jane', 'Doe', 'janedoe@email.com', '9087654321', '456 Oak St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'bobsmith', STANDARD_HASH_OUTPUT('password3567'), 'Bob', 'Smith', 'bobsmith@email.com', '5551234567', '789 Maple St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'sarajohnson', STANDARD_HASH_OUTPUT('password4342'), 'Sara', 'Johnson', 'sarajohnson@email.com', '1235556789', '345 Elm St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'davidlee', STANDARD_HASH_OUTPUT('password5674'), 'David', 'Lee', 'davidlee@email.com', '9876543210', '678 Pine St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'janewilliams', STANDARD_HASH_OUTPUT('password6123'), 'Jane', 'Williams', 'janewilliams@email.com', '5557891234', '901 Oak St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'samjones', STANDARD_HASH_OUTPUT('password7345'), 'Sam', 'Jones', 'samjones@email.com', '1237894561', '234 Maple St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'lucymiller', STANDARD_HASH_OUTPUT('password9088'), 'Lucy', 'Miller', 'lucymiller@email.com', '9873216540', '567 Pine St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'brianbrown', STANDARD_HASH_OUTPUT('password8889'), 'Brian', 'Brown', 'brianbrown@email.com', '5554567890', '890 Oak St');

INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address)
VALUES (APPLICANT_ID_SEQ.NEXTVAL, 'jennysmith', STANDARD_HASH_OUTPUT('password6710'), 'Jenny', 'Smith', 'jennysmith@gmail.com', '8989898989', '90 saint St');

-- loan officers insertion into table

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'emmawilson', STANDARD_HASH_OUTPUT('password231'), 'Emma', 'Wilson', 'emma.wilson@example.com', '5551234567');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'alexpatel', STANDARD_HASH_OUTPUT('password289'), 'Alex', 'Patel', 'alex.patel@example.com', '5552345678');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'samcarter', STANDARD_HASH_OUTPUT('password390'), 'Sam', 'Carter', 'sam.carter@example.com', '5553456789');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'ethanlee', STANDARD_HASH_OUTPUT('password456'), 'Ethan', 'Lee', 'ethan.lee@example.com', '5554567890');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'davidwil',  STANDARD_HASH_OUTPUT('password523'), 'David', 'Wil', 'david.wil@example.com', '5555678901');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'jessicataylor',  STANDARD_HASH_OUTPUT('password678'), 'Jessica', 'Taylor', 'jessica.taylor@example.com', '5556789012');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'christopheranderson',  STANDARD_HASH_OUTPUT('password790'), 'Christopher', 'Anderson', 'christopher.anderson@example.com', '5557890123');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'stephaniethomas',  STANDARD_HASH_OUTPUT('password458'), 'Stephanie', 'Thomas', 'stephanie.thomas@example.com', '5558901234');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'richardjackson',  STANDARD_HASH_OUTPUT('password909'), 'Richard', 'Jackson', 'richard.jackson@example.com', '5559012345');

INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number)
VALUES (OFFICER_ID_SEQ.nextval, 'amandawhite',  STANDARD_HASH_OUTPUT('password190'), 'Amanda', 'White', 'amanda.white@example.com', '5550123456');

-- loan applications insertion into table

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 1, 1, 10000, 'approved', 20000, '1 year', 5.0);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 2, 1, 20000, 'approved', 20000, '2 years', 4.5);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 3, 2, 15000, 'approved', 40000, '1 year', 5.0);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 4, 2, 30000, 'approved', 30000, '3 years', 4.0);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 5, 3, 20000, 'approved', 50000, '2 years', 5.5);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 6, 3, 25000, 'approved', 20000, '2 years', 5.0);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 7, 4, 40000, 'approved', 40000, '4 years', 4.5);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 8, 4, 10000, 'approved', 30000, '1 year', 6.0);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 9, 5, 50000, 'approved', 15000, '5 years', 4.0);

INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate)
VALUES (APPLICATION_ID_SEQ.nextval, 10, 5, 15000, 'approved', 15000, '2 years', 5.0);

-- loan disbursements insertion into table

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 1, TO_DATE('2022-02-01', 'YYYY-MM-DD'), 5000);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 2, TO_DATE('2022-03-15', 'YYYY-MM-DD'), 10000);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 3, TO_DATE('2022-04-21', 'YYYY-MM-DD'), 7500);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 4, TO_DATE('2022-05-10', 'YYYY-MM-DD'), 12000);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 5, TO_DATE('2022-06-05', 'YYYY-MM-DD'), 9000);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 6, TO_DATE('2022-07-19', 'YYYY-MM-DD'), 15000);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 7, TO_DATE('2022-08-12', 'YYYY-MM-DD'), 8000);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 8, TO_DATE('2022-09-27', 'YYYY-MM-DD'), 11000);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 9, TO_DATE('2022-10-16', 'YYYY-MM-DD'), 6500);

INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
VALUES (DISBURSMENT_ID_SEQ.NEXTVAL, 10, TO_DATE('2022-11-09', 'YYYY-MM-DD'), 10000);

-- loan repayments insertion into table

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 1, TO_DATE('2022-01-01', 'YYYY-MM-DD'), 1000);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 2, TO_DATE('2022-02-01', 'YYYY-MM-DD'), 2000);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 3, TO_DATE('2022-03-01', 'YYYY-MM-DD'), 1500);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 4, TO_DATE('2022-04-01', 'YYYY-MM-DD'), 3000);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 5, TO_DATE('2022-05-01', 'YYYY-MM-DD'), 2500);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 6, TO_DATE('2022-06-01', 'YYYY-MM-DD'), 1000);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 7, TO_DATE('2022-07-01', 'YYYY-MM-DD'), 500);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 8, TO_DATE('2022-08-01', 'YYYY-MM-DD'), 2000);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 9, TO_DATE('2022-09-01', 'YYYY-MM-DD'), 1000);

INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 10, TO_DATE('2022-10-01', 'YYYY-MM-DD'), 3000);

--VIEWS

CREATE OR REPLACE VIEW loan_details_view AS
SELECT 
    la.first_name || ' ' || la.last_name AS applicant_name,
    la.email AS applicant_email,
    la.phone_number AS applicant_phone,
    lo.first_name || ' ' || lo.last_name AS loan_officer_name,
    la.created_at AS application_date,
    laa.amount_requested AS requested_amount,
    laa.amount_approved AS approved_amount,
    laa.loan_term AS loan_term,
    laa.interest_rate AS interest_rate,
    laa.status AS application_status,
    ld.date_disbursed AS disbursement_date,
    ld.amount_disbursed AS disbursed_amount,
    lr.payment_date AS repayment_date,
    lr.amount_paid AS paid_amount
FROM 
    loan_applicants la
    JOIN loan_applications laa ON la.applicant_id = laa.applicant_id
    JOIN loan_officers lo ON laa.officer_id = lo.officer_id
    LEFT JOIN loan_disbursements ld ON laa.application_id = ld.application_id
    LEFT JOIN loan_repayments lr ON laa.application_id = lr.application_id;
    

-- SELECT * FROM loan_details_view;

CREATE OR REPLACE VIEW disbursements_by_officer_view AS
SELECT loan_officers.first_name || ' ' || loan_officers.last_name AS officer_name,
       loan_applications.applicant_id,
       loan_applicants.first_name || ' ' || loan_applicants.last_name AS applicant_name,
       loan_applications.amount_approved AS loan_amount,
       loan_disbursements.date_disbursed,
       SUM(loan_disbursements.amount_disbursed) AS amount_disbursed
FROM loan_officers
JOIN loan_applications ON loan_officers.officer_id = loan_applications.officer_id
JOIN loan_applicants ON loan_applications.applicant_id = loan_applicants.applicant_id
JOIN loan_disbursements ON loan_applications.application_id = loan_disbursements.application_id
GROUP BY loan_officers.first_name, loan_officers.last_name, loan_applications.applicant_id, loan_applicants.first_name, loan_applicants.last_name,
         loan_applications.amount_approved, loan_disbursements.date_disbursed;

-- SELECT * FROM disbursements_by_officer_view;

CREATE OR REPLACE VIEW repayments_by_applicant_view AS
SELECT loan_applicants.first_name || ' ' || loan_applicants.last_name AS applicant_name,
       loan_applications.application_id,
       loan_applications.amount_approved AS loan_amount,
       loan_repayments.payment_date,
       loan_repayments.amount_paid,
       loan_applications.amount_approved - SUM(loan_repayments.amount_paid) AS outstanding_balance
FROM loan_applicants
JOIN loan_applications ON loan_applicants.applicant_id = loan_applications.applicant_id
JOIN loan_repayments ON loan_applications.application_id = loan_repayments.application_id
GROUP BY loan_applicants.first_name, loan_applicants.last_name, loan_applications.application_id,
         loan_applications.amount_approved, loan_repayments.payment_date, loan_repayments.amount_paid;


-- SELECT * FROM repayments_by_applicant_view;

CREATE OR REPLACE VIEW loan_officer_view AS
SELECT 
    loan_officers.first_name || ' ' || loan_officers.last_name AS officer_name,
    COUNT(loan_applications.application_id) AS num_applications_processed,
    SUM(loan_applications.amount_approved) AS total_loan_amount_approved
FROM 
    loan_officers
LEFT JOIN 
    loan_applications ON loan_officers.officer_id = loan_applications.officer_id
GROUP BY 
    loan_officers.officer_id,
    loan_officers.first_name,
    loan_officers.last_name;

