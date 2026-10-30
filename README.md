# Olist Brazilian E-Commerce: Sales, Delivery and Customer Analysis

End-to-end analysis of about 100K orders (Sep 2016 to Oct 2018) from Olist, a Brazilian online marketplace. Built with Python (pandas, matplotlib, seaborn) and SQL.

## Business Questions
1. How did revenue and orders grow over time?
2. Which categories and states drive revenue?
3. How good is delivery, and does it affect customer reviews?
4. How do customers pay, and how many come back?
5. How concentrated is revenue among sellers?

## Dataset
- Kaggle: Brazilian E-Commerce Public Dataset by Olist (https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- 8 tables used: orders (99,441), order items (112,650), payments, reviews, customers, products, sellers, category translation
- Revenue = sum of item price on delivered orders (excludes freight), in Brazilian real (R$)

## Key Numbers
| KPI | Value |
|-----|-------|
| Total revenue (delivered orders) | R$ 13.2M |
| Delivered orders | 96,478 |
| Unique customers | 93,358 |
| Average order value | R$ 137.04 |
| Average delivery time | 12.6 days |
| Late delivery rate | 8.1% |
| Average review score | 4.16 / 5 |
| Repeat customer rate | 3.0% |

## Key Insights
1. **Strong growth, Black Friday peak.** Monthly revenue grew about 8x from Jan 2017 to Jan 2018. November 2017 was the peak month (R$ 988K): orders jumped 63% and revenue 52% over October.
2. **Revenue is concentrated in three states.** Sao Paulo alone brings 38% of revenue; SP, RJ and MG together bring 63%.
3. **Top categories:** health_beauty, watches_gifts and bed_bath_table lead. The top 10 of 74 categories make up 62% of revenue.
4. **Late delivery is linked to bad reviews.** Late orders average 2.57 stars vs 4.29 for on-time orders. 54% of late orders get a 1-2 star review, compared with 9% of on-time orders.
5. **Delivery is slow far from the southeast.** São Paulo averages 8.8 days, while states like Pará take 23.8 days, with higher late rates in the north and northeast.
6. **Payments:** credit cards make up 78.5% of payment value (about 3.5 installments on average); boleto is 18%.
7. **Retention is the biggest gap.** Only 3.0% of customers placed a second order.
8. **Sellers are concentrated.** The top 10% of 2,970 sellers earn 67% of revenue.

## Recommendations
- Cut late deliveries, especially in RJ, the northeast and the north, and set more realistic delivery estimates there.
- Launch retention campaigns (post-purchase emails, loyalty offers) to lift the 3% repeat rate.
- Prepare stock and logistics for Black Friday every year.
- Support and monitor top sellers, since a small group carries most of the revenue.

Note: these findings show associations, not proof of cause. For example, late orders may also differ in product type or distance.

## Charts
Charts are in the `screenshots` folder: monthly trend, top categories, revenue by state, delivery by state, reviews vs delivery, payment types and seller concentration.

## Files
- `olist_analysis.ipynb`: full Python analysis (run in Google Colab)
- `olist_queries.sql`: 9 SQL queries for the same questions (KPIs, monthly trend, top categories, state share with window functions, late vs on-time reviews, delivery by state, payments, repeat customers, seller concentration)
- `kpis.csv`: headline KPI table

## How to Run
1. Download the dataset from the Kaggle link above
2. Open `olist_analysis.ipynb` in Google Colab
3. Run all cells and upload the CSV files when asked (geolocation file is not needed)

## Tech Stack
Python, Pandas, NumPy, Matplotlib, Seaborn, SQL (SQLite syntax), Google Colab

## Author
Subhan | https://linkedin.com/in/subhan-basha-proddutur-36686725a
