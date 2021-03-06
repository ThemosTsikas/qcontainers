
subroutine test_qlist_1()
    use qlist_m
    use assert_test_m
    implicit none

    type(qlist_t) :: list

    integer :: i, isiz
    integer :: v, vback, vmax=50
    integer, allocatable :: vback_arr(:)

    print *, ""
    print *, "Start of test_qlist_1"

    isiz = storage_size(v) / 8
    call list%new(isiz)

    v = 444
    call list%addfirst(v)

    do v = 1, vmax
        call list%addfirst(v)
    end do

    call list%getfirst(vback)
    call assert_equal(vback, vmax)

    call list%getlast(vback)
    call assert_equal(vback, 444)

    call list%getat(-26, vback)
    call assert_equal(vback, 25)

    i = list%size()
    call assert_equal(i, 50+1)

    allocate(vback_arr(i))
    call list%toarray(vback_arr)

    call assert_equal(vback_arr(1), vmax)
    call assert_equal(vback_arr(i), 444)
end subroutine

subroutine test_qlist_2()
    use qlist_m
    use assert_test_m
    implicit none

    type(qlist_t) :: list

    integer :: i, isiz, imax=5
    real(8) :: v, vback
    type(qlist_obj_t) :: obj

    print *, ""
    print *, "Start of test_qlist_2"

    isiz = storage_size(v) / 8
    call list%new(isiz)

    do i = 1, imax
        v = i
        call list%addlast(v)
    end do

    i = 1
    call obj%init()
    do while (list%getnext(obj))
        call obj%getdata(vback)
        call assert_equal(vback, real(i, kind=8))
        i = i + 1
    end do

    isiz = list%size()
    do i = 1, isiz
        call list%popfirst(vback)
        call assert_equal(vback, real(i, kind=8))
    end do

    call assert_equal(list%size(), 0)
end subroutine

subroutine test_qlist_3()
    use qlist_m
    use assert_test_m

    type test_t
        integer :: id
        real(8) :: a
    end type

    type(qlist_t) :: list
    integer :: isiz, i, nelem
    type(test_t) :: v
    type(test_t), allocatable :: varr(:)
    logical :: suc

    print *
    print *, "Subroutine test_3. Start"

    isiz = storage_size(v) / 8
    call list%new(isiz)
    call list%setsize(5)    ! restrict size to 5 elements

    do i = 1, 6
        v%id = i
        v%a = i * 10
        call list%addlast(v,success=suc)
        if (i == 6) then
            call assert_false(suc) ! error because the max size already reached
        else
            call assert_true(suc)
        end if
    end do

    nelem = list%size()
    call assert_equal(nelem, 5)

    allocate(varr(nelem))
    call list%toarray(varr)

    call assert_equal(varr(3)%id, 3)
    call assert_equal(varr(3)%a, 3*10._8)
end subroutine

subroutine test_qlist_4()
    use qlist_m
    use assert_test_m

    type test_t
        integer :: id
        real(8), allocatable :: arr(:)
    end type

    type(qlist_t) :: list
    integer :: isiz, i, nelem
    type(test_t), pointer :: vp
    type(test_t), allocatable :: varr(:)
    logical :: isalloc

    print *, ""
    print *, "Start of test_qlist_4"

    isiz = storage_size(vp) / 8
    call list%new(isiz)

    print *, 'isiz=', isiz
    do i = 1, 5
        allocate(vp)
        allocate(vp%arr(i))
        vp%id = i
        vp%arr(:) = i*10

        call list%addlast(vp)
    end do

    nelem = list%size()
    call assert_equal(nelem, 5)

    allocate(varr(nelem))
    call list%toarray(varr)

    do i = 1, nelem
        call assert_equal(varr(i)%id, i)
        isalloc = allocated(varr(i)%arr)
        call assert_true(isalloc)
        call assert_equal(size(varr(i)%arr), i)
        call assert_equal(varr(i)%arr(i), real(i*10,kind=8))
    end do
end subroutine

subroutine test_qlist_5()
    use qlist_m
    use assert_test_m

    type(qlist_t) :: list
    integer :: siz
    character(len=:), allocatable :: string

    print *, ""
    print *, "Start of test_qlist_5"

    call list%new()
    call list%addlast("Do ", 3)
    call list%addlast("your ", 5)
    call list%addlast("best. No less.", 14)

    siz = list%datasize()
    allocate(character(len=siz) :: string)
    call list%toarray(string)
    call assert_equal(string, "Do your best. No less.")
end subroutine

subroutine test_qlist_6()
    use assert_test_m
    use qlist_m
    implicit none

    type(qlist_t) :: list, list_copy
    integer :: isiz
    integer :: i
    logical :: success

    print *, ""
    print *, "Start of test_qlist_6"

    isiz = storage_size(i) / 8
    call list%new(isiz)

    do i = 1, 5
        call list%addlast(i)
    end do

    list_copy = list
    call list_copy%addat(6, 6, success=success)
    call assert_true(success)

    call list_copy%getat(0, i, success) ! index can't be zero
    call assert_false(success)

    call list_copy%getat(-1, i)
    call assert_equal(i, 6)

    i = list_copy%size()
    call assert_equal(i, 6)

    i = list%size()
    call assert_equal(i, 5)

    call list%getat(-1, i, success)
    call assert_true(success)
    call assert_equal(i, 5)
end subroutine



subroutine test_qlist_7()
    use assert_test_m
    use qlist_m
    use iso_c_binding
    implicit none

    type values
        real, allocatable :: x(:)
        integer :: nv
    end type

    type(qlist_t) :: list
    integer :: isiz
    integer :: i, j
    integer :: nv
    type(values), pointer :: res
    type(c_ptr) :: lp

    type(qlist_obj_t) :: obj

    print *, ""
    print *, "Start of test_qlist_7"

    isiz = storage_size(lp) / 8
    call list%new(isiz)

    do j = 1, 3
        nv = 5 * j
        allocate(res)       ! allocate pointer
        allocate(res%x(nv))
        do i = 1, nv
            res%x(i) = i * 100.
        end do
        res%nv = nv

        lp = c_loc(res)
        call list%addlast(lp)
    end do

    call list%getat(1, lp)
    call c_f_pointer(lp, res)
    call assert_equal(res%nv, 5)
    call assert_equal(res%x(5), 5.*100.)

    call list%getat(3, lp)
    call c_f_pointer(lp, res)
    call assert_equal(res%nv, 15)
    call assert_equal(res%x(1), 1.*100.)
    call assert_equal(res%x(15), 15.*100.)

    ! Destructor of qlist will not free the memory allocated for Fortran pointer.
    ! User is self responsible to free memory allocated for the pointers of values.
    i = 0
    call obj%init()
    do while (list%getnext(obj))
        call obj%getdata(lp)
        call c_f_pointer(lp, res)

        i = i + 1
        call assert_equal(res%nv, i * 5)

        deallocate(res)
    end do
end subroutine

subroutine testing_qlist()
    use assert_test_m
    implicit none

    print *, "Testing qlist"

    call assert_init()

    call test_qlist_1()
    call test_qlist_2()
    call test_qlist_3()
    call test_qlist_4()
    call test_qlist_5()
    call test_qlist_6()
    call test_qlist_7()

    call assert_print_summary()
end subroutine

