-- Q15 — Top 5 Doctors with Most Revenue but Fewest Patients
SELECT
    `Doctor Name`,
    COUNT(patient_id) AS patient_count,
    SUM(`Total Bill`) AS total_revenue
FROM Doctor_Patients
GROUP BY `Doctor Name`
ORDER BY total_revenue DESC, patient_count ASC
LIMIT 5;
-- Q16 — Department Where Average Waiting Time Decreased for 3 Consecutive Months
WITH monthly_wait AS (
    SELECT
        department_referral,
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        AVG(patient_waittime) AS avg_waiting_time
    FROM `hospital er (1) (power bi)`
    GROUP BY department_referral, DATE_FORMAT(`date`, '%Y-%m')
),
wait_comparison AS (
    SELECT
        department_referral,
        month,
        avg_waiting_time,
        LAG(avg_waiting_time, 1) OVER (
            PARTITION BY department_referral
            ORDER BY month
        ) AS previous_month,
        LAG(avg_waiting_time, 2) OVER (
            PARTITION BY department_referral
            ORDER BY month
        ) AS two_months_before
    FROM monthly_wait
)
SELECT
    department_referral,
    month,
    avg_waiting_time
FROM wait_comparison
WHERE avg_waiting_time < previous_month
  AND previous_month < two_months_before;
-- Q17 — Male : Female Patient Ratio for Each Doctor + Ranking
WITH doctor_gender AS (
    SELECT
        d.`Doctor Name`,
        COUNT(CASE WHEN h.patient_gender = 'Male' THEN 1 END) AS male_patients,
        COUNT(CASE WHEN h.patient_gender = 'Female' THEN 1 END) AS female_patients
    FROM Doctor_Patients d
    JOIN `hospital er (1) (power bi)` h
        ON d.patient_id = h.patient_id
    GROUP BY d.`Doctor Name`
)
SELECT
    `Doctor Name`,
    male_patients,
    female_patients,
    ROUND(male_patients / NULLIF(female_patients, 0), 2) AS male_female_ratio,
    RANK() OVER (
        ORDER BY male_patients / NULLIF(female_patients, 0) DESC
    ) AS ratio_rank
FROM doctor_gender;
-- Q18 — Average Satisfaction Score for Each Doctor
SELECT
    d.`Doctor Name`,
    ROUND(AVG(h.patient_sat_score), 2) AS average_satisfaction_score
FROM Doctor_Patients d
JOIN `hospital er (1) (power bi)` h
    ON d.patient_id = h.patient_id
GROUP BY d.`Doctor Name`
ORDER BY average_satisfaction_score DESC;
-- Q19 — Doctors Who Treated Patients from Different Races + Diversity
SELECT
    d.`Doctor Name`,
    COUNT(DISTINCT h.patient_race) AS different_races
FROM Doctor_Patients d
JOIN `hospital er (1) (power bi)` h
    ON d.patient_id = h.patient_id
GROUP BY d.`Doctor Name`
HAVING COUNT(DISTINCT h.patient_race) > 1
ORDER BY different_races DESC;
-- Q20 — Male vs Female Total Bill Ratio for Each Department
SELECT
    d.department_referral,
    SUM(CASE
        WHEN h.patient_gender = 'Male' THEN d.`Total Bill`
        ELSE 0
    END) AS male_total_bill,
    SUM(CASE
        WHEN h.patient_gender = 'Female' THEN d.`Total Bill`
        ELSE 0
    END) AS female_total_bill,
    ROUND(
        SUM(CASE
            WHEN h.patient_gender = 'Male' THEN d.`Total Bill`
            ELSE 0
        END)
        /
        NULLIF(
            SUM(CASE
                WHEN h.patient_gender = 'Female' THEN d.`Total Bill`
                ELSE 0
            END), 0
        ),
        2
    ) AS male_female_bill_ratio
FROM Doctor_Patients d
JOIN `hospital er (1) (power bi)` h
    ON d.patient_id = h.patient_id
GROUP BY d.department_referral;
-- Q21 — Update Satisfaction Scores
-- UPDATE `hospital er (1) (power bi)`
-- SET patient_sat_score = LEAST(patient_sat_score + 2, 10)
-- WHERE department_referral = 'General Practice'
--   AND patient_waittime > 30
--   AND patient_sat_score IS NOT NULL;
