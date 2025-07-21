package main

import "core:fmt"

main :: proc() {
    day, year: int = 6, 2025 // variabel dengan tipe implicit
    
    // infer kaya di golang
    age, month := 19, "wa"
    month, age = "April", 7

    // constant, ini intinya dua tanda titik dua, yang pi infer, yang string implicit
    pi :: 3.14
    x : string : "huh"
    
    fmt.println("-< !!!Hello Folks!!! >-")
    fmt.printf("Hello from %i %s %i\n", day, month, year)

    // odin only has one loop statement
    fmt.println("START COUNTDOWN!!!!")
    for i := 9; i > 0; i -= 1 {
        fmt.printf("%i\n", i)
    }
    // if only single statement we can write the loop using do
    for i := 0; i < 5; i +=1 do fmt.print("😭")
    fmt.println()

    /*
        initial and post loop statements are optional, so we can write
        while loop like this
    */
    j := 0
    for j < 10 {
        fmt.println("ni hao 😈")
        j += 1
    }
}
