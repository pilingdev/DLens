"""
plot_yolo_comparison.py

Generates thesis-ready comparison charts for YOLOv9 vs YOLOv10 vs YOLOv11
mosquito detection model performance.

Outputs (saved next to this script, 300 DPI PNG):
  1. overall_metrics_comparison.png  - Precision/Recall/F1/mAP@50/mAP@50-95
  2. per_class_map_comparison.png    - per-class mAP@50-95
  3. mAP50_vs_mAP5095_comparison.png - mAP@50 vs mAP@50-95 side-by-side

To reuse with new numbers: just edit the MODELS / OVERALL_METRICS /
PER_CLASS_MAP dictionaries below and rerun the script.
"""

import matplotlib.pyplot as plt
import numpy as np
import os

# ----------------------------------------------------------------------
# 1. DATA — edit these values if your results change
# ----------------------------------------------------------------------

MODELS = ["YOLOv9", "YOLOv10", "YOLOv11"]
MODEL_COLORS = ["#4C72B0", "#DD8452", "#55A868"]  # blue, orange, green

OVERALL_METRICS = {
    "Precision":  [0.8867, 0.8517, 0.9588],
    "Recall":     [0.7816, 0.7694, 0.8771],
    "F1 Score":   [0.8308, 0.8085, 0.9161],
    "mAP@50":     [0.8110, 0.8081, 0.9294],
    "mAP@50-95":  [0.5513, 0.5196, 0.6697],
}

PER_CLASS_MAP = {  # mAP@50-95 per class
    "Aegypti":      [0.4912, 0.4991, 0.9032],
    "Albopictus":   [0.4079, 0.3952, 0.6697],
    "Anopheles":    [0.6148, 0.5499, 0.5825],
    "Culex":        [0.7084, 0.6595, 0.6697],
    "Non-mosquito": [0.5340, 0.4945, 0.5232],
}

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ----------------------------------------------------------------------
# 2. STYLE — clean, print-friendly look suitable for thesis documents
# ----------------------------------------------------------------------

plt.rcParams.update({
    "figure.dpi": 150,
    "savefig.dpi": 300,
    "font.size": 11,
    "axes.edgecolor": "#333333",
    "axes.labelcolor": "#222222",
    "axes.grid": True,
    "grid.color": "#dddddd",
    "grid.linewidth": 0.6,
    "axes.axisbelow": True,
    "font.family": "DejaVu Sans",
})


def _add_value_labels(ax, bars):
    """Print the value on top of each bar."""
    for bar in bars:
        height = bar.get_height()
        ax.annotate(
            f"{height:.3f}",
            xy=(bar.get_x() + bar.get_width() / 2, height),
            xytext=(0, 3),
            textcoords="offset points",
            ha="center", va="bottom",
            fontsize=8, color="#222222",
        )


def grouped_bar_chart(categories, data_dict, title, ylabel, filename,
                       ylim=(0, 1.05)):
    """
    categories: list of group labels (x-axis groups), e.g. metric names
                or class names
    data_dict: {category_name: [value_for_model1, value_for_model2, ...]}
    """
    n_groups = len(categories)
    n_models = len(MODELS)
    x = np.arange(n_groups)
    bar_width = 0.8 / n_models

    fig, ax = plt.subplots(figsize=(9, 5.5))

    for i, model in enumerate(MODELS):
        values = [data_dict[cat][i] for cat in categories]
        offset = (i - (n_models - 1) / 2) * bar_width
        bars = ax.bar(x + offset, values, bar_width,
                       label=model, color=MODEL_COLORS[i],
                       edgecolor="white", linewidth=0.5)
        _add_value_labels(ax, bars)

    ax.set_title(title, fontsize=13, fontweight="bold", pad=14)
    ax.set_ylabel(ylabel)
    ax.set_ylim(*ylim)
    ax.set_xticks(x)
    ax.set_xticklabels(categories)
    ax.legend(title="Model", frameon=False, loc="upper left",
              bbox_to_anchor=(1.01, 1.0))
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    fig.tight_layout()
    out_path = os.path.join(OUTPUT_DIR, filename)
    fig.savefig(out_path, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved: {out_path}")


# ----------------------------------------------------------------------
# 3. CHART 1 — Overall performance metrics
# ----------------------------------------------------------------------

grouped_bar_chart(
    categories=list(OVERALL_METRICS.keys()),
    data_dict=OVERALL_METRICS,
    title="Overall Model Performance: YOLOv9 vs YOLOv10 vs YOLOv11",
    ylabel="Score",
    filename="overall_metrics_comparison.png",
)

# ----------------------------------------------------------------------
# 4. CHART 2 — Per-class mAP@50-95
# ----------------------------------------------------------------------

grouped_bar_chart(
    categories=list(PER_CLASS_MAP.keys()),
    data_dict=PER_CLASS_MAP,
    title="Per-Class mAP@50-95: YOLOv9 vs YOLOv10 vs YOLOv11",
    ylabel="mAP@50-95",
    filename="per_class_map_comparison.png",
)

# ----------------------------------------------------------------------
# 5. CHART 3 — mAP@50 vs mAP@50-95 (two-panel comparison)
# ----------------------------------------------------------------------

fig, axes = plt.subplots(1, 2, figsize=(11, 5))
x = np.arange(len(MODELS))

for ax, (metric_key, metric_label) in zip(
        axes, [("mAP@50", "mAP@50"), ("mAP@50-95", "mAP@50-95")]):
    values = OVERALL_METRICS[metric_key]
    bars = ax.bar(x, values, width=0.55, color=MODEL_COLORS,
                   edgecolor="white", linewidth=0.5)
    _add_value_labels(ax, bars)
    ax.set_title(metric_label, fontsize=12, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels(MODELS)
    ax.set_ylim(0, 1.05)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

fig.suptitle("mAP Comparison Across IoU Thresholds", fontsize=13,
             fontweight="bold")
fig.tight_layout(rect=[0, 0, 1, 0.94])
out_path = os.path.join(OUTPUT_DIR, "mAP50_vs_mAP5095_comparison.png")
fig.savefig(out_path, bbox_inches="tight")
plt.close(fig)
print(f"Saved: {out_path}")

print("\nAll charts generated successfully.")