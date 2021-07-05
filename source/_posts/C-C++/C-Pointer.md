---
title: C Pointer
date: 2021-07-05 14:13:08
tags:
marks:
- BASIS
---

Although I haven't usually used the pointers in recent years, but sometimes I would be lost in C pointers when meeting some complex C pinter code. 
Whenever I don't understand, I need to search and learn the C pointers again. This time I want to make a conclusion for C pointers, list most common C pointer usages and some mistakes we usually make.

## Special Pointers `NULL` and `void *`

In C language, we have two special pointers `NULL` and `void *`, the `NULL` is meaning the pointer has not initialized, when you access a `NULL` pinter, there will be nothing to happen. Notice that the NULL must be capital, the null is a normal identifier in C. 

In many standard libraries, they will check input pinter params, if theirs values are NULL the function will prompt warnings or just return. So I suggest that we should also check input pinter params. this can make our functions more robust.

When should we use the NULL pointer? The most common condition is when you declare a pinter now and want to assign a value to it later. If you just declare a pointer like below, you would get an error when writing it or get a strange value when reading it. 

```C++
int main() {
    char *str;
    /* The pinter str hasn't been initialized, its address might be any value. 
    If the address is unaccessible, you will get a crash. */
    gets(str);  
    printf("%s", str);
    return 0;
}
```
If you assign a NULL to the pointer `str` when declaring it, the `printf` will directly output `(null)` and return the function. 

```C++
int main(){
    char *str = NULL;
    gets(str);
    printf("%s", str);
    return 0;
}
```

In fact, the `NULL` is a macro defined in `stdio.h`, its detailed define is `#define NULL ((void *)0)`. The `NULL` is point to a void point whose address is `0`. The low part of the memory addresses generally are reserve area, so the system can easily confirm whether the address is available.

The `void` is another special key word. A `void *` pinter a valid pointer, but you don't know its pinter type. The dynamic memory allocating function of C will return a `void pointer`, we need manually transform its type when using the pointer. 

```C++
int main(){
    // Allocate 10 bytes memory space and convert the return pointer to char * 
    char *str = (char *)malloc(sizeof(char) * 10);
    gets(str);
    printf("%s\n", str);
    return 0;
}
```

## Normal pinter & Array pointer

We all have learned the name of an array is the pointer that point to the begin address of the array, we may think the pointer and the array are the same, but this is wrong. **Arrays have their own types**

```C++
#include <stdio.h>
int main(){
    int a[6] = {0, 1, 2, 3, 4, 5};
    int *p = a;
    int len_a = sizeof(a) / sizeof(int);
    int len_p = sizeof(p) / sizeof(int);
    printf("len_a = %d, len_p = %d\n", len_a, len_p);
    return 0;
}

// Output:
// len_a = 6, len_p = 1
```

An array contains a set of values, but it doesn't have any end flag. When we set the `a` to the `p`, the `p` is just an `int pointer`, its address point to the first item of the array. We use `sizeof` to get the size of the point `p` can only get the memory size of an int pointer. Wherever it point to, you can't calculate the length of an array. 

If the type of point p is `int *`, then the type of point a is `int [6]`. The `int [6]` is a array type, its means there are six integer values in a variable, so when we use sizeof to get the size of the pointer a, we get the result is the total size of six integers. 

In some cases, An array type would be automatically converted to a normal pointer. For example **we read values through array subscript** or **pass an array to a function**. 

```C++
int main() {
    int a[6] = {0, 1, 2, 3, 4, 5};
    
    printf("result = %d", a[1]);
    return 0;
}

// Output: 
// result = 0
```

The `a` in `a[1]` is a normal integer pointer. The compiler will convert the subscript to the expression `*(a + 1)`, you can consider the `[]` is an operator, its expression is `x[y] = *(x + y)`, so you can rewrite the expression `a[1]` to `1[a]`, they have the same effect but the latter may be unreadable.

The other situation is you pass an array to a function.

```C++
#include <stdio.h>

void func1(int *arr) {
    printf("%lu", sizeof(arr));
}
void func2(int arr[]) {
    printf("%lu", sizeof(arr));
}
void func3(int arr[6]) {
    printf("%lu", sizeof(arr));
}

int main() {
    int a[6] = {0, 1, 2, 3, 4, 5};
    func1(a);
    func2(a);
    func3(a);
    return 0;
}

// Output(In 64 bits system): 
// 888
```

Whatever type you define the param as, you cannot get the length of the array, the compiler always pass a pointer not copy the whole array to a function. An array can have a large mount of items, if we copy its value when passing it to a function will waste a lot of memory. If you want to get the length of an array, you should pass the length through another param. 

```C++
#include <stdio.h>

void func4(int arr[], int ln) {
    for (int i = 0; i < ln; i++) {
        printf("%d\n", arr[i]);
    }
}

int main() {
    int a[6] = {0, 1, 2, 3, 4, 5};
    func4(a, sizeof(a) / sizeof(int));
    return 0;
}
```

## Understand a complex pointer

Before analysing a complex pointer, we review some common pointer types. 

- `int *p`: The p is a int ==pointer==
- `int **p`: The p is a pointer ==pointer==, the p point to another pointer.
- `int p[n]`: The p is an ==array==, you can make it as a int pointer in calculation.
- `int *p[n]`: The p is an ==array==, The type of its items is int pointer. 
- `int (*p)[n]`: The p is a ==pointer==, it point to an int array. 
- `int (*p)()`: The p is a ==pointer==, it point to a function.

We also should know the precedence of the operators in pointer expression.

- `()`: highest precedence
- `suffix [] and ()`: medium precedence (array and function)
- `prefix *`: lowest precedence

In the pointer `int *p[n]`, the precedence of `[]` if higher than the `*`, you can rewrite the expression to `int *(p[n])`, so we know the p is an array.

### Practice

- `char *(* c[10])(int **p)`
    1. Find the variable `char *(* `==c==`[10])(int **p)`, we know the c is an pointer array. its items are pointers.
    2. The suffix `(int **p)` means it's a function, the function needs a pointer param pointing to an int array and return a char pointer. 
    3. Finally, we can get the c is a pointer array, its items are function pointers, the type of the function is `char *f(int **p)`.

- `int (*(*(*p)(int *))[5])(int *)`
This expression is more complex, but it isn't difficult for you if you remember the rules above.
    1. Find the variable `int (*(*(*`==p==`)(int *))[5])(int *)`, we know the p is a pointer.
    2. The suffix `int (*(`==*==`(*p)`==(int *)==`)[5])(int *)` means the p is a function pinter. It needs an int pointer param and return a pointer.
    3. What does the result pinter point to? `int (`==*==`(*(*p)(int *))`==[5]==`)(int *)` It point to an pinter array, the length of the array is 5.
    4. The type of the items in the pointer array is the function pointer, the function needs an int pointer param and return an int value.

## Conclusion

The pointer is the most important concept in C, it's very flexible but always make questions more complex. In fact, the basis of many languages is using the pointers, understanding pointers will help us to further understand some data structures and algorithms. 