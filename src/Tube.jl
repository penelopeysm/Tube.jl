module Tube

using MacroTools
using Test: Test

export @c

struct NotTestSetCodeBlock
    code::Expr
end

"""
    TestSetCodeBlock(name::String[, args::Vector{<:AbstractCodeBlock}])

A struct representing a test set, its name, and its contents. If no
contents are given, it is assumed to be a test set with no contents.
"""
struct TestSetCodeBlock
    name::String
    args::Vector{Union{NotTestSetCodeBlock, TestSetCodeBlock}}
end
function TestSetCodeBlock(name::Symbol)
    return TestSetCodeBlock(name, [])
end

function set_name(block::TestSetCodeBlock, name::String)
    return TestSetCodeBlock(name, block.args)
end

"""
    @c

The 'capture' macro. This macro is used to parse the contents of a testset 
into a TestSetCodeBlock.

Generally, if you have something like this:

```julia
@testset "MyPackage.jl" begin
    ...
end
```

you'll want to change this to

```julia
ts = @c @testset "MyPackage.jl" begin
    ...
end
```

In other words, prepend your top-level testset with `@c` and assign it to a
variable.

This macro has many limitations. It's very preliminary. See `examples.jl` in
the repository for some illustrations.
"""
macro c(expr)
    _c("", expr)
end


function _c(context, expr)
    # TODO: This call to @capture assumes that name_ is just a simple string,
    # and that no other arguments are passed to @testset. If any of these are
    # not true, it will fail. In lieu of this, we could use Test.jl internal
    # functionality to parse the arguments, like:
    #     name_expr, _, _ = Test.parse_testset_args(args[1:end-1])
    # In the above, it returns esc("name") instead of "name", which I don't
    # know how to deal with.
    if @capture(expr, @testset name_ contents_)
        context *= ">" * name

        # Recursively parse its contents
        this_testset_contents = []

        if @capture(contents, for var_ in iter_; body_ end)
            # TODO: We don't know how to handle this yet
            error("Found a for loop")
        elseif @capture(contents, begin args__ end)
            for (i, arg) in enumerate(args)
                push!(this_testset_contents, _c(context, arg))
            end
        end

        # Return the parsed structure
        return TestSetCodeBlock(context, this_testset_contents)
    elseif @capture(expr, @testset args__)
        error("Don't know how to parse testset with many args")
    else
        # Not a testset; just return the line itself.
        return NotTestSetCodeBlock(expr)
    end
end


end  # module Tube
