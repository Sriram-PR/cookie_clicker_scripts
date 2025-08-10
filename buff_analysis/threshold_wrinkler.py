import matplotlib.pyplot as plt

# Parameters
base_cps = 1  # Base cookies per second
duration = 60  # Duration in seconds before popping
max_wrinklers = 14  # Maximum wrinklers possible

wrinklers_list = []
live_cookies_list = []
wrinkler_payout_list = []
total_cookies_list = []
profit_list = []

baseline = base_cps * duration  # Cookies without wrinklers

for n in range(max_wrinklers + 1):
    # Live CPS during sucking phase
    live_cps = base_cps * (1 - 0.05 * n)
    live_cookies = live_cps * duration

    # Total multiplier from wrinkler formula
    multiplier = 1 - 0.05 * n + 0.055 * n**2

    # Final total after popping wrinklers
    final_total = baseline * multiplier

    # Wrinkler payout portion = total - live earnings
    wrinkler_payout = final_total - live_cookies

    # Profit over baseline
    profit = final_total - baseline

    # Store for graph
    wrinklers_list.append(n)
    live_cookies_list.append(live_cookies)
    wrinkler_payout_list.append(wrinkler_payout)
    total_cookies_list.append(final_total)
    profit_list.append(profit)

    print(
        f"Wrinklers: {n} | Multiplier: {multiplier:.3f}x | "
        f"Live: {live_cookies:.1f} | Payout: {wrinkler_payout:.1f} | "
        f"Total: {final_total:.1f} | Baseline: {baseline} | Profit: {profit:.1f}"
    )

# --- Plot ---
plt.figure(figsize=(10, 6))
plt.bar(
    wrinklers_list,
    live_cookies_list,
    label="Live Cookies (During Sucking)",
    color="orange",
)
plt.bar(
    wrinklers_list,
    wrinkler_payout_list,
    bottom=live_cookies_list,
    label="Wrinkler Payout (After Popping)",
    color="brown",
)

plt.plot(
    wrinklers_list,
    total_cookies_list,
    "o-",
    color="black",
    label="Total Cookies (Final)",
)
plt.axhline(baseline, color="gray", linestyle="--", label="Baseline (No Wrinklers)")

plt.xlabel("Number of Wrinklers")
plt.ylabel("Cookies")
plt.title("Wrinkler Effect: Live Earnings vs Payout")
plt.legend()
plt.grid(True, linestyle="--", alpha=0.6)

plt.tight_layout()
plt.savefig("output/buff_wrinklers.png", dpi=400)
