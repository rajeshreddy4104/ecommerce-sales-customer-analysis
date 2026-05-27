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
    orders["order_date"] = pd.to_datetime(orders["order_date"])
    orders["ship_date"] = pd.to_datetime(orders["ship_date"])
    orders["order_year"] = orders["order_date"].dt.year
    orders["order_month"] = orders["order_date"].dt.month
    orders["order_month_name"] = orders["order_date"].dt.strftime("%b")
    orders["ship_days"] = (orders["ship_date"] - orders["order_date"]).dt.days
    orders["profit_margin"] = orders["profit"] / orders["sales"]

    returned_orders = set(returns["order_id"].dropna())
    orders["is_returned"] = orders["order_id"].isin(returned_orders)

    orders["discount_band"] = pd.cut(
        orders["discount"],
        bins=[-0.01, 0, 0.10, 0.20, 0.30, 1],
        labels=["No Discount", "0-10%", "10-20%", "20-30%", "30%+"],
    )
    return orders


def print_section(title: str) -> None:
    print(f"\n{'=' * 80}\n{title}\n{'=' * 80}")


def main() -> None:
    orders, returns, people = load_data()
    orders = add_features(orders, returns)

    print_section("Dataset Shape")
    print(f"Orders rows: {orders.shape[0]:,}")
    print(f"Returns rows: {returns.shape[0]:,}")
    print(f"People rows: {people.shape[0]:,}")
    print(f"Date range: {orders['order_date'].min().date()} to {orders['order_date'].max().date()}")

    print_section("Overall KPIs")
    kpis = {
        "Total Sales": orders["sales"].sum(),
        "Total Profit": orders["profit"].sum(),
        "Total Quantity": orders["quantity"].sum(),
        "Total Shipping Cost": orders["shipping_cost"].sum(),
        "Profit Margin": orders["profit"].sum() / orders["sales"].sum(),
        "Return Rate": orders["is_returned"].mean(),
    }
    for metric, value in kpis.items():
        print(f"{metric}: {value:,.4f}" if "Rate" in metric or "Margin" in metric else f"{metric}: {value:,.2f}")

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
        orders.groupby("segment")
        .agg(
            customers=("customer_id", "nunique"),
            orders=("order_id", "nunique"),
            sales=("sales", "sum"),
            profit=("profit", "sum"),
        )
        .sort_values("sales", ascending=False)
        .round(2)
    )

    print_section("Discount Impact")
    print(
        orders.groupby("discount_band", observed=False)
        .agg(line_items=("order_id", "count"), sales=("sales", "sum"), profit=("profit", "sum"))
        .assign(profit_margin=lambda df: df["profit"] / df["sales"])
        .round(4)
    )

    print_section("Top 10 Loss-Making Products")
    print(
        orders.groupby(["product_id", "product_name", "category", "sub_category"])
        .agg(sales=("sales", "sum"), profit=("profit", "sum"), avg_discount=("discount", "mean"))
        .query("profit < 0")
        .sort_values("profit")
        .head(10)
        .round(4)
    )


if __name__ == "__main__":
    main()
