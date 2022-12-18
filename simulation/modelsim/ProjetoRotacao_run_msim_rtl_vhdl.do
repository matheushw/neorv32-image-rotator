transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/maxThroughput.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_bootloader_image.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_application_image.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_package.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/test_setups/neorv32_test_setup_bootloader.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/mem/neorv32_imem.default.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/mem/neorv32_dmem.default.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_uart.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_top.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_sysinfo.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_mtime.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_gpio.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_fifo.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu_regfile.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu_decompressor.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu_cp_shifter.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu_cp_muldiv.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu_control.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu_bus.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu_alu.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cpu.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_cfs.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_busswitch.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_bus_keeper.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_boot_rom.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_imem.entity.vhd}
vcom -93 -work work {/home/matheus/projeto/neorv32-main/neorv32-main/rtl/core/neorv32_dmem.entity.vhd}

