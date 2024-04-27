# First Architecture Project : Interactive Monthly Calendar Application
# Done by students --> Name : Abdelkarim Eiss ID : 1200015
#		   --> Name : Momen Salem     ID : 1200034
#
# INSTRUCTOR AND SECTION 
# INSTRUCTOR NAME: Dr.Aziz Qaroush 
# SECTION NO.: 2
# The idea in our project is to read the calender from file and convert it to 2D array to simplify update, add
# or delete its content. also do calculation on array and finally save the result to the same file
#
# our array convention is built like this 
# |0 |1....9|
# |1 |
# |. |
# |. |
# |30|
# our 2D array have 31 row indeacting the days with 9 column indicating the valid times (from 8AM-5PM we have 9 times)  
# so first column indecate the time from 8AM-9AM the second 9AM-10AM and so on until 4PM-5PM
# after reading file is done any operation can by used on array with less effort and time

################ Data Section ################
.data
file_name:	.asciiz "C:\\Users\\Asus\\Desktop\\A . ( Plans )\\Calendar.txt"
# to make the program run properly the path must be the path of Calendar.txt file

#-----------------------Menu Choices Messages----------------------------
welcomeMSG: .asciiz "\n\t\t~Welcome To the monthly calendar program~\t\t\n"
menu:	.asciiz "\nWhat do you need from the menu, please enter your choice:\n"
View_Calendar:	.asciiz "\t1- View the calendar.\n"
MSG_for_viewCalendar: .asciiz "\nWhat do you need from this option?\n"
View_Calendar1:	.asciiz "1- View it per day.\n"
View_Calendar2:	.asciiz "2- View it per set of days.\n"
View_Calendar3:	.asciiz "3- View it for a given slot in a given day.\n"
View_Statistics:	.asciiz "\t2- View the statistics.\n"
Add_NewAppointment:	.asciiz "\t3- Add new appointment.\n"
Delete_AnAppointment:	.asciiz "\t4- Delete an appointment.\n"
Exit_And_Save:	.asciiz "\t5- Exit the program and save all data into a file.\n"
#-----------------------Menu Results Messages----------------------------
NL: .asciiz "\nThe number of lectures = "
NO: .asciiz "\nThe number of office hours = "
NM: .asciiz "\nThe number of meetings = "
avg_lect: .asciiz "\nAverage lectures per day = "
ratio_LtoOH: .asciiz "\nThe ratio between total number of lectures to total number of office hours = "
metting: .asciiz "(There is a meeting)"
lecture: .asciiz "(There is a lecture)"
officehour: .asciiz "(There is an office hour)"
adding_done_msg: .asciiz "\nAdding appointment done properly"
deleting_done_msg: .asciiz "\nDeleting appointment done properly"
save_exit: .asciiz "\nSave done, welcome\n"
#-----------------------Prompts Messages----------------------------
enter: .asciiz "\t\t\t==>Enter: "
enterTheDay: .asciiz "\t\t\t==>Enter the day (Please between 1 to 31 only): "
View_Calendar2_MSG: .asciiz "\t\t\t==>Enter the number of days: "
View_Calendar3_MSG_FirstTime: .asciiz "\t\t\t==>Enter the first time of the slot: "
View_Calendar3_MSG_SecondTime: .asciiz "\t\t\t==>Enter the second time of the slot: "
read_appointment: .asciiz "\t\t\t==>Enter the appointment type (L, M and O if OH): "

#-----------------------Symbols----------------------------
Lecture: .asciiz " L"
OH: .asciiz " OH"
Meeting: .asciiz " M"
dash: .asciiz "-"
twoPoints: .asciiz ": "
newLine: .asciiz "\n"
comma: .asciiz ", "
Free: .asciiz " F"
split: .asciiz "\n-------------------------------------------------------------------\n"
#-----------------------Errors Messages----------------------------
index_error_msg: .asciiz "\nThere is an error in file the day must be from 1-31 only\n"
error_time_msg:	.asciiz "\nThere is an error in file the time must be from 8AM-5PM only\n"
zero_time_error_msg:	.asciiz "\nTheir is no time zero in range 8AM-5PM\n"
order_time_error_msg:	.asciiz "\nTheir is an error in time format in file\n"
ElseMSG: .asciiz "\nError, Please choose from the menu only!\n"
noDataForThisDay: .asciiz "\nSorry, there is no data for this day!\n"
OFE: .asciiz "\nThe file does not opened correctly, There is an error in the path of file or in the file name\n"
incorrect_Index_MSG: .asciiz "\nThere is an error!, the day must be from 1-31 only!\n"
incorrect_time: .asciiz "\nThere is an error!!, the time must be from 8AM - 5PM only!\n"
incorrect_appointment: .asciiz "\nThere is an error!!, the appointment type must be (L or M or (O=OH)) only!\n"
time_error: .asciiz "\nThe first time slot must be less than the second only !\n"
conflict_msg1: .asciiz "\nThere is a conflict in the time slot "
conflict_msg2: .asciiz " do you want to change it [Y/N]?\n"
delete_type_error: .asciiz "\nThe type reserved not the same as the type to delete"

#-----------------------Saves Needed & Initializations----------------------------
# file contents in bytes temporarily value (2048)
file_content: 	.space 2048 
# initialize the array contents to zeros (no appointments) and size to 31 * 9 = 279 byte  
calendar_arr:	.byte 0:279
# the new buffer to write the array and also the size is temporarily 2048
write_file: .space 2048
#Symbols array for save and exit part to provide the symbols
symbol: .space 8


################ Text(Code) Section ################
.text
.globl main
main: 
################################################ Reading File ################################################
	# first thing is to check if the file exist and then read the file to our array 
	la $a0, file_name
	li $v0, 13
	syscall
	bge $v0, 0, file_opened_correctly
	# if the file name is not correct or there is an error in path then we print error message and stop the program
	la $a0, OFE	# OFE --> open file error
	li $v0, 4
	syscall
	j exit_program
file_opened_correctly:
	move $s7, $v0
	
	move $a0, $s7
	li $a1, 0
	la $a1, file_content
	li $a2, 279
	li $v0, 14
	syscall
	
	la $s0, file_content	# the address of content of the file
	la $a0, calendar_arr
	li $s1, 0	# register to save the first number from time period
line_begin:
	lb $a1, 0($s0)
	beqz $a1, file_end
	lb $t1, 1($s0)
	li $t5, ':'	# check if the number has one digit which mean that the byte after number is :
	and $t4, $t1, $t5
	beq $t4, $t5, one_digit_day
	subiu $a1, $a1,'0'
	sll $t2, $a1, 3
	sll $t0, $a1, 1
	# multiply the first digit by 10 and add to it the second digit to have the number as two digit
	addu $a1, $t0, $t2
	addiu $s0, $s0, 1	# add 1 byte (1 and then 2) if the number of day has two digits
	addu $a1, $a1, $t1
one_digit_day:
	addiu $s0, $s0, 1	# add 1 to start linking after the day number
	beq $a1, '0', index_error	# check if the index day is zero (error)
	subiu $a1, $a1, 0x31 #conver ascii to int (and subtract the index by 1 --> day 1 has index 0 in our array)
	bgt $a1, 30, index_error
	
	jal arr_index_first_col 	#find the address of the day in array and point to the first column
	move $s2, $v0	#save the index address returned from the function
read_line_content:
	lb $t0, 0($s0)
	beqz $t0, file_end
	li $t1, '\r'	# save the carriage return value indecating the end of line
	bne $t1, $t0, not_EOL
	addiu $s0, $s0, 2	# add 2 because after \r their is \n and we pass it by adding 2
	j line_begin
not_EOL:	# not end of line label indecating that the pointer is not at the end of line 
	lb $t3, 1($s0)	#check if the number has two or one digit
	li $t1, '0'
	li $t2, '9'
	li $t4, 'L'
	beq $t0, $t4, store_lecture
	li $t4, 'O'
	beq $t0, $t4, store_office_hour
	li $t4, 'M'
	beq $t0, $t4, store_metting
	blt $t0, $t1, increment
	bgt $t0, $t2, increment
	li $t4, '-'	#check if the byte next to number is '-' which means this time has one digit
	beq $t3, $t4, one_digit_time
	li $t4, ' '	#check if the number is after - which means that the next to it can be digit or space
	beq $t3, $t4, one_digit_time
	addiu $s0, $s0, 1
	subiu $t0, $t0, '0'	# convert the digit from ascii to int (befort shift it to left) also because this number has 2 digits bellow we convert the first digit 
	# when obtain the first digit then we must multiply it by 10 to make it the second digit
	sll $t1, $t0, 3
	sll $t0, $t0, 1
	addu $t0, $t0, $t1
	addu $t0, $t0, $t3
	
	# check if the two digit number not in [10, 11, 12] --> out of our calender time so print error message and stop program
	subiu $t1, $t0, '0'	# convert ascii to int by subtracting '0' to check if the number is grater than 12 or not
	li $t2, 12
	bgtu $t1, $t2, error_Time
	
one_digit_time:
	subiu $t0, $t0, '0' # convert ascii to int for proper use
	beqz $t0, zero_time_error	# if time is zero there is an error (not in proper range)
	li $t1, 5	#check if the number is less than 5 Time range [8AM-5PM]
	beq $t0, 6, error_Time
	beq $t0, 7, error_Time
	bgtu $t0, $t1, proper_time
	addiu $t0, $t0, 12
	
proper_time:	#label to indicate that the time is in 24-hour format and in proper range
	# $t0 --> the time in 24-hour format
	bleu $t0, $s1, order_time_error 
	beqz $s1, save_number	# this is the first number go and read the second one
	# if the loop reach here then the two numbers are readed properly 
	# then we must calculate the column index in our array (using the difference between numbers)
	
	subu $s3, $t0, $s1	# subtract the second time from the first one and save the number of cells to fill it later
	subiu $s1, $s1, 8	# subtract our time by 8 to obtain column index (8 means first column 9 second .... until 17(5PM) means 9 column index)
	addu $s4, $s2, $s1	# the address of the needed cell (true row and column in our array)

	li $s1, 0
	j increment
	
save_number:
	move $s1, $t0	
	j increment

store_lecture:
	li $t0, 1	# in our convinsion we let the number 1 to represent the value for lecture type
	beqz $s3, increment	# loop finish is for subtracting the last increment index 
	sb $t0, 0($s4)
	addiu $s4, $s4, 1
	subiu $s3, $s3, 1
	j store_lecture

store_office_hour:
	li $t0, 2	# in our convinsion we let the number 2 to represent the value for lecture type
	beqz $s3, increment	# loop finish is for subtracting the last increment index 
	sb $t0, 0($s4)
	addiu $s4, $s4, 1
	subiu $s3, $s3, 1
	j store_office_hour

store_metting:
	li $t0, 3	# in our convinsion we let the number 2 to represent the value for lecture type
	beqz $s3, increment	# loop finish is for subtracting the last increment index 
	sb $t0, 0($s4)
	addiu $s4, $s4, 1
	subiu $s3, $s3, 1
	j store_metting	
	
increment:
	addiu $s0, $s0, 1
	j read_line_content 
		

arr_index_first_col:
	# find the array index to save the day in his index (day serve as index for array)
	# $arr[i][j] = $arr + (i * arr_column) + j = $arr + (i * 9) + j (we have 9 appointments from 8AM-5PM
	# multiplication is convert to shift for simplicity --> (i * 9 = i * (8 + 1) = i << 3 + i)
	# $t1 = i (the day number loaded from file)	
	sll $t3, $a1, 3
	addu $t3, $t3, $a1
	addu $t4, $t3, $a0	# the address of the day is calculated here
	move $v0, $t4	#return the result value (the index of row in our matrix)
	jr $ra
	
index_error:
	la $a0, index_error_msg
	li $v0, 4
	syscall
	j exit_program

order_time_error:
	la $a0, order_time_error_msg
	li $v0, 4
	syscall
	j exit_program	
error_Time:
	la $a0, error_time_msg
	li $v0, 4
	syscall
	j exit_program	
	
zero_time_error:
	la $a0, zero_time_error_msg
	li $v0, 4
	syscall
	j exit_program
exit_program:
	la $v0, 10
	syscall	
file_end:
	move $a0, $s7
	li $v0, 16
	syscall
	
	
	
################################################ Menu ################################################	
	#welcome MSG
	la $a0, welcomeMSG
	li $v0, 4
	syscall
#MENU
menuLoop:
	la $a0, split
	li $v0, 4
	syscall
	#Menu MSG
	la $a0, menu
	li $v0, 4
	syscall
	#FirstChoice----View_Calendar
	la $a0, View_Calendar
	li $v0, 4
	syscall    
 	#SecondChoice--View_Statistics
 	la $a0, View_Statistics
	li $v0, 4
	syscall
	#ThirdChoice---Add_NewAppointment
	la $a0, Add_NewAppointment
	li $v0, 4
	syscall
	#ForthChoice----Delete_AnAppointment
	la $a0, Delete_AnAppointment
	li $v0, 4
	syscall 
	#Exit and save choice
	la $a0, Exit_And_Save
	li $v0, 4
	syscall   
	#Enter Your Choice
	la $a0, enter
	li $v0, 4
	syscall 
	#Read The Choice
	li $v0, 5
	syscall

	move $t6, $v0 #The entry
	#Check the proper of choice
	li $t5, 1
	li $v1, 2
	li $a1, 3
	#if x<1 and x>4 -->error
	bltu $t6,$t5, errorChoice
	bgtu $t6,5, errorChoice
	beq $t6,$t5, FirstChoice
	beq $t6,$v1, Second_choice
	beq $t6, $a1, Third_choice
	beq $t6, 4, Fourth_choice
	beq $t6, 5, Exit # To save the result on the same file and exist the program



################################################ First Choice ################################################
FirstChoice:
	#Menu MSG
	la $a0, MSG_for_viewCalendar
	li $v0, 4
	syscall
	
	#FirstChoice----View_Calendar
	la $a0, View_Calendar1
	li $v0, 4
	syscall
	#SecondChoice----View_Calendar
	la $a0, View_Calendar2
	li $v0, 4
	syscall
	#ThirdChoice----View_Calendar
	la $a0, View_Calendar3
	li $v0, 4
	syscall
	
	#Enter Your Choice
	la $a0, enter
	li $v0, 4
	syscall 
	#Read The Choice
	li $v0, 5
	syscall
	move $t6, $v0 #The entry (Store the choice number)
	
	#if x<1 and x>3 -->error
	bltu $t6,$t5, errorChoice
	bgtu $t6,$a1, errorChoice
	###Check the choice
	beq $t6, 1, First_viewPerDay
	beq $t6, 2, Second_viewSetDays
	beq $t6, 3, Third_ASpecificSlot
###### First-First Choice #########
First_viewPerDay:
	###First Choice
       li $s7, 0 # A flag for the comma checker, to check if 0 go to menuLoop, else
       #serve the second choice
       #A msg to enter the day number
       la $a0, enterTheDay
	li $v0, 4
	syscall
       #Read The day index
	li $v0, 5
	syscall
	move $t2,$v0 #Move the day to find the its position in the array
	##To check if the day is correct [1-31] or not
	jal Day_Checker
	#To print the day number
	move $a0,$t2
	li $v0, 1
	syscall
	#To print two points ':'
	la $a0, twoPoints
	li $v0, 4
	syscall
	subiu $t2,$t2,1 # To find the position on the array--> for example, if the day index equals to 1 then its position on the array is equal to 0
       # To find the day index in calendar array
	# $arr[i][j] = $arr + (i * arr_column) + j = $arr + (i * 9) + j (we have 9 appointments from 8AM-5PM
	# multiplication is convert to shift for simplicity --> (i * 9 = i * (8 + 1) = i << 3 + i)
	la $t1, calendar_arr #load the address of the calendar array
	sll $t3, $t2, 3
	addu $t3, $t3, $t2
	addu $t4, $t3, $t1	# the address of the day is calculated here
	move $v0, $t4	#Save the result value (the index of row in our matrix)
	#Check only
	move $a3,$v0 #a0=address of the position
	#Counter for the Loading loop
	li $s0, 0 #Also, we know the position of the cell using it
	#Counter to check if the all contents are zeros-->no data
	li $s1,0
	#The first hour == 8 in the position zero
	li $s3,8
loadAgain:
	beq $s1,9, EmptyContents  #If no data for this day
	beq $s0,9,menuLoop #if the cells for this day are finished 
	###
	lb $a2, 0($a3) #The day number from the array
	beqz $a2, noData #If the cell's content equals to zero-->no data on it
	#To print the day number
	move $a0,$a2 #a0=address of the position
	#if integer= 1 -->L, 2-->OH, 3--->M
	beq $a0,1,Alecture
	beq $a0,2,AnOH
	beq $a0,3,AMeeting
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	j loadAgain

errorChoice:
	#error msg for the wrong entry
	la $a0, ElseMSG
	li $v0, 4
	syscall
	j menuLoop
#For the choice one in the first choice
noData:
	addiu $s0, $s0, 1 # Increment the loop counter
	addiu $s1, $s1, 1 # Increment the Zeros counter
	addiu $a3, $a3, 1 # Increment the address
	j loadAgain
	
EmptyContents:
	#A msg to display that there is no data for a specific day
	la $a0, noDataForThisDay
	li $v0, 4
	syscall
	j menuLoop
#Lecture Process
Alecture:
	#Save on $s4 the start of the time slot
	addu $s4,$s3,$s0
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFlectCells
continue1:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time of the interval which is in $s4
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the lecture symbol
	la $a0, Lecture
	li $v0, 4
	syscall
	#To ignore the comma if the cursor in the last cell
	jal Comma_Checker #To check if there is any slot after this slot or no to print it
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
	j loadAgain
#Office Hours Process
AnOH:
	#Save on $s4 the start of the time slot
	addu $s4,$s3,$s0
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFohCells
continue2:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time of the interval whhich is in $s4
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the OH symbol
	la $a0, OH
	li $v0, 4
	syscall
	#To ignore the comma if the cursor in the last cell
	jal Comma_Checker #To check if there is any slot after this slot or no to print it
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
	j loadAgain
#The Meeting Process
AMeeting:
	#Save on $s4 the start of the time slot
	addu $s4,$s3,$s0
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFmCells
continue3:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time of the interval whhich is in $s4
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall

	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the OH symbol
	la $a0, Meeting
	li $v0, 4
	syscall
	#To ignore the comma if the cursor in the last cell
	jal Comma_Checker #To check if there is any slot after this slot or no to print it
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
	j loadAgain

#To find the number of lect Cells
NumberOFlectCells:
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue1 #If not equal the previous value
	addiu $s5,$s5,1
	addiu $a3,$a3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFlectCells
	
#To find the number of OH Cells
NumberOFohCells:
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue2 #If not equal the previous value
	addiu $s5,$s5,1
	addiu $a3,$a3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFohCells
#To find the number of M Cells
NumberOFmCells:
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue3 #If not equal the previous value
	addiu $s5,$s5,1
	addiu $a3,$a3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFmCells
#General functions for all choices
#To convert the hour from 24-hours time format to 12-hours time format if it between (12-17)
FirstTimeToTwelveHoursFormat:
	#To check if the time between 1-5
	bltu $s4, 18, CONTINUE #if the time less than 6 to include time=5
	j doneee1
CONTINUE:
	bgtu $s4, 12, ToTwelve1
	j doneee1
ToTwelve1:
	subiu $s4, $s4, 12 # to convert the format to 12-hours time format
	#ex: 13 = 13-12 = 1 --> as we know, 13=1 in the time formats
doneee1:
	jr $ra #To return to the last position
##For the second time in the interval
#To convert the hour from 24-hours time format to 12-hours time format if it between (12-17)
SecondTimeToTwelveHoursFormat:
	#To check if the time between 1-5
	bgtu $t9, 12, ToTwelve2
	j doneee2
	bltu $t9, 18, ToTwelve2
	j doneee2
ToTwelve2:
	subiu $t9, $t9, 12 # to convert the format to 12-hours time format
	#ex: 13 = 13-12 = 1 --> as we know, 13=1 in the time formats
doneee2:
	jr $ra #To return to the last position

#Function to check the possibility of print the comma after the slot
Comma_Checker:
	move $t0, $s0 #To get the cells counter
	move $a1, $a3 #To get the address
CHECK:
	beq $t0,9,transition #if the cells for this day are finished
	j proceed #ELSE
transition:
	beq $s7, 0, menuLoop
	beq $s7, 1, loadAgain_Second
proceed:
	lb $t1, ($a1)
	beqz $t1, update_counter #If the cell's content equals to zero-->no data on it
	j checked
update_counter:
	addiu $t0, $t0, 1 #Update the counter
	addiu $a1, $a1, 1 #Update the address
	j CHECK
checked:
	jr $ra # To return to the next instruction
############################################	
###For the second choice in the first choice
Second_viewSetDays:
	li $s7, 1 # Update the flag that used in the comma checker function
	#$s7 is used to check if 0 go to menuLoop, else serve the second choice in first choice
	#SecondChoice MSG----View_Calendar
	la $a0, View_Calendar2_MSG
	li $v0, 4
	syscall
	#A counter for the loop --> which equal the number of days, also
	li $k0, 0
	#Read The number of days
	li $v0, 5
	syscall
	move $k1,$v0 #Move the day to find the its position in the array
##Loop to read a days from the user and serve it
daysLoop:
	#To print a new line
	la $a0, newLine
	li $v0, 4
	syscall
	#Chaeck the number of read days
	beq $k0,$k1, menuLoop
	addiu $k0, $k0, 1 #Update the counter
	#A msg to enter the day number
       la $a0, enterTheDay
	li $v0, 4
	syscall
       #Read The day index
	li $v0, 5
	syscall
	move $t2,$v0 #Move the day to find the its position in the array
	##To check if the day is correct [1-31] or not
	jal Day_Checker
	#To print the day number
	move $a0,$t2
	li $v0, 1
	syscall
	#To print two points ':'
	la $a0, twoPoints
	li $v0, 4
	syscall
	subiu $t2,$t2,1 # To find the position on the array--> for example, if the day index equals to 1 then its position on the array is equal to 0
       # To find the day index in calendar array
	# $arr[i][j] = $arr + (i * arr_column) + j = $arr + (i * 9) + j (we have 9 appointments from 8AM-5PM
	# multiplication is convert to shift for simplicity --> (i * 9 = i * (8 + 1) = i << 3 + i)
	la $t1, calendar_arr #load the address of the calendar array
	sll $t3, $t2, 3
	addu $t3, $t3, $t2
	addu $t4, $t3, $t1	# the address of the day is calculated here
	move $v0, $t4	#Save the result value (the index of row in our matrix)
	#Check only
	move $a3,$v0 #a0=address of the position
	#Counter for the Loading loop
	li $s0, 0 #Also, we know the position of the cell using it
	#Counter to check if the all contents are zeros-->no data
	li $s1,0
	#The first hour == 8 in the position zero
	li $s3,8
loadAgain_Second:
	beq $s1,9, EmptyContents_Second  #If no data for this day
	beq $s0,9,daysLoop #if the cells for this day are finished 
	###
	lb $a2, 0($a3) #The day number from the array
	beqz $a2, noData_Second #If the cell's content equals to zero-->no data on it
	#To print the day number
	move $a0,$a2 #a0=address of the position
	#if integer= 1 -->L, 2-->OH, 3--->M
	beq $a0,1,Alecture_Second
	beq $a0,2,AnOH_Second
	beq $a0,3,AMeeting_Second
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	j loadAgain_Second
#To check if no contents for a day
EmptyContents_Second:
	#A msg to display that there is no data for a specific day
	la $a0, noDataForThisDay
	li $v0, 4
	syscall
	j daysLoop
#For the choice one in the first choice
noData_Second:
	addiu $s0, $s0, 1 # Increment the loop counter
	addiu $s1, $s1, 1 # Increment the Zeros counter
	addiu $a3, $a3, 1 # Increment the address
	j loadAgain_Second
#Lecture Process
Alecture_Second:
	#Save on $s4 the start of the time slot
	addu $s4,$s3,$s0
	
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFlectCells_Second
continue1_Second:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time of the interval which is in $s4
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the lecture symbol
	la $a0, Lecture
	li $v0, 4
	syscall
	#To ignore the comma if the cursor in the last cell
	jal Comma_Checker #To check if there is any slot after this slot or no to print it
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
	j loadAgain_Second
#OH Process
AnOH_Second:
	#Save on $s4 the start of the time slot
	addu $s4,$s3,$s0
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFohCells_Second
continue2_Second:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time of the interval whhich is in $s4
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the OH symbol
	la $a0, OH
	li $v0, 4
	syscall
	#To ignore the comma if the cursor in the last cell
	jal Comma_Checker #To check if there is any slot after this slot or no to print it
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
	j loadAgain_Second
#The Meeting Process
AMeeting_Second:
	#Save on $s4 the start of the time slot
	addu $s4,$s3,$s0
	#UPDATE
	addiu $a3, $a3, 1 # Increment the address
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFmCells_Second
continue3_Second:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time of the interval whhich is in $s4
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the OH symbol
	la $a0, Meeting
	li $v0, 4
	syscall
	#To ignore the comma if the cursor in the last cell
	jal Comma_Checker #To check if there is any slot after this slot or no to print it
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
	j loadAgain_Second

#To find the number of lect Cells
NumberOFlectCells_Second:
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue1_Second #If not equal the previous value
	addiu $s5,$s5,1
	addiu $a3,$a3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFlectCells_Second
	
#To find the number of OH Cells
NumberOFohCells_Second:
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue2_Second #If not equal the previous value
	addiu $s5,$s5,1
	addiu $a3,$a3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFohCells_Second
#To find the number of M Cells
NumberOFmCells_Second:
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue3_Second #If not equal the previous value
	addiu $s5,$s5,1
	addiu $a3,$a3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	#move $t9, $s5
	j NumberOFmCells_Second
############################################
###For the third choice in the first choice
Third_ASpecificSlot:
	li $s7, 2 # Update the flag
	#for the comma checker, to check if 0 go to menuLoop, else serve the second choice in first choice
	#To enter the day
	la $a0, enterTheDay
	li $v0, 4
	syscall
	#Read The day index
	li $v0, 5
	syscall
	move $t2,$v0 #Move the day to find the its position in the array
	jal Day_Checker
	#After the day is checked
Read_Time_Again:	
	#A msg
	la $a0, View_Calendar3_MSG_FirstTime
	li $v0, 4
	syscall
       #Read The first time
	li $v0, 5
	syscall
	move $t1,$v0 #Move to find the its position in the array
	#A msg
	la $a0, View_Calendar3_MSG_SecondTime
	li $v0, 4
	syscall
	#Read the second time
	li $v0, 5
	syscall
	move $t3,$v0 #Move to find the its position in the array
	# check if the first time for appointement is entered in the true range
	bgtu $t1, 12, incorrect # If incorrect, the program will request the time again
	beq $t1, 6, incorrect
	beq $t1, 7, incorrect
	beqz $t1, incorrect
	# check if the second time for appointement is entered in the true range
	bgtu $t3, 12, incorrect
	beq $t3, 6, incorrect
	beq $t3, 7, incorrect
	beqz $t3, incorrect
	#To print the day number
	move $a0,$t2
	li $v0, 1
	syscall
	#To print two points ':'
	la $a0, twoPoints
	li $v0, 4
	syscall
	#To check if the time between 1-5 --> We need to convert it as a 24-hours format
	bleu $t1,5,ProcessTheFirstTimeSlot
	j FirstTimeConverted ## To skip if the first statement false
	bgeu $t1,1,ProcessTheFirstTimeSlot
FirstTimeConverted:
	bleu $t3,5,ProcessTheSecondTimeSlot
	j SecondTimeConverted ## To skip if the first statement false
	bgeu $t3,1,ProcessTheSecondTimeSlot
SecondTimeConverted:

	#Calculate the positions of the first and second times
	subiu $k0, $t1,8 #For the first time
	subiu $k1, $t3,8 #For the second time
	##To calculate the address of the column in the specific day
	##This depends on: &matrix[i][j] = &matrix + (i×COLS + j) × Element_size
	subiu $t2,$t2,1 # To find the position on the array (i)--> for example, if the day index equals to 1 then its position on the array is equal to 0
       # To find the day index in calendar array
	la $t1, calendar_arr #load the address of the calendar array (&matrix)
	sll $t3, $t2, 3 ##(i*8)
	addu $t3, $t3, $t2 ## (i*8)+i=i*9 , since the number of columns=9
	addu $t3, $t3, $k0 ####To move the cursor of the address to the start time of the slot
	addu $t4, $t3, $t1	# the address of the day is calculated here
	move $v0, $t4	#Save the result value (the index of row in our matrix)
	move $a3,$v0 #Return the address and save it
SlotLoop:
	beq $k0,$k1, menuLoop #To chech if in the end of the time slot
	lb $a2, 0($a3) #The column's address on the array		
	beqz $a2, FreeData_FThird #If the cell's content equals to zero-->no data on it
	#To print the day number
	move $a0,$a2 #a0=address of the position
	#if integer= 1 -->L, 2-->OH, 3--->M
	beq $a0,1,Alecture_Third
	beq $a0,2,AnOH_Third
	beq $a0,3,AMeeting_Third
	addiu $a3,$a3,1 #Update the address
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	j SlotLoop
#To convert the time format if the input 1,2,3,4,5 to make it in the 24-hours format
ProcessTheFirstTimeSlot:
	addiu $t1,$t1,12
	j FirstTimeConverted
ProcessTheSecondTimeSlot:
	addiu $t3,$t3,12
	j SecondTimeConverted
#To check the day is in the range [1-31] or not
Day_Checker:
	bgeu $t2, 1, firstCheck
	j enter_day_again
firstCheck:
	bleu $t2, 31, secondCheck
	j enter_day_again
secondCheck:
	jr $ra #Return and complete
enter_day_again:
	#An error msg for a user
	la $a0, incorrect_Index_MSG
	li $v0, 4
	syscall
	#To enter the day
	la $a0, enterTheDay
	li $v0, 4
	syscall
	#Read The day index
	li $v0, 5
	syscall
	move $t2,$v0 #Move the day to find the its position in the array
	j Day_Checker

#As a linker between time error checker and the function of the msg
incorrect:
	jal ERROR_TIME_MSG
	j Read_Time_Again
#To check the time correctness
ERROR_TIME_MSG:
	#An error msg for a user
	la $a0, incorrect_time
	li $v0, 4
	syscall
	jr $ra

#To check if the cell's content equals to zero-->no data on it-->So it is a free cell
FreeData_FThird:
	#Save on $s4 the start of the time slot
	addiu $s4,$k0,8
	#UPDATE
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberFREECells
continue1_FREE:
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1

	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the lecture symbol
	la $a0, Free
	li $v0, 4
	syscall
	beq $k0, $k1, SKIP #To skip the comma if we are at the last requested slot
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
SKIP:
	j SlotLoop

#Lecture Process
Alecture_Third:
	#Save on $s4 the start of the time slot
	addiu $s4,$k0,8

	#UPDATE
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	beq $k0,$k1, continue1_Third #To chech if in the end of the time slot
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFlectCells_Third
continue1_Third:
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the lecture symbol
	la $a0, Lecture
	li $v0, 4
	syscall
	beq $k0, $k1, SKIP1 #To ignore the comma
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
SKIP1:
	j SlotLoop
AnOH_Third:
	#Save on $s4 the start of the time slot
	addiu $s4,$k0,8
	#UPDATE
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFohCells_Third
continue2_Third:
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17] and convert it to a 12-hours format
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	#To print the first time
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the OH symbol
	la $a0, OH
	li $v0, 4
	syscall
	beq $k0, $k1, SKIP2
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
SKIP2:
	j SlotLoop
AMeeting_Third:
	#Save on $s4 the start of the time slot
	addiu $s4,$k0,8
	#UPDATE
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFmCells_Third
continue3_Third:
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17] and convert it to a 12-hours format
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	move $a0,$s4 #a0=address of the position
	li $v0, 1
	syscall
	#To print the dash
	la $a0, dash
	li $v0, 4
	syscall
	#To print the next value of the interval
	move $a0,$t9
	li $v0, 1
	syscall
	#To print the OH symbol
	la $a0, Meeting
	li $v0, 4
	syscall
	beq $k0, $k1, SKIP3 #To ignore the comma
	#To print a comma
	la $a0, comma
	li $v0, 4
	syscall
SKIP3:
	j SlotLoop

#To find the number of lect Cells
NumberOFlectCells_Third:
	beq $k0,$k1, continue1_Third #To check if in the end of the time slot
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue1_Third #If not equal the previous value
	addiu $s5,$s5,1
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	#move $t9, $s5
	j NumberOFlectCells_Third
	
#To find the number of OH Cells
NumberOFohCells_Third:
	beq $k0,$k1, continue2_Third #To chech if in the end of the time slot
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue2_Third #If not equal the previous value
	addiu $s5,$s5,1
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	#move $t9, $s5
	j NumberOFohCells_Third
#To find the number of M Cells
NumberOFmCells_Third:
	beq $k0,$k1, continue3_Third #To chech if in the end of the time slot
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue3_Third #If not equal the previous value
	addiu $s5,$s5,1
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	#move $t9, $s5
	j NumberOFmCells_Third
#To find the number of F (free) Cells
NumberFREECells:
	beq $k0,$k1, continue1_FREE #To chech if in the end of the time slot
	lb $s6,0($a3) #Load the next value
	bne $s6, $a2, continue1_FREE #If not equal the previous value
	addiu $s5,$s5,1
	addiu $k0,$k0,1 #Update the cursor which in the start time slot
	addiu $a3, $a3, 1 # Increment the address
	#move $t9, $s5
	j NumberFREECells
	
	
	
################################################ Second Choice ################################################
Second_choice:
	# in this choice we will loop for all values in our array so we need for loop until all cells readed
	# after this we must count how many lectures, office hours and mettings by compare each cell value
	la $s0, calendar_arr	# load the address of array first
	li $s1, 0	# initiate the number of lectures
	li $s2, 0	# initiate the number of office hours
	li $s3, 0	# initiate the number of mettings
	li $t0, 0	# variable to break the loop if we read all entries in array (if equal 279 then stop reading)

	
loop:
	beq $t0, 279, loop_done	# number 279 indecate the number of rows * columns in array
	lb $t3, 0($s0)
	beq $t3, 1, add_lecture
	beq $t3, 2, add_office_hour
	beq $t3, 3, add_metting
	addiu $t0, $t0, 1
	addiu $s0, $s0, 1
	j loop
	
add_lecture:
	addiu $s1, $s1, 1	# increment the number of lectures
	addiu $s0, $s0, 1	# increment the pointer of array (point to next cell)
	addiu $t0, $t0, 1	# increment number of cells readed until now
	j loop
add_office_hour:
	addiu $s2, $s2, 1	# increment the number of office hours
	addiu $s0, $s0, 1	# increment the pointer of array (point to next cell)
	addiu $t0, $t0, 1	# increment number of cells readed until now
	j loop
add_metting:
	addiu $s3, $s3, 1	# increment the number of meeting
	addiu $s0, $s0, 1	# increment the pointer of array (point to next cell)
	addiu $t0, $t0, 1	# increment number of cells readed until now
	j loop	
		 
loop_done:
	la $s0, calendar_arr	
	li $s4, 0	# initiate the number of days
	li $t0, 31	# variable to break the loop if we read all rows in array
	li $t1, 8	# variable to break the loop if we read all columns in array 
count_days:
	beqz $t0, count_days_done	# if $t0 = zero then all rows were readed and thier is no day reamin
	beqz $t1, day_increment		# thier is no appointment (column) in this day (row)
	lb $t3, 0($s0)
	bnez $t3, add_day
	addiu $s0, $s0, 1
	subiu $t1, $t1, 1	# decrease the number of columns to check (still in the same day)
	j count_days
add_day:
	addiu $s4, $s4, 1	# increment the number of days that has an appointment in thier time
	addu $s0, $s0, $t1	# add the reamining number of columns (we have an appointment in this day so ignore any value in row after that)
	addiu $s0, $s0, 1	# add one to make the pointer point to next day
	li $t1, 8		# reinitiate the number of coulmns for that new day	
	j count_days
day_increment:
	subiu $t0, $t0, 1
	addiu $s0, $s0, 1	# point to the next row (day)
	li $t1, 8		# reinitiate the number of coulmns for that day
	j count_days
count_days_done:
	
	# print the number of lectures 
	la $a0, NL
	li $v0, 4
	syscall
	move $a0, $s1
	li $v0, 1
	syscall
	
	# print the number of office hours
	la $a0, NO
	li $v0, 4
	syscall
	move $a0, $s2
	li $v0, 1
	syscall
	
	# print the number of meetings 
	la $a0, NM
	li $v0, 4
	syscall
	move $a0, $s3
	li $v0, 1
	syscall
	
	# print the avg lectures per day message
	la $a0, avg_lect
	li $v0, 4
	syscall
	# move the values to coprocessor 1 to have the result value in float format (division may have float result)
	mtc1 $s1, $f0	
	mtc1 $s4, $f1
	div.s $f2, $f0, $f1	# divide total number of lectures to number of days	
	mov.s $f12, $f2
	li $v0, 2
	syscall
	
	# print the ratio between total number of hours reserved for lectures and total number reserved for office hours 
	la $a0, ratio_LtoOH
	li $v0, 4
	syscall
	#divu $t0, $s1, $s2 	# divide total number of lectures to total number of office hours
	
	move $a0, $s1		# print number of hours reserved for lectures
	li $v0, 1
	syscall
	li $a0, ':'		# load colon to print the ration as L:OH
	li $v0, 11
	syscall
	move $a0, $s2		# print number of hours reserved for office hours
	li $v0, 1
	syscall
	j menuLoop

	
		
################################################ Third Choice ################################################	
#Third choice of the menu which is add a new appointment
Third_choice:	
	##Day index
	#A msg for a user
	la $a0, enterTheDay
	li $v0, 4
	syscall
	#Read The day
	li $v0, 5
	syscall
	move $t0,$v0
	#To check the day index if proper or not
	bgtu $t0, 31, indexError #If index>31 -->incorrect
	bltu $t0, 1, indexError #if index<1 -->incorrect
FirstTimeError:
	##First Time
	#A msg to read the first time slot
	la $a0, View_Calendar3_MSG_FirstTime
	li $v0, 4
	syscall
	#Read the time
	li $v0, 5
	syscall
	move $t1,$v0
	# check if the first time for appointement is entered in the true range
	bgtu $t1, 12, Time1_Check
	beq $t1, 6, Time1_Check		# there is no time 6 or 7 just from 8-5
	beq $t1, 7, Time1_Check
	beqz $t1, Time1_Check
	

# prompt the second time slot from user
SecondTimeError:
	#A msg to read the second time slot
	la $a0, View_Calendar3_MSG_SecondTime
	li $v0, 4
	syscall
	#Read the time
	li $v0, 5
	syscall
	move $t2,$v0
	
	# check if the first time for appointement is entered in the true range
	bgtu $t2, 12, Time2_Check
	beq $t2, 6, Time2_Check
	beq $t2, 7, Time2_Check
	beqz $t2, Time2_Check
	
	#check if the times is from 1-5 which must convert to 13-17
	bgtu $t1, 5, check_second_time
	addiu $t1, $t1, 12
	
check_second_time:
	bgtu $t2, 5, appointment_read_again
	addiu $t2, $t2, 12
appointment_read_again:
	bgeu $t1, $t2, Time_error
	#A msg to read the appointment type
	la $a0, read_appointment
	li $v0, 4
	syscall
	#Read the appointment
	li $v0, 12
	syscall
	move $t5,$v0
	#To check the correctness of the appointment type
	beq $t5, 'L', good_app
	beq $t5, 'O', good_app
	beq $t5, 'M', good_app
	j Wrong_appointment
	
good_app:
	subiu $t0, $t0, 1	# calculate the index of the row (day)
	#Calculate the positions of the first and second times
	subiu $t1, $t1,8 #For the first time
	subiu $t2, $t2,8 #For the second time
	# call index function to calculate the address of row then use the difference between first and second columns to check the cells
	la $a0, calendar_arr	# save the first argument for the function bellow
	move $a1, $t0		# save the second argument for the function
	jal arr_index_first_col
	move $s0, $v0		# save the result returned from function
	addu $s0, $s0, $t1	# make the pointer point to the needed column (the first time indecate our column is array)
	# at this line we have pointer to our needed cell with needed type 
	# first we want to calculate how many slots do you need to reserve 
	# by subtracting the second time from the first we have this information
	subu $s1, $t2, $t1
	# in reg s1 -> the number of cells to be check if they reserved or not to check if there is a conflict
	# change the appointment type to our convention (L -> 1, O -> 2, M -> 3)
	li $t6, 0	# this is flag to print the conflict message (if there is a conflict with more one slot with same type just print one message)
	bne $t5, 'L', check_O
	li $t5, 1
	j type_done
check_O:
	bne $t5, 'O', M_type
	li $t5, 2
	j type_done
M_type:	
       	li $t5, 3
type_done:
	# here i must check if the range of columns are reserved or not ???
	beqz $s1, adding_done
	lb $s2, 0($s0)		# load the array call to check if there is an appointment (conflict)
	bnez $s2, check_conflict
	move $t6, $t5	# change the flag value 
	sb $t5, 0($s0)
	j increment_pointer
	
check_conflict:
	# check if the appointment is the same type as the needed to add or not (if they have the same type there is no conflict)
	bne $s2, $t5, conflict		# here the type reserved not the same as wanted so there is a conflict
	j increment_pointer
conflict:
	beq $s2, $t6, dont_print
	la $a0, conflict_msg1
	li $v0, 4
	syscall
	bne $s2, 1, notLecture
	la $a0, lecture
	li $v0, 4
	syscall
	j print_msg2
notLecture:
	bne $s2, 2, notOfficehour
	la $a0, officehour
	li $v0, 4
	syscall
	j print_msg2
notOfficehour:
	la $a0, metting
	li $v0, 4
	syscall
print_msg2:
	la $a0, conflict_msg2
	li $v0, 4
	syscall
	li $v0, 12
	syscall
	bne $v0, 'Y', increment_pointer
dont_print:
	move $t6, $t5	# change the flag value 
	sb $t5, 0($s0)
	
increment_pointer:
	addiu $s0, $s0, 1
	subiu $s1, $s1, 1
	j type_done	
adding_done:
	beqz $t6, menuLoop
	la $a0, adding_done_msg
	li $v0, 4
	syscall	
	j menuLoop

#To display an error message on the screen
indexError:
	#An error msg for a user
	la $a0, incorrect_Index_MSG
	li $v0, 4
	syscall
	j Third_choice
#To display an error message on the screen about the first time
Time1_Check:
	#An error msg for a user
	la $a0, incorrect_time
	li $v0, 4
	syscall
	j FirstTimeError
#To display an error message on the screen about the second time
Time2_Check:
	#An error msg for a user
	la $a0, incorrect_time
	li $v0, 4
	syscall
	j SecondTimeError
Time_error:
	#An error msg for a user
	la $a0, time_error
	li $v0, 4
	syscall
	j FirstTimeError

Wrong_appointment:
	#An error msg for a user
	la $a0, incorrect_appointment
	li $v0, 4
	syscall
	j appointment_read_again



################################################ Fourth Choice ################################################
#Fourth choice of the menu which is delete an appointment
# i add the prefex D to mean Delte for each needed label 
Fourth_choice:	
	##Day index
	#A msg for a user
	la $a0, enterTheDay
	li $v0, 4
	syscall
	#Read The day
	li $v0, 5
	syscall
	move $t0,$v0
	#To check the day index if proper or not
	bgtu $t0, 31, indexErrorD #If index>31 -->incorrect
	bltu $t0, 1, indexErrorD #if index<1 -->incorrect
FirstTimeErrorD:
	##First Time
	#A msg to read the first time slot
	la $a0, View_Calendar3_MSG_FirstTime
	li $v0, 4
	syscall
	#Read the time
	li $v0, 5
	syscall
	move $t1,$v0
	# check if the first time for appointement is entered in the true range
	bgtu $t1, 12, Time1_CheckD
	beq $t1, 6, Time1_CheckD		# there is no time 6 or 7 just from 8-5
	beq $t1, 7, Time1_CheckD
	beqz $t1, Time1_CheckD
	

# prompt the second time slot from user
SecondTimeErrorD:
	#A msg to read the second time slot
	la $a0, View_Calendar3_MSG_SecondTime
	li $v0, 4
	syscall
	#Read the time
	li $v0, 5
	syscall
	move $t2,$v0
	
	# check if the first time for appointement is entered in the true range
	bgtu $t2, 12, Time2_CheckD
	beq $t2, 6, Time2_CheckD
	beq $t2, 7, Time2_CheckD
	beqz $t2, Time2_CheckD
	
	#check if the times is from 1-5 which must convert to 13-17
	bgtu $t1, 5, check_second_timeD
	addiu $t1, $t1, 12
	
check_second_timeD:
	bgtu $t2, 5, appointment_read_againD
	addiu $t2, $t2, 12
appointment_read_againD:
	bgeu $t1, $t2, Time_errorD
	#A msg to read the appointment type
	la $a0, read_appointment
	li $v0, 4
	syscall
	#Read the appointment
	li $v0, 12
	syscall
	move $t5,$v0
	#To check the correctness of the appointment type
	beq $t5, 'L', good_appD
	beq $t5, 'O', good_appD
	beq $t5, 'M', good_appD
	j Wrong_appointmentD
	
good_appD:
	subiu $t0, $t0, 1	# calculate the index of the row (day)
	#Calculate the positions of the first and second times
	subiu $t1, $t1,8 #For the first time
	subiu $t2, $t2,8 #For the second time
	# call index function to calculate the address of row then use the difference between first and second columns to check the cells
	la $a0, calendar_arr	# save the first argument for the function bellow
	move $a1, $t0		# save the second argument for the function
	jal arr_index_first_col
	move $s0, $v0		# save the result returned from function
	addu $s0, $s0, $t1	# make the pointer point to the needed column (the first time indecate our column is array)
	# at this line we have pointer to our needed cell with needed type 
	# first we want to calculate how many slots do you need to reserve 
	# by subtracting the second time from the first we have this information
	subu $s1, $t2, $t1
	# in reg s1 -> the number of cells to be check if they reserved or not to check if there is a conflict
	# change the appointment type to our convention (L -> 1, O -> 2, M -> 3)
	li $t6, 0	# this is flag to print the conflict message (if there is a conflict with more one slot with same type just print one message)
	bne $t5, 'L', check_OD	# convert the type from character to integer as in our array
	li $t5, 1
	j type_doneD
check_OD:
	bne $t5, 'O', M_typeD
	li $t5, 2
	j type_doneD
M_typeD:	
       	li $t5, 3
type_doneD:
	# here i must check if the range of columns are reserved or not ???
	beqz $s1, deleting_done
	lb $s2, 0($s0)		# load the array call to check if there is an appointment (conflict)
	bnez $s2, check_delete
	j increment_pointerD
	
check_delete:
	# check if the appointment is the same type as the needed to delete the slot
	beq $s2, $t5, delete_slot	# here the type reserved not the same as wanted so there is a conflict
	la $a0, delete_type_error
	li $v0, 4
	syscall
	j increment_pointerD
delete_slot:
	move $t6, $t5	# change the flag value 
	sb $zero, 0($s0)	#delete the slot by changing its value to zero

increment_pointerD:
	addiu $s0, $s0, 1
	subiu $s1, $s1, 1
	j type_doneD	
deleting_done:
	beqz $t6, menuLoop
	la $a0, deleting_done_msg
	li $v0, 4
	syscall	
	j menuLoop

#To display an error message on the screen
indexErrorD:
	#An error msg for a user
	la $a0, incorrect_Index_MSG
	li $v0, 4
	syscall
	j Fourth_choice
#To display an error message on the screen about the first time
Time1_CheckD:
	#An error msg for a user
	la $a0, incorrect_time
	li $v0, 4
	syscall
	j FirstTimeErrorD
#To display an error message on the screen about the second time
Time2_CheckD:
	#An error msg for a user
	la $a0, incorrect_time
	li $v0, 4
	syscall
	j SecondTimeErrorD
Time_errorD:
	#An error msg for a user
	la $a0, time_error
	li $v0, 4
	syscall
	j FirstTimeErrorD

Wrong_appointmentD:
	#An error msg for a user
	la $a0, incorrect_appointment
	li $v0, 4
	syscall
	j appointment_read_againD
	
	
################################################ Fifth Choice ################################################
##Save all contents with the updates to the file and exit
Exit: #save_exit
	la $a3, write_file #To get the address of the file buffer
	li $s2, 0 #The Index for the fisrt day
	li $s0,0 #Counter for cells
	li $s1,0 #Counter for zeros
	#Save the symbols to get it when it's needed
	la $t5, symbol
	li $t6, ':' #Two points
	sb $t6, 0($t5) #store the two points
	li $t6, ',' #comma
	sb $t6, 1($t5) #store the comma
	li $t6, ' ' #space
	sb $t6, 2($t5) #store the space
	li $t6, '-' #dash
	sb $t6, 3($t5) #store the dash
	li $t6, 'L' #Lecture symbol
	sb $t6, 4($t5) #store L
	li $t6, 'M' #Meeting symbol
	sb $t6, 5($t5) #store M
	li $t6, 'O' #First part of OH symbol
	sb $t6, 6($t5) #store the O
	li $t6, 'H' #Second part of OH symbol
	sb $t6, 7($t5) #store the H
	
DayAddress: #loop for each day, to get the conent of day cells
	li $s7, 0 #Initiate a flag to mark when the day isn't exist
	li $t3, 0 #Clear the register to use it in the next day
	li $t4, 0 #Clear the register to use it in the next day
	la $t0, calendar_arr #To get the address of the calendar
	sll $t3, $s2, 3
	addu $t3, $t3, $s2
	addu $t4, $t3, $t0	# the address of the day is calculated here
	move $v0, $t4	#Save the result value (the index of row in our matrix)
	move $s3,$v0 #a0=address of the position
	##
LOOP_FOR_A_day: #Loop for each day
	
	beq $s1,9, DAYS_LOOP  #If no data for this day
	##edited
	beq $s0,9, end_line #if the cells for this day are finished
	###
	lb $t1, 0($s3) #load from the first cell
	beqz $t1, Cell_Equal_Zero #If the cell's content equals to zero-->no data on it
	beq $s7, 1, Go_To_Check_cell_content
	li $s7, 1 #Initiate a flag to mark when the day is exist
	###Print the day only one time and iff the day is exist
	#To find the day number and save it
	move $v0, $s2
	# check if the day has one or two digit (1 dont like 11 in print process)
	bgtu $v0, 8, two_digit_day
	
	#if the first time contain one digit just convert it to ascii and save it to buffer
	addiu $v0, $v0, '1'	# add one to chage the day index to its day number is ascii
	sb $v0, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	
	j print_colon

two_digit_day:
	addiu $v0, $v0, 1
	li $s4, 10	
	divu $v0, $s4 #Unsigned divison --> store in LO (qoutient) and HI (Remainder)
	mflo $t7 #(t7=LO)
	mfhi $t8 #(t8=HI)
	addiu $t7, $t7, '0' #Change to ascii
	sb $t7, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	addiu $t8, $t8, '0' #Change to ascii
	sb $t8, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	
print_colon:
	#Symbol ={':',',',' ','-','L','M','O','H'}
	lb $t6,0($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#To save the space
	lb $t6,2($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	
Go_To_Check_cell_content:
	#if integer= 1 -->L, 2-->OH, 3--->M
	beq $t1,1,Lecture_Process
	beq $t1,2,AnOH_Process
	beq $t1,3,Meeting_Process
	#UPDATE
	addiu $s0,$s0,1 #Update the counter of the loop
	addiu $s3, $s3, 1 #Update the address of the source buffer
	j LOOP_FOR_A_day
Cell_Equal_Zero:
	#Only skip this value
	addiu $s0, $s0, 1 # Increment the loop counter
	addiu $s1, $s1, 1 # Increment the Zeros counter
	addiu $s3, $s3, 1 #Update the address of the source buffer
	j LOOP_FOR_A_day
end_line:
	li $v0, '\r'
	sb $v0, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	li $v0, '\n'
	sb $v0, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer	
DAYS_LOOP: #Loop for all days
	
	#Re-initiate the counters for the next day
	li $s0,0 #Counter for cells
	li $s1,0 #Counter for zeros
	addiu $s2, $s2, 1 # Increment the day index
	########################################################################
	bltu $s2, 31, DayAddress
	#beq $s2,3,writee #if the cells for this day are finished
	j writee
#For the save lecture process	
Lecture_Process:
	#Save on $s4 the start of the time slot
	addiu $s4,$s0, 8
	#UPDATE
	addiu $s3, $s3, 1 # Increment the address of the source buffer
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFlectCells_Process
continue_process:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	# check if the time is 1 or 2 digit to print properly
	
	# reg s4 has the first time value
	# reg t9 has the second time value
	#branch if x>9, To check if the number contains two digits or not
	bgtu $s4, 9, twoDigit1L
	
	#if the first time contain one digit just convert it to ascii and save it to buffer
	addiu $s4, $s4, '0'
	sb $s4, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#Save the dash
	lb $t6,3($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	j second_timeL

twoDigit1L:
	li $v0, 10	
	divu $s4, $v0 #Unsigned divison --> store in LO (qoutient) and HI (Remainder)
	mflo $t7 #(t6=LO)
	mfhi $t8 #(=HI)
	addiu $t7, $t7, '0' #Change to ascii
	sb $t7, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	addiu $t8, $t8, '0' #Change to ascii
	sb $t8, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#Save the dash
	lb $t6,3($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	
second_timeL:
	bgtu $t9, 9, twoDigit2L
	#if the first time contain one digit just convert it to ascii and save it to buffer
	addiu $t9, $t9, '0'
	sb $t9, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	j time_doneL

twoDigit2L:
	li $v0, 10	
	divu $t9, $v0 #Unsigned divison --> store in LO (qoutient) and HI (Remainder)
	mflo $t7 #(t6=LO)
	mfhi $t8 #(=HI)
	addiu $t7, $t7, '0' #Change to ascii
	sb $t7, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	addiu $t8, $t8, '0' #Change to ascii
	sb $t8, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer

time_doneL:

	la $t5, symbol #Load the address of symbols to use it
	#Symbol ={':',',',' ','-','L','M','O','H'}
	#To save the first time of the interval which is in $s4
	#To save a space
	lb $t6,2($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#To save the appointement symbol
	lb $t6, 4($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	# check if we want to print comma or not (if thier is no appointment no need for comma)
	jal Comma_Checker_Write
	#To save the comma
	lb $t6,1($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#To save a space
	lb $t6,2($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#jal Comma_Checker #To check if there is any slot after this slot or no to print it
	j LOOP_FOR_A_day
#To find the number of lect Cells
NumberOFlectCells_Process:
	lb $s6,0($s3) #Load the next value
	bne $s6, $t1, continue_process #If not equal the previous value
	addiu $s5,$s5,1
	addiu $s3,$s3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFlectCells_Process
#To save the OH
AnOH_Process:
	#Save on $s4 the start of the time slot
	addiu $s4,$s0, 8
	#UPDATE
	addiu $s3, $s3, 1 # Increment the address of the source buffer
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFohCells_Process
continue_process2:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	# check if the time is 1 or 2 digit to print properly
		
	# reg s4 has the first time value
	# reg t9 has the second time value
	
	#branch if x>9, To check if the number contains two digits or not
	bgtu $s4, 9, twoDigit1OH
	
	#if the first time contain one digit just convert it to ascii and save it to buffer
	addiu $s4, $s4, '0'
	sb $s4, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#Save the dash
	lb $t6,3($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	j second_timeOH

twoDigit1OH:
	li $v0, 10	
	divu $s4, $v0 #Unsigned divison --> store in LO (qoutient) and HI (Remainder)
	mflo $t7 #(t6=LO)
	mfhi $t8 #(=HI)
	addiu $t7, $t7, '0' #Change to ascii
	sb $t7, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	addiu $t8, $t8, '0' #Change to ascii
	sb $t8, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#Save the dash
	lb $t6,3($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	
second_timeOH:
	bgtu $t9, 9, twoDigit2OH
	#if the first time contain one digit just convert it to ascii and save it to buffer
	addiu $t9, $t9, '0'
	sb $t9, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	j time_doneOH

twoDigit2OH:
	li $v0, 10	
	divu $t9, $v0 #Unsigned divison --> store in LO (qoutient) and HI (Remainder)
	mflo $t7 #(t6=LO)
	mfhi $t8 #(=HI)
	addiu $t7, $t7, '0' #Change to ascii
	sb $t7, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	addiu $t8, $t8, '0' #Change to ascii
	sb $t8, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer

time_doneOH:

	la $t5, symbol #Load the address of symbols to use it
	#Symbol ={':',',',' ','-','L','M','O','H'}
	#To save the first time of the interval which is in $s4
	#To save a space
	lb $t6,2($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#To save the appointement symbol
	
	lb $t6, 6($t5) # part 1
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	
	lb $t6, 7($t5) # part 2
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#check comma
	jal Comma_Checker_Write
	#To save the comma
	lb $t6,1($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#To save a space
	lb $t6,2($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#jal Comma_Checker #To check if there is any slot after this slot or no to print it
	j LOOP_FOR_A_day
#To find the number of lect Cells
NumberOFohCells_Process:
	lb $s6,0($s3) #Load the next value
	bne $s6, $t1, continue_process2 #If not equal the previous value
	addiu $s5,$s5,1
	addiu $s3,$s3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFohCells_Process

#To save the meeting slot into a file
Meeting_Process:
	#Save on $s4 the start of the time slot
	addiu $s4,$s0, 8
	#UPDATE
	addiu $s3, $s3, 1 # Increment the address of the source buffer
	addiu $s0,$s0,1 #Update the counter of the loop
	#Counter for the number of cells
	li $s5,0
	###To find the number of the cells
	j NumberOFmCells_Process
continue_process3:	
	#To find the end time of the appointment 
	#== start time+number of cells (after the cell which I located)+1(the cell which I located)
	addu $t9, $s5, $s4
	addiu $t9, $t9, 1
	#To check if the time between [1-5]=[13-17]
	jal FirstTimeToTwelveHoursFormat
	jal SecondTimeToTwelveHoursFormat
	# check if the time is 1 or 2 digit to print properly
	
	# reg s4 has the first time value
	# reg t9 has the second time value
	
	#branch if x>9, To check if the number contains two digits or not
	bgtu $s4, 9, twoDigit1
	
	#if the first time contain one digit just convert it to ascii and save it to buffer
	addiu $s4, $s4, '0'
	sb $s4, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#Save the dash
	lb $t6,3($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	j second_time

twoDigit1:
	li $v0, 10	
	divu $s4, $v0 #Unsigned divison --> store in LO (qoutient) and HI (Remainder)
	mflo $t7 #(t6=LO)
	mfhi $t8 #(=HI)
	addiu $t7, $t7, '0' #Change to ascii
	sb $t7, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	addiu $t8, $t8, '0' #Change to ascii
	sb $t8, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#Save the dash
	lb $t6,3($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	
second_time:
	bgtu $t9, 9, twoDigit2
	#if the first time contain one digit just convert it to ascii and save it to buffer
	addiu $t9, $t9, '0'
	sb $t9, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	j time_done

twoDigit2:
	li $v0, 10	
	divu $t9, $v0 #Unsigned divison --> store in LO (qoutient) and HI (Remainder)
	mflo $t7 #(t6=LO)
	mfhi $t8 #(=HI)
	addiu $t7, $t7, '0' #Change to ascii
	sb $t7, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	addiu $t8, $t8, '0' #Change to ascii
	sb $t8, 0($a3) #store
	addiu $a3, $a3, 1 # Increment the address of the destination buffer

time_done:

	la $t5, symbol #Load the address of symbols to use it
	#Symbol ={':',',',' ','-','L','M','O','H'}
	#To save the first time of the interval which is in $s4
	

	#To save a space
	lb $t6,2($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#To save the appointement symbol
	lb $t6, 5($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#check comma
	jal Comma_Checker_Write
	#To save the comma
	lb $t6,1($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#To save a space
	lb $t6,2($t5)
	sb $t6, 0($a3)
	addiu $a3, $a3, 1 # Increment the address of the destination buffer
	#jal Comma_Checker #To check if there is any slot after this slot or no to print it
	j LOOP_FOR_A_day
#To find the number of lect Cells
NumberOFmCells_Process:
	lb $s6,0($s3) #Load the next value
	bne $s6, $t1, continue_process3 #If not equal the previous value
	addiu $s5,$s5,1
	addiu $s3,$s3,1
	addiu $s0, $s0, 1 # Increment the first choice loop counter
	j NumberOFmCells_Process
	
Comma_Checker_Write:
	move $t0, $s0 #To get the cells counter
	move $a1, $s3 #To get the address
CHECK_Write:
	beq $t0,9,transition_Write #if the cells for this day are finished
	j proceed_Write #ELSE
transition_Write:
	j end_line
proceed_Write:
	lb $t1, ($a1)
	beqz $t1, update_counter_Write #If the cell's content equals to zero-->no data on it
	j checked_Write
update_counter_Write:
	addiu $t0, $t0, 1 #Update the counter
	addiu $a1, $a1, 1 #Update the address
	j CHECK_Write
checked_Write:
	jr $ra # To return to the next instruction
	
	
	
################################################ Save Result To The Same File ################################################	
writee:
	# to write the needed content on same file we open the file first then calculate the buffer size
	# needed to pe printed and then write the buffer content to the file

	# Open file for writing
    	li $v0, 13        # System call for open
    	la $a0, file_name  # Pointer to file name
    	li $a1, 1         # Flag for write
    	syscall
    	move $s0, $v0     # Save file descriptor
    	
    	# Calculate length of buffer (our translated array)
	la $a0, write_file
	li $t0, 0

calculate_length:
    	lb $t1, 0($a0)
    	beqz $t1, end_length_calculation
    	addiu $a0, $a0, 1
    	addiu $t0, $t0, 1
    	j calculate_length

end_length_calculation:
    	
    	# Write to file (replace 'buffer' with new content)
    	li $v0, 15        # System call for write
    	move $a0, $s0     # File descriptor
    	la $a1, write_file    # Pointer to new content buffer
    	move $a2, $t0      # Number of bytes to write
    	syscall
	
	# colse the file after update it
	li $v0, 16
	syscall
	
	la $a0, save_exit
	li $v0, 4
	syscall
	# jump to exit program and stop the execution
	j exit_program