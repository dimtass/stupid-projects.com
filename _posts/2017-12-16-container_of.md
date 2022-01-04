---
title: container_of()
date: 2017-12-16T13:43:23+00:00
author: dimtass
layout: post
categories: ["Embedded"]
tags: ["Embedded"]
img_src: "/images"
img_width: 580
img_extras: ".shadow"
---
## Intro

A small post for one of the more beautiful and useful macros in C. I consider the _container_of()_macro to be the equivalent of the _[Euler's identity](https://en.wikipedia.org/wiki/Euler%27s_identity)_for the C language.Like the Euler's identity is considered to be an example of mathematical beauty, the container_of is considered to be an example of C programming beauty. It has everything in there and it's more simple than it looks. So, let's see how it works.

## Explanation

Actually there are many good explanations of how _container_of_ works, some of them are good, some just waste internet space. I'll give my explanation hoping that it won't waste more internet space.

The _container_of_ macro is defined in [several places](https://elixir.free-electrons.com/linux/latest/ident/container_of) in the Linux kernel. This is the macro.

```c
#definecontainer_of(ptr,type,member)({\
    consttypeof(((type*)0)->member)*__mptr=(ptr);\
    (type*)((char*)__mptr-offsetof(type,member));}
```

That's a mess right. So, lets start breaking up things. First of all, there are other two things in there that need explanation. These are the _typeof_ and the _offsetof_.

The _typeof_ is a compiler extension. It's not a function and it's not a macro. All it does is that during compile type evaluates or replaces the type of the variable that the _typeof()_ has. For example, consider this code:

```c
inttmp_int=20
```

Then _typeof(tmp_int)_ is int, therefore everywhere you use the _typeof(tmp_int)_ the compiler will place that with the int keyword. Therefore, if you write this:


```c
typeof(tmp_int)tmp_int2=tmp_int;
```

then, the compiler will replace the _typeof(tmp_int)_ with int, so the above will be the same as writing this:


```c
inttmp_int2=tmp_int;
```

The offsetof is another beautiful macro that you will find in the Linux kernel and it's also defined in several places. This is the macro


```c
#defineoffsetof(TYPE,MEMBER)((size_t)&((TYPE*)0)->MEMBER)
```

The purpose of this function is to retrieve the offset of the address of a member variable of a structure. Let's make that more simple. Let's consider the following image.

![]({{page.img_src}}/offsetof_1.jpg){: width="{{page.img_width}}" {{page.img_extras}}}

This is a struct that has a green and a blue member. We can write this as

```c
struct {
     greena;
     blueb;
}
```

Suppose that the tape measure is the RAM and each cm of the tape is a byte; then if I ask what's the offset of blue member in the RAM then the answer is obvious and it's 120. But what's the offset of the blue member in the structure? In that caseyou need to calculate it by subtract 118 from 120, because 120 is the offset of the blue member in the tape (RAM) and 118 is the offset of the structure in the tape (RAM). So this needs to do a subtraction to calculate the relative offset, which is 2.

Now, lets do this.

![]({{page.img_src}}/offsetof_2.jpg){: width="{{page.img_width}}" {{page.img_extras}}}


What happened now? You see it's the same structure but now I've slide the tape measure so the offset of the struct starts from zero. Now if I ask, what's the offset of the blue member, then the answer is obvious and it's 2.

Now that the struct offset is `normalized`, we don't even care about the size of the green member or the size of the structure because it's easy the absolute offset is the same with relative offset. This is exactly what`&((TYPE *)0)->MEMBER`does. This code dereferences the struct to the zero offset of the memory.

This generally is not a clever thing to do, but in this case this code is not executed or evaluated. It's just a trick like the one I've shown above with the tape measure. The _offsetof()_macro will just return the offset of the member compared to zero. It's just a number and you don't access this memory. Therefore, doing this trick the only thing you need to know is the type of the structure.

Also, note that the 0 dereference doesn't declare a variable.

Ok, so now let's go back to the container_of() macro and have a look in this line

```c
const typeof(((type *)0)->member) * __mptr = (ptr)
```

Here the`((type *)0)->member`doesn't declare or point to variable and it's not an instance. It's a compiler trick to point to the member type offset, as I've explained before. The compiler, by knowing the offset of the member in the structure and the structure type, knows also the type of the member in that index. Therefore, using the example of the tape measure, the _typeof()_ the member on the offset 2 when the struct is dereferenced to 0, is blue.

So the code for the example with the tape measure becomes:

```c
consttypeof(((type*)0)->member)*__mptr=(ptr);
constblue*__mptr=(ptr);
```

and

```c
(type*)((char*)__mptr-offsetof(type,member));
```

becomes
```c
(x *)((char *)__mptr - 2);
```

The above means that the address of the the blue member minus the relative offset of the blue is dereferenced to the struct x. If you subtract the relative offset of the blue member from the address of the blue member, you get the absolute address of the struct x.

So, let's see the container_of() macro again.

```c
#define container_of(ptr, type, member) ({ \
    const typeof(((type *)0)->member) * __mptr = (ptr); \
    (type *)((char *)__mptr - offsetof(type, member)); }
```

Think about the tape measure example and try to evaluate this:

```c
container_of(120, x, blue)
```

This means that we want to get a pointer in the absolute address of struct x when we know that in the position 120 we have a blue member. The _container_of()_ macro will return the offset of the blue member (which is located in 120) minus the relative offset of blue in the x struct. That will evaluate to 120-2=118, so we'll get the offset of the x struct by knowing the offset of the blue member.

## Issues

Well, there are a few issues with the container_of() macro. These issues have to do with the some versions of gcc compilers. For example, let's say that you have this structure:

```c
structperson{
    intage;
    char*name;
};
```

If you try to do this:

```c
structpersonsomebody;
somebody.name=(char*)malloc(25);
if(!somebody.name){
    printf("Mallocfailed!\n");
    return;
}
strcpy(somebody.name,"JohnDoe");
somebody.age=38;
char*person_name=&somebody.name;
structperson*v=container_of(person_name,structperson,name);h
```

Then if you have a GCC compiler with version 5.4.0-6 then you'll get this error:

```sh
error: cannot convert ‘char*’ to ‘char* const*’ in initialization
     const typeof(((type *)0)->member) * __mptr = (ptr);
```

Instead if you do this:

```c
int * p_age = &somebody.age;
struct person * v =container_of(p_age, struct person, age);
```

Then the compiler will build the source code. Also, if you use a later compiler then both examples will be built. Therefore, have that in mind that the type checking thing is mainly a compiler trick and needs the compiler to handle this right.

## Conclusion

_`container_of()`_ and _`offsetof()`_ macros are a beautiful piece of code. They are compact, simple and have everything in there. In 3 lines of beauty. Of course, you can use _container_of()_ without know how it works, but where's the fun then?