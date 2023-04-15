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