"""Centralized paths and physical hardware constants for the optimization task.

Example:
    >>> import src
    >>> _P = src.paths_and_constants.Paths()
    >>> _C = src.paths_and_constants.Constants()
    >>> print(_C.total_volume_ml)
"""

from pathlib import Path


class Paths:
    """Centralized project directories and file paths."""

    root: Path = Path(__file__).resolve().parents[1]
    data_dir: Path = root / "data"
    models_dir: Path = root / "models"
    results_dir: Path = root / "results"


class Constants:
    """Global constants used across the project."""

    total_volume_ml: float = 100.0
