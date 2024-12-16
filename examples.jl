using Tube

## Testsets work

ts = @c @testset "Tube.jl" begin
    println("Not a testset")
end

## Nested testsets work

ts = @c @testset "Tube.jl" begin
    println("not a testset")
    @testset "inner" begin
        @test 1 == 1
    end
end

## String interpolation doesn't work
## LoadError: MethodError: no method matching *(::String, ::Expr)

n = "name"
ts = @c @testset "$n" begin
    println("not a testset")
end

## For loops don't work
## LoadError: Found a for loop

ts = @c @testset "Tube.jl" for _ in 1:10
    println("Not a testset")
end
