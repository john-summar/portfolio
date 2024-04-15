import plotly.express as px
from dash import Dash, html, dcc, Input, Output
import dash_bootstrap_components as dbc
import pandas as pd
import random

# https://www.kaggle.com/datasets/rkiattisak/sports-car-prices-dataset

# to update on page load, you can load figure straight into dcc.Graph(argument is 'figure =')
# then I can update/filter based on a hover over the treemap


csv_path = "https://docs.google.com/spreadsheets/d/1mbWxDrFBzazFdtFvp7DfZ1yq8x5l_va6Nlr6xYZyohM/export?format=csv"
df = pd.read_csv(csv_path)  # get data
# clean said data so plotly makes cleaner graphs with it
df["CarMake"] = df["CarMake"].astype(str)
df["CarModel"] = df["CarModel"].astype(str)
df["OriginCountry"] = df["OriginCountry"].astype(str)
df["CountryISO"] = df["CountryISO"].astype(str)
df["EngineSize(L)"] = df["EngineSize(L)"].astype(float)
df["Horsepower"] = df["Horsepower"].astype(float)
df["Torque(lb-ft)"] = df["Torque(lb-ft)"].astype(float)
df["0-60 MPHTime(seconds)"] = df["0-60 MPHTime(seconds)"].astype(float)
df["Price(in USD)"] = df["Price(in USD)"].astype(float)


default_plot_type = "0-60 MPHTime(seconds)"
default_years = (min(df["Year"]), max(df["Year"]))

app = Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP, dbc.themes.DARKLY])

app.layout = html.Div(
    [
        dbc.Row(
            [
                dbc.Col(
                    html.H1(
                        "Project 2", id="project-title", style={"font-weight": "bold"}
                    ),
                    align="center",
                    width=8,
                    class_name="border ",
                ),
                dbc.Col(
                    html.Button(
                        id="button",
                        children="CLICK ME!",
                        style={"background-color": "white", "color": "black"},
                    ),
                    width=4,
                    align="center",
                ),
            ]
        ),
        dbc.Row(
            [
                dbc.Col(
                    dcc.Dropdown(
                        options=[
                            {"label": make, "value": make}
                            for make in df["CarMake"].sort_values().unique()
                        ],
                        value="All",
                        id="make-dropdown",
                    ),
                    width=3,
                    class_name="border",
                ),
                dbc.Col(
                    dcc.Graph(
                        id="treemap"
                    ),  # figure = px.treemap(df, path=["CarMake", "CarModel"], values="Horsepower") and then make a callback that updates charts below based on hover_data
                    width=9,
                    class_name="border",
                ),
            ]
        ),
        dbc.Row(
            dbc.Col(
                dcc.RangeSlider(
                    min=1965,
                    max=2023,
                    step=5,
                    value=default_years,
                    id="year-slider",
                    allowCross=False,
                    tooltip={"placement": "bottom", "always_visible": True},
                ),
            )
        ),
        dbc.Row(
            [
                dbc.Col(
                    dcc.RadioItems(
                        options=[
                            {"label": "0-60 Time", "value": "0-60 MPHTime(seconds)"},
                            {"label": "Horsepower", "value": "Horsepower"},
                            {"label": "Torque", "value": "Torque(lb-ft)"},
                        ],
                        value=default_plot_type,
                        inline=True,
                        id="radio-button",
                    ),
                    width=3,
                    class_name="border",
                ),
                dbc.Col(dcc.Graph(id="multi-plot"), width=9, class_name="border"),
            ]
        ),
    ]
)


@app.callback(Output("project-title", "style"), [Input("button", "n_clicks")])
def easter_egg(n_clicks):
    if n_clicks is not None and n_clicks > 0:
        # Change the color to a random color on button click
        random_color = "#{:06x}".format(random.randint(0, 0xFFFFFF))
        return {"color": random_color}
    else:
        # Default style
        return {"color": "white"}


default_make = "All"
default_plot_type = "0-60 MPHTime(seconds)"
default_years = (min(df["Year"]) + 10, max(df["Year"]) - 13)


@app.callback(
    Output("treemap", "figure"),
    [Input("make-dropdown", "value"), Input("multi-plot", "hoverData")],
)
def treemap(make, hover_data):
    if make is None or make == "All":
        fig = px.treemap(df, path=["CarMake", "CarModel"], values="Horsepower")

        if hover_data is not None:
            hover_df = df.copy()
            hover_brand = hover_data["points"][0]["hovertext"]
            hover_df = hover_df[hover_df["CarMake"] == hover_brand]

            fig = px.treemap(
                hover_df,
                path=[px.Constant("All"), "CarMake", "CarModel"],
                values="Horsepower",
            )

        else:
            fig = px.treemap(df, path=["CarMake", "CarModel"], values="Horsepower")

    else:
        plot_df = df[df["CarMake"] == make]
        fig = px.treemap(plot_df, path=["CarMake", "CarModel"], values="Horsepower")

        if hover_data is not None:
            hover_brand = hover_data["points"][0]["hovertext"]
            if hover_brand != "All":
                hover_df = df[df["CarMake"] == hover_brand]
                fig = px.treemap(
                    hover_df,
                    path=[px.Constant("All"), "CarMake", "CarModel"],
                    values="Horsepower",
                )

    return fig


@app.callback(
    Output("multi-plot", "figure"),
    [
        Input("radio-button", "value"),
        Input("make-dropdown", "value"),
        Input("year-slider", "value"),
    ],
)
def multi_plot(plot_type, make, selected_years):
    # Set default values if not selected by the user

    if plot_type is None:
        plot_type = default_plot_type
    if selected_years is None:
        selected_years = default_years

    make_filtered_df = df

    make_year_filtered_df = make_filtered_df[
        (make_filtered_df["Year"] >= selected_years[0])
        & (make_filtered_df["Year"] <= selected_years[1])
    ]

    if plot_type == "0-60 MPHTime(seconds)":
        fig = px.scatter(
            make_year_filtered_df,
            x="Price(in USD)",
            y="0-60 MPHTime(seconds)",
            color="CarMake",
            hover_name="CarMake",
            hover_data=["CarModel", "Year"],
        )
    elif plot_type == "Horsepower":
        fig = px.scatter(
            make_year_filtered_df,
            x="Price(in USD)",
            y="Horsepower",
            color="EngineSize(L)",
            hover_name="CarMake",
            hover_data=["CarModel", "Year"],
        )
    elif plot_type == "Torque(lb-ft)":
        fig = px.scatter(
            make_year_filtered_df,
            x="Price(in USD)",
            y="Torque(lb-ft)",
            color="EngineSize(L)",
            hover_name="CarMake",
            hover_data=["CarModel", "Year"],
        )
    else:
        fig = px.scatter(
            make_year_filtered_df,
            x="Price(in USD)",
            y="0-60 MPHTime(seconds)",
            color="CarMake",
            hover_name="CarMake",
            hover_data=["CarModel", "Year"],
        )
    return fig


if __name__ == "__main__":
    app.run(debug=True)
