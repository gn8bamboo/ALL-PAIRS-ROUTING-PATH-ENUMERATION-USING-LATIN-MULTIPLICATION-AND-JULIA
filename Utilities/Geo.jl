import Base:rand

# define a "point" temporarily with "type" instead of "immutable" to avoid a bug
mutable struct Point{T<:Number}
    x::T
    y::T
end
# convenience constructor
Point(x::T, y::S) where {T<:Number, S<:Number} = Point(promote(x,y)...)


# define a "Ellipse" temporarily with "type" instead of "immutable" to avoid a bug
mutable struct Ellipse{T<:Number}
    center::Point{T}
    a::T     # semi-major axis length que
    b::T     # semi-minor axis length
    theta::T # angle of major axis to the x-axis

    function Ellipse{T}(center::Point{T}, a::T, b::T, theta::T) where T<:Number
        if (a <= 0 || b <= 0)
            error("semi-major and semi-minor axis lengths must be positive")
        end
        if a < b
            tmp = a
            a = b
            b = tmp
        end
        if theta < -pi/2
            while theta < -pi/2
                theta += pi
            end
        elseif theta > pi/2
            while theta > pi/2
                theta -= pi
            end
        end
        new{T}(center, a, b, theta)
    end
end
Ellipse(center::Point{T}, a::T, b::T, theta::T)  where {T<:Number} = Ellipse{T}(center, a, b, theta)



# define rand function for point and ellipse
rand(::Type{Point{T}}) where {T<:Float64} = Point{T}(rand(T), rand(T))
rand(::Type{Ellipse{T}}) where {T<:Float64} = Ellipse{T}(rand(Point{T}), rand(T), rand(T), randangle(T))

randangle(::Type{T}) where {T<:Float64} = pi*(rand(T)-1)
for object in (Point, Ellipse)
   @eval begin
       rand(::Type{$(object)}) = rand($(object){Float64})
        # function randomarray{T<:Number}(::$(object), s::Tuple)
        #     return reshape( [random($(object)) for i=1:prod(s)], s )
        # end
   end
end
