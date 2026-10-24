## =====================================================================================================
## INITIAL PART TO AGGREGATE METRICS (IN ONE OF FIRSL CELLS)
## =====================================================================================================

import time
import os
import psutil
import pandas as pd

# Global variables and tracking setup
notebook_metrics = []
cell_start_wall = 0
cell_start_cpu = 0
cell_counter = 0

# Record overall session start time
workflow_start_wall = time.perf_counter()
process = psutil.Process(os.getpid())

def pre_run_cell_hook(info):
    global cell_start_wall, cell_start_cpu
    cell_start_wall = time.perf_counter()
    # Sum user + system CPU time
    cpu_t = process.cpu_times()
    cell_start_cpu = cpu_t.user + cpu_t.system

def post_run_cell_hook(result):
    global cell_counter
    cell_counter += 1
    
    # Calculate elapsed wall-clock and CPU time
    wall_elapsed = time.perf_counter() - cell_start_wall
    cpu_t = process.cpu_times()
    cpu_elapsed = (cpu_t.user + cpu_t.system) - cell_start_cpu
    
    # Active CPU cores utilized during this cell
    avg_cores_used = (cpu_elapsed / wall_elapsed) if wall_elapsed > 0 else 0.0
    
    # Current RAM usage in MB
    ram_rss_mb = process.memory_info().rss / (1024 * 1024)
    
    notebook_metrics.append({
        'cell_step': cell_counter,
        'cell_id': getattr(result, 'cell_id', f"step_{cell_counter}"),
        'execution_time_sec': round(wall_elapsed, 4),
        'avg_cores_used': round(avg_cores_used, 2),
        'pct_of_alloc_40_cores': round((avg_cores_used / 40.0) * 100, 1),
        'ram_rss_mb': round(ram_rss_mb, 2)
    })

# Register execution hooks
ip = get_ipython()
ip.events.register('pre_run_cell', pre_run_cell_hook)
ip.events.register('post_run_cell', post_run_cell_hook)

print("Workflow monitoring active.")

## ======================================================================================================================
## EXPORT METRICS TO CSV FILE (VERY LAST CELL)
## ======================================================================================================================

# Calculate total elapsed workflow runtime
total_workflow_runtime_sec = time.perf_counter() - workflow_start_wall

# Generate per-step DataFrame
df_per_step = pd.DataFrame(notebook_metrics)

# Generate overall total summary DataFrame
df_total_summary = pd.DataFrame([{
    'total_runtime_sec': round(total_workflow_runtime_sec, 2),
    'total_runtime_min': round(total_workflow_runtime_sec / 60.0, 2),
    'peak_cores_used': round(df_per_step['avg_cores_used'].max(), 2),
    'avg_cores_used_overall': round(df_per_step['avg_cores_used'].mean(), 2),
    'peak_ram_rss_mb': round(df_per_step['ram_rss_mb'].max(), 2),
    'total_steps_executed': len(df_per_step)
}])

# Export both to CSV
df_per_step.to_csv('per_step_execution_report.csv', index=False)
df_total_summary.to_csv('total_workflow_summary.csv', index=False)

# Display summaries in output
print("=== OVERALL WORKFLOW SUMMARY ===")
print(f"Total Runtime       : {total_workflow_runtime_sec:.2f} seconds ({total_workflow_runtime_sec / 60:.2f} minutes)")
print(f"Peak Cores Used     : {df_per_step['avg_cores_used'].max():.2f} / 40 cores")
print(f"Average Core Usage  : {df_per_step['avg_cores_used'].mean():.2f} cores")
print(f"Peak RAM Usage      : {df_per_step['ram_rss_mb'].max():.2f} MB")
print("\nSaved exports:")
print(" - 'per_step_execution_report.csv'")
print(" - 'total_workflow_summary.csv'")