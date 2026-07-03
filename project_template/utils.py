"""Generic, reusable utility functions for the project."""

import dataclasses
import enum
from pathlib import Path
import random
import sys
import typing

from loguru import logger
from loguru._logger import Logger
import numpy as np


def set_seed(seed: int = 42) -> None:
    """Set random seed for reproducibility across random, numpy, and PyTorch (if available)."""
    random.seed(seed)
    np.random.seed(seed)
    try:
        import torch
        torch.manual_seed(seed)
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)
    except ImportError:
        pass


def cast_random_state(
    seed: int | np.random.RandomState | None = None,
) -> np.random.RandomState:
    """Cast seed to a numpy.random.RandomState instance."""
    if seed is None or isinstance(seed, (int, np.integer)):
        return np.random.RandomState(seed)
    if isinstance(seed, np.random.RandomState):
        return seed
    raise ValueError(
        f"{seed} cannot be used to seed a numpy.random.RandomState instance"
    )


def get_logger() -> Logger:
    """Configure and return a custom loguru logger."""
    logger.remove()
    custom_format = (
        "{time:%y-%m-%d %H:%M:%S} | "
        "<level>{level.name:.1s}</level> | "
        "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
        "<level>{message}</level>"
    )
    logger.add(sys.stderr, format=custom_format, colorize=True)
    return logger


def enum_values[E](enum_cls: type[E]) -> list[str]:
    """Return a list of string values for a StrEnum class."""
    return [e.value for e in enum_cls]  # type: ignore[attr-defined]


def _format_float(val: float) -> str:
    """Format float: scientific notation for very large/small values, else 4 decimals."""
    if val == 0.0:
        return "0.0"
    abs_val = abs(val)
    if abs_val < 1e-3 or abs_val >= 1e4:
        return f"{val:.4e}"
    s = f"{val:.4f}".rstrip("0").rstrip(".")
    return s if "." in s or "e" in s else f"{s}.0"


def _format_dataclass(val: typing.Any, indent: int, spaces: int) -> str:
    """Format a dataclass recursively into an indented representation."""
    prefix = " " * indent
    sub_prefix = " " * (indent + spaces)
    fields = dataclasses.fields(val)
    if not fields:
        return f"{val.__class__.__name__}()"
    lines = []
    for f in fields:
        v = getattr(val, f.name)
        formatted_v = format_config(v, indent + spaces, spaces)
        lines.append(f"{sub_prefix}{f.name}={formatted_v.lstrip()}")
    joined = ",\n".join(lines) + ","
    return f"{val.__class__.__name__}(\n{joined}\n{prefix})"


def _format_dict(val: dict[typing.Any, typing.Any], indent: int, spaces: int) -> str:
    """Format a dictionary recursively into an indented representation."""
    prefix = " " * indent
    sub_prefix = " " * (indent + spaces)
    if not val:
        return "{}"
    lines = []
    for k, v in val.items():
        formatted_v = format_config(v, indent + spaces, spaces)
        lines.append(f"{sub_prefix}{repr(k)}: {formatted_v.lstrip()}")
    joined = ",\n".join(lines) + ","
    return f"{{\n{joined}\n{prefix}}}"


def _format_sequence(
    val: list[typing.Any] | tuple[typing.Any, ...] | set[typing.Any],
    indent: int,
    spaces: int,
) -> str:
    """Format sequence, choosing multiline for complex/long structures."""
    prefix = " " * indent
    sub_prefix = " " * (indent + spaces)
    if not val:
        empty_reprs = {list: "[]", tuple: "()", set: "set()"}
        return empty_reprs[type(val)]

    is_complex = any(
        dataclasses.is_dataclass(x) or isinstance(x, (dict, list, tuple, set))
        for x in val
    )
    if is_complex or len(val) > 10:
        lines = []
        for x in val:
            formatted_x = format_config(x, indent + spaces, spaces)
            lines.append(f"{sub_prefix}{formatted_x.lstrip()}")
        joined = ",\n".join(lines) + ","
        start, end = {list: ("[", "]"), tuple: ("(", ")"), set: ("{", "}")}[type(val)]
        return f"{start}\n{joined}\n{prefix}{end}"

    items = [format_config(x, 0, spaces) for x in val]
    start, end = {list: ("[", "]"), tuple: ("(", ")"), set: ("{", "}")}[type(val)]
    return f"{start}{', '.join(items)}{end}"


def format_config(val: typing.Any, indent: int = 0, spaces: int = 2) -> str:
    """Format configuration objects into a highly readable string.

    Floating point numbers are formatted with scientific notation if they are
    very large (>= 1e4) or very small (< 1e-3), otherwise they are rounded
    to at most 4 decimal places.
    """
    if dataclasses.is_dataclass(val):
        return _format_dataclass(val, indent, spaces)
    if isinstance(val, dict):
        return _format_dict(val, indent, spaces)
    if isinstance(val, (list, tuple, set)):
        return _format_sequence(val, indent, spaces)
    if isinstance(val, bool):
        return str(val)
    if isinstance(val, (int, np.integer)):
        return str(int(val))
    if isinstance(val, (float, np.floating)):
        return _format_float(float(val))
    if isinstance(val, Path):
        return repr(str(val))
    if isinstance(val, enum.Enum):
        return f"{val.__class__.__name__}.{val.name}"
    return repr(val)
