# Power BI Dashboard Interactivity

The Power BI dashboard is the final storytelling layer for the project. It connects the cleaned dataset, SQL analysis, Python EDA, KPI framework, and business recommendations into an interactive reporting experience.

## Interactive Features

| Feature | Description | Business Purpose |
| --- | --- | --- |
| KPI cards | Total Sales, Total Profit, Total Orders, AOV, Profit Margin %, Repeat Customer Rate | Gives immediate executive summary |
| Slicers | Date, Region, Market, Category, Segment, Ship Mode | Allows focused analysis by business dimension |
| Drill-downs | Category to sub-category to product; region to state to city | Enables detailed root-cause exploration |
| Filters | Returned orders, discount band, customer type, sales bucket | Helps isolate business scenarios |
| Interactive visuals | Trend charts, bar charts, maps, matrix tables, scatter plots | Supports comparison and exploration |
| Cross-filtering | Selecting a visual updates other dashboard visuals | Connects customer, product, region, and profit views |

## Dashboard Pages

| Page | Focus |
| --- | --- |
| Executive Overview | KPIs, sales trend, profit trend, top categories, top regions |
| Customer Analytics | Segments, top customers, repeat customers, basic CLV |
| Product & Profitability | Category profit, loss-making products, discount vs profit |
| Regional Performance | Region, state, city performance, regional growth |
| Operations | Shipping mode, shipping delay, returns, discount bands |

## Dashboard Coverage

The current dashboard includes the main portfolio visuals needed to explain the project:

- KPI cards for sales, quantity, orders, and profit
- Slicers for region, category, segment, and market
- Sales trend over time
- Sales and profit by category
- Sales by region and customer segment
- Top products by sales and profit
- Sales and profit by market
- Sales by ship mode
- Customer segment contribution

## Recommended Future Improvements

- Use `Distinct Count` of `Order ID` for Total Orders.
- Add KPI cards for `Average Order Value`, `Profit Margin %`, and `Repeat Customer Rate`.
- Change the sales trend from daily `Order Date` to monthly `Year Month` to reduce visual noise.
- Compact slicers into dropdowns or a left filter panel to free dashboard space.
- Replace the dotted page border with a cleaner theme or remove it.
- Rename fields in visuals from technical labels such as `Sum of Sales` to business labels such as `Total Sales`.

## Dashboard Goal

The dashboard should not only show what happened. It should help users quickly identify where revenue is growing, where profit is weak, which customers/products matter most, and which operational levers need attention.
