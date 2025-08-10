import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# --- Buff cycle parameters ---
gapInterval_ms = 50
toggleDelay_ms = 25
clickInterval_ms = 10
buff_duration_s = 10
base_cpc = 1.0  # cookies per click without buffs

# --- Wrinkler parameters ---
max_wrinklers = 14

# --- Buff cycle timing ---
time_sell = gapInterval_ms / 1000
time_prebuild = (toggleDelay_ms + gapInterval_ms) / 1000
time_buy = gapInterval_ms / 1000
time_postbuild = (toggleDelay_ms + gapInterval_ms) / 1000
cycle_time_s = time_sell + time_prebuild + time_buy + time_postbuild

clicks_per_second = 1000 / clickInterval_ms
max_cycles_possible = int(buff_duration_s // cycle_time_s)

# --- Storage ---
results = np.zeros((max_wrinklers + 1, max_cycles_possible))
rows = []

# --- Simulation ---
for wrinklers in range(max_wrinklers + 1):
    suck_multiplier = max(0, 1 - 0.05 * wrinklers)

    for buff_cycles in range(1, max_cycles_possible + 1):
        buff_percent = buff_cycles * 100
        time_for_cycles = buff_cycles * cycle_time_s
        time_left_clicking = max(buff_duration_s - time_for_cycles, 0)

        total_clicks = time_left_clicking * clicks_per_second
        cookies_during_buff = (
            total_clicks * base_cpc * suck_multiplier * (1 + buff_percent / 100)
        )

        payout_multiplier = (1 - 0.05 * wrinklers) + 0.055 * (wrinklers**2)
        final_cookies = cookies_during_buff * payout_multiplier

        results[wrinklers, buff_cycles - 1] = final_cookies

        rows.append(
            {
                "wrinklers": wrinklers,
                "buff_cycles": buff_cycles,
                "buff_percent": buff_percent,
                "time_for_cycles_s": time_for_cycles,
                "time_left_clicking_s": time_left_clicking,
                "total_clicks": total_clicks,
                "cookies_during_buff": cookies_during_buff,
                "final_cookies": final_cookies,
            }
        )

# --- Save CSV ---
df = pd.DataFrame(rows)
df.to_csv("output/godzamok_v_wrinkler_heatmap.csv", index=False)

# --- Print best combos ---
for wrinklers in range(max_wrinklers + 1):
    best_cycles = np.argmax(results[wrinklers]) + 1
    best_value = results[wrinklers, best_cycles - 1]
    print(
        f"Wrinklers {wrinklers}: Best buff cycles = {best_cycles}, Final Cookies = {best_value:.2f}"
    )

# --- Heatmap ---
plt.figure(figsize=(10, 6))
plt.imshow(results, cmap="viridis", aspect="auto", origin="lower")
plt.colorbar(label="Final Cookies")
plt.xticks(
    range(max_cycles_possible), [str(i) for i in range(1, max_cycles_possible + 1)]
)
plt.yticks(range(max_wrinklers + 1), [str(i) for i in range(max_wrinklers + 1)])
plt.xlabel("Buff Cycles")
plt.ylabel("Number of Wrinklers")
plt.title("Final Cookies for Wrinkler & Buff Cycle Combinations")
plt.tight_layout()
plt.savefig("output/godzamok_v_wrinkler_heatmap.png", dpi=400)
