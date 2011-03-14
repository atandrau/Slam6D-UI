require 'pp'

class KDTree
   attr_reader :root
   attr_reader :points

   def initialize(points, dim)
     @dim = dim
     @root = KDNode.new(dim).parse(points)
   end

   def add_node(point)
     @root.add(point)
   end

   def find(*range)
     range.collect!{ |pa|
       pa = Range.new(pa.first, pa.last) if pa.kind_of? Array
     }
     @points = []
     query(range, @root)
     @points
   end

   def query(range, node)
     axis = node.axis
     median = node.location[axis]

     if node.left && (median >= range[axis].begin)
       query(range, node.left)
     end
     if node.right && (median <= range[axis].end)
       query(range, node.right)
     end
     if (0..@dim-1).all?{|ax|
         range[ax].include? node.location[ax]
       }
       @points << node.location
     end
   end

   def print
     @root.print
   end
end

class KDNode
   attr_reader :left, :right
   attr_reader :location

   attr_reader :axis

   def initialize(dim, location=nil, left=nil, right=nil)
     @dim = dim
     @location = location
     @left = left
     @right = right
   end

   def parse(points, depth = 0)
     @axis = depth % @dim

     points = points.sort_by{|point| point[@axis]}
     half = points.length / 2

     @location = points[half]
     @left = KDNode.new(@dim).parse(points[0..half-1], depth+1) unless half < 1
     @right = KDNode.new(@dim).parse(points[half+1..-1], depth+1) unless half+1 >= points.length
     self
   end

   def add(point)
     if @location[@axis] < point[@axis]
       @left ? @left.add(point) : @left = KDNode.new(point)
     else
       @right ? @right.add(point) : @right = KDNode.new(point)
     end
   end

   def remove
     self.parse(@left.to_a + @right.to_a, @axis)
   end

   def to_a
     @left.to_a + [@location] + @right.to_a
   end

   def print(l=0)
     @left.print(l+1) if @left
     puts("  "*l + @location.inspect)
     @right.print(l+1) if @right
   end
end