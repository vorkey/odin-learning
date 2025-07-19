package basic

import "core:fmt"

variables :: proc() {

	number: int

	fmt.println(number) // 0

	number = 7

	fmt.println(number) // 7

	another_number: int = 10

	fmt.println(another_number) // 10

	// type inference, the compiler automatically assumes this to be integer
	yet_another_number := 13

	fmt.println(yet_another_number)

	// floating point 32 bit
	float_number: f32

	fmt.println(float_number) // 0

	float_number = 2.9012

	fmt.println(float_number) // should be 2.9012 however it could be 2.89999 or something instead because of limited precision

	// formatted string using printfln, this one cuts decimal to 1
	fmt.printfln("%.1f", float_number)

	// by default compiler infer number with fractional part as f64, or 64 bit floating number
	another_float_number := 7.24

	// this prints the type of another_float_number, which is f64
	fmt.println(typeid_of(type_of(another_float_number)))

	// so for creating f32 we could write explicitly like this
	a_f32: f32 = 4.3
	// or this, which cast the value 4.3 to type f32 which then inferred by compiler?
	// I don't know what is the advantage of doing this to be honest
	another_f32 := f32(4.3)
}
