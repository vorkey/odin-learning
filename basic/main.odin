package basic

import "core:fmt"

// this is the procedure which will be called first when executing program
main :: proc() {
	fmt.println("Hello Odin!!!")

	// procedure from another file
	variables()

	loops_result := loops(21) // 210

	if_statements(loops_result)

	cat := structs()

	fmt.println(cat)

	pointers(&cat)

	fmt.println(cat)
}
