#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>

#define REG0_HPS_LED_CONTROL_OFFSET 0x0
/* #define REG1 (Add offset for SYS_CLKs_sec) */
#define REG2_LED_REG_OFFSET 0x08
/* #define REG3 (Add offset for Base_rate) */

int main () {
	FILE *file;
	size_t ret;	
	uint32_t val;

	file = fopen ("/dev/hps_led_patterns" , "rb+" );
	if (file == NULL) {
		printf("failed to open file\n");
		exit(1);
	}

	// Test reading the regsiters sequentially
	printf("\n***************\n* read initial register values\n***************\n\n");

	ret = fread(&val, 4, 1, file);
	printf("HPS_LED_control = 0x%x\n", val);

	// todo: print SYS_CLKs_sec
	// todo: print Base_rate

	ret = fread(&val, 4, 1, file);
	printf("empty register = 0x%x\n", val);

	ret = fread(&val, 4, 1, file);
	printf("LED_reg = 0x%x\n", val);


	// Reset file position to 0
	ret = fseek(file, 0, SEEK_SET);
	printf("fseek ret = %d\n", ret);
	printf("errno =%s\n", strerror(errno));

	// Write to all registers using fseek
	printf("\n***************\n* write all registers with desired setup values \n***************\n\n");

    // Example
	val = 0x55;
    ret = fseek(file, REG3_LED_REG_OFFSET, SEEK_SET);
	ret = fwrite(&val, 4, 1, file);
   // todo: printf() with message writing val to register LED_reg


    
	// todo:  Write desired values to all registers
	
    
	

	printf("\n***************\n* register values after writing\n***************\n\n");
	
	// todo:  Read all the register back again and display the values and names of the associated control registers

    

	fclose(file);
	return 0;
}
