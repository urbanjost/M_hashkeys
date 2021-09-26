module M_hashkeys
   use,intrinsic :: ISO_FORTRAN_ENV, only : int8,int16,int32,int64,real32,real64,real128
   use iso_c_binding
contains
   function sha256(str)
      implicit none
      character(len=64) :: sha256
      character(len=*), intent(in) :: str
      sha256 = sha256b(str, 1)
   end function sha256
   function dirty_sha256(str)
      implicit none
      character(len=64) :: dirty_sha256
      character(len=*), intent(in) :: str
      dirty_sha256 = sha256b(str, 0)
   end function dirty_sha256
   function sha256b(str, swap)
      implicit none
      character(len=64)            :: sha256b
      character(len=*), intent(in) :: str
      integer,          intent(in) :: swap
      integer(kind=c_int64_t) :: length
      integer(kind=c_int32_t) :: temp1
      integer(kind=c_int32_t) :: temp2
      integer(kind=c_int32_t) :: i
      integer :: break
      integer :: pos0
      integer(kind=c_int32_t),parameter :: h0_ref(8)= [&
      & int(z'6a09e667',kind=c_int32_t), &
      & int(z'bb67ae85',kind=c_int32_t), &
      & int(z'3c6ef372',kind=c_int32_t), &
      & int(z'a54ff53a',kind=c_int32_t), &
      & int(z'510e527f',kind=c_int32_t), &
      & int(z'9b05688c',kind=c_int32_t), &
      & int(z'1f83d9ab',kind=c_int32_t), &
      & int(z'5be0cd19',kind=c_int32_t)]
      integer(kind=c_int32_t),parameter :: k0_ref(64)=[ &
      & int(z'428a2f98',kind=c_int32_t), int(z'71374491',kind=c_int32_t), int(z'b5c0fbcf',kind=c_int32_t), &
      & int(z'e9b5dba5',kind=c_int32_t), int(z'3956c25b',kind=c_int32_t), int(z'59f111f1',kind=c_int32_t), &
      & int(z'923f82a4',kind=c_int32_t), int(z'ab1c5ed5',kind=c_int32_t), int(z'd807aa98',kind=c_int32_t), &
      & int(z'12835b01',kind=c_int32_t), int(z'243185be',kind=c_int32_t), int(z'550c7dc3',kind=c_int32_t), &
      & int(z'72be5d74',kind=c_int32_t), int(z'80deb1fe',kind=c_int32_t), int(z'9bdc06a7',kind=c_int32_t), &
      & int(z'c19bf174',kind=c_int32_t), int(z'e49b69c1',kind=c_int32_t), int(z'efbe4786',kind=c_int32_t), &
      & int(z'0fc19dc6',kind=c_int32_t), int(z'240ca1cc',kind=c_int32_t), int(z'2de92c6f',kind=c_int32_t), &
      & int(z'4a7484aa',kind=c_int32_t), int(z'5cb0a9dc',kind=c_int32_t), int(z'76f988da',kind=c_int32_t), &
      & int(z'983e5152',kind=c_int32_t), int(z'a831c66d',kind=c_int32_t), int(z'b00327c8',kind=c_int32_t), &
      & int(z'bf597fc7',kind=c_int32_t), int(z'c6e00bf3',kind=c_int32_t), int(z'd5a79147',kind=c_int32_t), &
      & int(z'06ca6351',kind=c_int32_t), int(z'14292967',kind=c_int32_t), int(z'27b70a85',kind=c_int32_t), &
      & int(z'2e1b2138',kind=c_int32_t), int(z'4d2c6dfc',kind=c_int32_t), int(z'53380d13',kind=c_int32_t), &
      & int(z'650a7354',kind=c_int32_t), int(z'766a0abb',kind=c_int32_t), int(z'81c2c92e',kind=c_int32_t), &
      & int(z'92722c85',kind=c_int32_t), int(z'a2bfe8a1',kind=c_int32_t), int(z'a81a664b',kind=c_int32_t), &
      & int(z'c24b8b70',kind=c_int32_t), int(z'c76c51a3',kind=c_int32_t), int(z'd192e819',kind=c_int32_t), &
      & int(z'd6990624',kind=c_int32_t), int(z'f40e3585',kind=c_int32_t), int(z'106aa070',kind=c_int32_t), &
      & int(z'19a4c116',kind=c_int32_t), int(z'1e376c08',kind=c_int32_t), int(z'2748774c',kind=c_int32_t), &
      & int(z'34b0bcb5',kind=c_int32_t), int(z'391c0cb3',kind=c_int32_t), int(z'4ed8aa4a',kind=c_int32_t), &
      & int(z'5b9cca4f',kind=c_int32_t), int(z'682e6ff3',kind=c_int32_t), int(z'748f82ee',kind=c_int32_t), &
      & int(z'78a5636f',kind=c_int32_t), int(z'84c87814',kind=c_int32_t), int(z'8cc70208',kind=c_int32_t), &
      & int(z'90befffa',kind=c_int32_t), int(z'a4506ceb',kind=c_int32_t), int(z'bef9a3f7',kind=c_int32_t), &
      & int(z'c67178f2',kind=c_int32_t)]
      integer(kind=c_int32_t) :: h0(8)
      integer(kind=c_int32_t) :: k0(64)
      integer(kind=c_int32_t) :: a0(8)
      integer(kind=c_int32_t) :: w0(64)
      logical,save :: printme=.true.
      if(printme)then
         write(*,'(*(b32.32,1x))')h0_ref
         write(*,'(*(b32.32,1x))')k0_ref
         printme=.false.
      endif
      h0 = h0_ref
      k0 = k0_ref
      break  = 0
      pos0   = 1
      length = len(trim(str))
      do while (break .ne. 1)
         call consume_chunk(str, length, w0(1:16), pos0, break, swap)
         do i=17,64
            w0(i) = ms1(w0(i-2)) + w0(i-16) + ms0(w0(i-15)) + w0(i-7)
         enddo
         a0 = h0
         do i=1,64
            temp1 = a0(8) + cs1(a0(5)) + ch(a0(5),a0(6),a0(7)) + k0(i) + w0(i)
            temp2 = cs0(a0(1)) + maj(a0(1),a0(2),a0(3))
            a0(8) = a0(7)
            a0(7) = a0(6)
            a0(6) = a0(5)
            a0(5) = a0(4) + temp1
            a0(4) = a0(3)
            a0(3) = a0(2)
            a0(2) = a0(1)
            a0(1) = temp1 + temp2
         enddo
         h0 = h0 + a0
      enddo
      write(sha256b,'(8z8.8)') h0(1), h0(2), h0(3), h0(4), h0(5), h0(6), h0(7), h0(8)
   end function sha256b
   function swap32(inp)
      implicit none
      integer(kind=c_int32_t) :: swap32
      integer(kind=c_int32_t), intent(in)  :: inp
      call mvbits(inp, 24, 8, swap32,  0)
      call mvbits(inp, 16, 8, swap32,  8)
      call mvbits(inp,  8, 8, swap32, 16)
      call mvbits(inp,  0, 8, swap32, 24)
   end function swap32
   function swap64(inp)
      implicit none
      integer(kind=c_int64_t) :: swap64
      integer(kind=c_int64_t), intent(in)  :: inp
      call mvbits(inp, 56, 8, swap64,  0)
      call mvbits(inp, 48, 8, swap64,  8)
      call mvbits(inp, 40, 8, swap64, 16)
      call mvbits(inp, 32, 8, swap64, 24)
      call mvbits(inp, 24, 8, swap64, 32)
      call mvbits(inp, 16, 8, swap64, 40)
      call mvbits(inp,  8, 8, swap64, 48)
      call mvbits(inp,  0, 8, swap64, 56)
   end function swap64
   function swap64a(inp)
      implicit none
      integer(kind=c_int64_t) :: swap64a
      integer(kind=c_int64_t), intent(in)  :: inp
      call mvbits(inp,  0, 8, swap64a, 32)
      call mvbits(inp,  8, 8, swap64a, 40)
      call mvbits(inp, 16, 8, swap64a, 48)
      call mvbits(inp, 24, 8, swap64a, 56)
      call mvbits(inp, 32, 8, swap64a,  0)
      call mvbits(inp, 40, 8, swap64a,  8)
      call mvbits(inp, 48, 8, swap64a, 16)
      call mvbits(inp, 56, 8, swap64a, 24)
   end function swap64a
   function ch(a, b, c)
      integer(kind=c_int32_t) :: ch
      integer(kind=c_int32_t), intent(in) :: a
      integer(kind=c_int32_t), intent(in) :: b
      integer(kind=c_int32_t), intent(in) :: c
      ch = ieor(iand(a, b), (iand(not(a), c)))
   end function ch
   function maj(a, b, c)
      integer(kind=c_int32_t) :: maj
      integer(kind=c_int32_t), intent(in) :: a
      integer(kind=c_int32_t), intent(in) :: b
      integer(kind=c_int32_t), intent(in) :: c
      maj = ieor(iand(a, b), ieor(iand(a, c), iand(b, c)))
   end function maj
   function cs0(a)
      implicit none
      integer(kind=c_int32_t) :: cs0
      integer(kind=c_int32_t), intent(in) :: a
      cs0 = ieor(ishftc(a, -2), ieor(ishftc(a, -13), ishftc(a, -22)))
   end function cs0
   function cs1(a)
      implicit none
      integer(kind=c_int32_t) :: cs1
      integer(kind=c_int32_t), intent(in) :: a
      cs1 = ieor(ishftc(a, -6), ieor(ishftc(a, -11), ishftc(a, -25)))
   end function cs1
   function ms0(a)
      implicit none
      integer(kind=c_int32_t) :: ms0
      integer(kind=c_int32_t), intent(in) :: a
      ms0 = ieor(ishftc(a, -7), ieor(ishftc(a, -18), ishft(a, -3)))
   end function ms0
   function ms1(a)
      implicit none
      integer(kind=c_int32_t) :: ms1
      integer(kind=c_int32_t), intent(in) :: a
      ms1 = ieor(ishftc(a, -17), ieor(ishftc(a, -19), ishft(a, -10)))
   end function ms1
   subroutine consume_chunk(str, length, inp, pos0, break, swap)
      implicit none
      character(len=*),        intent(in)    :: str
      integer(kind=c_int64_t), intent(in)    :: length
      integer(kind=c_int32_t), intent(inout) :: inp(*)
      integer,                 intent(inout) :: pos0
      integer,                 intent(inout) :: break
      integer,                 intent(in)    :: swap
      character(len=4)        :: last_word
      integer(kind=c_int64_t) :: rest
      integer(kind=c_int32_t) :: to_pad
      integer(kind=c_int32_t) :: leftover
      integer(kind=c_int32_t) :: space_left
      integer(kind=c_int32_t),parameter :: zero= int(b'00000000000000000000000000000000',kind=c_int32_t)
      integer(kind=c_int8_t),parameter  :: ipad0=int(b'00000000',kind=c_int8_t)
      integer(kind=int64),save :: ipad1__              =int(b'10000000',kind=int64)
      integer(kind=c_int8_t),save :: ipad1             ;equivalence(ipad1,ipad1__)
      integer(kind=c_int8_t)  :: i
      rest = length - pos0 + 1
      if (rest .ge. 64) then
         inp(1:16) = transfer(str(pos0:pos0+64-1), inp(1:16))
         if (swap .eq. 1) then
            do i=1,16
               inp(i) = swap32(inp(i))
            enddo
         endif
         pos0 = pos0 + 64
      else
         space_left = 16
         leftover   = rest/4
         if (leftover .gt. 0) then
            inp(1:leftover) = transfer(str(pos0:pos0+leftover*4-1), inp(1:16))
            if (swap .eq. 1) then
               do i=1,leftover
                  inp(i) = swap32(inp(i))
               enddo
            endif
            pos0 = pos0 + leftover*4
            rest = length - pos0 + 1
            space_left = space_left - leftover
         endif
         if (space_left .gt. 0) then
            if (break .ne. 2) then
               if (rest .gt. 0) then
                  last_word(1:rest) = str(pos0:pos0+rest-1)
                  pos0 = pos0 + rest
               endif
               last_word(rest+1:rest+1) = transfer(ipad1, last_word(1:1))
               to_pad = 4 - rest - 1
               do i=1,to_pad
                  last_word(rest+1+i:rest+1+i) = transfer(ipad0, last_word(1:1))
               enddo
               inp(17-space_left) = transfer(last_word(1:4), inp(1))
               if (swap .eq. 1) then
                  inp(17-space_left) = swap32(inp(17-space_left))
               endif
               space_left = space_left - 1
               break = 2
            endif
            if (space_left .eq. 1) then
               inp(16) = zero
               space_left = 0
            endif
            rest = 0
         endif
         if ((rest .eq. 0) .and. (space_left .ge. 2)) then
            do while (space_left .gt. 2)
               inp(17-space_left) = zero
               space_left = space_left - 1
            enddo
            inp(15:16) = transfer(swap64a(length*8), inp(15:16))
            break = 1
         endif
      endif
   end subroutine consume_chunk
end module M_hashkeys
program demo_sha256
   use M_hashkeys, only : sha256, dirty_sha256
   implicit none
   character(len=:),allocatable :: str
   character(len=64)            :: ref
   str=""
   ref="E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855"
   call unit_check('sha256',sha256(str)==ref,'test sha256 1')
   str="abc"
   ref="BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD"
   call unit_check('sha256',sha256(str)==ref,'test sha256 2')
   str="abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
   ref="248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1"
   call unit_check('sha256',sha256(str)==ref,'test sha256 3')
   str="abcdefghbcdefghicdefghijdefghijkefghijklfghi&
   &jklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu"
   ref="CF5B16A778AF8380036CE59E7B0492370B249B11E8F07A51AFAC45037AFEE9D1"
   call unit_check('sha256',sha256(str)==ref,'test sha256 4')
   str=repeat("a",1000000)
   ref="CDC76E5C9914FB9281A1C7E284D73E67F1809A48A497200E046D39CCC7112CD0"
   call unit_check('sha256',sha256(str)==ref,'test sha256 5')
   str="message digest"
   ref="F7846F55CF23E14EEBEAB5B4E1550CAD5B509E3348FBC4EFA3A1413D393CB650"
   call unit_check('sha256',sha256(str)==ref,'test sha256 6')
   str="secure hash algorithm"
   ref="F30CEB2BB2829E79E4CA9753D35A8ECC00262D164CC077080295381CBD643F0D"
   call unit_check('sha256',sha256(str)==ref,'test sha256 7')
   str="SHA256 is considered to be safe"
   ref="6819D915C73F4D1E77E4E1B52D1FA0F9CF9BEAEAD3939F15874BD988E2A23630"
   call unit_check('sha256',sha256(str)==ref,'test sha256 8')
   str="For this sample, this 63-byte string will be used as input data"
   ref="F08A78CBBAEE082B052AE0708F32FA1E50C5C421AA772BA5DBB406A2EA6BE342"
   call unit_check('sha256',sha256(str)==ref,'test sha256 9')
   str="This is exactly 64 bytes long, not counting the terminating byte"
   ref="AB64EFF7E88E2E46165E29F2BCE41826BD4C7B3552F6B382A9E7D3AF47C245F8"
   call unit_check('sha256',sha256(str)==ref,'test sha256 10')
   ref="69E3FACD5F08321F78117BD53476E5321845433356F106E7013E68EC367F3017"
   call unit_check('sha256',dirty_sha256(str)==ref,'test dirtysha256 1')
contains
   subroutine unit_check(name,test,message)
      character(len=*),intent(in) :: name
      logical,intent(in)          :: test
      character(len=*),intent(in) :: message
      write(*,'(a)') repeat("=",64)
      write(*,'(a)') sha256(str)
      write(*,'(a)') ref
      if(test)then
         write(*,*)trim(name)," PASSED: ",trim(message)
      else
         write(*,*)trim(name)," FAILED: ",trim(message)
      endif
   end subroutine unit_check
end program demo_sha256
