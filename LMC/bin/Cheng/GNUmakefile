TOP = ../../../..
BOXLIB_DIR = $(TOP)/BoxLib
IAMR_DIR = $(TOP)/IAMR
COMBUSTION_DIR = $(TOP)/Combustion
#
# Build configuration
#
PRECISION       = DOUBLE
DEBUG           = TRUE
DEBUG           = FALSE
DIM             = 3
COMP            = g++
FCOMP           = gfortran
USE_MPI         = TRUE
USE_OMP         = FALSE
USE_SWIRL_DATA  = TRUE
VERBOSE         = TRUE

# Enable flctin namelist
#USE_FLCTS       = TRUE
USE_FLCTS       = TRUE

#USE_PARTICLES   = TRUE
USE_PARTICLES   = FALSE

# Enable ht.velocity_plotfile option
USE_VELOCITY    = FALSE

# Enable time-dependent forcing term
USE_TDEPFORCING = FALSE

# Choose model (from list below), and pmf file
#CHEMISTRY_MODEL = DRM19
#fEXE_sources += drm19Soln_seed_0.50.f

#CHEMISTRY_MODEL = CHEMH
#fEXE_sources += chemHSoln_seed_0.00.f

CHEMISTRY_MODEL = LIDRYERMOD
fEXE_sources += LiDryer_040_01ATM.f

Blocs   := .

CEXE_sources +=
FEXE_sources += PROB_$(DIM)D.F
CEXE_headers += 
FEXE_headers += probdata.H

include $(COMBUSTION_DIR)/LMC/tools/make/Make.LMC
#
# Available chemistry models:
#
# CanuH2 chem-CH4-2step chem-H dme glar gri Hai H-CW header inert Konnov
# LiDryer Marinov prf_ethanol Roehl sandiego smooke usc
#
