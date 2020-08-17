import AbstractPlotting
import GeometryBasics
export visualize

"""
    visualize(pcloud::PointCloud; kwargs...)

Visualize PointCloud `pcloud` at `index`.

Dimension of points in PointCloud `pcloud` must be 3.

### Optional Arguments:
- color (Symbol)       - Color of the marker, default `:blue`
- markersize (Number)  - Size of the marker, default `0.02*npoints(pcloud)/1024`

"""
function visualize(p::PointCloud, index::Number = 1; kwargs...)
    points = p[index]
    size(points, 1) == 3 || error("dimension of points in PointCloud must be 3.")

    kwargs = convert(Dict{Symbol,Any}, kwargs)
    get!(kwargs, :color, :blue)
    get!(kwargs, :markersize, 0.5)

    AbstractPlotting.meshscatter(points[3, :], points[1, :], points[2, :]; kwargs...)
end

"""
    visualize(m::TriMesh, index::Int=1; kwargs...)

Visualize mesh at `index` in TriMesh `m`.

### Optional Arguments:
- color (Symbol)       - Color of the marker, default `:red`

"""
function visualize(m::GeometryBasics.Mesh; kwargs...) where {T,R}
    kwargs = convert(Dict{Symbol,Any}, kwargs)
    get!(kwargs, :color, :red)

    AbstractPlotting.mesh(GeometryBasics.normal_mesh(m); kwargs...)
end

visualize(m::TriMesh, index::Int = 1; kwargs...) = visualize(GBMesh(m, index); kwargs...)

"""
    visualize(v::VoxelGrid, index::Int=1; kwargs...)

Visualize voxel at `index` in VoxelGrid `v`.

### Optional Arguments:
- color (Symbol)       - Color of the marker, default `:red`

"""
function visualize(v::VoxelGrid, index::Int=1, thresh::Number=0.49f0; algo=:Exact, kwargs...)
    algo in [:Exact, :MarchingCubes, :MarchingTetrahedra, :NaiveSurfaceNets] ||
        error("given algo: $(algo) is not supported. Accepted algo are
              {:Exact,:MarchingCubes, :MarchingTetrahedra, :NaiveSurfaceNets}.")
    kwargs = convert(Dict{Symbol,Any}, kwargs)
    get!(kwargs, :color, :violet)
    method = algo==:Exact ? _voxel_exact : _voxel_algo
    v,f = method(cpu(v[index]),Float32(thresh),algo)

    m = GBMesh(v,f)
    AbstractPlotting.mesh(GeometryBasics.normal_mesh(m); kwargs...)
end

visualize(v::Dataset.AbstractDataPoint; kwargs...) = visualize(v.data; kwargs...)

visualize(v::AbstractCustomObject; kwargs...) =
    error("Define visualize function for custom type: $(typeof(v)).
            Use `import Flux3D.visualize` and define function
            `visualize(v::$(typeof(v)); kwargs...)`")
