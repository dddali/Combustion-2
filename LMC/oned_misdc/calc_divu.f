      subroutine calc_divu(scal,beta,I_R,divu,dx,time)
      implicit none
      include 'spec.h'

c     Quantities passed in
      real*8 scal(-1:nx,nscal)
      real*8 beta(-1:nx,nscal)
      real*8 divu(0:nx-1)
      real*8 I_R(0:nx-1,0:maxspec)
      real*8 dx, time
      
      real*8 Y(maxspec)
      real*8 HK(maxspec)
      real*8 cpmix,mwmix
      real*8 ddivu(0:nx-1,maxspec)
      
      real*8 RWRK,rho,T
      integer IWRK,i,n
      real*8 divu_max,marc,sum

C debugging FIXME
      integer hi, lo, ncomp, j

      call get_temp_visc_terms(scal,beta,divu,dx,time)
      call get_spec_visc_terms(scal,beta,ddivu,dx,time)

      marc=0.d0
      do i = 0,nx-1
         rho = 0.d0
         do n = 1,Nspec
            rho = rho + scal(i,FirstSpec + n - 1)
         enddo
C CEG:: makes a small difference b/t using rho & scal(density)
         rho = scal(i,Density)
         do n = 1,Nspec
            Y(n) = scal(i,FirstSpec + n - 1) / rho
         enddo
         T = scal(i,Temp)
         call CKMMWY(Y,IWRK,RWRK,mwmix)
         call CKCPBS(T,Y,IWRK,RWRK,cpmix)

C FIXME
C         write(11,1006) i, divu(i)*1.d3/cpmix
C CEG additions
         call CKHMS(T,IWRK,RWRK,HK)

C using I_R(Temp) seems to make osciallations worse 
C         divu(i) = (divu(i)/(rho*cpmix) + I_R(i,0)) / T
C         marc = MAX(ABS(divu(i)),marc)
         divu(i) = divu(i)/(rho*cpmix*T)
         sum = 0.0d0
         do n=1,Nspec
            divu(i) = divu(i)
C     &           + (ddivu(i,n) + I_R(i,n))*invmwt(n)*mwmix/rho
     &           + (ddivu(i,n) + I_R(i,n))*invmwt(n)*mwmix/rho
     &           - HK(n)*I_R(i,n)/(rho*cpmix*T)
C
C CEG:: debugging. remove me
C            sum = sum -HK(n)*I_R(i,n)/(rho*cpmix*T)
         enddo
       enddo
C debugging FIXME
 1006 FORMAT((I5,1X),6(E22.15,1X))      
         hi = 255
         lo = 0
         ncomp = 7
         open(UNIT=11, FILE='dfsn.dat', STATUS = 'REPLACE')
         write(11,*)'# ', hi-lo, ncomp 
         do j=lo,hi
            write(11,1006) j, (ddivu(j,n),n=1,Nspec)
         enddo
         close(11)
C         stop
CCCCCCCCCCCCC


      divu_max = ABS(divu(0))
      do i = 1,nx-1
         divu_max = MAX(divu_max,ABS(divu(i)))
      enddo
      print *,'*********** DIVU norm = ',divu_max,marc
c      print *,'*********** DIVU norm = ',divu_max

C      close(11)

      end
