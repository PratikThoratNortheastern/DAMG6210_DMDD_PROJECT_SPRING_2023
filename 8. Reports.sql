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