--triggers for not allowing an entry to be created in loan disbursements table and loan repayments table for a loan application whose status is "rejected"


CREATE OR REPLACE TRIGGER prevent_disbursement_on_rejection
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
 
 --trigger for not allowing the total repayments amount to be greated total disbursed amount

-- CREATE OR REPLACE TRIGGER loan_repayment_check
-- BEFORE INSERT OR UPDATE ON loan_repayments
-- FOR EACH ROW
-- DECLARE
--     v_disbursements NUMBER;
--     v_repayments NUMBER;
-- BEGIN
--     SELECT SUM(amount_disbursed) INTO v_disbursements
--     FROM loan_disbursements
--     WHERE application_id = :new.application_id;

--     SELECT SUM(amount_paid) INTO v_repayments
--     FROM loan_repayments
--     WHERE application_id = :new.application_id;

--     IF (v_repayments + :new.amount_paid) > v_disbursements THEN
--         RAISE_APPLICATION_ERROR(-20001, 'Total repayments cannot be more than total disbursements for a loan application.');
--     END IF;
-- END;
-- /



-- INSERT INTO loan_disbursements(disbursement_id, application_id, date_disbursed, amount_disbursed)
-- VALUES (DISBURSEMENT_ID_SEQ.NEXTVAL, 300004, TO_DATE('2022-05-13', 'YYYY-MM-DD'), 12000);

-- -- -- insert a repayment that is within the amount disbursed
-- INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
-- VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 300004, TO_DATE('2022-04-01', 'YYYY-MM-DD'), 3000);

-- -- -- insert a repayment that exceeds the amount disbursed
-- INSERT INTO loan_repayments (repayment_id, application_id, payment_date, amount_paid)
-- VALUES (REPAYMENT_ID_SEQ.NEXTVAL, 300004, TO_DATE('2022-04-01', 'YYYY-MM-DD'), 19000);

-- SELECT SUM(amount_disbursed) from loan_disbursements where application_id = 300004;
-- SELECT SUM(amount_paid) from loan_repayments where application_id = 300004;

--trigger for total disbursed amount should be less than amount approved

CREATE OR REPLACE TRIGGER loan_disbursement_check
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

