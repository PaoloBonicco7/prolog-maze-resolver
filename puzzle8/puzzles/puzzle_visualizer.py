from __future__ import annotations

from typing import Sequence, Tuple
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

State = Tuple[int, ...]  # 9 elementi


def validate_state(lst: Sequence[int]) -> State:
    if len(lst) != 9:
        raise ValueError("Lo stato deve avere ESATTAMENTE 9 elementi.")
    if sorted(lst) != list(range(9)):
        raise ValueError("Lo stato deve contenere tutti i numeri 0..8 una sola volta.")
    return tuple(int(x) for x in lst)


def render_8puzzle(state: State, out_path: str = "puzzle.png", cell_size: float = 0.9) -> None:
    """
    state: lista/tupla di 9 elementi in row-major (righe da sinistra a destra, dall'alto in basso)
    Esempio: [1,2,3,4,5,6,7,8,0]
      1 2 3
      4 5 6
      7 8 0
    """
    n = 3  # 3x3
    fig, ax = plt.subplots(figsize=(n * cell_size, n * cell_size), dpi=220)

    ax.set_xlim(0, n)
    ax.set_ylim(0, n)
    ax.set_aspect("equal")

    # Griglia (linee)
    ax.set_xticks(range(n + 1))
    ax.set_yticks(range(n + 1))
    ax.grid(True, linewidth=1.2)

    # Niente assi/etichette
    ax.set_xticklabels([])
    ax.set_yticklabels([])
    ax.tick_params(length=0)

    # Disegno celle
    for idx, val in enumerate(state):
        r = idx // n           # 0..2 (riga logica dall'alto)
        c = idx % n            # 0..2
        x = c
        y = (n - 1) - r        # flip verticale per avere (0,0) in alto a sinistra "visivo"

        # Cella: vuoto (0) in grigio chiaro, numeri in bianco
        face = "lightgray" if val == 0 else "white"
        ax.add_patch(Rectangle((x, y), 1, 1, facecolor=face, edgecolor="none"))

        # Numero (non per lo 0)
        if val != 0:
            ax.text(
                x + 0.5, y + 0.5, str(val),
                ha="center", va="center",
                fontsize=22, fontweight="bold"
            )

    ax.set_title("8-Puzzle", pad=10)
    plt.tight_layout()
    plt.savefig(out_path, bbox_inches="tight")
    plt.close(fig)


def main():
    # Inserisci qui la tua iniziale
    iniziale = [1,2,3,4,5,6,0,7,8]  # % 31 mosse

    state = validate_state(iniziale)
    file_name="8puzzle_2.png"
    render_8puzzle(state, out_path=file_name)
    print("Creato: ", file_name)


if __name__ == "__main__":
    main()