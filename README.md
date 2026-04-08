# E-Commerce Customer Churn Analysis

**SQL Analysis Report | 50,000 Customers | PostgreSQL + Power BI**

> This project answers five business-critical questions about customer retention using structured SQL analysis on a 50,000-row e-commerce dataset. It uncovers two distinct groups of customers who leave, identifies cart abandonment as the root cause of a full disengagement chain, and reveals a high-value customer segment whose departures cannot be predicted with any available behavioral data.

---
## A Note on Key Terms
Before diving in, here are a few terms used throughout this document:
* **Churn / Churned:** A customer who has stopped doing business with the company. Churn rate is the percentage of customers who left out of the total.
* **Lifetime Value (LTV):** The total amount of money a customer has spent with the company over their entire relationship. A customer with high LTV is a high-spending customer.
* **Cart Abandonment Rate:** The percentage of times a customer added items to their shopping cart but did not complete the purchase.
* **RFM:** A framework that scores customers on three dimensions: Recency (how recently they bought), Frequency (how often they buy), and Monetary (how much they spend). Used to identify the most valuable and most at-risk customers.
* **Email Open Rate:** The percentage of marketing emails sent to a customer that they actually opened.

---

## Project Overview

Customer churn is one of the most expensive problems in e-commerce. This project investigates **why customers leave**, **who is most at risk**, and **what signals appear before they go** — using a structured SQL-first analysis pipeline connected to a Power BI dashboard.

* **Total customers analyzed:** 49,920 after cleaning
* **Overall churn rate:** 28.89% (nearly 1 in 3 customers)
* **Average customer age:** 38 years
* **Average membership tenure:** 2.98 years

A key finding emerged early: **churn rate is consistent across all age groups (above 24), all countries, and all genders.** Who a customer *is* does not predict whether they will leave. The drivers of churn lie in behavior, not demographics.

The dataset was sourced from [Kaggle](https://www.kaggle.com/).

---

## Tech Stack

|Tool|Purpose|
|-|-|
|PostgreSQL|Data exploration, EDA, segmentation logic|
|Power BI|Interactive dashboard and visual storytelling|
|Excel|Data validation support|

---

## Repository Structure

```
ecommerce-churn-analysis/
│
├── README.md
│
├── sql/
│   ├── exploration/
│   │   ├── 01_behavioral_signals.sql          # Q1: Engagement vs friction by churn status
│   │   ├── 02_recency_frequency_ltv.sql       # Q2: Purchase recency, frequency and LTV
│   │   ├── 03_high_value_customer_profile.sql # Q3: What top 20% LTV customers have in common
│   │   ├── 04_discounts_and_loyalty.sql       # Q4: Do promotions create loyalty or churn?
│   │   ├── 05_support_interactions.sql        # Q5: How support calls relate to retention
│   │   └── 06_cart_abandonment_deep_dive.sql  # Deep dive: Cart abandonment as churn root cause
│   │
│   └── final/
│       └── vw_churn_master.sql                # Master view loaded into Power BI
│
├── dashboard/
│   └── screenshots/
│       ├── 01_overview.png
│       ├── 02_churn_chain.png
│       └── 03_loyalty_and_value.png
│
└── data/
    └── README.md                              # Dataset source — raw data not included (link available for download)
```

---

## Business Questions & Findings

### Q1 — What behaviors signal a customer is about to leave?

Churned customers behave measurably differently from active ones across every engagement metric:

|Metric|Active Customers|Churned Customers|Difference|
|-|-|-|-|
|Logins per month|12.6|9.1|-28%|
|Avg session duration (min)|29.2|23.7|-19%|
|Pages per session|9.3|7.4|-20%|
|Email open rate|22.9%|15.9%|-31%|
|Mobile app usage|20.7|16.1|-22%|
|Cart abandonment rate|54.2%|64.2%|+18%|
|Support calls|5.2|6.9|+33%|
|Days since last purchase|26.9|36.9|+37%|

These are not coincidental signals — they form a pattern of gradual withdrawal that begins with checkout friction and ends with departure.

---

### Q2 — How do recency and frequency relate to churn?

Purchase recency is one of the clearest predictors of churn:

|Time Since Last Purchase|Customers|Churn Rate|
|-|-|-|
|0–30 days|30,108|24.9%|
|31–60 days|10,831|32.1%|
|61–90 days|3,810|38.7%|
|91–180 days|2,135|49.0%|
|180+ days|116|66.4%|

Churn nearly triples from the most recent to most inactive group. The **90-day mark** is a key threshold — churn crosses 38.7% once a customer has been inactive for over two months, suggesting win-back campaigns should be triggered well before that point.

Notably, churned customers had a *slightly higher* average order value than active ones ($134.76 vs $118.38). They didn't spend less per transaction — they simply stopped coming back.

---

### Q3 — What do the most valuable customers have in common?

Customers in the top 20% by lifetime value (avg LTV > $2,800) are the most digitally active segment in the dataset. They log in twice as often as the bottom 40%, spend more time browsing, use the mobile app nearly twice as much, and carry significantly higher account credit balances ($2,705 vs $1,781 average).

**Despite all of this, they churn at 38.3%** — the second highest rate across all LTV tiers and well above the overall average of 28.89%.

Every available explanation was examined and eliminated:

* **Support calls:** Lowest average of any tier — rules out frustration
* **Return rates:** Identical to the overall average — rules out product dissatisfaction
* **Gender:** 38.2% (men), 38.3% (women), 39.9% (other) — effectively identical
* **Country:** Ranges from 36.2% (UK, Germany) to 40.6% (India) — no meaningful pattern
* **Signup cohort:** All four quarters cluster between 37.8% and 39.7%
* **Recency:** Churned top-20% customers are distributed across all recency buckets — they leave while still active, not after fading

**The bottom line:** This is the most important unsolved problem in the dataset. The company's best customers are leaving at an above-average rate and nothing in the available behavioral data explains or predicts it. Exit surveys are the only path forward.

---

### Q4 — Do discounts create loyalty or just temporary buyers?

Discounts do reduce churn — but at a cost:

|Discount Usage Tier|Churn Rate|
|-|-|
|Low (≤20%)|35.3%|
|Medium (21–50%)|29.3%|
|High (51–75%)|25.6%|
|Very High (>75%)|26.2%|

The benefit plateaus beyond 50% usage — more discounts beyond that threshold don't improve retention further.

The deeper issue is margin compression. Heavy discount users show a gross spend vs LTV gap of **$297**, compared to **$183** for low discount users — a 62% difference. Discounts are not changing how customers behave; they are simply buying at lower prices. The company is retaining customers at a lower margin per transaction.

---

### Q5 — How do support interactions relate to loyalty?

Contacting support is a sign of friction, not engagement. The clearest picture comes from combining support call volume with email engagement:

|Customer Segment|Churn Rate|Avg LTV|
|-|-|-|
|High Email + Low Calls|14.4%|$1,821|
|Low Email + Low Calls|22.4%|$1,241|
|High Email + High Calls|37.0%|$1,549|
|Low Email + High Calls|45.7%|$1,047|

The gap between best and worst segment: a customer who rarely calls and regularly opens emails is worth **$774 more** and churns at **one-third the rate** of a customer who calls frequently and has stopped opening emails.

Critically, these two extreme groups are **demographically and transactionally identical** — same average age, tenure, order value, return rate, and discount usage. The difference is not who they are; it's what they have experienced.

---

### Deep Dive — Cart Abandonment as the Root Cause

Cart abandonment is the starting point of the entire disengagement chain:

|Cart Abandonment Tier|Avg Email Open Rate|Avg Support Calls|Churn Rate|
|-|-|-|-|
|Low (0–40%)|36|4|18.3%|
|Medium (41–60%)|23|5|19.8%|
|High (61–80%)|14|6|34.5%|
|Very High (81–100%)|9|7|74.7%|

As cart abandonment rises, email engagement drops, support calls increase, and churn spikes — a clean, progressive chain across all 49,920 customers. **Fixing the checkout experience is the single most impactful lever available to reduce churn.**

---

## Master View: `vw_churn_master`

The final transformation layer creates an enriched view on top of all raw columns with the following calculated fields:

|Column|Description|
|-|-|
|`r_score`|Recency score (NTILE 1–5)|
|`f_score`|Frequency score (NTILE 1–5)|
|`m_score`|Monetary score (NTILE 1–5)|
|`ltv_quintile`|LTV quintile ranking|
|`ltv_segment`|Labeled LTV tier (Top 20%, Upper-Mid, Mid, Bottom 40%)|
|`discount_usage_tier`|Discount behavior bucket|
|`support_tier`|Support call volume bucket|
|`cart_abandonment_tier`|Cart abandonment rate bucket|
|`recency_bucket`|Days since last purchase bucket|
|`activity_tier`|Login frequency bucket|
|`age_group`|Customer age bracket|
|`risk_segment`|Combined support × email engagement risk matrix|

This view was connected directly to Power BI as the primary data source for the dashboard.

---

## Dashboard

The Power BI dashboard has three pages:

**Overview** — Total customers, churn rate (28.89%), age group distribution, and country breakdown. Establishes that demographics do not predict churn.

**Churn Chain** — Cart abandonment → email engagement drop → support call increase → churn progression, and a risk segment matrix comparing LTV and churn rate across four customer groups.

**Loyalty & Value** — Churn rate by days since last purchase and by discount usage tier, with gap metrics comparing churned vs active customers.

> Screenshots available in `/dashboard/screenshots/`

---

## Recommended Actions

|Finding|Recommended Action|
|-|-|
|Cart abandonment triggers a full disengagement chain|Audit the checkout experience: identify where payment failures, confusing steps, or unexpected costs are causing drop-offs|
|Churn risk crosses 38% after 60 days of inactivity|Trigger a win-back campaign at the 45-day mark, before the high-risk threshold|
|High support calls + low email engagement predicts 45.7% churn|Flag accounts after the 3rd support call and assign proactive outreach|
|Discounts reduce churn but compress revenue per transaction|Replace blanket discount campaigns with a loyalty rewards program|
|Top 20% LTV customers churn at 38.3% with no behavioral warning|Launch exit surveys immediately for this segment|

---

## Assumptions & Limitations

* `Days_Since_Last_Purchase` is a static snapshot — no timestamps are available to track behavioral changes over time
* `Credit_Balance` definition was not confirmed (money owed vs. available credit) — findings related to this field should be validated before acting on them
* Customers below 18 and above 150 years old exist in ~50 rows and were excluded as data quality issues
* Cart abandonment values above 100% exist in ~30 rows and were excluded as data quality issues
* `Social_Media_Engagement_Score` is a composite score with unknown components and weights
* Support call *reasons* are not recorded — the data shows that call frequency predicts churn but cannot explain what problems are driving contacts
* All findings describe correlations; confirming causality would require controlled experiments such as A/B testing checkout improvements

---

## Dataset

* **Source:** [Kaggle — E-Commerce Customer Churn Dataset](https://www.kaggle.com/datasets/dhairyajeetsingh/ecommerce-customer-behavior-dataset)
* **Rows:** 50,000 customer-level records
* **Key fields:** Login frequency, session duration, cart abandonment rate, days since last purchase, lifetime value, customer service calls, email open rate, discount usage rate, membership years, and more

> Raw data is not included in this repository. Download it directly from the Kaggle link above.

---

## Author

**Victor Mateo** — Data Analyst

[LinkedIn](https://linkedin.com/in/vmateor) · [Email](mailto:vmateorich@gmail.com)

