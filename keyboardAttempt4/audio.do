# Create a new library
vlib work

# Compile your Verilog files
vlog audio.v
vlog i2c_av_cfg.v
vlog I2C_programmer.v
vlog nf_clapDetected.v
vlog nf_top_level_module.v
vlog serial_adc.v
vlog serial_dac.v

# Run the simulation with the top-level module "nf_top_level_module"
vsim nf_top_level_module

# Add signals to the waveform window
add wave {/*}

# Run the simulation for a specified time
run 100ns

# Alternatively, you can run the simulation indefinitely
# run -all

# Close the simulation
quit
