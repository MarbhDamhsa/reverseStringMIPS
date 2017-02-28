###########################################################################################
# Another MIPS Exercise: Have user enter a string of text.                                #
# Reverse characters entered by the user in memory in place.                              #
# Print reversed sequence of characters.                                                  #
###########################################################################################
# Note: for the purpose of this exercise, do not use stack memory to reverse characters.  #
# Instead, use logic to swap pairs of characters.                                         #
# Every non-trivial line of code in your program must have a readable comment             #
# or pseudocode explaining what it does.                                                  #
###########################################################################################
#                   #
# C++ code to use   #
#                   #
#####################
# string input;
#
# while (cout << "enter a string: ",
# getline(cin, input)) {
# if (input.length() == 0) {
#    cout << "nothing to do\n";
#    continue;
# }
# size_t idx_tail = input.length() - 1;
# size_t idx_front = 0;
# for(; idx_front < idx_tail; ++idx_front, --idx_tail)
# {
#     char front = input[idx_front];
#     input[idx_front] = input[idx_tail];
#     input[idx_tail] = front;
# }
##########################################################################################

.data
    .eqv READ_STRING_SERVICE      8
    .eqv SERVICE_PRINT_INT        1
    .eqv PRINT_STRING_SERVICE     4
    .eqv SERVICE_EXIT            10
    .eqv MAX_STRING_SIZE         80
    .eqv NEWLINE                0xA         #Hexadecimal for '\n'
    
### Declare variables    
input:     .space       80
msg_length:.asciiz      "string length is: "
prompt:    .asciiz      "enter a string: "
idx_tail:  .word        0
idx_front: .word        0

.text
    li  $v0, PRINT_STRING_SERVICE
    la  $t0, prompt 
    add $a0, $t0, $zero
    syscall                          

    li  $v0, READ_STRING_SERVICE
    la  $t0, input
    add $a0, $t0, $zero
    li  $a1, MAX_STRING_SIZE
    syscall

    # find the length of input string:
    la  $a0, input
    jal string_length
    
    # at this point $t3 has the length of input
    move $s3, $t3                     # preserve the length of input
    li   $v0, PRINT_STRING_SERVICE
    la   $t0, msg_length 
    add  $a0, $t0, $zero
    syscall 

    li  $v0, SERVICE_PRINT_INT           
    add $a0, $s3, $zero               # load $a0
    syscall
    
    beqz $s3, program_exit            # empty input ends program
    
    ############################################################
    # size_t idx_tail = input.length() - 1;
    # size_t idx_front = 0;
    # for(; idx_front < idx_tail; ++idx_front, --idx_tail)
    # {
    #     char front = input[idx_front];
    #     input[idx_front] = input[idx_tail];
    #     input[idx_tail] = front;
    # }
    ###########################################################
    
    move $t0, $s3               # input.length()
    move $t1, $zero             # idx_front 
    addu $t2, $t1, $t0          # idx_tail
    la   $t4, input             # location of character buffer 

    # swap characters in place
swap_characters:
    lb   $t5, input( $t1 )      # save from character in temporary registry $t5
    lb   $t6, input( $t2 )      # save tail character in temporary registry $t6
    sb   $t6, input( $t1 )      # store tail character as new front character
    sb   $t5, input( $t2 )      # store front character as new tail character
    addi $t1, $t1,  1           # increment head index
    addi $t2, $t2, -1           # decrement tail index
    slt  $t7, $t1, $t2          # if ( t1 < t2 )  $t7 == 1, zero otherwise
    bnez $t7, swap_characters
    
    # print the result
    li  $v0, PRINT_STRING_SERVICE
    la  $t0, input 
    add $a0, $t0, $zero
    syscall
    
program_exit:    
    li $v0, SERVICE_EXIT
    syscall        
	
###############################################################################
###
###
###    Procedures
###
###
###############################################################################

string_length:
    addiu $sp, $sp, -20               # allocate enough space to preserve 5 4-byte registers
	  sw $ra, 0($sp)
	  sw $t1, 4($sp)
	  sw $a0, 8($sp)
    sw $t2, 12($sp)
	  sw $t4, 16($sp)

    # find the length of input string:
    move $t4, $a0                     # address of string
    move $t3, $zero                   # init input buffer index
    li   $t1, NEWLINE
    
compare_char_to_newline:
    addu $a0, $t4, $t3                # compute address of a char
    lb   $t2, 0($a0)                  # load next character from input string
    beq  $t1, $t2, length_is_ready    # compare  char with \n
    addi $t3, $t3, 1                  # increment index
    j compare_char_to_newline
    
length_is_ready:
	  lw $ra, 0($sp)
	  lw $t1, 4($sp)
	  lw $a0, 8($sp)
    lw $t2, 12($sp)
	  lw $t4, 16($sp)
	  addiu $sp, $sp, 20         # deallocate register space  
    jr $ra                     # return back to the caller
# string_length ends
