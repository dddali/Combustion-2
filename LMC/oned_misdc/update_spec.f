        subroutine update_spec(nx,scal_old,scal_new,aofs,tforce,dx,dt)

        implicit none

        include 'nums.fi'
        include 'sndata.fi'

        integer nx

c       Quantities passed in
        real*8 scal_old(-1:nx  ,nscal)
        real*8 scal_new(-1:nx  ,nscal)
        real*8     aofs(0 :nx-1,nscal)
        real*8   tforce(0 :nx-1,nscal)
        real*8 dx
        real*8 dt

c       Local variables
        integer i,n

        do n = FirstSpec,LastSpec
          do i = 0,nx-1
            scal_new(i,n) = scal_old(i,n) + dt * aofs(i,n) 
     $                                    + dt * tforce(i,n)
          enddo
          scal_new(nx,n) = scal_new(nx-1,n)
        enddo

        do i = 0,nx-1
          scal_new(i,Density) = scal_new(i,FirstSpec)
     $                         +scal_new(i,FirstSpec+1)
     $                         +scal_new(i,FirstSpec+2)
        enddo
        scal_new(nx,Density) = scal_new(nx-1,Density)

        end
