package basic

import "core:fmt"

// file naming doesn't matter, as long as package is the same inside the same folder, the files will be compiled
// as one executable

// this procedure has parameter n, when this is called from main.odin, it supplied 21 as argument
// this also returns something with type int, denoted as "-> int" after parameter
loops :: proc(n: int) -> int {

	fmt.println(n) // prints the given argument, which is 21

	// loops, there is only one keyword for loop in odin which is "for"
	// this one run 5 times from 0 to 4
	for i in 0 ..< 5 {
		fmt.println(i) // 0, 1, 2, 3, 4
	}

	// same loop as above
	for i := 0; i < 5; i += 1 {
		fmt.println(i) // 0, 1, 2, 3, 4
	}

	// this one enclosed in curly brackets, so that the "i" here not exist outside this brackets
	// handy so that we don't make conflict with code outside this
	{
		// same loop as above, just moved the i outside
		i := 0
		for i < 5 {
			fmt.println(i) // 0, 1, 2, 3, 4
			i += 1
		}
	}


	result: int

	// using n from the procedure parameter
	for i in 0 ..< n {
		fmt.println(i) // 0, 1, ..., 19, 20
		result += i
	}

	// this return the sum of all number before n
	return result
}
