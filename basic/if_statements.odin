package basic

import "core:fmt"


if_statements :: proc(number: int) {

	if true {
		fmt.println("This is always printed")
	}

	// what is %v again? 
	if number > 10 {
		fmt.printfln("the number %v is bigger than 10", number)
	}

	// we can use ! to invert boolean
	fmt.println(number)

	// inferred as type "bool"
	a_condition := number < 50

	if a_condition {
		fmt.println("number is less than 50")
	}
}
