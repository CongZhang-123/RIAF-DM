module dm_cooling_table_module
    use interp2d_module, only: dp, read_table, interp2d
    implicit none

    private
    public :: init_qdm_table, qdm_from_table

    character(len=*), parameter :: qdm_table_file = "../cooling-data/cooling_rate.dat"
    real(dp), parameter :: sigma_ref = 1.0e-30_dp
    real(dp), parameter :: mevtoerg = 1.602e-6_dp
    real(dp), parameter :: cgs_to_internal = 8.87e-27_dp

    real(dp), allocatable :: radius_grid(:), tem_grid(:), qdm_table(:,:)
    logical :: table_loaded = .false.

contains

    subroutine init_qdm_table()
        if (table_loaded) return

        call read_table(qdm_table_file, radius_grid, tem_grid, qdm_table)
        table_loaded = .true.
    end subroutine init_qdm_table

    real(dp) function qdm_from_table(r, te, m, sigmadm) result(qdm)
        real(dp), intent(in) :: r, te, m, sigmadm
        real(dp) :: qdm_mev_ref

        if (sigmadm == 0.0_dp) then
            qdm = 0.0_dp
            return
        end if

        if (.not. table_loaded) call init_qdm_table()

        qdm_mev_ref = interp2d(radius_grid, tem_grid, qdm_table, r, te)

        ! cooling_rate.dat is tabulated in MeV for sigma_ref, then converted to code units.
        qdm = qdm_mev_ref * (sigmadm / sigma_ref) &
             * mevtoerg * cgs_to_internal * m**3
    end function qdm_from_table

end module dm_cooling_table_module
