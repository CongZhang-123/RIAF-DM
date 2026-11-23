# The -ffpe-trap option enables exception trapping and makes sure that NaN 
# occurrences result in core dumps, i.e. if a NaN happens the program will 
# stop. This fixes the problem of the code hanging with 100% CPU usage.
#
# Old school way of compiling:
# gfortran -O -ffpe-trap=invalid,zero dynamics_new.f -o dynamics_new
# gfortran -O spectrum_new.f -o spectrum_new
# gfortran -O ssd_new.f -o ssd_new
# gfortran -O ssd_alone.f -o ssd_alone

FC = gfortran
FFLAGS = -O 
#OBJS = pram.o main.o bnd.o calcha.o calflx.o calsf.o caluu.o cdtcfl.o correction.o coord.o ct.o func.o grid.o hll.o mdgrmhd.o mpisub.o physfunc.o rec.o recov.o restar.o rkt.o
# Compile the tabulated DM cooling modules into the dynamics executable.
DYNAMICS_SRCS = ../cooling-data/interp2d.f90 \
	../cooling-data/dm_cooling_table.f90 \
	dynamics.f

all: dynamics spectrum ssd ssd_alone

dynamics: $(DYNAMICS_SRCS)
	$(FC) $(FFLAGS) -ffpe-trap=invalid,zero $(DYNAMICS_SRCS) -o $@

spectrum: spectrum.f
	$(FC) $(FFLAGS) -fopenmp $^ -o $@

ssd: ssd_new.f
	$(FC) $(FFLAGS) ssd_new.f -o ssd_new

ssd_alone: ssd_alone.f
	$(FC) $(FFLAGS) $^ -o $@

clean:
	rm -f *.o *.mod *_new *_alone spectrum 
