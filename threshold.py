import matplotlib.pyplot as plt

# --- From AHK script ---
gapInterval_ms = 50
toggleDelay_ms = 25
clickInterval_ms = 10
buff_duration_s = 10

# --- User-configurable ---
base_cpc = 1.0  # base cookies per click without buffs

# --- Calculate time for one buff cycle ---
time_sell = gapInterval_ms / 1000
time_prebuild = (toggleDelay_ms + gapInterval_ms) / 1000
time_buy = gapInterval_ms / 1000
time_postbuild = (toggleDelay_ms + gapInterval_ms) / 1000

cycle_time_s = time_sell + time_prebuild + time_buy + time_postbuild
print(f"Time per buff cycle: {cycle_time_s:.3f} s")

# --- Click rate ---
clicks_per_second = 1000 / clickInterval_ms
print(f"Clicks per second: {clicks_per_second}")

# --- Simulate until buff time runs out ---
max_cycles_possible = int(buff_duration_s // cycle_time_s)
buff_cycles_range = range(1, max_cycles_possible + 1)

buff_percents = []
click_counts = []
cookie_totals = []

best_cycles = None
best_cookies = -1

for buff_cycles in buff_cycles_range:
    buff_percent = buff_cycles * 100
    time_for_cycles = buff_cycles * cycle_time_s
    time_left_clicking = max(buff_duration_s - time_for_cycles, 0)
    total_clicks = time_left_clicking * clicks_per_second
    total_cookies = total_clicks * base_cpc * (1 + buff_percent / 100)

    print(f"\nBuff cycles: {buff_cycles}")
    print(f"  Buff %: {buff_percent}")
    print(f"  Time for cycles: {time_for_cycles:.3f} s")
    print(f"  Time left for clicking: {time_left_clicking:.3f} s")
    print(f"  Total clicks: {total_clicks:.0f}")
    print(f"  Total cookies: {total_cookies:.2f}")

    buff_percents.append(buff_percent)
    click_counts.append(total_clicks)
    cookie_totals.append(total_cookies)

    if total_cookies > best_cookies:
        best_cookies = total_cookies
        best_cycles = buff_cycles

print(f"\nOptimal setup: {best_cycles} buff cycles → {best_cookies:.2f} cookies")

# --- Graph ---
fig, ax1 = plt.subplots()

color = "tab:green"
ax1.set_xlabel("Buff cycles")
ax1.set_ylabel("Final Cookies", color=color)
ax1.plot(
    buff_cycles_range,
    cookie_totals,
    marker="s",
    linestyle="-",
    color=color,
    label="Cookies",
)
ax1.tick_params(axis="y", labelcolor=color)

ax1.axvline(best_cycles, color="gray", linestyle="--", linewidth=1)
ax1.text(best_cycles + 0.5, best_cookies, f"Best: {best_cycles} cycles", color="gray")

ax2 = ax1.twinx()
ax2.set_ylabel("Buff % / Clicks", color="tab:blue")
ax2.plot(buff_cycles_range, click_counts, marker="o", color="tab:blue", label="Clicks")
ax2.plot(
    buff_cycles_range,
    buff_percents,
    marker="x",
    linestyle="--",
    color="tab:red",
    label="Buff %",
)
ax2.tick_params(axis="y", labelcolor="tab:blue")

fig.suptitle("Buff stacking: Final Cookies, Clicks, and Buff %")
ax1.legend(loc="upper left")
ax2.legend(loc="upper right")
plt.savefig("buff_cycles.png", dpi=400, bbox_inches="tight")
