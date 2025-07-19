package basic

import "core:fmt"

// collection of variables
Cat :: struct {
	name: string,
	age:  int,
}

structs :: proc() -> Cat {
	cat1: Cat

	// print the whole struct
	fmt.println(cat1) // Cat{name = "", age = 0}

	cat1.name = "Helter"
	cat1.age = 3

	fmt.println(cat1)

	// create and initialize on single line
	cat2 := Cat {
		name = "Loiter",
		age  = 4,
	}

	fmt.println(cat2)

	// reinitialize a struct by assigning
	cat1 = {
		name = "Barbara",
		age  = 1,
	}

	fmt.println(cat1)


	return cat2
}
