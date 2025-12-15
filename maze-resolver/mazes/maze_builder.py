import re
from dataclasses import dataclass
from pathlib import Path
from typing import List, Set, Tuple, Optional

import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

Pos = Tuple[int, int]  # (row, col), 1-based in input


@dataclass
class Maze:
    rows: int
    cols: int
    start: Pos
    obstacles: Set[Pos]
    goals: List[Pos]


def parse_maze(text: str) -> Maze:
    # Remove comments that start with %
    lines = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("%"):
            continue
        # Remove inline comments after %
        line = line.split("%", 1)[0].strip()
        if line:
            lines.append(line)
    clean = "\n".join(lines)

    def grab_int(pattern: str) -> int:
        m = re.search(pattern, clean)
        if not m:
            raise ValueError(f"Campo mancante: {pattern}")
        return int(m.group(1))

    cols = grab_int(r"num_col\((\d+)\)\.")
    rows = grab_int(r"num_righe\((\d+)\)\.")

    m_start = re.search(r"iniziale\(pos\((\d+)\s*,\s*(\d+)\)\)\.", clean)
    if not m_start:
        raise ValueError("Campo mancante: iniziale(pos(r,c)).")
    start = (int(m_start.group(1)), int(m_start.group(2)))

    obstacles: Set[Pos] = set()
    for m in re.finditer(r"occupata\(pos\((\d+)\s*,\s*(\d+)\)\)\.", clean):
        obstacles.add((int(m.group(1)), int(m.group(2))))

    # finale([pos(r,c), pos(r,c), ...]).
    m_finale = re.search(r"finale\(\[(.*?)\]\)\.", clean, flags=re.DOTALL)
    if not m_finale:
        raise ValueError("Campo mancante: finale([pos(...), ...]).")

    goals: List[Pos] = []
    finale_body = m_finale.group(1)
    for m in re.finditer(r"pos\((\d+)\s*,\s*(\d+)\)", finale_body):
        goals.append((int(m.group(1)), int(m.group(2))))

    # Basic validation
    def in_bounds(p: Pos) -> bool:
        r, c = p
        return 1 <= r <= rows and 1 <= c <= cols

    if not in_bounds(start):
        raise ValueError(f"Start fuori griglia: {start}")

    for p in obstacles:
        if not in_bounds(p):
            raise ValueError(f"Ostacolo fuori griglia: {p}")

    for p in goals:
        if not in_bounds(p):
            raise ValueError(f"Goal fuori griglia: {p}")

    return Maze(rows=rows, cols=cols, start=start, obstacles=obstacles, goals=goals)


def render_maze(maze: Maze, out_path: str = "maze.png", cell_size: float = 0.5) -> None:
    rows, cols = maze.rows, maze.cols

    fig_w = cols * cell_size
    fig_h = rows * cell_size
    fig, ax = plt.subplots(figsize=(fig_w, fig_h), dpi=200)

    # Background
    ax.add_patch(Rectangle((0, 0), cols, rows, facecolor="white", edgecolor="none"))

    # Draw grid lines
    ax.set_xlim(0, cols)
    ax.set_ylim(0, rows)
    ax.set_aspect("equal")

    ax.set_xticks(range(cols + 1))
    ax.set_yticks(range(rows + 1))
    ax.grid(True, linewidth=0.6)

    # Helper: convert (row,col) 1-based with origin top-left into matplotlib coords
    # We'll place cells with (0,0) at bottom-left, so y is flipped.
    def cell_xy(p: Pos) -> Tuple[int, int]:
        r, c = p
        x = c - 1
        y = rows - r
        return x, y

    # Obstacles (black)
    for p in maze.obstacles:
        x, y = cell_xy(p)
        ax.add_patch(Rectangle((x, y), 1, 1, facecolor="black"))

    # Goals (red)
    for p in maze.goals:
        x, y = cell_xy(p)
        ax.add_patch(Rectangle((x, y), 1, 1, facecolor="red", alpha=0.9))

    # Start (green) on top (if overlaps with obstacle/goal, it will be visible)
    sx, sy = cell_xy(maze.start)
    ax.add_patch(Rectangle((sx, sy), 1, 1, facecolor="limegreen"))

    # Remove axis labels (keep only grid)
    ax.set_xticklabels([])
    ax.set_yticklabels([])
    ax.tick_params(length=0)

    ax.set_title(f"Labirinto {rows}x{cols}", pad=10)
    plt.tight_layout()
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


def main():
    # 1) Incolla qui il testo del labirinto (quello che hai mandato tu).
    #    In alternativa, leggi da file (vedi sotto).
    labyrinth_text = r"""
num_col(20).
num_righe(20).
iniziale(pos(1, 1)).
occupata(pos(1, 10)).
occupata(pos(1, 11)).
occupata(pos(1, 12)).
occupata(pos(2, 5)).
occupata(pos(2, 6)).
occupata(pos(2, 15)).
occupata(pos(3, 5)).
occupata(pos(3, 10)).
occupata(pos(3, 15)).
occupata(pos(4, 2)).
occupata(pos(4, 3)).
occupata(pos(4, 4)).
occupata(pos(4, 6)).
occupata(pos(4, 8)).
occupata(pos(4, 12)).
occupata(pos(4, 18)).
occupata(pos(5, 6)).
occupata(pos(5, 8)).
occupata(pos(5, 12)).
occupata(pos(5, 18)).
occupata(pos(6, 2)).
occupata(pos(6, 3)).
occupata(pos(6, 4)).
occupata(pos(6, 10)).
occupata(pos(6, 11)).
occupata(pos(6, 12)).
occupata(pos(6, 18)).
occupata(pos(7, 8)).
occupata(pos(7, 12)).
occupata(pos(7, 18)).
occupata(pos(8, 8)).
occupata(pos(8, 12)).
occupata(pos(8, 18)).
occupata(pos(9, 5)).
occupata(pos(9, 6)).
occupata(pos(9, 7)).
occupata(pos(9, 8)).
occupata(pos(9, 12)).
occupata(pos(9, 18)).
occupata(pos(10, 10)).
occupata(pos(10, 11)).
occupata(pos(10, 12)).
occupata(pos(10, 18)).
occupata(pos(11, 2)).
occupata(pos(11, 3)).
occupata(pos(11, 4)).
occupata(pos(11, 6)).
occupata(pos(11, 12)).
occupata(pos(11, 18)).
occupata(pos(12, 6)).
occupata(pos(12, 12)).
occupata(pos(12, 18)).
occupata(pos(13, 8)).
occupata(pos(13, 9)).
occupata(pos(13, 10)).
occupata(pos(13, 12)).
occupata(pos(13, 18)).
occupata(pos(14, 15)).
occupata(pos(14, 16)).
occupata(pos(14, 17)).
occupata(pos(14, 18)).
occupata(pos(15, 5)).
occupata(pos(15, 6)).
occupata(pos(15, 7)).
occupata(pos(15, 8)).
occupata(pos(15, 12)).
occupata(pos(15, 18)).
occupata(pos(16, 10)).
occupata(pos(16, 11)).
occupata(pos(16, 12)).
occupata(pos(16, 18)).
occupata(pos(17, 2)).
occupata(pos(17, 3)).
occupata(pos(17, 4)).
occupata(pos(17, 6)).
occupata(pos(17, 12)).
occupata(pos(17, 18)).
occupata(pos(18, 6)).
occupata(pos(18, 12)).
occupata(pos(18, 18)).
occupata(pos(19, 8)).
occupata(pos(19, 9)).
occupata(pos(19, 10)).
occupata(pos(19, 12)).
occupata(pos(19, 18)).
occupata(pos(20, 15)).
occupata(pos(20, 16)).
occupata(pos(20, 17)).
occupata(pos(20, 18)).
occupata(pos(20, 19)).
finale([pos(20, 20)]).
"""

    # Se preferisci leggere da file:
    # labyrinth_text = Path("labirinto.pl").read_text(encoding="utf-8")

    maze = parse_maze(labyrinth_text)
    render_maze(maze, out_path="maze_20x20.png")
    print("Creato: maze_20x20.png")


if __name__ == "__main__":
    main()