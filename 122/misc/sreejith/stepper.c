#define MODULE

#include <linux/module.h>
#include <asm/uaccess.h>
#include <sys/io.h>
#include <linux/fs.h>

#define LPT_BASE 0x378
#define DEVICE_NAME "stepper"

static int Major,i,j,k;
static int Device_Open = 0;


//static int pattern[2][8][8] = {   
//        {{0xA,0x9,0x5,0x6},{0xA,0x8,0x9,0x1,0x5,0x4,0x6,0x2}},
//        {{0x6,0x5,0x9,0xA},{0x2,0x6,0x4,0x5,0x1,0x9,0x8,0xA}}
//};

static int pattern[2][8][8] = {
	{{0xA,0x9,0x5,0x6,0xA,0x9,0x5,0x6},{0xA,0x8,0x9,0x1,0x5,0x4,0x6,0x2}},
        {{0x6,0x5,0x9,0xA,0x6,0x5,0x9,0xA},{0x2,0x6,0x4,0x5,0x1,0x9,0x8,0xA}}
};

int step()
{
	if(k<8) {
//        	if(pattern[i][j][k]==0) {
//			k=0; 
//			printk("%d\n",pattern[i][j][k]);
//	                k++;
//		}
//		else {
	                printk("%d\n",pattern[i][j][k]);
			k++;
//		}	
	}
        else  {
		k=0;
		printk("%d\n",pattern[i][j][k]); /*#####*/
                k++; /*#####*/
	}
        return 0;
}

static int stepper_open(struct inode *inode,struct file *filp)
{
	static int counter = 0;
	if(Device_Open) return -EBUSY;
	printk("Opening in WR mode...\n");
	Device_Open++;
	MOD_INC_USE_COUNT;
	return 0;
}
	
static int stepper_release(struct inode *inode,struct file *filp)
{
	printk("Clossing...\n");
	Device_Open --;
	MOD_DEC_USE_COUNT;
	return 0;
}
static int stepper_write(struct file *file, const char *buffer, size_t len, loff_t *offset)
{
	char *data;
        char cmd;
	get_user(data,buffer);
	switch (cmd=data) {
		case 'H': 
			printk("Reffer README file\n");
			break;
		case 'h':
			printk("Half-Step mode initialized\n");
			j=0; 
			break;
		case 'f':
                        printk("Full-Step mode initialized\n");
			j=1;
			break;
		case 'F':
			i=0; 
			step();
			break;
		case 'R':
			i=1;
			step();
       	                break;
//		default:
//			printk("Give 'H' for Help\n");
//			break;
	}
	return 1;
}

static struct file_operations fops={
        open:stepper_open,
	write:stepper_write,
        release:stepper_release,
};

int init_module(void)
{
	Major = register_chrdev(0, DEVICE_NAME, &fops);
	if (Major < 0) {
		printk("<1>Registering the character device failed with %d \n",Major);
		return Major;
	}
	printk("<1>Registered, got Major no= %d\n",Major);
	return 0;
}

void cleanup_module(void)
{
	printk("<1>Unregistered\n");
	unregister_chrdev(Major,DEVICE_NAME);
}	
