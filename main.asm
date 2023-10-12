option casemap:none
ExitProcess proto
WriteConsoleA proto
ReadConsoleA proto
Sleep proto
GetStdHandle proto
.data
input_handle QWORD ?
output_handle QWORD ?
h0 DD 6A09E667H
h1 DD 0BB67AE85H
h2 DD 3C6EF372H
h3 DD 0A54FF53AH
h4 DD 510E527FH
h5 DD 9B05688CH
h6 DD 1F83D9ABH
h7 DD 5BE0CD19H
h0_2 DD 6A09E667H
h1_2 DD 0BB67AE85H
h2_2 DD 3C6EF372H
h3_2 DD 0A54FF53AH
h4_2 DD 510E527FH
h5_2 DD 9B05688CH
h6_2 DD 1F83D9ABH
h7_2 DD 5BE0CD19H
z0 DD ?
z1 DD ?
ma DD ?
ch1 DD ?
t1 DD ?
t2 DD ?
k DD  428A2F98H, 71374491H, 0B5C0FBCFH, 0E9B5DBA5H, 3956C25BH, 59F111F1H, 923F82A4H, 0AB1C5ED5H
  DD  0D807AA98H, 12835B01H, 243185BEH, 550C7DC3H, 72BE5D74H, 80DEB1FEH, 9BDC06A7H, 0C19BF174H
  DD  0E49B69C1H, 0EFBE4786H, 0FC19DC6H, 240CA1CCH, 2DE92C6FH, 4A7484AAH, 05CB0A9DCH, 76F988DAH
  DD  983E5152H, 0A831C66DH, 0B00327C8H, 0BF597FC7H, 0C6E00BF3H, 0D5A79147H, 06CA6351H, 14292967H
  DD  27B70A85H, 2E1B2138H, 4D2C6DFCH, 53380D13H, 650A7354H, 766A0ABBH, 081C2C92EH, 92722C85H
  DD  0A2BFE8A1H, 0A81A664BH, 0C24B8B70H, 0C76C51A3H, 0D192E819H, 0D6990624H, 0F40E3585H, 106AA070H
  DD  19A4C116H, 01E376C08H, 2748774CH, 34B0BCB5H, 391C0CB3H, 4ED8AA4AH, 05B9CCA4FH, 682E6FF3H
  DD  748F82EEH, 78A5636FH, 84C87814H, 8CC70208H, 90BEFFFAH, 0A4506CEBH, 0BEF9A3F7H, 0C67178F2H
message DB 64  DUP(0)
result DB 64 DUP(0)
temp DB 32 DUP(0)
op DB 3 DUP(0)
chars_written QWORD ?
string1 DB 10,"SHA256 hash encryption",10,"1 = Encrypt, Other Exit",10
string2 DB 10,"Encrypted: "
string DB "Good Bay"
string3 DB "Enter a line to encrypt: "
.code
	main proc
		mov rcx,-10
		call GetStdHandle
		mov input_handle,rax
		mov rcx,-11
		call GetStdHandle
		mov output_handle,rax
		call play
		mov rcx,5000
		call Sleep
		mov rcx,0
		call ExitProcess
	main endp

	input_string proc
		mov rcx,input_handle
		lea rdx,message
		mov r8,60
		mov r9,offset chars_written
		push 0h
		call ReadConsoleA
		pop rcx
		ret
	input_string endp

	print_string proc
		mov rcx,output_handle
		mov rdx,rsi
		mov r8,rbx
		mov r9,offset chars_written
		push 0h
		call WriteConsoleA
		pop rcx
		ret
	print_string endp

	play proc
		run_play:
			call clean 
			lea rsi,string1
			mov rbx,48
			call print_string
			call input_string
			cmp message,'1'
			jne end_play
			lea rsi,string3
			mov rbx,25
			call print_string
			call input_string
			mov rsi,offset string2
			mov rbx,11
			call print_string
			call encrypt
			mov rsi,offset result
			mov rbx,32
			call print_string
			jmp run_play
		end_play:
		lea rsi,string
		mov rbx,8
		call print_string
		ret
	play endp

	encrypt proc
		call add_one_bit
		call from_old_to_young_bytes
		mov r15,15
		mov r12,2
		mov rbx,16
		mov rsi,offset message
		run_enc1:
			sub rbx,r15
			mov r8b,[rsi+rbx]
			mov r9b,r8b
			mov r10b,r8b
			mov cl,7
			ror r8b,cl
			mov cl,18
			ror r9b,cl
			mov cl,3
			shr r10b,cl
			xor r8b,r9b
			xor r8b,r10b
			mov r13b,r8b
			add rbx,r15
			sub rbx,r12
			mov r8b,[rsi+rbx]
			mov r9b,r8b
			mov r10b,r8b
			mov cl,17
			ror r8b,cl
			mov cl,19
			ror r9b,cl
			mov cl,10
			shr r10b,cl
			xor r8b,r9b
			xor r8b,r10b
			mov r14,0
			mov r14b,r8b
			add rbx,r12
			mov [rsi+rbx],r13b
			mov rcx,0
			mov ecx,[rsi+rbx]
			add r14,rcx
			mov [rsi+rbx],r14b
			mov rdi,rsi
			add rdi,rbx
			sub rdi,16
			mov al,[rdi]
			add [rsi+rbx],al
			add rdi,16
			sub rdi,7
			mov al,[rdi]
			add [rsi+rbx],al
			inc rbx
			cmp rbx,64
			jl run_enc1
		mov r15d,h0
		mov r14d,h1
		mov r13d,h2
		mov r12d,h3
		mov r11d,h4
		mov r10d,h5
		mov r9d,h6
		mov r8d,h7
		mov h0_2,r15d
		mov h1_2,r14d
		mov h2_2,r13d
		mov h3_2,r12d
		mov h4_2,r11d
		mov h5_2,r10d
		mov h6_2,r9d
		mov h7_2,r8d
		mov rbx,64
		mov rsi,offset message
		mov rdi,offset k
		run_enc2:
			mov r8d,h0_2
			mov r9d,r8d
			mov r10d,r8d
			mov cl,2
			ror r8d,cl
			mov cl,13
			ror r9d,cl
			mov cl,22
			ror r10d,cl
			xor r8d,r9d
			xor r8d,r10d
			mov z0,r8d
			mov r8d,h0_2
			mov r9d,h1_2
			mov r10d,h2_2
			mov r11d,r8d
			and r11d,r9d
			mov r12d,r8d
			and r12d,r10d
			mov r13d,r10d
			and r13d,r9d
			xor r11d,r12d
			xor r11d,r13d
			mov t2,r11d
			mov r11,0
			mov r11d,z0
			mov rcx,0
			mov ecx,t2
			add rcx,r11
			mov t2,ecx
			mov r8d,h4_2
			mov r9d,r8d
			mov r10d,r8d
			mov cl,6
			ror r8d,cl
			mov cl,11
			ror r9d,cl
			mov cl,25
			ror r10d,cl
			xor r8d,r9d
			xor r8d,r10d
			mov z1,r8d
			mov r8d,h4_2
			mov r9d,r8d
			and r8d,h5_2
			not r9d
			and r9d,h6_2
			xor r8d,r9d
			mov ch1,r8d
			mov r8d,h7_2
			mov rcx,0
			mov ecx,r8d
			mov rax,0
			mov eax,z1
			add rcx,rax
			and rcx,0FFFFFFFFH
			mov eax,ch1
			add rcx,rax
			and rcx,0FFFFFFFFH
			mov eax,[rdi]
			add rcx,rax
			and rcx,0FFFFFFFFH
			mov rax,0
			mov al,[rsi]
			add rcx,rax
			and rcx,0FFFFFFFFH
			mov t1,ecx
			mov eax,h6_2
			mov h7_2,eax
			mov eax,h5_2
			mov h6_2,eax
			mov eax,h4_2
			mov h5_2,eax
			mov eax,h3_2
			mov h4_2,eax
			mov rax,0
			mov eax,t1
			mov rcx,0
			mov ecx,h4_2
			add rcx,rax
			and rcx,0FFFFFFFFH
			mov h4_2,ecx
			mov eax,h2_2
			mov h3_2,eax
			mov eax,h0_2
			mov h1_2,eax
			mov rax,0
			mov eax,t1
			mov rcx,0
			mov ecx,t2
			add rcx,rax
			mov h0_2,ecx
			inc rsi
			add rdi,4
			dec rbx
			jnz run_enc2
		mov r8,0
		mov r8d,h0
		mov r9,0
		mov r9d,h1
		mov r10,0
		mov r10d,h2
		mov r11,0
		mov r11d,h3
		mov r12,0
		mov r12d,h4
		mov r13,0
		mov r13d,h5
		mov r14,0
		mov r14d,h6
		mov r15,0
		mov r15d,h7
		mov rax,0
		mov eax,h0_2
		mov rbx,0
		mov ebx,h1_2
		mov rcx,0
		mov ecx,h2_2
		mov rdx,0
		mov edx,h3_2
		mov rsi,0
		mov esi,h4_2
		mov rdi,0
		mov edi,h5_2
		add r8,rax
		add r9,rbx
		add r10,rcx
		add r11,rdx
		add r12,rsi
		add r13,rdi
		mov rax,0
		mov rbx,0
		mov eax,h6_2
		mov ebx,h7_2
		add r14,rax
		add r15,rbx
		mov rsi,offset temp
		mov [rsi],r8d
		add rsi,4
		mov [rsi],r9d
		add rsi,4
		mov [rsi],r10d
		add rsi,4
		mov [rsi],r11d
		add rsi,4
		mov [rsi],r12d
		add rsi,4
		mov [rsi],r13d
		add rsi,4
		mov [rsi],r14d
		add rsi,4
		mov [rsi],r15d
		sub rsi,28
		mov rdi,offset result
		mov rbx,32
		init_result:
			mov ah,[rsi]
			mov cl,4
			shr ah,cl
			mov [rdi],ah
			inc rdi
			mov al,[rsi]
			and al,0FH
			mov [rdi],al
			inc rdi
			inc rsi
			dec rbx
			jnz init_result
		lea rsi,result
		mov rbx,64
		mov ah,55
		mov al,48
		to_printable:
			mov cl,[rsi] 
			cmp cl,9
			jg letter
			add [rsi],al
			jmp next_to_printable
			letter:
			add [rsi],ah
			next_to_printable:
			inc rsi
			dec rbx
			jnz to_printable
		ret
	encrypt endp

	clean proc
		lea rsi,message
		lea rdi,result
		mov rbx,64
		run_clean:
			mov byte ptr [rsi],0
			mov byte ptr [rdi],0
			inc rsi
			inc rdi
			dec rbx
			jnz run_clean
		ret
	clean endp

	add_one_bit proc
		mov rsi,offset message
		run_add:
			cmp byte ptr [rsi],0
			je end_add
			inc rsi
			jmp run_add
		end_add:
		dec rsi
		mov byte ptr[rsi],0
		dec rsi
		mov byte ptr[rsi],80H
		ret
	add_one_bit endp

	from_old_to_young_bytes proc
		mov rsi,offset message
		mov rdi,offset message
		add rsi,3
		mov rbx,16
		run_switch1:
			run_switch2:
				mov al,[rsi]
				mov ah,[rdi]
				mov [rsi],ah
				mov [rdi],al
				inc rsi
				dec rdi
				cmp rsi,rdi
				jng run_switch2
			add rdi,6
			inc rsi
			dec rbx
			jnz run_switch1
		ret
	from_old_to_young_bytes endp
end













