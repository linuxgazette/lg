#include <link.h>
#include <elf.h>
#include <sys/ptrace.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <stdio.h>
#include <errno.h>

/* 
 * search locations of DT_SYMTAB and DT_STRTAB and save them into global
 * variables, also save the nchains from hash table.
 */

unsigned long symtab;
unsigned long strtab;
int nchains;

/* attach to pid */
void ptrace_attach(int pid)
{
	if ((ptrace(PTRACE_ATTACH, pid, NULL, NULL)) < 0) {
		perror("ptrace_attach");
		exit(-1);
	}
	waitpid(pid, NULL, WUNTRACED);
}

/* detach process */
void ptrace_detach(int pid)
{
	if (ptrace(PTRACE_DETACH, pid, NULL, NULL) < 0) {
		perror("ptrace_detach");
		exit(-1);
	}
}

/* read data from location addr */
void read_data(int pid, unsigned long addr, void *vptr, int len)
{
	int i, count;
	long word;
	unsigned long *ptr = (unsigned long *) vptr;
	count = i = 0;
	while (count < len) {
		word = ptrace(PTRACE_PEEKTEXT, pid, addr + count, NULL);
		count += 4;
		ptr[i++] = word;
	}
}

/* read string from pid's memory */
char *read_str(int pid, unsigned long addr, int len)
{
	char *ret = calloc(32, sizeof(char));
	read_data(pid, addr, ret, len);
	return ret;
}

/* write data to location addr */
void write_data(int pid, unsigned long addr, void *vptr, int len)
{
	int i, count;
	long word;
	i = count = 0;
	while (count < len) {
		memcpy(&word, vptr + count, sizeof(word));
		word = ptrace(PTRACE_POKETEXT, pid, addr + count, word);
		count += 4;
	}
}

/* locate link-map in pid's memory */
struct link_map *locate_linkmap(int pid)
{
	Elf32_Ehdr *ehdr = malloc(sizeof(Elf32_Ehdr));
	Elf32_Phdr *phdr = malloc(sizeof(Elf32_Phdr));
	Elf32_Dyn *dyn = malloc(sizeof(Elf32_Dyn));
	Elf32_Word got;
	struct link_map *l = malloc(sizeof(struct link_map));
	unsigned long phdr_addr, dyn_addr, map_addr;

	/* 
	 * first we check from elf header, mapped at 0x08048000, the offset
	 * to the program header table from where we try to locate
	 * PT_DYNAMIC section.
	 */

	read_data(pid, 0x08048000, ehdr, sizeof(Elf32_Ehdr));
	phdr_addr = 0x08048000 + ehdr->e_phoff;
	printf("program header at %p\n",(void *) phdr_addr);
	read_data(pid, phdr_addr, phdr, sizeof(Elf32_Phdr));

	while (phdr->p_type != PT_DYNAMIC) {
		read_data(pid, phdr_addr += sizeof(Elf32_Phdr), phdr,
			  sizeof(Elf32_Phdr));
	}
	
	/* 
	 * now go through dynamic section until we find address of the GOT
	 */

	read_data(pid, phdr->p_vaddr, dyn, sizeof(Elf32_Dyn));
	dyn_addr = phdr->p_vaddr;

	while (dyn->d_tag != DT_PLTGOT) {
		read_data(pid, dyn_addr +=
			  sizeof(Elf32_Dyn), dyn, sizeof(Elf32_Dyn));
	}

	got = (Elf32_Word) dyn->d_un.d_ptr;
	got += 4;	/* second GOT entry, remember? */
	/* 
	 * now just read first link_map item and return it 
	 */
	read_data(pid, (unsigned long) got, &map_addr, 4);
	read_data(pid, map_addr, l, sizeof(struct link_map));
	free(phdr);
	free(ehdr);
	free(dyn);
	return l;
}

/* resolve the tables for symbols*/
void resolv_tables(int pid, struct link_map *map)
{
	Elf32_Dyn *dyn = malloc(sizeof(Elf32_Dyn));
	unsigned long addr;
	addr = (unsigned long) map->l_ld;
	read_data(pid, addr, dyn, sizeof(Elf32_Dyn));
	while (dyn->d_tag) {
		switch (dyn->d_tag) {
		case DT_HASH:
			read_data(pid, dyn->d_un.d_ptr +
				  map->l_addr + 4, &nchains,
				  sizeof(nchains));
			break;
		case DT_STRTAB:
			strtab = dyn->d_un.d_ptr;
			break;
		case DT_SYMTAB:
			symtab = dyn->d_un.d_ptr;
			break;
		default:
			break;
		}
		addr += sizeof(Elf32_Dyn);
		read_data(pid, addr, dyn, sizeof(Elf32_Dyn));
	}
	free(dyn);
}

/* find symbol in DT_SYMTAB */
unsigned long find_sym_in_tables(int pid, struct link_map *map,
				 char *sym_name)
{
	Elf32_Sym *sym = malloc(sizeof(Elf32_Sym));
	char *str;
	int i = 0;
	while (i < nchains) {
		read_data(pid, symtab + (i * sizeof(Elf32_Sym)), sym,
			  sizeof(Elf32_Sym));
		i++;
		if (ELF32_ST_TYPE(sym->st_info) != STT_FUNC)
			continue;

		/* read symbol name from the string table */
		str = read_str(pid, strtab + sym->st_name, 32);
		
		/* compare it with our symbol*/
		if (strcmp(str, sym_name) == 0) {
			printf("\nSuccess: got it\n");
			return (map->l_addr + sym->st_value);
		}
	}
	/* no symbol found, return 0 */
	printf("\nSorry, No such sym %s\n", sym_name);
	return 0;
}

int main(int argc, char *argv[])
{
	int pid;
	unsigned long value;
	struct link_map *lm;
	pid = atoi(argv[1]);
	ptrace_attach(pid);
	lm = locate_linkmap(pid);
	printf("\nVaule of lm is %p\n", lm);
	resolv_tables(pid, lm);
	value = find_sym_in_tables(pid, lm, argv[2]);
	printf("The value of %s is %x\n", argv[2], value);
	ptrace_detach(pid);
	return 0;
}
