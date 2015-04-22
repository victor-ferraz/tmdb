REM
REM

ECHO WARNING: Removing existing results directory
RMDIR /S /Q results
MKDIR results

if exist ..\ISE\tmdb_core.prj (
	copy ..\ISE\tmdb_core.prj       .\results\
	copy ..\ISE\tmdb_core.prj       .\
) else (
	COPY tmdb_core.prj              .\results\
)	

if exist ..\ISE\tmdb_core.xst (
	copy ..\ISE\tmdb_core.xst       .\results\
	copy ..\ISE\tmdb_core.xst		.\
) else (
	COPY tmdb_core.xst              .\results\
)	

COPY *.ngc                          .\results\

if not exist .\xst mkdir .\xst && mkdir .\xst\projnav.tmp

REM Run Synthesis

ECHO "### Running Xst - "
xst -ifn tmdb_core.xst

COPY tmdb_core.ngc .\results
cd .\results

REM Run ngdbuild

ngdbuild -uc ..\..\tmdb_core.ucf -p xc6slx150t-fgg676-3 tmdb_core.ngc tmdb_core.ngd

REM end run ngdbuild section

REM Run map

ECHO 'Running NGD'
map -register_duplication on -global_opt speed -logic_opt on -retiming on -timing -ol high -p xc6slx150t-fgg676-3 -o mapped.ncd tmdb_core.ngd

REM Run par

ECHO 'Running par'
par -ol high mapped.ncd routed.ncd 

REM Report par results

ECHO 'Running design through bitgen'
bitgen -w routed.ncd

REM Trace Report

ECHO 'Running trce'
trce -e 10 routed.ncd mapped.pcf -o routed

REM Run netgen

ECHO 'Running netgen to create gate level Verilog model'
netgen -ofmt verilog -sim -sdf_path ../../implement/results -dir . -tm gtp_dual_0_top -w routed.ncd routed.v

REM Change directory to implement

CD ..

