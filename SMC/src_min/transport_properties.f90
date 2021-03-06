module transport_properties

  use chemistry_module
  use eglib_module
  use multifab_module
  use variables_module

  implicit none

  private

  public get_transport_properties

contains

  subroutine get_transport_properties(Q, mu, xi, lam, Ddiag, ng, ghostcells_only)
    type(multifab), intent(in   ) :: Q
    type(multifab), intent(inout) :: mu, xi, lam, Ddiag
    integer, intent(in), optional :: ng
    logical, intent(in), optional :: ghostcells_only
 
    integer :: ngwork
    logical :: lgco
    integer :: ngq, n, dm, lo(Q%dim), hi(Q%dim), wlo(Q%dim), whi(Q%dim)
    double precision, pointer, dimension(:,:,:,:) :: qp, mup, xip, lamp, dp

    dm = Q%dim
    ngq = nghost(Q)

    ngwork = ngq
    if (present(ng)) then
       ngwork = min(ngwork, ng)
    end if

    lgco = .false.
    if (present(ghostcells_only)) then
       lgco = ghostcells_only
    end if

    do n=1,nfabs(Q)
       
       qp => dataptr(Q,n)
       mup => dataptr(mu,n)
       xip => dataptr(xi,n)
       lamp => dataptr(lam,n)
       dp => dataptr(Ddiag,n)

       lo = lwb(get_box(Q,n))
       hi = upb(get_box(Q,n))

       wlo = lo - ngwork
       whi = hi + ngwork

       if (dm .ne. 3) then
          call bl_error("Only 3D is supported in get_transport_properties")
       else
          call get_trans_prop_3d(lo,hi,ngq,qp,mup,xip,lamp,dp,wlo,whi,lgco)
       end if

    end do

  end subroutine get_transport_properties

  subroutine get_trans_prop_3d(lo,hi,ng,q,mu,xi,lam,Ddiag,wlo,whi,gco)
    logical, intent(in) :: gco  ! ghost cells only
    integer, intent(in) :: lo(3), hi(3), ng, wlo(3), whi(3)
    double precision,intent(in )::    q(lo(1)-ng:hi(1)+ng,lo(2)-ng:hi(2)+ng,lo(3)-ng:hi(3)+ng,nprim)
    double precision,intent(out)::   mu(lo(1)-ng:hi(1)+ng,lo(2)-ng:hi(2)+ng,lo(3)-ng:hi(3)+ng)
    double precision,intent(out)::   xi(lo(1)-ng:hi(1)+ng,lo(2)-ng:hi(2)+ng,lo(3)-ng:hi(3)+ng)
    double precision,intent(out)::  lam(lo(1)-ng:hi(1)+ng,lo(2)-ng:hi(2)+ng,lo(3)-ng:hi(3)+ng)
    double precision,intent(out)::Ddiag(lo(1)-ng:hi(1)+ng,lo(2)-ng:hi(2)+ng,lo(3)-ng:hi(3)+ng,nspecies)

    integer :: i, j, k, n, iwrk, nglo, nghi
    double precision :: rwrk
    integer :: np, ii
    double precision :: Cpck(nspecies)
    double precision, allocatable :: Tt(:), Xt(:,:), Yt(:,:), Cpt(:,:), D(:,:)
    double precision, allocatable :: ME(:), MK(:), L1(:), L2(:)

    ! eglib parameters
    integer, parameter :: ITLS=1, IFLAG=5

    np = whi(1) - wlo(1) + 1
    call eglib_init(nspecies, np, ITLS, IFLAG)
    
    !$omp parallel private(i,j,k,n,iwrk,rwrk,ii,Cpck) &
    !$omp private(Tt,Xt,Yt,Cpt,D,ME,MK,L1,L2)
    
    allocate(Tt(np))
    allocate(ME(np))
    allocate(MK(np))
    allocate(L1(np))
    allocate(L2(np))
    
    allocate(Xt(nspecies,np))
    allocate(Yt(nspecies,np))
    allocate(Cpt(nspecies,np))
    allocate(D(nspecies,np))
    
    !$omp do
    do k=wlo(3),whi(3)
       do j=wlo(2),whi(2)

          if (gco) then
             if ( (j.ge.lo(2) .and. j.le.hi(2)) .and. &
                  (k.ge.lo(3) .and. k.le.hi(3)) ) then
                cycle
             end if
          end if
          
          do i=wlo(1), whi(1)
             ii = i-wlo(1)+1
             Tt(  ii) = q(i,j,k,qtemp)
             Xt(:,ii) = q(i,j,k,qx1:qx1+nspecies-1)
             Yt(:,ii) = q(i,j,k,qy1:qy1+nspecies-1)
             CALL CKCPMS(Tt(ii), iwrk, rwrk, Cpck)
             Cpt(:,ii) = Cpck
          end do
          
          CALL EGMPAR(np, Tt, Xt, Yt, Cpt, egwork, egiwork)
          
          CALL EGME3(np, Tt, Yt, egwork, ME) 
          mu(wlo(1):whi(1),j,k) = ME
          
          CALL EGMK3(np, Tt, Yt, egwork, MK) 
          xi(wlo(1):whi(1),j,k) = MK
          
          CALL EGMVR1(np, Tt, Yt, egwork, D)
          do n=1,nspecies
             do i=wlo(1), whi(1)
                ii = i-wlo(1)+1
                Ddiag(i,j,k,n) = D(n,ii)
             end do
          end do
          
          CALL EGML1(np,  1.d0, Tt, Xt, egwork, L1)
          CALL EGML1(np, -1.d0, Tt, Xt, egwork, L2)
          lam(wlo(1):whi(1),j,k) = 0.5d0*(L1+L2)
          
       end do
    end do
    !$omp end do
    
    deallocate(Tt, Xt, Yt, Cpt, D, ME, MK, L1, L2)
    !$omp end parallel

    if (gco) then

       nglo = lo(1) - wlo(1)
       nghi = whi(1) - hi(1)
       np = nglo + nghi

       if (np .le. 0) return

       call eglib_init(nspecies, np, ITLS, IFLAG)
    
       !$omp parallel private(i,j,k,n,iwrk,rwrk,ii,Cpck) &
       !$omp private(Tt,Xt,Yt,Cpt,D,ME,MK,L1,L2)
       
       allocate(Tt(np))
       allocate(ME(np))
       allocate(MK(np))
       allocate(L1(np))
       allocate(L2(np))
       
       allocate(Xt(nspecies,np))
       allocate(Yt(nspecies,np))
       allocate(Cpt(nspecies,np))
       allocate(D(nspecies,np))
    
       !$omp do
       do k=lo(3),hi(3)
          do j=lo(2),hi(2)

             do i=lo(1)-nglo, lo(1)-1
                ii = i-lo(1)+nglo+1
                Tt(  ii) = q(i,j,k,qtemp)
                Xt(:,ii) = q(i,j,k,qx1:qx1+nspecies-1)
                Yt(:,ii) = q(i,j,k,qy1:qy1+nspecies-1)
                CALL CKCPMS(Tt(ii), iwrk, rwrk, Cpck)
                Cpt(:,ii) = Cpck
             end do

             do i=hi(1)+1, hi(1)+nghi
                ii = i-hi(1)+nglo
                Tt(  ii) = q(i,j,k,qtemp)
                Xt(:,ii) = q(i,j,k,qx1:qx1+nspecies-1)
                Yt(:,ii) = q(i,j,k,qy1:qy1+nspecies-1)
                CALL CKCPMS(Tt(ii), iwrk, rwrk, Cpck)
                Cpt(:,ii) = Cpck
             end do
          
             CALL EGMPAR(np, Tt, Xt, Yt, Cpt, egwork, egiwork)
          
             CALL EGME3(np, Tt, Yt, egwork, ME) 
             mu(lo(1)-nglo:lo(1)-1,j,k) = ME(1:nglo)
             mu(hi(1)+1:hi(1)+nghi,j,k) = ME(nglo+1:)
          
             CALL EGMK3(np, Tt, Yt, egwork, MK) 
             xi(lo(1)-nglo:lo(1)-1,j,k) = MK(1:nglo) 
             xi(hi(1)+1:hi(1)+nghi,j,k) = MK(nglo+1:)
             
             CALL EGMVR1(np, Tt, Yt, egwork, D)
             do n=1,nspecies
                do i=lo(1)-nglo, lo(1)-1
                   ii = i-lo(1)+nglo+1
                   Ddiag(i,j,k,n) = D(n,ii)
                end do
                do i=hi(1)+1, hi(1)+nghi
                   ii = i-hi(1)+nglo
                   Ddiag(i,j,k,n) = D(n,ii)
                end do
             end do
             
             CALL EGML1(np,  1.d0, Tt, Xt, egwork, L1)
             CALL EGML1(np, -1.d0, Tt, Xt, egwork, L2)
             lam(lo(1)-nglo:lo(1)-1,j,k) = 0.5d0*(L1(1:nglo )+L2(1:nglo ))
             lam(hi(1)+1:hi(1)+nghi,j,k) = 0.5d0*(L1(nglo+1:)+L2(nglo+1:))
             
          end do
       end do
       !$omp end do
       
       deallocate(Tt, Xt, Yt, Cpt, D, ME, MK, L1, L2)
       !$omp end parallel
    
    end if

  end subroutine get_trans_prop_3d

end module transport_properties
