-- Deep dive: Cart abandonment as root cause

-- Step 1: Check cart abandonment distribution
-- so we can validate our bucket boundaries

SELECT
    ROUND(eccd."Cart_Abandonment_Rate"::numeric, 0) AS abandonment_rate,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS weight_pct
FROM ecommerce_customer_churn_dataset eccd
WHERE eccd."Cart_Abandonment_Rate" IS NOT NULL
GROUP BY ROUND(eccd."Cart_Abandonment_Rate"::numeric, 0)
ORDER BY abandonment_rate;

-- Step 1: Does high cart abandonment correlate with high support calls?

SELECT
    CASE
        WHEN eccd."Cart_Abandonment_Rate"::numeric <= 40 THEN '1 - Low (0-40%)'
        WHEN eccd."Cart_Abandonment_Rate"::numeric > 40 AND eccd."Cart_Abandonment_Rate"::numeric <= 60 THEN '2 - Medium (41-60%)'
        WHEN eccd."Cart_Abandonment_Rate"::numeric > 60 AND eccd."Cart_Abandonment_Rate"::numeric <= 80 THEN '3 - High (61-80%)'
        WHEN eccd."Cart_Abandonment_Rate"::numeric > 80 AND eccd."Cart_Abandonment_Rate"::numeric <= 100 THEN '4 - Very High (81-100%)'
        ELSE '5 - Outliers (>100%)'
    END AS cart_abandonment_tier,
    COUNT(*) AS customers,
    ROUND(100.0 * SUM(eccd."Churned"::numeric) / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(eccd."Customer_Service_Calls"::numeric), 1) AS avg_support_calls,
    ROUND(AVG(eccd."Email_Open_Rate"::numeric), 1) AS avg_email_open_rate,
    ROUND(AVG(eccd."Login_Frequency"::numeric), 1) AS avg_logins,
    ROUND(AVG(eccd."Total_Purchases"::numeric), 1) AS avg_purchases,
    ROUND(AVG(eccd."Lifetime_Value"::numeric), 2) AS avg_ltv,
    ROUND(AVG(eccd."Product_Reviews_Written"::numeric), 1) AS avg_reviews,
    ROUND(AVG(eccd."Wishlist_Items"::numeric), 1) AS avg_wishlist_items,
    ROUND(AVG(eccd."Mobile_App_Usage"::numeric), 1) AS avg_mobile_usage
FROM ecommerce_customer_churn_dataset eccd
WHERE eccd."Cart_Abandonment_Rate" IS NOT NULL
GROUP BY cart_abandonment_tier
ORDER BY cart_abandonment_tier;


-- Step 2: Does cart abandonment progressively drive the full disengagement chain?
-- Looking for: high abandonment → more calls → less logins
-- → less purchases → lower ltv → higher churn

SELECT
    CASE
        WHEN eccd."Cart_Abandonment_Rate"::numeric <= 40 THEN '1 - Low (0-40%)'
        WHEN eccd."Cart_Abandonment_Rate"::numeric > 40 AND eccd."Cart_Abandonment_Rate"::numeric <= 60 THEN '2 - Medium (41-60%)'
        WHEN eccd."Cart_Abandonment_Rate"::numeric > 60 AND eccd."Cart_Abandonment_Rate"::numeric <= 80 THEN '3 - High (61-80%)'
        WHEN eccd."Cart_Abandonment_Rate"::numeric > 80 AND eccd."Cart_Abandonment_Rate"::numeric <= 100 THEN '4 - Very High (81-100%)'
        ELSE '5 - Outliers (>100%)'
    END AS cart_abandonment_tier,
    eccd."Churned",
    COUNT(*) AS customers,
    ROUND(AVG(eccd."Customer_Service_Calls"::numeric), 1) AS avg_calls,
    ROUND(AVG(eccd."Email_Open_Rate"::numeric), 1) AS avg_email_open_rate,
    ROUND(AVG(eccd."Session_Duration_Avg"::numeric), 1) AS avg_session_duration,
    ROUND(AVG(eccd."Login_Frequency"::numeric), 1) AS avg_logins,
    ROUND(AVG(eccd."Total_Purchases"::numeric), 1) AS avg_purchases,
    ROUND(AVG(eccd."Lifetime_Value"::numeric), 2) AS avg_ltv
FROM ecommerce_customer_churn_dataset eccd
WHERE eccd."Cart_Abandonment_Rate" IS NOT NULL
GROUP BY cart_abandonment_tier, eccd."Churned"
ORDER BY cart_abandonment_tier, eccd."Churned";

-- Last purchase behavior of low abandonment churned customers
-- Are they sudden leavers or gradual faders?

SELECT
    CASE
        WHEN eccd."Days_Since_Last_Purchase"::numeric <= 30 THEN '1 - Very Recent (0-30 days)'
        WHEN eccd."Days_Since_Last_Purchase"::numeric > 30 AND eccd."Days_Since_Last_Purchase"::numeric <= 60 THEN '2 - Recent (31-60 days)'
        WHEN eccd."Days_Since_Last_Purchase"::numeric > 60 AND eccd."Days_Since_Last_Purchase"::numeric <= 90 THEN '3 - Moderate (61-90 days)'
        WHEN eccd."Days_Since_Last_Purchase"::numeric > 90 AND eccd."Days_Since_Last_Purchase"::numeric <= 180 THEN '4 - Distant (91-180 days)'
        ELSE '5 - Very Distant (180+ days)'
    END AS recency_bucket,
    eccd."Churned",
    COUNT(*) AS customers,
    ROUND(AVG(eccd."Lifetime_Value"::numeric), 2) AS avg_ltv,
    ROUND(AVG(eccd."Customer_Service_Calls"::numeric), 1) AS avg_calls,
    ROUND(AVG(eccd."Login_Frequency"::numeric), 1) AS avg_logins,
    ROUND(AVG(eccd."Credit_Balance"::numeric), 2) AS avg_credit_balance,
    ROUND(AVG(eccd."Discount_Usage_Rate"::numeric), 1) AS avg_discount_usage,
    ROUND(AVG(eccd."Total_Purchases"::numeric), 1) AS avg_purchases
FROM ecommerce_customer_churn_dataset eccd
WHERE eccd."Cart_Abandonment_Rate"::numeric <= 40
AND eccd."Days_Since_Last_Purchase" IS NOT NULL
GROUP BY recency_bucket, eccd."Churned"
ORDER BY recency_bucket, eccd."Churned";