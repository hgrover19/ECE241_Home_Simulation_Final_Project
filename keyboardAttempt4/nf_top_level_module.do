# top_level_test.do
vlib work
# Compile the Verilog files
vlog nf_top_level_module.v
vlog audio.v  
vlog i2c_av_cfg.v
vlog I2C_programmer.v
vlog nf_clapDetected.v
vlog serial_adc.v
vlog serial_dac.v

vlog keyboardAttempt4.v

vsim nf_top_level_module
# Elaborate the design
vsim nf_clapDetectedtop_level_module

log {/*}
add wave {/*}

# Run simulation for a certain time
run 1000ns

# Exit ModelSim
quit -sim
