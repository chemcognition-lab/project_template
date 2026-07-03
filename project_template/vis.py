"""Plotting and visualization helpers for the optimization pipeline."""

from pathlib import Path

from loguru import logger
import matplotlib.pyplot as plt
import seaborn as sns  # type: ignore


def set_visualization_style() -> None:
    """Set global plotting style parameters for polished scientific figures."""
    sns.set_theme(
        style="ticks",
        palette="husl",
        rc={
            "axes.grid": True,
            "grid.color": "#e5e5e5",
            "grid.linestyle": "--",
            "grid.linewidth": 0.6,
            "savefig.dpi": 300,
            "savefig.transparent": True,
            "savefig.pad_inches": 0.1,
            "axes.linewidth": 2.5,
            "legend.markerscale": 1.0,
            "legend.fontsize": "small",
        },
    )


def save_figure(fig: plt.Figure, path: Path) -> None:
    """Save a matplotlib figure as both PNG (solid white bg) and SVG (transparent)."""
    # PNG with opaque white background
    fig.savefig(
        path,
        dpi=300,
        bbox_inches="tight",
        facecolor="white",
        transparent=False,
    )
    # SVG with transparent background
    fig.savefig(
        path.with_suffix(".svg"),
        bbox_inches="tight",
        transparent=True,
    )
    plt.close(fig)
    logger.info(f"Saved figure to {path} and {path.with_suffix('.svg')}")

