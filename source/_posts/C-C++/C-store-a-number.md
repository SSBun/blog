---
title: How to store an integer in the Memory?
date: 2021-06-21 15:51:05
tags:
- C
- Memory
marks:
- BASIS
---

Before learning how to store an integer in memory, first we review some information about the integer in memory. In current modern computer system, the integer usually have three kinds of length, `int`, `short int` and `long int`.  In 64 bits system, the `int` generally occupies 4 bytes memory space, the `short int` needs 2 bytes, the `long int` needs 8 bytes in Linux/Mac or 4 bytes in Windows. If the integer is having sign, the highest bit of the integer binary is the sign bit. Sign bit is one means the integer is negative, zero means positive.

## How to store an Integer in Memory?
The simplest way to storing a integer is just to saving the binary of the integer, but in modern computer systems, they save the integers without this way. The reason is about the subtraction of integers. From our point of view, the subtraction is similar to the addition, if you know how to calculate a addition, you must know how to calculate a subtraction. But in computer systems, in hardwares, the addition and the subtraction are two distinct operations, so the engineers need to design two different circuits to implement them, this is too complex. 

The simplest is the best. The smart scientists begin to think how to merge the subtraction and the addition to one operation. Finally, they implement a new storing format for integers, there are three concepts we should know:

- **Original code**
- **Reverse code**
- **Complement code**

### Original code
Convert an integer to binary format, this is the original code. eg: 
- `short a = 6`, the `original code` of `a` is `0000 0000 0000 0110`; 
- `short b = -18` the `original code` of `b` is `1000 0000 0001 0010` (the highest bit of the b is one means the b is negative)

### Reverse code
The reverse code has some differences with negative and positive. For positive, the reverse code is equal to it's original code. For negative, the reverse code is to reverse all bits of the original code except the sign bit (convert 1 to 0, 0 to 1). 
- `short a = 6`
    - **original code:**`0000 0000 0000 0110`
    - **reverse code:** `0000 0000 0000 0110`
- `short b = -18`
    - **original code:**`1000 0000 0001 0010`
    - **reverse code:** `1111 1111 1110 1101`

### Complement code
For positive, the complement code is equal to the reverse code and original code. For negative, the complete code has a small modification to the reverse code is adding one to the reverse code.
- `short a = 6`
    - **original code:**- - - `0000 0000 0000 0110`
    - **reverse code:**- - - -`0000 0000 0000 0110`
    - **complement code:**- - `0000 0000 0000 0110`
- `short b = -18`
    - **original code:**- - - `1000 0000 0001 0010`
    - **reverse code:**- - - -`1111 1111 1110 1101` *reverse all bits except sign bit*
    - **complement code:**- - `1111 1111 1110 1110` *reverse code plus 1*

**At present, the computer systems store integers with the `complement code` format, when reading the integers, we need to reversely convert the `complement code` to the `reverse code` and then to the `original code`**

## How does the complement code help computers to execute the subtraction?

***We are ready to execute the expression `6 - 18`, the `6 - 18` is equal to the `6 + (-18)`.***

### If we add the original codes of the `6` and `-18` directly, can we get a correct answer?
- = `6 + (-18)`
- = `0000 0000 0000 0110`<sub>original</sub> + `1000 0000 0001 0010`<sub>original</sub>
- = `1000 0000 0001 1000`<sub>original</sub>
- = `-24`

> If we make the sign bit join the calculation, can only get an error answer.


### If we add the reverse codes of the `6` and `-18`, what's will happen?
- = `6 + (-18)`
- = `0000 0000 0000 0110`<sub>reverse</sub> + `1111 1111 1110 1101`<sub>reverse</sub>
- = `1111 1111 1111 0011`<sub>reverse</sub>
- = `1000 0000 0000 1100`<sub>original</sub>
- = `-12`

The answer `-12` is correct, can we calculate the correct answer just depends on reverse codes? Let's see another example: `18 - 6`:
- = `18 + (-6)`
- = `0000 0000 0001 0010`<sub>reverse</sub> + `1111 1111 1111 1001`<sub>reverse</sub>
- = `1 0000 0000 0000 1011`<sub>reverse</sub>
- = `0000 0000 0000 1011`<sub>reverse</sub>
- = `0000 0000 0000 1011`<sub>original</sub>
- = `11`

The correct answer is `12`, but the calculation result is `11`, it's one less than the correct answer. The result of **a small number minus a large number** is right, is the result one less than the correct answer in every situation of a large number minus a small number?
You can inspect it by yourself, my answer is YES. So we need to figure out a way to add one to the result when calculating a large number minus a small one. Now, it's time to introduce the `complement code`, a genius-lik idea.

### The genius-like idea complement code
The complement code is the reverse code plus one. If we calculate a small number minus a large number, we will plus one when converting the reverse code to the complement code, we know the answer is negative, so we need to reversely convert the complement code to the reverse code, the result will minus one at this time, finally, the answer won't have any changes.  
If we calculate a large number minus a small number, we know the result is one less than the correct answer when calculating them with the reverse codes. If we use the complement code, because the complement code is reverse code plus one and the answer is positive that we don't need to revert it again. Finally the result is equal to the correct answer.

> The complement code is a genius-like design that greatly reducing the complexity of the circuit

## The value range of integers
The `short`, `int` and `long` are the common integer types in C. They can only store a limited length integer, if the integer is too long, the over part would be cut, the final value saved would be error, we say this situation as `overflow`. 

### The value range of unsigned integers

For easily to calculate, we make an example with `short int`. The `short int` occupy a bytes, eight bits, to store an integer, setting all bits to 1 is the max value, setting all bits to 0 is the min value. The max value `1111 1111` is equal to `2^8 - 1 = 255`, we use a small trick to fleetly calculate the max value, the value of `1111 1111` is not easy to get, we can add 1 to it to get the result `1 0000 0000` and then minus 1. 

|                | bytes   | min value | max value                                |
|----------------|---------|:----------|------------------------------------------|
| unsigned char  | 1 byte  | `0`       | `2^8 - 1 = 255`                          |
| unsigned short | 2 bytes | `0`       | `2^16 - 1 = 65,535 ≈ 65 thousand`        |
| unsigned int   | 4 bytes | `0`       | `2^32 - 1 = 4,294,967,295 ≈ 4.2 billion` |
| unsigned long  | 8 bytes | `0`       | `2^64 - 1 ≈ 1.84*10^19`                  |

### The value range of signed integers

| complement code | reverse code | original code | value  |
|-----------------|--------------|---------------|--------|
| 1111 1111       | 1111 1110    | 1000 0001     | -1     |
| 1111 1110       | 1111 1101    | 1000 0010     | -2     |
| 1111 1101       | 1111 1100    | 1000 0011     | -3     |
| ...             | ...          | ...           | ...    |
| 1000 0011       | 1000 0010    | 1111 1101     | -125   |
| 1000 0010       | 1000 0001    | 1111 1110     | -126   |
| 1000 0001       | 1000 0000    | 1111 1111     | -127   |
| `1000 0000`     | --           | --            | `-128` |
| 0111 1111       | 0111 1111    | 0111 1111     | 127    |
| 0111 1110       | 0111 1110    | 0111 1110     | 126    |
| 0111 1101       | 0111 1101    | 0111 1101     | 125    |
| ...             | ...          | ...           | ...    |
| 0000 0010       | 0000 0010    | 0000 0010     | 2      |
| 0000 0001       | 0000 0001    | 0000 0001     | 1      |
| 0000 0000       | 0000 0000    | 0000 0000     | 0      |

Also use the `short int` as the example, the singed integer is stored with the complement code format in the memory. The complement codes are from `0000 0000` to `1111 1111`, in the period from `0000 0000` to `0111 1111` the values are positive **(0 to 127)**, in the period from `1000 0001` to `1111 1111` the values are negative **(-127 to -1)**.

 You might find that there is no the code `1000 0000`, this because the hightest bit of the complement code is 1, so it's a negative value and we should minus one from it to transform it to the reverse code. But all bits of it are zero, so it have to borrow an one to the hightest bit. The hightest bit is signed bit that can not be changed. Now we know the complement code `1000 0000` can not be convert to a integer, how do we deal with this value? Discarding the value is too wasteful, people specific the value as the number `-128 `. 

### Value overflow

The integer types `char`, `short`, `int` and `long` have limited length, the over bits would be discarded when you assign a very large value. When occurring overflow, as some hightest bits are ignored, the result will be very strange.

Let's see an example:

```c++
#include <stdio.h>
int main()
{
    unsigned int a = 0x100000000;
    int b = 0xffffffff;
    printf("a=%u, b=%d\n", a, b);
    return 0;
}
```

The variable `a` is an `unsigned int`, so its length is 4 bytes, the max value of it is `0xFFFFFFFF`. The assigned value `0x100000000` is equal to `0xFFFFFFFF + 1` and over the value range of the `unsigned int`, so the hightest bit will be cut, all the remaining bits are 0. So that the value of the variable `a` is 0 in the memory.

The variable `b` is a `signed int`, its value is saved in the memory with complement format. The count of its value bit is 31, but the assigned value is `0xFFFFFFFF` that has 32 bits, so the highest bit will be overwritten to 1, then we get the complement value of the `b` is `0xFFFFFFFF`. Converting to original code, we can get the value is `-1`.