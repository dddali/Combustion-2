TOP = ../../../..
BOXLIB_DIR = ${TOP}/BoxLib
IAMR_DIR = ${TOP}/IAMR
COMBUSTION_DIR = ${TOP}/Combustion

#
# Build configuration
#

PRECISION       = DOUBLE
DEBUG           = FALSE
DIM             = 2
COMP            = g++
FCOMP           = gfortran
USE_MPI         = TRUE
USE_OMP         = FALSE
VERBOSE         = FALSE

# Enable SDC code - add .SDC to executable
# and compile in the #ifdef LMC_SDC
USE_LMC_SDC = TRUE

# Enable flctin namelist
USE_FLCTS       = FALSE

USE_PARTICLES   = FALSE

# Enable ht.velocity_plotfile option
USE_VELOCITY    = FALSE

# Enable time-dependent forcing term
USE_TDEPFORCING = FALSE

# Choose model (from list below), and pmf file
#CHEMISTRY_MODEL = DRM19
#fEXE_sources += drm19Soln_seed_0.125.f

CHEMISTRY_MODEL = CHEMH
fEXE_sources += chemHSoln_seed_0.00.f

#CHEMISTRY_MODEL = BURKEMOD_D
#fEXE_sources += pmf_BurkeMOD_040_10atm.f

Blocs   := .

CEXE_sources +=
FEXE_sources += PROB_$(DIM)D.F PROB_F.F
CEXE_headers += 
FEXE_headers += probdata.H PROB_F.H

include $(COMBUSTION_DIR)/LMC/tools/make/Make.LMC

# Available chemistry models:
# CanuH2 chem-CH4-2step chem-H dme glar gri Hai H-CW header inert Konnov
# LiDryer Marinov prf_ethanol Roehl sandiego smooke usc
