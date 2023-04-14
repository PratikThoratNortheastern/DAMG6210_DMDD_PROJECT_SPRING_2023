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