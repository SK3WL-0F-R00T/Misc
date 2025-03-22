import math

def calculate_time_exponent(
    ghz_per_core: float = 2.5,
    num_cores: int = 4,
    num_machines: int = 1,
    bits_to_crack: int = 128
):
    """
    Calculates an approximate exponent (as in 2^exponent) for the time (in years)
    required to perform 2^bits_to_crack operations.
    
    Each machine is assumed to have the same number of cores running at the given GHz rate.
    The calculation converts each multiplicative factor to a power-of-two representation:
      1. Convert GHz per core to operations per second (1 GHz = 1e9 ops) and round up the exponent.
      2. Account for multiple cores and multiple machines by adding their exponents.
      3. Multiply by the number of seconds in a day (86400), rounding up the exponent.
      4. Compute the exponent difference between the total required operations (2^bits_to_crack)
         and the daily throughput.
      5. Convert days to years by subtracting the exponent for 365.
    
    Returns:
      A float representing the exponent such that the required time is approximately 2^(returned value) years.
    """

    # Step 1: Calculate the exponent for operations per second per core.
    exponent_core_exact = math.log2(ghz_per_core * 1e9)
    exponent_core = math.ceil(exponent_core_exact)

    # Step 2: Account for multiple cores and machines.
    exponent_cores = math.ceil(math.log2(num_cores))
    exponent_machines = math.ceil(math.log2(num_machines))
    exponent_total_ops_sec = exponent_core + exponent_cores + exponent_machines

    # Step 3: Convert operations per second to operations per day.
    exponent_secs_day_exact = math.log2(86400)
    exponent_ops_per_day = exponent_total_ops_sec + math.ceil(exponent_secs_day_exact)

    # Step 4: Calculate the exponent for the number of days needed.
    exponent_days_needed = bits_to_crack - exponent_ops_per_day

    # Step 5: Convert days to years (using 365 days/year).
    exponent_years_exact = exponent_days_needed - math.log2(365)

    print("\n--- Calculation Steps ---")
    print(f"Step 1: {ghz_per_core} GHz per core -> log2({ghz_per_core}e9) ≈ {exponent_core_exact:.2f}, rounded up to 2^{exponent_core}")
    print(f"Step 2: {num_cores} cores per machine -> log2({num_cores}) ≈ {math.log2(num_cores):.2f}, rounded up to 2^{exponent_cores}")
    print(f"         {num_machines} machines -> log2({num_machines}) ≈ {math.log2(num_machines):.2f}, rounded up to 2^{exponent_machines}")
    print(f"         Total operations per second = 2^{exponent_total_ops_sec}")
    print(f"Step 3: Multiplying by 86400 sec/day -> log2(86400) ≈ {exponent_secs_day_exact:.2f}, ops/day = 2^{exponent_ops_per_day}")
    print(f"Step 4: 2^{bits_to_crack} total operations divided by ops/day gives: 2^{exponent_days_needed} days")
    print(f"Step 5: Converting days to years by subtracting log2(365) ≈ {math.log2(365):.2f} yields: 2^{exponent_years_exact:.2f} years")
    print(f"Final exponent for years (rounded): ~2^{round(exponent_years_exact)}")

    return exponent_years_exact

if __name__ == "__main__":
    print("\nAttacker Work Calculation:")
    calculate_time_exponent(
        ghz_per_core=2.4,
        num_cores=96,
        num_machines=500000,
        bits_to_crack=128
    )
