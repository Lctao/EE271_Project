#Nicolas Wainstein cshrc file


# Aliases
alias rsg16 'ssh -X nicolasw@rsg16'
alias PDK 'cd /cad/synopsys_EDK/SAED_PDK90nm/'
alias l 'ls'
alias c 'cd ..'

# Licences
setenv LM_LICENSE_FILE 27003@rsg1:27000@cadlic0:27001@cadlic0:27040@license4
setenv SNPSLMD_QUEUE true

# Tool Locations
setenv SYNOPSYS_DC /cad/synopsys/dc_shell/J-2014.09-SP3
setenv SYNOPSYS_ICC /cad/synopsys/icc/J-2014.09-SP3
setenv SYNOPSYS_PTS /cad/synopsys/pts/H-2012.12-SP2
setenv SYNOPSYS_ESP /cad/synopsys/esp/2009.06-SP1
setenv SYNOPSYS_FM /cad/synopsys/fm/2010.03
setenv NCX_ROOT /cad/synopsys/ncx/2009.12-SP2
setenv VCS_HOME /cad/synopsys/vcs-mx/latest
setenv CADENCE_SOC /cad/cadence/SOC8.1.lnx86
setenv CALIBRE_ROOT /cad/mentor/2011.1/ixl_cal_2011.1_15.11
setenv CDSHOME /cad/cadence/IC6.16.110
#setenv CADENCE_VIRTUOSO $CDSHOME"/tools.lnx86/dfII"
setenv HSPICE_ROOT /cad/synopsys/hspice/H-2013.03-SP2/hspice
setenv CSCOPE_ROOT /cad/synopsys/cosmosScope/H-2012.12
setenv SENTAURUS_ROOT /cad/synopsys/sentaurus/2009.06-SP2
setenv MILKYWAY_ROOT /cad/synopsys/milkyway/D-2010.03-SP3
setenv FORMALITY_ROOT /cad/synopsys/fm/2010.03
setenv MGC_HOME $CALIBRE_ROOT
setenv AMS_HOME /cad/cadence/AMSD8.20.001.lnx86/IUS82
setenv STARRC_HOME /cad/synopsys/starrc/F-2011.12-SP2/amd64_starrc
setenv SYNPLIFY_HOME /hd/cad/synopsys/synplify/G-2012.09-SP1
setenv WV_HOME /cad/synopsys/cx/2009.09/C-2009.09/cx_C-2009_09
setenv MMSIM_HOME /cad/cadence/MMSIM7.20.284.lnx86/tools
setenv EXTHOME /cad/cadence/EXT14.23.000.lnx86
setenv ASSURAHOME /cad/cadence/ASSURA4.10.006_IC614.lnx86

# Cadence Virtuoso
source /cad/modules/tcl/init/csh
module load base/rsg
module load ic/6.16.080
# Sythesis tools
module load dc_shell
module load calibre/2016.8
module load icc
module load pts
module load vcs
module load genesis2
module load synopsys_edk
module load cdesigner
module load hercules
module load starrc
module load cx
module load synopsys_edk
#module load synopsys_pdk
# HSpice
module load hspice/H-2013.03-SP2

###env fir ee271 project
setenv EE271_PROJ /home/project_part2/
setenv EE271_VECT ${EE271_PROJ}/vect/

