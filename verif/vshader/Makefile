VCS=/proj/cadtools/bin/vcs
SRC=../../rtl/vertex_shader/vs_alu.v \
    ../../rtl/vertex_shader/vs_defines.vh \
    ../../rtl/vertex_shader/vs_common_utils.v \
    ../../rtl/vertex_shader/vs_core.v \
    test_vshader.v
TGT=simv
VERICOM=/proj/cadtools/bin/vericom
VERDI=/proj/cadtools/bin/verdi
TAB_FILE=/proj/cadsim/simtools/simtools2.linux/pli64_rh4/dummytbv.tab
PLI_FILE=/proj/cadsim/simtools/simtools2.linux/pli64_rh4/dummytbv_vcs.a
VERDI_TAB=/proj/caeeda/NOVAS/VERDI/201001/share/PLI/vcs_latest/LINUX/verdi.tab
VERDI_PLI=/proj/caeeda/NOVAS/VERDI/201001/share/PLI/vcs_latest/LINUX/pli.a

FLAGS= -P $(VERDI_TAB) $(VERDI_PLI) -unit_timescale=1ps/1ps 
all:simv

$(TGT):$(SRC)
	rm out -rf
	mkdir out
	$(VCS) -sverilog $(FLAGS) +define+DUMPFSDB  -f run.f -sgq normal 
run:
	/proj/caeeda/SYNOPSYS/bin/simv -sgq normal 
seewave:
	$(VERDI) -f run.f -top test -ssf ./out/vshader.fsdb -sgq normal
clean:
	rm simv; rm csrc -rf; rm *.daidir -rf; rm out -rf; rm verdiLog -rf; rm vcs.log; rm novas.*; rm ucli.key
