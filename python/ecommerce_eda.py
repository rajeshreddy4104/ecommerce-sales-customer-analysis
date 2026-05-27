"""Exploratory data analysis for the e-commerce analytics project.

Run:
    python python/ecommerce_eda.py
"""

from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "Data & Resources" / "ECOMM DATA.xlsx"


def clean_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Convert source headers into analysis-friendly snake_case names."""
    df = df.copy()
    df.columns = (
        df.columns.str.strip()
        .str.lower()
        .str.replace("-", "_", regex=False)
        .str.replace(" ", "_", regex=False)
    )
    return df


def load_data() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    try:
        orders = clean_columns(pd.read_excel(DATA_PATH, sheet_name="Orders"))
        returns = clean_columns(pd.read_excel(DATA_PATH, sheet_name="Returns"))
        people = clean_columns(pd.read_excel(DATA_PATH, sheet_name="People"))
    except ImportError as exc:
        raise SystemExit(
            "Missing Excel dependency. Install project requirements with: "
            "pip install -r requirements.txt"
        ) from exc
    return orders, returns, people


def add_features(orders: pd.DataFrame, returns: pd.DataFrame) -> pd.DataFrame:
    orders = orders.copy()

    text_columns = ["category", "sub_category", "segment", "market", "region", "ship_mode"]
    for column in text_columns:
        orders[column] = orders[column].astype(str).str.strip().str.title()

    orders["order_date"] = pd.to_datetime(orders["order_date"])
    orders["ship_date"] = pd.to_datetime(orders["ship_date"])
    orders["order_year"] = orders["order_date"].dt.year
    orders["order_month"] = orders["order_date"].dt.month
    orders["order_month_name"] = orders["order_date"].dt.strftime("%b")
    orders["shipping_delay"] = (orders["ship_date"] - orders["order_date"]).dt.days
    orders["profit_margin"] = orders["profit"] / orders["sales"]
    orders["customer_segment"] = orders["segment"]
    orders["sales_bucket"] = pd.cut(
        orders["sales"],
        bins=[-0.01, 100, 500, 1000, float("inf")],
        labels=["Low", "Medium", "High", "Premium"],
    )

    returned_orders = set(returns["order_id"].dropna())
    orders["is_returned"] = orders["order_id"].isin(returned_orders)

    orders["discount_band"] = pd.cut(
        orders["discount"],
        bins=[-0.01, 0, 0.10, 0.20, 0.30, 1],
        labels=["No Discount", "0-10%", "10-20%", "20-30%", "30%+"],
    )
    return orders


def data_quality_report(orders: pd.DataFrame) -> None:
    numeric_columns = ["sales", "quantity", "discount", "shipping_cost", "profit"]

    print_section("Data Quality Checks")
    print("Null values by column:")
    print(orders.isna().sum().sort_values(ascending=False).head(10))

    print("\nDuplicate full rows:")
    print(orders.duplicated().sum())

    print("\nDuplicate order/product line checks:")
    print(orders.duplicated(subset=["order_id", "product_id", "product_name"]).sum())

    print("\nData types:")
    print(orders.dtypes)

    print("\nCategory standardization checks:")
    for column in ["category", "segment", "market", "ship_mode"]:
        print(f"{column}: {sorted(orders[column].dropna().unique())}")

    print("\nOutlier check using IQR bounds:")
    for column in numeric_columns:
        q1 = orders[column].quantile(0.25)
        q3 = orders[column].quantile(0.75)
        iqr = q3 - q1
        lower = q1 - 1.5 * iqr
        upper = q3 + 1.5 * iqr
        outliers = orders[(orders[column] < lower) | (orders[column] > upper)]
        print(f"{column}: {len(outliers):,} potential outliers")


def print_section(title: str) -> None:
    print(f"\n{'=' * 80}\n{title}\n{'=' * 80}")


def calculate_kpis(orders: pd.DataFrame) -> dict[str, float | str]:
    total_sales = orders["sales"].sum()
    total_profit = orders["profit"].sum()
    total_orders = orders["order_id"].nunique()
    customer_order_counts = orders.groupby("customer_id")["order_id"].nunique()

    return {
        "Total Sales": total_sales,
        "Total Profit": total_profit,
        "Total Orders": total_orders,
        "Average Order Value": total_sales / total_orders,
        "Profit Margin %": total_profit / total_sales,
        "Top Region": orders.groupby("region")["sales"].sum().idxmax(),
        "Top Category": orders.groupby("category")["sales"].sum().idxmax(),
        "Repeat Customer Rate": (customer_order_counts > 1).mean(),
    }


def main() -> None:
    orders, returns, people = load_data()
    orders = add_features(orders, returns)
    data_quality_report(orders)

    print_section("Dataset Shape")
    print(f"Orders rows: {orders.shape[0]:,}")
    print(f"Returns rows: {returns.shape[0]:,}")
    print(f"People rows: {people.shape[0]:,}")
    print(f"Date range: {orders['order_date'].min().date()} to {orders['order_date'].max().date()}")

    print_section("Overall KPIs")
    kpis = calculate_kpis(orders)
    for metric, value in kpis.items():
        if isinstance(value, str):
            print(f"{metric}: {value}")
        elif "Rate" in metric or "%" in metric:
            print(f"{metric}: {value:.2%}")
        else:
            print(f"{metric}: {value:,.2f}")

    print_section("Sales by Category")
    print(
        orders.groupby("category")
        .agg(sales=("sales", "sum"), profit=("profit", "sum"), quantity=("quantity", "sum"))
        .sort_values("sales", ascending=False)
        .round(2)
    )

    print_section("Sales by Market")
    print(
        orders.groupby("market")
        .agg(sales=("sales", "sum"), profit=("profit", "sum"), profit_margin=("profit_margin", "mean"))
        .sort_values("sales", ascending=False)
        .round(4)
    )

    print_section("Top 10 Countries by Sales")
    print(
        orders.groupby("country")
        .agg(sales=("sales", "sum"), profit=("profit", "sum"))
        .sort_values("sales", ascending=False)
        .head(10)
        .round(2)
    )

    print_section("Customer Segment Performance")
    print(
        orders.groupby("customer_segment")
        .agg(
            customers=("customer_id", "nunique"),
            orders=("order_id", "nunique"),
            sales=("sales", "sum"),
            profit=("profit", "sum"),
        )
        .sort_values("sales", ascending=False)
        .round(2)
    )

    print_section("Top 10 Customers by Sales")
    customer_summary = (
        orders.groupby(["customer_id", "customer_name", "customer_segment"])
        .agg(
            orders=("order_id", "nunique"),
            sales=("sales", "sum"),
            profit=("profit", "sum"),
            quantity=("quantity", "sum"),
        )
        .assign(
            avg_order_value=lambda df: df["sales"] / df["orders"],
            basic_clv=lambda df: df["sales"],
            profit_margin=lambda df: df["profit"] / df["sales"],
            is_repeat_customer=lambda df: df["orders"] > 1,
        )
        .sort_values("sales", ascending=False)
    )
    print(customer_summary.head(10).round(4))

    print_section("Repeat Customer Analysis")
    repeat_summary = (
        customer_summary.reset_index()
        .groupby("is_repeat_customer")
        .agg(
            customers=("customer_id", "nunique"),
            sales=("sales", "sum"),
            profit=("profit", "sum"),
            avg_order_value=("avg_order_value", "mean"),
        )
        .assign(profit_margin=lambda df: df["profit"] / df["sales"])
    )
    print(repeat_summary.round(4))

    print_section("Sales Bucket Performance")
    print(
        orders.groupby("sales_bucket", observed=False)
        .agg(line_items=("order_id", "count"), sales=("sales", "sum"), profit=("profit", "sum"))
        .assign(profit_margin=lambda df: df["profit"] / df["sales"])
        .round(4)
    )

    print_section("Discount Impact")
    print(
        orders.groupby("discount_band", observed=False)
        .agg(line_items=("order_id", "count"), sales=("sales", "sum"), profit=("profit", "sum"))
        .assign(profit_margin=lambda df: df["profit"] / df["sales"])
        .round(4)
    )

    print_section("Profit by Category")
    print(
        orders.groupby("category")
        .agg(sales=("sales", "sum"), profit=("profit", "sum"), avg_discount=("discount", "mean"))
        .assign(profit_margin=lambda df: df["profit"] / df["sales"])
        .sort_values("profit", ascending=False)
        .round(4)
    )

    print_section("Top 10 Loss-Making Products")
    product_profitability = (
        orders.groupby(["product_id", "product_name", "category", "sub_category"])
        .agg(sales=("sales", "sum"), profit=("profit", "sum"), avg_discount=("discount", "mean"))
        .assign(profit_margin=lambda df: df["profit"] / df["sales"])
    )
    print(
        product_profitability.query("profit < 0")
        .sort_values("profit")
        .head(10)
        .round(4)
    )

    print_section("Top 10 Low-Margin Products with Positive Sales")
    print(
        product_profitability.query("sales > 0")
        .sort_values("profit_margin")
        .head(10)
        .round(4)
    )


if __name__ == "__main__":
    main()
