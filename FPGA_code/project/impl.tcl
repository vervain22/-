# Fabric Compiler 自动生成的实现脚本

set_arch -family Logos2 -device PG2L100H -speedgrade -6 -package FBG484
compile -top_module image_pcie_capture
synthesize -ads -selected_syn_tool_opt 2 
set_arch -family Logos2 -device PG2L100H -speedgrade -6 -package FBG484
compile -top_module image_pcie_capture
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr 
report_timing 
gen_bit_stream -compress_bitstream true -master_configuration_clock_frequency {40M} 
