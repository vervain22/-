# Fabric Compiler 自动生成的实现脚本

set_arch -family Logos2 -device PG2L50H -speedgrade -6 -package FBG484
compile -top_module test_ddr
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr -optimize_multi_corner_timing -fix_hold_violation 
report_timing 
gen_bit_stream 
set_arch -family Logos2 -device PG2L50H -speedgrade -6 -package FBG484
compile -top_module test_ddr
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr -optimize_multi_corner_timing -fix_hold_violation 
set_arch -family Logos2 -device PG2L50H -speedgrade -6 -package FBG484
compile -top_module test_ddr
synthesize -ads -selected_syn_tool_opt 2 
dev_map 
pnr -optimize_multi_corner_timing -fix_hold_violation 
report_timing 
gen_bit_stream 
