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
