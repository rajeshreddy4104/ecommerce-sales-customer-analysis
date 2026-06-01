# Power BI Dashboard Review

## Current Status

The current Power BI dashboard is included in the project as both a PBIX file and exported PDF. It covers the main business areas needed for the project:

- Executive KPIs
- Sales trend
- Sales and profit by category
- Sales by region
- Sales by segment
- Top products by sales
- Top products by profit
- Sales and profit by market
- Sales by ship mode
- Customer segment contribution

## What Works Well

| Area | Why It Works |
| --- | --- |
| KPI cards | Gives quick executive summary |
| Region/category/segment/market slicers | Allows interactive filtering |
| Sales vs profit category views | Shows that revenue and profitability are different |
| Top product charts | Supports product-level business decisions |
| Market comparison | Helps identify strongest global markets |
| Ship mode view | Adds operational analysis |

## Recommended Improvements

| Issue | Fix |
| --- | --- |
| Sales trend is too noisy | Use monthly `Year Month` instead of daily `Order Date` |
| Total Orders may be overcounted | Use distinct count of `Order ID` |
| KPI framework is incomplete | Add AOV, Profit Margin %, and Repeat Customer Rate cards |
| Slicers take too much space | Use dropdown slicers or a left-side filter panel |
| Visual labels are technical | Rename labels to business-friendly names |
| Dotted page border is distracting | Remove it or use a cleaner theme |

## Included Screenshots

The exported dashboard screenshots are saved as:

```text
assets/screenshots/executive_overview.png
assets/screenshots/product_analysis.png
assets/screenshots/customer_market_analysis.png
```

The dashboard files are saved as:

```text
dashboards/ecommerce_sales_customer_dashboard.pbix
dashboards/ecommerce_sales_customer_dashboard.pdf
```
