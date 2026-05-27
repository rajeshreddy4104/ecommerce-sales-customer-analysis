# Data Quality & Feature Engineering

## Data Cleaning Checks

The analysis validates the dataset before building KPIs or dashboards.

| Check | Purpose |
| --- | --- |
| Null checks | Identify missing values that may affect KPI accuracy |
| Duplicate checks | Detect repeated rows or repeated order/product line items |
| Data type conversions | Convert order and shipping dates into datetime fields |
| Outlier checks | Flag unusually high or low values in sales, profit, discount, quantity, and shipping cost |
| Category standardization | Strip whitespace and standardize text categories for consistent grouping |

## Data Type Conversions

| Field | Conversion |
| --- | --- |
| Order Date | Converted to datetime |
| Ship Date | Converted to datetime |
| Sales | Used as numeric revenue |
| Profit | Used as numeric profit |
| Discount | Used as numeric discount rate |
| Shipping Cost | Used as numeric shipping cost |

## Feature Engineering

| Feature | Description | Business Use |
| --- | --- | --- |
| order_year | Year extracted from order date | Yearly sales and profit trend |
| order_month | Month extracted from order date | Monthly and seasonal analysis |
| shipping_delay | Days between order date and ship date | Shipping speed and operational analysis |
| profit_margin | Profit divided by sales | Profitability comparison |
| customer_segment | Standardized customer segment field | Customer behavior analysis |
| sales_bucket | Groups transactions by order value | Revenue band analysis |
| discount_band | Groups discount levels | Discount impact analysis |
| is_returned | Flags returned orders | Return-rate and product quality analysis |

## Outlier Handling Approach

Outliers are flagged using the IQR method:

```text
IQR = Q3 - Q1
Lower Bound = Q1 - 1.5 * IQR
Upper Bound = Q3 + 1.5 * IQR
```

Outliers are not automatically removed because large sales, profit, or shipping-cost values may be valid business events. Instead, they are reviewed as potential high-impact transactions.

## Business Impact

These cleaning and feature engineering steps make the analysis more reliable by ensuring that KPIs are calculated from consistent fields, date trends are properly extracted, and profitability can be compared across customers, products, regions, and discount levels.

