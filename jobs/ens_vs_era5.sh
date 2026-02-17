#!/bin/bash
#
# ================================
# SBATCH CONFIGURATION
# ================================
#SBATCH --job-name=wb2
#SBATCH --partition=fat_genoa
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --time=120:00:00
#SBATCH --output=logs/%j.out
#SBATCH --error=logs/%j.out

# ================================
# Environment setup
# ================================
set -e
set -u

echo "Running on node: $SLURMD_NODENAME"
echo "Allocated CPUs: $SLURM_CPUS_PER_TASK"

# Activate virtual environment
source env/venv/bin/activate

# Optional but recommended to prevent oversubscription
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

# ================================
# Run WeatherBench2 evaluation
# ================================

python scripts/evaluate.py \
	--forecast_path=gs://weatherbench2/datasets/hres/2016-2022-0012-240x121_equiangular_with_poles_conservative.zarr \
	--obs_path=gs://weatherbench2/datasets/era5/1959-2022-6h-240x121_equiangular_with_poles_conservative.zarr \
	--climatology_path=gs://weatherbench2/datasets/era5-hourly-climatology/1990-2017_6h_240x121_equiangular_with_poles_conservative.zarr \
	--by_init=True \
	--regions=all \
	--eval_configs=probabilistic,ensemble_binary,probabilistic_spatial,ensemble_binary_spatial,probabilistic_spatial_histograms \
	--time_start=2020-01-01T06:00:00 \
	--time_stop=2020-01-10T00:00:00 \
	--output_file_prefix=ens_vs_era5 \
	--output_dir=./result \
	--use_beam=False \
	--use_parallel=True \
	--num_threads=$SLURM_CPUS_PER_TASK \
	--input_chunks=init_time=1,lead_time=12 \
# skipna: True with hres_t0?
