using ProToPortal
using Test
using Aqua

@testset "ProToPortal.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ProToPortal; ambiguities = false)
    end
    # Write your tests here.
end
