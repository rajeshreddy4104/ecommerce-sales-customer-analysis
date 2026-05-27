# E-Commerce Sales & Customer Analytics Dashboard

## Executive Summary

This project analyzes global e-commerce order data to understand sales performance, customer behavior, category trends, profitability, regional performance, and discount impact. The original Power BI dashboard has been expanded into an end-to-end analytics portfolio project using SQL, Python, and Power BI.

The analysis helps answer business questions such as:

- Which markets, countries, and states generate the most revenue?
- Which product categories and sub-categories drive sales and profit?
- How do discounts affect profitability?
- Which customer segments contribute the most sales?
- Which shipping modes are most used and how do they affect cost?
- Where should the business focus to improve profit margins?

## Dashboard Preview

![E-Commerce Sales Dashboard](E-Commerce%20Data%20Analysis_page.jpg)

## Project Goal

Build an end-to-end analytics project that analyzes:

- Sales performance
- Customer behavior
- Product and category trends
- Profit analysis
- Regional performance
- Discount impact
- Business recommendations

## Tools Used

| Tool | Purpose |
| --- | --- |
| SQL | Data exploration, KPI calculation, segmentation, trend analysis |
| Python | Data cleaning, exploratory data analysis, feature engineering |
| Power BI | Dashboard development and interactive business reporting |
| Excel | Source data storage |
| GitHub | Project documentation and version control |

## Dataset Overview

The dataset contains global e-commerce transactions from **2011-01-01** to **2014-12-31**.

| Table / Sheet | Description |
| --- | --- |
| Orders | Main order-level transaction data |
| Returns | Returned order information |
| People | Region-to-manager mapping |

Key fields include:

- Order ID, Order Date, Ship Date
- Customer ID, Customer Name, Segment
- Country, Market, Region, State, City
- Category, Sub-Category, Product Name
- Sales, Quantity, Discount, Shipping Cost, Profit
- Ship Mode, Order Priority

## Key KPIs

| KPI | Value |
| --- | ---: |
| Total Sales | 12.64M |
| Total Profit | 1.47M |
| Total Quantity | 178.31K |
| Total Shipping Cost | 1.35M |
| Total Orders / Rows | 51,290 |
| Returned Orders | 1,173 |

## Project Architecture

```text
E-Commerce-Data-Analysis-main/
├── Data & Resources/
│   └── ECOMM DATA.xlsx
├── sql/
│   └── ecommerce_analysis.sql
├── python/
│   └── ecommerce_eda.py
├── docs/
│   └── data_dictionary.md
├── E-Commerce Data Analysis.pbix
├── E-Commerce Data Analysis.pdf
├── E-Commerce Data Analysis_page.jpg
├── requirements.txt
└── README.md
```

## Analysis Performed

### 1. Sales Performance

- Calculated total sales, profit, quantity, and shipping cost.
- Analyzed sales trends by year and month.
- Identified high-performing markets, countries, and states.

### 2. Customer Behavior

- Measured sales by customer segment.
- Identified top customers by revenue and profit.
- Compared consumer, corporate, and home office performance.

### 3. Product & Category Trends

- Compared sales and profit across Furniture, Office Supplies, and Technology.
- Identified top sub-categories and products.
- Evaluated categories with high sales but weak profitability.

### 4. Profit Analysis

- Calculated profit margin.
- Compared profitable and loss-making products.
- Analyzed regions and categories with negative profit.

### 5. Regional Performance

- Compared sales across APAC, EU, US, LATAM, EMEA, Africa, and Canada.
- Identified top countries and states.
- Evaluated market-level contribution to total sales.

### 6. Discount Impact

- Compared profit margins across discount ranges.
- Identified cases where high discounts reduced profitability.
- Highlighted categories and regions sensitive to discounting.

## Business Insights

- **APAC is the highest revenue-generating market**, followed by EU and the US.
- **Technology generates the highest sales**, while Office Supplies contributes strong order volume.
- **Standard Class is the dominant shipping mode**, contributing the majority of sales.
- **The United States is the top country by sales**, followed by Australia and France.
- **England and California are among the strongest state-level performers.**
- **Discounting requires careful control**, because higher discounts can reduce or reverse profit margins.

## Recommendations

- Prioritize high-performing markets such as APAC, EU, and the US for growth campaigns.
- Review low-profit and negative-profit products before increasing promotion spend.
- Use discount thresholds to prevent margin erosion.
- Optimize shipping strategy by monitoring Standard Class volume and shipping cost.
- Focus category-level strategy on Technology growth while improving Furniture profitability.
- Track returned orders to identify product, region, or shipping-related quality issues.

## Power BI Dashboard Features

- KPI cards for sales, profit, quantity, and shipping cost
- Category, ship mode, and market filters
- Sales by country
- Sales by state
- Sales by category
- Sales by market
- Sales by shipping mode

## Skills Demonstrated

- SQL data analysis
- Python exploratory data analysis
- Data cleaning and feature engineering
- KPI design
- Profitability analysis
- Power BI dashboarding
- Business insight generation
- GitHub project documentation

## How to Use This Project

1. Open `Data & Resources/ECOMM DATA.xlsx` to review the source dataset.
2. Run SQL queries from `sql/ecommerce_analysis.sql` after importing the data into a SQL database.
3. Install Python dependencies:

```bash
pip install -r requirements.txt
```

4. Run Python EDA:

```bash
python python/ecommerce_eda.py
```

5. Open `E-Commerce Data Analysis.pbix` in Power BI Desktop to explore the dashboard.
6. Review `E-Commerce Data Analysis.pdf` for the exported dashboard report.

## Project Files

| File | Description |
| --- | --- |
| `E-Commerce Data Analysis.pbix` | Power BI dashboard file |
| `E-Commerce Data Analysis.pdf` | Exported dashboard report |
| `E-Commerce Data Analysis_page.jpg` | Dashboard preview image |
| `Data & Resources/ECOMM DATA.xlsx` | Source dataset |
| `sql/ecommerce_analysis.sql` | SQL business analysis queries |
| `python/ecommerce_eda.py` | Python EDA and feature engineering script |
| `docs/data_dictionary.md` | Data dictionary |
