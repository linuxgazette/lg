#include<linux/module.h>
#include<linux/init.h>
#include"my_dev.h"

MODULE_AUTHOR("ranjmis");
MODULE_DESCRIPTION("A simple char device");

static int r_init(void);
static void r_cleanup(void);

module_init(r_init);
module_exit(r_cleanup);


static int r_init(void)
{
printk("<1>hi\n");
if(register_chrdev(222,"my_device",&my_fops)){
	printk("<1>failed to register");
}
return 0;
}
static void r_cleanup(void)
{
printk("<1>bye\n");
unregister_chrdev(222,"my_device");
return ;
}

