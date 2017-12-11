# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
.include "./cs47_common_macro.asm"
	# Macro : extract_nth_bit
        # Usage : extract_nth_bit(<0x0 or 0x1) at nth position>, <Source bit pattern>, <Position>) 
        .macro extract_nth_bit($regD, $regS, $regT)
        li	$regD, 1
        sllv	$regD, $regD, $regT # Create mask
	and	$regD, $regD, $regS # Extract bit
	srlv	$regD, $regD, $regT # Move the bit to the most right
	.end_macro
	# Macro : insert_to_nth_bit
        # Usage : insert_to_nth_bit(<Bit pattern>, <Position to insert>, <Bit vale to insert>, <Temporary Mask>) 
        .macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
        li	$maskReg, 1 # initalize reg to 1
        sllv	$maskReg, $maskReg, $regS # shift to the inserting position 
        not 	$maskReg, $maskReg # inverse the bit pattern
        and 	$regD, $regD, $maskReg # Make the inserting position to be 0
	sllv	$regT, $regT, $regS # Shift the inserting bit to the inserting position
	or	$regD, $regD, $regT # Insert the bit to that position
	.end_macro
