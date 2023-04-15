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

-- SELECT * FROM loan_officer_view;

CREATE OR REPLACE VIEW admin_view AS
SELECT 
    applicant_id AS USER_ID,
    first_name || ' ' || last_name AS USER_NAME,
    'loan applicant' AS USER_TYPE,
    email,
    phone_number,
    address
FROM 
    loan_applicants
UNION ALL
SELECT 
    officer_id AS USER_ID,
    first_name || ' ' || last_name AS USER_NAME,
    'loan officer' AS USER_TYPE,
    email,
    phone_number,
    NULL AS address
FROM 
    loan_officers;

-- SELECT * FROM admin_view;

--permissions for VIEWS
GRANT SELECT ON loan_details_view TO APP_ADMIN;
-- GRANT SELECT ON loan_details_view TO APP_APPLICANT;
-- GRANT SELECT ON loan_details_view TO APP_OFFICER;

GRANT SELECT ON disbursements_by_officer_view to APP_ADMIN;

GRANT SELECT ON repayments_by_applicant_view to APP_ADMIN;
-- GRANT SELECT ON repayments_by_applicant_view to APP_OFFICER;

GRANT SELECT ON loan_officer_view to APP_ADMIN;

GRANT SELECT ON admin_view to APP_ADMIN;

--TRIGGERS
--triggers for not allowing an entry to be created in loan disbursements table and loan repayments table for a loan application whose status is "rejected"


CREATE OR REPLACE TRIGGER trg_prevent_disbursement_on_rejection
BEFORE INSERT ON loan_disbursements
FOR EACH ROW
DECLARE
    app_status VARCHAR2(20);
BEGIN
    SELECT status INTO app_status
    FROM loan_applications
    WHERE application_id = :NEW.application_id;
    
    IF app_status = 'rejected' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Disbursement is not allowed for a rejected loan application');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_reject_loan_repayment
BEFORE INSERT ON loan_repayments
FOR EACH ROW
DECLARE
    l_status VARCHAR2(20);
BEGIN
    SELECT status INTO l_status
    FROM loan_applications
    WHERE application_id = :new.application_id;
    IF l_status = 'rejected' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Loan application has been rejected. Repayment cannot be added.');
    END IF;
END;
/

-- INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
-- VALUES (DISBURSEMENT_ID_SEQ.NEXTVAL, 300005, TO_DATE('2022-06-05', 'YYYY-MM-DD'), 9000);


-- INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
-- VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 300003, TO_DATE('2022-03-01', 'YYYY-MM-DD'), 1500);

--trigger for total disbursed amount should be less than amount approved

CREATE OR REPLACE TRIGGER trg_loan_disbursement_check
BEFORE INSERT OR UPDATE ON loan_disbursements
FOR EACH ROW
DECLARE
    v_amount_approved NUMBER;
    v_amount_disbursed NUMBER;
BEGIN
    SELECT amount_approved INTO v_amount_approved
    FROM loan_applications
    WHERE application_id = :new.application_id;

    SELECT SUM(amount_disbursed) INTO v_amount_disbursed
    FROM loan_disbursements
    WHERE application_id = :new.application_id;

    IF (v_amount_disbursed + :new.amount_disbursed) > v_amount_approved THEN
        RAISE_APPLICATION_ERROR(-20001, 'The total amount disbursed cannot exceed the amount approved for the loan application.');
    END IF;
END;
/

-- INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
-- VALUES (DISBURSEMENT_ID_SEQ.NEXTVAL, 300004, TO_DATE('2022-05-13', 'YYYY-MM-DD'), 20000);

--STORED PROCEDURES
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

--ADMIN PACKAGE
-- Admin Data Insertion package

CREATE OR REPLACE PACKAGE admin_insert_pack AS 
    PROCEDURE insert_loan_applicants_proc
    (
        v_applicant_id IN loan_applicants.applicant_id%TYPE,
        v_username IN loan_applicants.user_name%TYPE,
        v_password IN loan_applicants.password%TYPE,
        v_first_name IN loan_applicants.first_name%TYPE,
        v_last_name IN loan_applicants.last_name%TYPE,
        v_email IN loan_applicants.email%TYPE,
        v_phone_number IN loan_applicants.phone_number%TYPE,
        v_address IN loan_applicants.address%TYPE,
        v_createdat IN loan_applicants.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    );    
    PROCEDURE insert_loan_officers_proc
    (
        v_officer_id IN loan_officers.officer_id%TYPE,
        v_username IN loan_officers.user_name%TYPE,
        v_password IN loan_officers.password%TYPE,
        v_first_name IN loan_officers.first_name%TYPE,
        v_last_name IN loan_officers.last_name%TYPE,
        v_email IN loan_officers.email%TYPE,
        v_phone_number IN loan_officers.phone_number%TYPE,
        v_createdat IN loan_officers.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    );
    PROCEDURE insert_loan_applications_proc
    (         
        v_application_id IN loan_applications.application_id%TYPE,
        v_applicant_id IN loan_applications.applicant_id%TYPE,
        v_officer_id IN loan_applications.officer_id%TYPE,
        v_amount_requested IN loan_applications.amount_requested%TYPE,
        v_status IN loan_applications.status%TYPE,
        v_amount_approved IN loan_applications.amount_approved%TYPE,
        v_loan_term IN loan_applications.loan_term%TYPE,
        v_interest_rate IN loan_applications.interest_rate%TYPE,
        v_createdat IN loan_applications.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    );
    PROCEDURE insert_loan_disbursements_proc
    (
        v_disbursement_id IN loan_disbursements.disbursement_id%TYPE,
        v_application_id IN loan_disbursements.application_id%TYPE,
        v_date_disbursed IN loan_disbursements.date_disbursed%TYPE,
        v_amount_disbursed IN loan_disbursements.amount_disbursed%TYPE,
        v_createdat IN loan_disbursements.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    );
    PROCEDURE insert_loan_repayments_proc
    (   v_repayment_id IN loan_repayments.repayment_id%TYPE,
        v_application_id IN loan_repayments.application_id%TYPE,
        v_payment_date IN loan_repayments.payment_date%TYPE,
        v_amount_paid IN loan_repayments.amount_paid%TYPE,
        v_createdat IN loan_repayments.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    );
END admin_insert_pack;
/

CREATE OR REPLACE PACKAGE BODY admin_insert_pack AS 
    PROCEDURE insert_loan_applicants_proc
    (
        v_applicant_id IN loan_applicants.applicant_id%TYPE,
        v_username IN loan_applicants.user_name%TYPE,
        v_password IN loan_applicants.password%TYPE,
        v_first_name IN loan_applicants.first_name%TYPE,
        v_last_name IN loan_applicants.last_name%TYPE,
        v_email IN loan_applicants.email%TYPE,
        v_phone_number IN loan_applicants.phone_number%TYPE,
        v_address IN loan_applicants.address%TYPE,
        v_createdat IN loan_applicants.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    ) AS
    BEGIN
        INSERT INTO loan_applicants (applicant_id, user_name, password, first_name, last_name, email, phone_number, address, created_at)
        VALUES (v_applicant_id, v_username, v_password, v_first_name, v_last_name, v_email, v_phone_number, v_address, v_createdat);
    END insert_loan_applicants_proc;
    
    PROCEDURE insert_loan_officers_proc
    (
        v_officer_id IN loan_officers.officer_id%TYPE,
        v_username IN loan_officers.user_name%TYPE,
        v_password IN loan_officers.password%TYPE,
        v_first_name IN loan_officers.first_name%TYPE,
        v_last_name IN loan_officers.last_name%TYPE,
        v_email IN loan_officers.email%TYPE,
        v_phone_number IN loan_officers.phone_number%TYPE,
        v_createdat IN loan_officers.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    ) AS
    BEGIN
        INSERT INTO loan_officers (officer_id, user_name, password, first_name, last_name, email, phone_number, created_at)
        VALUES (v_officer_id, v_username, v_password, v_first_name, v_last_name, v_email, v_phone_number, v_createdat);
    END insert_loan_officers_proc;
    
    PROCEDURE insert_loan_applications_proc
    (         
        v_application_id IN loan_applications.application_id%TYPE,
        v_applicant_id IN loan_applications.applicant_id%TYPE,
        v_officer_id IN loan_applications.officer_id%TYPE,
        v_amount_requested IN loan_applications.amount_requested%TYPE,
        v_status IN loan_applications.status%TYPE,
        v_amount_approved IN loan_applications.amount_approved%TYPE,
        v_loan_term IN loan_applications.loan_term%TYPE,
        v_interest_rate IN loan_applications.interest_rate%TYPE,
        v_createdat IN loan_applications.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    ) AS
    BEGIN
        INSERT INTO loan_applications (application_id, applicant_id, officer_id, amount_requested, status, amount_approved, loan_term, interest_rate, created_at)
        VALUES (v_application_id, v_applicant_id, v_officer_id, v_amount_requested, v_status, v_amount_approved, v_loan_term, v_interest_rate, v_createdat);
    END insert_loan_applications_proc;
    
    PROCEDURE insert_loan_disbursements_proc
    (
        v_disbursement_id IN loan_disbursements.disbursement_id%TYPE,
        v_application_id IN loan_disbursements.application_id%TYPE,
        v_date_disbursed IN loan_disbursements.date_disbursed%TYPE,
        v_amount_disbursed IN loan_disbursements.amount_disbursed%TYPE,
        v_createdat IN loan_disbursements.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    ) AS
    BEGIN
        INSERT INTO loan_disbursements (disbursement_id, application_id, date_disbursed, amount_disbursed, created_at)
        VALUES (v_disbursement_id, v_application_id, v_date_disbursed, v_amount_disbursed, v_createdat);
    END insert_loan_disbursements_proc;

    PROCEDURE insert_loan_repayments_proc
    (
        v_repayment_id IN loan_repayments.repayment_id%TYPE,
        v_application_id IN loan_repayments.application_id%TYPE,
        v_payment_date IN loan_repayments.payment_date%TYPE,
        v_amount_paid IN loan_repayments.amount_paid%TYPE,
        v_createdat IN loan_repayments.created_at%TYPE DEFAULT CURRENT_TIMESTAMP
    ) AS
    BEGIN
        INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid, created_at)
        VALUES (v_repayment_id, v_application_id, v_payment_date, v_amount_paid, v_createdat);
    END insert_loan_repayments_proc;

END admin_insert_pack;
/
grant EXECUTE ON admin_insert_pack to APP_ADMIN;

--INSERTION PACKAGE SCRIPT
EXEC SUPERUSER.reset_data('loan_repayments');
EXEC SUPERUSER.reset_data('loan_disbursements');
EXEC SUPERUSER.reset_data('loan_applications');
EXEC SUPERUSER.reset_data('loan_officers');
EXEC SUPERUSER.reset_data('loan_applicants');

EXEC SUPERUSER.reset_seq('REPAYMENT_ID_SEQ', 500001);
EXEC SUPERUSER.reset_seq('DISBURSEMENT_ID_SEQ', 400001);
EXEC SUPERUSER.reset_seq('APPLICATION_ID_SEQ', 300001);
EXEC SUPERUSER.reset_seq('OFFICER_ID_SEQ', 200001);
EXEC SUPERUSER.reset_seq('APPLICANT_ID_SEQ', 100001);

EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'johndoe', SUPERUSER.STANDARD_HASH_OUTPUT('password7871'), 'John', 'Doe', 'johndoe@email.com', '1234567890', '123 Main St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'janedoe', SUPERUSER.STANDARD_HASH_OUTPUT('password1234'), 'Jane', 'Doe', 'janedoe@email.com', '2345678901', '456 First St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'bobsmith', SUPERUSER.STANDARD_HASH_OUTPUT('passwordabcd'), 'Bob', 'Smith', 'bobsmith@email.com', '3456789012', '789 Second St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'sallyjones', SUPERUSER.STANDARD_HASH_OUTPUT('password5578'), 'Sally', 'Jones', 'sallyjones@email.com', '4567890123', '012 Third St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'tomwilliams', SUPERUSER.STANDARD_HASH_OUTPUT('passwordxyz'), 'Tom', 'Williams', 'tomwilliams@email.com', '5678901234', '345 Fourth St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'carolbrown', SUPERUSER.STANDARD_HASH_OUTPUT('password1734'), 'Carol', 'Brown', 'carolbrown@email.com', '6789012345', '678 Fifth St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'franklinrodriguez', SUPERUSER.STANDARD_HASH_OUTPUT('passwordaocd'), 'Franklin', 'Rodriguez', 'franklinrodriguez@email.com', '7890123456', '901 Sixth St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'hannahlee', SUPERUSER.STANDARD_HASH_OUTPUT('password6678'), 'Hannah', 'Lee', 'hannahlee@email.com', '8901234567', '234 Seventh St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'peterkim', SUPERUSER.STANDARD_HASH_OUTPUT('passwordxdz'), 'Peter', 'Kim', 'peterkim@email.com', '9012345678', '567 Eighth St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'marynguyen', SUPERUSER.STANDARD_HASH_OUTPUT('password1534'), 'Mary', 'Nguyen', 'marynguyen@email.com', '0123456789', '890 Ninth St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'jimmyli', SUPERUSER.STANDARD_HASH_OUTPUT('passwordapcd'), 'Jimmy', 'Li', 'jimmyli@email.com', '1234567891', '123 Tenth St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'jameydoe', SUPERUSER.STANDARD_HASH_OUTPUT('password1034'), 'Jamey', 'Doe', 'jameydoe@email.com', '0987654321', '456 Elm St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'samjones', SUPERUSER.STANDARD_HASH_OUTPUT('password4567'), 'Sam', 'Jones', 'samjones@email.com', '1112223333', '789 Oak Ave');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'alexsmith', SUPERUSER.STANDARD_HASH_OUTPUT('password7890'), 'Alex', 'Smith', 'alexsmith@email.com', '4445556666', '321 Pine Rd');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'amandawoods', SUPERUSER.STANDARD_HASH_OUTPUT('password5778'), 'Amanda', 'Woods', 'amandawoods@email.com', '7778889999', '654 Cedar Ln');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'davidlee', SUPERUSER.STANDARD_HASH_OUTPUT('password2968'), 'David', 'Lee', 'davidlee@email.com', '3334445555', '987 Maple St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'nataliejackson', SUPERUSER.STANDARD_HASH_OUTPUT('password1357'), 'Natalie', 'Jackson', 'nataliejackson@email.com', '8889990000', '654 Pine St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'ryanmiller', SUPERUSER.STANDARD_HASH_OUTPUT('password3690'), 'Ryan', 'Miller', 'ryanmiller@email.com', '4443332222', '789 Cedar Ave');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'jacobturner', SUPERUSER.STANDARD_HASH_OUTPUT('password8024'), 'Jacob', 'Turner', 'jacobturner@email.com', '5554443333', '987 Oak Rd');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'emilyroberts', SUPERUSER.STANDARD_HASH_OUTPUT('password2468'), 'Emily', 'Roberts', 'emilyroberts@email.com', '2223334444', '321 Cedar St');
EXEC SUPERUSER.admin_insert_pack.insert_loan_applicants_proc(SUPERUSER.APPLICANT_ID_SEQ.NEXTVAL,'ericbrown', SUPERUSER.STANDARD_HASH_OUTPUT('password1857'), 'Eric', 'Brown', 'ericbrown@email.com', '7776665555', '654 Elm Ave');
commit;


EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'emmawilson', SUPERUSER.STANDARD_HASH_OUTPUT('password231'), 'Emma', 'Wilson', 'emma.wilson@email.com', '5551234567');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'johnsmith', SUPERUSER.STANDARD_HASH_OUTPUT('password4561'), 'John', 'Smith', 'john.smith@email.com', '5552345678');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'jessicamiller', SUPERUSER.STANDARD_HASH_OUTPUT('password789'), 'Jessica', 'Miller', 'jessica.miller@email.com', '5553456789');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'ryanlee', SUPERUSER.STANDARD_HASH_OUTPUT('password012'), 'Ryan', 'Lee', 'ryan.lee@email.com', '5554567890');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'katebrown', SUPERUSER.STANDARD_HASH_OUTPUT('password345'), 'Kate', 'Brown', 'kate.brown@email.com', '5555678901');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'williamjones', SUPERUSER.STANDARD_HASH_OUTPUT('password678'), 'William', 'Jones', 'william.jones@email.com', '5556789012');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'sarahwang', SUPERUSER.STANDARD_HASH_OUTPUT('password901'), 'Sarah', 'Wang', 'sarah.wang@email.com', '5557890123');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'davidtaylor', SUPERUSER.STANDARD_HASH_OUTPUT('password234'), 'David', 'Taylor', 'david.taylor@email.com', '5558901234');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'amynguyen', SUPERUSER.STANDARD_HASH_OUTPUT('password567'), 'Amy', 'Nguyen', 'amy.nguyen@email.com', '5559012345');
EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'markdavis', SUPERUSER.STANDARD_HASH_OUTPUT('password890'), 'Mark', 'Davis', 'mark.davis@email.com', '5550123456');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'sophialewis', SUPERUSER.STANDARD_HASH_OUTPUT('password1239'), 'Sophia', 'Lewis', 'sophia.lewis@email.com', '5551234567');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'danielkim', SUPERUSER.STANDARD_HASH_OUTPUT('password4562'), 'Daniel', 'Kim', 'daniel.kim@email.com', '5552345678');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'tomhanks', SUPERUSER.STANDARD_HASH_OUTPUT('password321'), 'Tom', 'Hanks', 'tomhanks@email.com', '5559876543');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'jenniferlopez', SUPERUSER.STANDARD_HASH_OUTPUT('password1023'), 'Jennifer', 'Lopez', 'jennifer.lopez@email.com', '5551112222');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'brucelee', SUPERUSER.STANDARD_HASH_OUTPUT('password8456'), 'Bruce', 'Lee', 'bruce.lee@email.com', '5553334444');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'angelinajolie', SUPERUSER.STANDARD_HASH_OUTPUT('password7800'), 'Angelina', 'Jolie', 'angelina.jolie@email.com', '5555551212');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'georgeclooney', SUPERUSER.STANDARD_HASH_OUTPUT('password999'), 'George', 'Clooney', 'george.clooney@email.com', '5557778888');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'merylstreep', SUPERUSER.STANDARD_HASH_OUTPUT('password777'), 'Meryl', 'Streep', 'meryl.streep@email.com', '5552223333');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'jimcarrey', SUPERUSER.STANDARD_HASH_OUTPUT('password555'), 'Jim', 'Carrey', 'jim.carrey@email.com', '5554445555');
-- EXEC SUPERUSER.admin_insert_pack.insert_loan_officers_proc(SUPERUSER.OFFICER_ID_SEQ.NEXTVAL,'scarlettjohansson', SUPERUSER.STANDARD_HASH_OUTPUT('password333'), 'Scarlett', 'Johansson', 'scarlett.johansson@email.com', '5556667777');
commit;

EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100001, 200001,50000,'approved',50000,12,6);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100002, 200002,75000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100003, 200003,25000,'approved',25000,6,7);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100004, 200004,80000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100005, 200005,60000,'approved',60000,9,5);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100006, 200006,45000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100007, 200007,20000,'approved',20000,3,8);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100008, 200008,35000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100009, 200009,90000,'approved',90000,12,4);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100010, 200010,55000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100011, 200001,75000,'approved',70000,2,6.5);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100012, 200002,60000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100013, 200003,80000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100014, 200004,90000,'approved',85000,5,7);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100015, 200005,50000,'approved',45000,2,5.5);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100016, 200006,75000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100017, 200007,40000,'approved',35000,6,4.5);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100018, 200008,70000,'approved',65000,2,6);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100019, 200009,95000,'rejected',0,0,0);
EXEC SUPERUSER.admin_insert_pack.insert_loan_applications_proc(SUPERUSER.APPLICATION_ID_SEQ.NEXTVAL,100020, 200010,85000,'approved',80000,3,7.5);
commit;

EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300001, TO_DATE('2022-04-01', 'YYYY-MM-DD'),10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300001, TO_DATE('2022-05-02', 'YYYY-MM-DD'),10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300003, TO_DATE('2022-01-02', 'YYYY-MM-DD'),5000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300003, TO_DATE('2022-03-03', 'YYYY-MM-DD'),10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300005, TO_DATE('2022-05-03', 'YYYY-MM-DD'),10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300005, TO_DATE('2022-07-04', 'YYYY-MM-DD'),20000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300007, TO_DATE('2022-06-04', 'YYYY-MM-DD'),5000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300007, TO_DATE('2022-08-05', 'YYYY-MM-DD'),5000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300009, TO_DATE('2022-03-05', 'YYYY-MM-DD'),20000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300011, TO_DATE('2022-02-06', 'YYYY-MM-DD'),25000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300014, TO_DATE('2022-09-07', 'YYYY-MM-DD'),35000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300014, TO_DATE('2022-10-08', 'YYYY-MM-DD'),5000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300015, TO_DATE('2022-11-08', 'YYYY-MM-DD'),15000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300017, TO_DATE('2022-12-09', 'YYYY-MM-DD'),15000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300018, TO_DATE('2022-11-09', 'YYYY-MM-DD'),15000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300020, TO_DATE('2022-11-10', 'YYYY-MM-DD'),20000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_disbursements_proc(SUPERUSER.DISBURSEMENT_ID_SEQ.NEXTVAL,300020, TO_DATE('2022-04-11', 'YYYY-MM-DD'),20000);
commit;

EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300001, TO_DATE('2022-05-01', 'YYYY-MM-DD'), 10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300001, TO_DATE('2022-06-02', 'YYYY-MM-DD'), 5000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300003, TO_DATE('2022-03-03', 'YYYY-MM-DD'), 5000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300003, TO_DATE('2022-05-04', 'YYYY-MM-DD'), 5000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300005, TO_DATE('2022-06-05', 'YYYY-MM-DD'), 10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300005, TO_DATE('2022-08-06', 'YYYY-MM-DD'), 10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300007, TO_DATE('2022-10-07', 'YYYY-MM-DD'), 4000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300007, TO_DATE('2022-09-08', 'YYYY-MM-DD'), 4000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300009, TO_DATE('2022-05-09', 'YYYY-MM-DD'), 15000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300011, TO_DATE('2022-04-10', 'YYYY-MM-DD'), 20000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300014, TO_DATE('2022-12-10', 'YYYY-MM-DD'), 4000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300014, TO_DATE('2022-11-11', 'YYYY-MM-DD'), 10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300015, TO_DATE('2022-12-30', 'YYYY-MM-DD'), 10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300017, TO_DATE('2022-12-12', 'YYYY-MM-DD'), 10000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300018, TO_DATE('2022-12-13', 'YYYY-MM-DD'), 11000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300020, TO_DATE('2022-12-14', 'YYYY-MM-DD'), 15000);
EXEC SUPERUSER.admin_insert_pack.insert_loan_repayments_proc(SUPERUSER.REPAYMENT_ID_SEQ.NEXTVAL, 300020, TO_DATE('2022-06-15', 'YYYY-MM-DD'), 10000);
commit;

--FUNCTIONS

-- Function to calculate monthly installment 

CREATE OR REPLACE FUNCTION calculate_loan_payment(
    loan_amount IN NUMBER,
    interest_rate IN NUMBER,
    loan_term IN NUMBER
)
RETURN NUMBER
IS
    monthly_interest_rate NUMBER;
    monthly_payment NUMBER;
BEGIN
    monthly_interest_rate := interest_rate / 1200; -- divide by 1200 to convert from annual rate to monthly rate
    monthly_payment := (loan_amount * monthly_interest_rate) / (1 - (1 + monthly_interest_rate) ** (-loan_term*12));
    RETURN monthly_payment;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculating loan payment: ' || SQLERRM);
        RETURN NULL;
END;
/

grant EXECUTE ON calculate_loan_payment to APP_ADMIN;
grant EXECUTE ON calculate_loan_payment to APP_OFFICER;

SELECT la.applicant_id, calculate_loan_payment(la.amount_approved, la.interest_rate, la.loan_term) AS monthly_payment 
FROM loan_applications la WHERE status='approved';


--REPORTS
--Report on Loan Application Approval Rate by Loan Officer

CREATE OR REPLACE VIEW loan_application_approval_rate AS 
SELECT 
    lo.officer_id, 
    lo.first_name || ' ' || lo.last_name AS loan_officer, 
    COUNT(*) AS total_applications, 
    COUNT(CASE WHEN la.status = 'approved' THEN 1 END) AS approved_applications, 
    ROUND(COUNT(CASE WHEN la.status = 'approved' THEN 1 END) / COUNT(*) * 100, 2) AS approval_rate
FROM 
    loan_applications la 
    JOIN loan_officers lo ON la.officer_id = lo.officer_id 
GROUP BY 
    lo.officer_id, 
    lo.first_name, 
    lo.last_name 
ORDER BY 
    approval_rate DESC;


--Report on Loan Disbursement Amount and Repayment Status by Applicant

CREATE OR REPLACE VIEW loan_disbursement_amount_and_repayment_status AS
SELECT
la.applicant_id,
la.first_name || ' ' || la.last_name AS applicant_name,
SUM(ld.amount_disbursed) AS total_disbursed,
COALESCE(SUM(lr.amount_paid), 0) AS total_repaid,
ROUND(COALESCE(SUM(lr.amount_paid), 0) / SUM(ld.amount_disbursed) * 100, 2) AS repayment_rate,
CASE WHEN COALESCE(SUM(lr.amount_paid), 0) >= SUM(ld.amount_disbursed) THEN 'Fully Repaid' ELSE 'Pending' END AS repayment_status
FROM
loan_applicants la
JOIN loan_applications laa ON la.applicant_id = laa.applicant_id
JOIN loan_disbursements ld ON laa.application_id = ld.application_id
LEFT JOIN loan_repayments lr ON laa.application_id = lr.application_id
GROUP BY
la.applicant_id,
la.first_name,
la.last_name
ORDER BY
total_disbursed DESC;

-- Report on quarterly total disbursements between 2021 and 2023

CREATE OR REPLACE VIEW total_q_disbursements_between_2021_and_2023 AS
SELECT
  TO_CHAR(ld.date_disbursed, 'YYYY-Q') AS quarter,
  SUM(ld.amount_disbursed) AS total_disbursement
FROM
  loan_disbursements ld
  JOIN loan_applications la ON ld.application_id = la.application_id
WHERE
  la.status = 'approved'
  AND TO_CHAR(ld.date_disbursed, 'YYYY-Q') BETWEEN '2021-Q1' AND '2023-Q4'
GROUP BY
  TO_CHAR(ld.date_disbursed, 'YYYY-Q')
ORDER BY
  quarter;

-- Report on quarterly total repayments between 2021 and 2023

CREATE OR REPLACE VIEW total_q_repayments_between_2021_and_2023 AS
SELECT 
    TO_CHAR(lr.payment_date, 'YYYY-Q') AS quarter,
    SUM(lr.amount_paid) AS total_repayments
FROM 
    loan_repayments lr
    JOIN loan_applications la ON lr.application_id = la.application_id
    JOIN loan_disbursements ld ON lr.application_id = ld.application_id
WHERE 
    lr.payment_date BETWEEN TO_DATE('2021-01-01', 'YYYY-MM-DD') AND TO_DATE('2023-12-31', 'YYYY-MM-DD')
GROUP BY 
    TO_CHAR(lr.payment_date, 'YYYY-Q')
ORDER BY 
    quarter ASC;

--Report to get average time taken for loan repayment

CREATE OR REPLACE VIEW avg_time_to_repay_by_applicant AS
SELECT 
  la.applicant_id,
  AVG(lr.payment_date - ld.date_disbursed) AS avg_days_to_repay
FROM 
  loan_applications la
  JOIN loan_disbursements ld ON la.application_id = ld.application_id
  JOIN loan_repayments lr ON la.application_id = lr.application_id
GROUP BY 
  la.applicant_id;


select * from loan_application_approval_rate;
select * from loan_disbursement_amount_and_repayment_status;
select * from total_q_disbursements_between_2021_and_2023;
select * from total_q_repayments_between_2021_and_2023;
select * from avg_time_to_repay_by_applicant;
SELECT * FROM repayments_by_applicant_view;
SELECT * FROM disbursements_by_officer_view;