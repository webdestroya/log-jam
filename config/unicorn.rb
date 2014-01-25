# number of workers
worker_processes ENV['UNICORN_WORKERS'].to_i

# bailout after
timeout 30

# Preload everything beforehand
preload_app true
