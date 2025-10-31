#!/usr/bin/env python3
import subprocess
import statistics
import sys
import time
from datetime import datetime
from scipy.stats import ttest_ind, shapiro, mannwhitneyu


def run_hey(url, duration="5s", concurrency=10):
    """Run hey for given URL and return the Requests/sec float value."""
    try:
        result = subprocess.run(
            ["hey", "-z", duration, "-c", str(concurrency), url],
            capture_output=True, text=True, check=True
        )
        for line in result.stdout.splitlines():
            if "Requests/sec:" in line:
                return float(line.split()[1])
    except Exception as e:
        print(f"Error running hey on {url}: {e}")
    return 0.0


def log(line, file_handle):
    """Print to console and write to file."""
    print(line)
    file_handle.write(line + "\n")
    file_handle.flush()


def progressive_test(results1, results2):
    """Perform t-test or Mann–Whitney depending on normality of data."""
    if len(results1) < 3 or len(results2) < 3:
        return None, None, "Not enough data"

    try:
        stat1, p1 = shapiro(results1)
        stat2, p2 = shapiro(results2)
        normal1 = p1 > 0.05
        normal2 = p2 > 0.05

        if normal1 and normal2:
            test_name = "Welch’s t-test"
            stat, p_val = ttest_ind(results1, results2, equal_var=False)
        else:
            test_name = "Mann–Whitney U test"
            stat, p_val = mannwhitneyu(results1, results2, alternative="two-sided")

        return test_name, stat, p_val
    except Exception:
        return None, None, "Error computing test"


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <URL1> <URL2>")
        sys.exit(1)
    url1, url2 = sys.argv[1], sys.argv[2]

    ROUNDS = 100
    DURATION = "30s"
    CONCURRENCY = 1000
    RESULTS_FILE = "benchmark/results.txt"

    with open(RESULTS_FILE, "a") as f:
        log("============================================================", f)
        log(f"Run started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", f)
        log(f"Comparing:\n  URL1: {url1}\n  URL2: {url2}", f)
        log(f"  Rounds: {ROUNDS} × {DURATION} each\n", f)

        results1, results2 = [], []

        for i in range(1, ROUNDS + 1):
            log(f"▶️ Round {i}/{ROUNDS}", f)

            r1 = run_hey(url1, DURATION, CONCURRENCY)
            r2 = run_hey(url2, DURATION, CONCURRENCY)

            results1.append(r1)
            results2.append(r2)

            # Compute running averages
            avg1 = statistics.mean(results1)
            avg2 = statistics.mean(results2)

            log(f"  {url1:<40} {r1:8.2f} req/s (avg: {avg1:.2f})", f)
            log(f"  {url2:<40} {r2:8.2f} req/s (avg: {avg2:.2f})", f)

            # Perform progressive statistical test if enough samples
            test_name, stat, p_val = progressive_test(results1, results2)
            if test_name:
                significance = "✅ Significant" if p_val < 0.05 else "⚪ Not significant"
                faster_url = url1 if avg1 > avg2 else url2
                log(f"  📊 {test_name}: stat={stat:.4f}, p={p_val:.6f} → {significance}", f)
                log(f"  ⚡ Faster URL so far: {faster_url}", f)
            else:
                log(f"  ℹ️ {stat}", f)

            time.sleep(0.5)

        # Compute final averages
        final_avg1 = statistics.mean(results1) if results1 else 0
        final_avg2 = statistics.mean(results2) if results2 else 0

        log("=" * 60, f)
        log("🏁 FINAL RESULTS:", f)
        log(f"  {url1:<40} {final_avg1:8.2f} req/s avg", f)
        log(f"  {url2:<40} {final_avg2:8.2f} req/s avg", f)

        if final_avg1 > final_avg2:
            log(f"\n✅ {url1} is faster by {final_avg1 - final_avg2:.2f} req/s on average", f)
        elif final_avg2 > final_avg1:
            log(f"\n✅ {url2} is faster by {final_avg2 - final_avg1:.2f} req/s on average", f)
        else:
            log("\n🤝 Both URLs performed equally on average", f)

        log(f"\nRun finished: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", f)
        log("============================================================\n", f)


if __name__ == "__main__":
    main()
