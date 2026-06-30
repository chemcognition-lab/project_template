"""Plotting and visualization helpers for the optimization pipeline."""

import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns  # type: ignore


def set_visualization_style() -> None:
    """Set global plotting style parameters for high-quality figures."""
    mpl.rcParams["savefig.dpi"] = 300
    mpl.rcParams["savefig.pad_inches"] = 0.1
    mpl.rcParams["savefig.transparent"] = True
    mpl.rcParams["axes.linewidth"] = 2.5
    mpl.rcParams["legend.markerscale"] = 1.0
    mpl.rcParams["legend.fontsize"] = "small"
    sns.set_theme(style="ticks")  # Set ticks style as default
