module interp2d_module
    use iso_fortran_env, only: real64
    implicit none

    integer, parameter :: dp = real64

contains

    subroutine read_table(table_file, radius, tem, table)
        character(len=*), intent(in) :: table_file
        real(dp), allocatable, intent(out) :: radius(:), tem(:), table(:,:)
        integer :: i, unit
        integer :: nr, nt
        integer :: slash_pos
        character(len=1024) :: table_dir, radius_file, tem_file

        ! Use the DM-electron cooling table directory for matching radius/temperature grids.
        slash_pos = scan(table_file, "/", back=.true.)
        if (slash_pos > 0) then
            table_dir = table_file(:slash_pos)
        else
            table_dir = ""
        end if

        radius_file = trim(table_dir) // "radius.dat"
        tem_file = trim(table_dir) // "Tem.dat"

        nr = count_lines(radius_file)
        nt = count_lines(tem_file)

        allocate(radius(nr), tem(nt), table(nr, nt))

        open(newunit=unit, file=radius_file, status="old")
        do i = 1, nr
            read(unit, *) radius(i)
        end do
        close(unit)

        open(newunit=unit, file=tem_file, status="old")
        do i = 1, nt
            read(unit, *) tem(i)
        end do
        close(unit)

        open(newunit=unit, file=table_file, status="old")
        do i = 1, nr
            read(unit, *) table(i, :)
        end do
        close(unit)
    end subroutine read_table

    real(dp) function interp2d(radius, tem, table, r0, t0) result(v0)
        real(dp), intent(in) :: radius(:), tem(:), table(:,:)
        real(dp), intent(in) :: r0, t0
        integer :: i, j, k, nr, nt
        real(dp) :: x0, y0, x1, x2, y1, y2
        real(dp) :: tx, ty
        real(dp) :: f11, f21, f12, f22

        nr = size(radius)
        nt = size(tem)

        if (t0 < tem(1)) then
            v0 = 0.0_dp
            return
        end if

        x0 = log(r0)
        y0 = log(t0)

        i = nr - 1
        do k = 1, nr - 1
            if (x0 <= log(radius(k + 1))) then
                i = k
                exit
            end if
        end do

        j = nt - 1
        do k = 1, nt - 1
            if (y0 <= log(tem(k + 1))) then
                j = k
                exit
            end if
        end do

        x1 = log(radius(i))
        x2 = log(radius(i + 1))
        y1 = log(tem(j))
        y2 = log(tem(j + 1))

        tx = (x0 - x1) / (x2 - x1)
        ty = (y0 - y1) / (y2 - y1)

        f11 = table(i, j)
        f21 = table(i + 1, j)
        f12 = table(i, j + 1)
        f22 = table(i + 1, j + 1)

        v0 = (1.0_dp - tx) * (1.0_dp - ty) * f11 &
           + tx * (1.0_dp - ty) * f21 &
           + (1.0_dp - tx) * ty * f12 &
           + tx * ty * f22
    end function interp2d

    integer function count_lines(filename) result(n)
        character(len=*), intent(in) :: filename
        integer :: unit, ios
        character(len=1024) :: line

        n = 0
        open(newunit=unit, file=filename, status="old")
        do
            read(unit, "(A)", iostat=ios) line
            if (ios /= 0) exit
            if (len_trim(line) > 0) n = n + 1
        end do
        close(unit)
    end function count_lines

end module interp2d_module
