package basic

import "core:fmt"

// this procedure has parameter of type ^Cat, read that as "pointer to Cat", the ^Cat type contains a memory address.
// We can go through this pointer to modify the memory that lives there
pointers :: proc(cat: ^Cat) {
	// printing a pointer shows the value at that memory address
	fmt.println(cat) // &Cat{name = "...", age = .}

	// we can use format string %p to print the address of that pointer instead
	fmt.printfln("%p", cat)

	// this will go through pointer cat and modify the age field. honestly I don't really understand why some need pointer and some don't. oh well...
	// even if we don't return, the main procedure in the main.odin file can see the changes as well.
	//  that's why we print the cat after this pointers() procedure call, we should see the changes
	cat.age = 11

	fmt.println(cat) // &Cat{name = "...", age = 11}
}
