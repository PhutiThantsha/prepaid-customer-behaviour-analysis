-- SQLite dialect. Grain: one eligible customer over Jan-Jun 2026.
-- Monthly aggregation occurs BEFORE cohort-level reporting.
CREATE TEMP VIEW customer_month AS
SELECT c.customer_id, m.month,
       COUNT(p.purchase_id) AS purchase_count,
       COALESCE(SUM(p.amount_cents), 0) AS spend_cents
FROM customers c CROSS JOIN months m
LEFT JOIN purchases p ON p.customer_id = c.customer_id AND p.month = m.month
GROUP BY c.customer_id, m.month;

CREATE TEMP VIEW customer_segments AS
SELECT customer_id,
       SUM(CASE WHEN purchase_count > 0 THEN 1 ELSE 0 END) AS purchase_months,
       SUM(purchase_count) AS purchase_count,
       SUM(spend_cents) AS spend_cents,
       CASE
         WHEN SUM(CASE WHEN purchase_count > 0 THEN 1 ELSE 0 END) >= 5 THEN 'Regular'
         WHEN SUM(CASE WHEN purchase_count > 0 THEN 1 ELSE 0 END) >= 1 THEN 'Occasional'
         ELSE 'No observed purchases'
       END AS segment
FROM customer_month
GROUP BY customer_id;
