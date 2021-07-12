---
title: How does a C program use the memory?
date: 2021-07-06 11:39:06
tags:
- C
- Memory
marks:
- Basis
---

Usually, we never care how a program is executed on a computer, but in many program languages, we always are noticed that you need carefully allocate and release the memory, if you don't you may get a memory leak, which may cause the computer system kill your progress.

Of course, we don't do this by ourselves now. In modern advanced program languages, they usually provide automatic memory management. You can freely allocate a block of memory and don't care when to release it, the compiler will observe it and release it at the appropriate time. 

But in some high-performance scenarios(game, basic frameworks) or memory limited, we need to control the memory usage manually and do our best to optimize the usage rate. This time understanding the basis of computer memory management is the basis to write fine code. 

Next, let's look at the composition of a computer storage system:

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210706145750.png)

**`Disk`**: Disks usually have a large capacity, we use them to store large files. Disks are also used to persistently store data because they can keep data without electricity, but their data exchange speed is very slow.

**`Memory`**: When running a program, the computer system needs to copy it from the disk to the memory. The data exchange speed of the memory is much fast than the disk.

**`Register`**: Registers are the very small and the high access speed electric elements in CPUs. The capacity of a register is very small, every register can only store 64 bits of data in a 64-bits computer system. A CPU usually has dozens or even hundreds of registers for performing complex tasks.

Registers are very important for a computer to perform tasks, the CPU uses them to perform mathematic calculations, control the number of loops or mark the running status of it. The further information about registers we will talk about it later below.

**`Cache`** : Why does the computer system need to add a cache for the CPU? Although the memory is very fast but not enough compared with the execution speed of the CPU. If using the CPU directly exchanges data with the memory, the memory will depress the performance efficiency seriously, so we need a cache to store the data used frequently to optimize this problem. Of course, we can't cache all data we need, engineers designed a complex algorithm to pick what data we should cache. 

Finally, we should know that the program code cannot be executed by the CPU, we need to translate the code to CPU instructions. We can only use CPU instructions to order the CPU to perform various calculations. Every kind of CPU has their own instruction set, but they don't have a big gap.

## The memory of a computer

The memory we normally say is the computer hardware, my computer has two 8GB memory banks, maybe your computer has 32GB memory banks, but the memory today we say is the virtual memory, what's the virtual memory? why we need it?

When a program is compiled to an executable file, the program code, global variables and strings will be convert to memory addresses, then the CPU can find the data in memory through its address. Once an executable file is created, it cannot be modified, so the memory addresses the program used also are fixed. There is a problem occurred here, **if two programs use the same memory addresses, one program modify its data would influence another one, even occurring crash.**

**Another problem is that a program can easily access all the data of the whole memory, if you are running a rouge program, it might steal your data or crash your system**. Too dangerous!

For system safety and isolating programs, The computer system introduce a middle layer used to map virtual memory addresses and real memory addresses.
![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210708165509.png)
Every address a program used is virtual, two same virtual addresses in different programs will be mapped to different address in real memory. It provides the system the ability to manage the whole memory, this make controlling memory permission be possible, we can set the memory used to save data doesn't have execution permission, the memory used to store code cannot be modified and the the memory occupied by the system cannot be accessed.

### Virtual memory size

The virtual memory size depends on the data bus width and the address bus width. Usually the data bus width is equal to the bits of the CPU. In 64 Bits CPU, once addressing can access 64 bits data, total 8 bytes. The address bus width represent that how many addresses you can access. The product of them two is the accessible virtual memory size of the CPU.

**32 Bits CPU**
CPUs such as Intel 80386 and Intel Pentium 4 have 32 Bits address bus and data bus, theirs addressing space is `2^32`, the data size of once addressing is 4 Bytes, so we can calculate the virtual address space of them is `2^32 * 4` Bytes (2^8 * 2^8 * 2^8 * 4 Bytes = 4GB).

**64 Bits CPU**
Now personal computers usually use 64 Bits system and CPU, the latest softwares are also developed with 64 Bits. Just like above we calculated, A 64 Bits CPU has an 8 Bytes data bus but doesn't have the same wide address bus, because its virtual memory space is too big that the hardware we created recent hardly support this. 
Like Intel CPUs, i3, i5 and i7, they usually have an 40~50 Bits address bus. Both Windows and Linux have a length limit to virtual addresses. In 64 Bits systems, they can only use the low 48 Bits.  Even so, the virtual memory space we calculated is `8 Bytes * 2^48 = 256TB`, we don't need so much memory space in the foreseeable future. 

### Memory alignment
In computer system, the memory use Byte as the store unit. We can theoretically access any byte in the memory, but the CPU use the address bus to access data. In 32 Bits system, once addressing can access 4 Bytes data. In 64 Bits system, once addressing can access 8 Bytes data. A 32 Bits CPU once can process 4 Bytes data, to be more efficient, it would access 4 Bytes once addressing.
Taking the 32 Bits CPU as an example, the actual addressing step is 4 Bytes, that is the CPU would only access the memory address that is a multiple of 4 (eg: 0, 4, 8, 12) and cannot directly access these addresses 1, 3, 11, etc... In this addressing pattern, we don't need to repeatedly address an address and wouldn't ignore any address. 

As a developer, we better define a variable in an addressing step range, so that we can get its value through once addressing. If we store a variable over one addressing step, we need to access the memory twice and splice the values. 

**Try to store a variable in an addressing step range, avoid storing variables over step range, this is the memory alignment.**

```C++
#include <stdio.h>

typedef struct {
    int a;
    char b;
    int c;
} Person;

int main() {    
    Person me = {0, 0, 0};
    printf("%lu\n", sizeof(me));    
    printf("&a: %X\n&b: %X\n&c: %X\n", &me.a, &me.b, &me.c);
    return 0;
}
// Output:
// 12
// &a: EFBFF450
// &b: EFBFF454
// &c: EFBFF458
```
In above example, we define a struct having two int properties and one char property. In 64 Bits system, the int type occupy 4 Bytes memory and the char type needs one Byte, normally the size of the struct Person is `4 + 4 + 1 = 9` Bytes, but actually the executing result is 12. Look up the addresses of the `me.b` and the `me.c` you can find the address of the `me.c` doesn't following the `me.b`, it aligned its address to the next addressing step. The memory alignment sacrifices memory utilization for access efficiency. 

## Memory paging

**We we need the memory paging?**
In the chapters above, we have understood some basic knowledge about virtual memory. But whether you think about the question that if the physical memory is not enough, what the system should do?  The max memory space of a 32 Bits system is 4GB, so every application has a 4Gb virtual memory space. If our computer only has 2GB physical memory and an application needs more than 2GB of memory, how does the system load the application into the memory?

**What's the memory paging?**
An application doesn't use all its memory at the same time, thanks to virtual memory mapping, we can copy partial unused data from the physical memory to the disk. When we copy the memory data to the disk, we don't copy byte by byte and we don't copy in addressing steps. The system will copy a block of memory at a time, we term it as the `memory page`.  

Modern computer systems all use `paging` to map and divide the virtual memory and the physical memory. The concept of paging is dividing the memory into multiple parts, we can only copy the necessary data from disk to memory when running the application. If the physical memory is not enough,  we can copy partial former data to disk for releasing memory space. 

**The paging size**
The paging size depends on the hardware design. Some CPUs might provide several paging size, the computer system can freely select, but the system can only use one paging size at the same time. Almost all PC computer systems select 4KB as their paging size. If our computer is 32 Bits, the virtual memory space is 4GB, one page occupies 4 Bytes, total having 2^32^/2^12^ = 2^20 pages, the physical memory also use the same way to divide. 

![](https://ssbun-lot.oss-cn-beijing.aliyuncs.com/img/20210712163943.png)

In the image above, application A, application B, and the physical memory all have 8 memory pages. Most of the virtual memory of the two applications were mapped to the physical memory, but they use up all physical memory, so like the virtual pages `VP6`(App A) and `VP5`(App B) were copied to the disk pages.

When application A wants to access the data in `VP6`, the system will copy it from disk to physical memory and then map the physical memory to the virtual memory. Maybe you have already noticed that the VP3 of application A and the VP7 of application B used the same physical page. Through mapping multiple virtual pages to the same physical page, we can implement `memory sharing`.

## C program memory distribution map

A program needs to be copied to memory before executing it, but what's the distribution of the program binary data in memory? Where the computer store dynamic data generated while running? 

The memory distribution in different computer systems is not same. Linux is an open-source computer system and it's very popular in server area. The design of the memory distribution of Linux is much clear and tidy than Windows, so we use Linux to learn the memory distribution today. If you're interested with Windows, understanding Linux is helpful to you to learn Windows. 



