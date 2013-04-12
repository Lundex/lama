#Libraries Used:#
 * [LuaSocket](http://w3.impa.br/~diego/software/luasocket/)
 * [LuaLogging](http://www.keplerproject.org/lualogging/)

#Features and Explanations:#
 * The project is split into individual packages, with __"singletons"__ defined in the source directory, and __"classes"__ defined in the __obj/__ directory. The key thing to note is that, when a __"singleton"__ is included, it (a table) is stored in the global context in an entry of the same name as the file (as such, I basically include all of these in _Game.lua_). When a __"class"__ is included, it (a table) is returned by the require() call for use locally.

 * A special table, called Cloneable (stored in __obj/Cloneable.lua__), provides psuedo-inheritance across tables. If you check the reference, a Cloneable has three fundamental functions. Cloneable.clone, Cloneable.new, and Cloneable.initialize.

 * __Cloneable.clone(parent)__ provides an interface to create a new table with its metatable __index set to the given parent, which should generally be a Cloneable. We call this new table a Cloneable, as it is a clone of the parent, which should be a clone of Cloneable. In essence, it inherets the functions and attributes of every clone in the heirarchy all the way up to Cloneable. We call this a "pure" clone, and they generally act like classes in other languages.

 * __Cloneable.new(parent, ...)__ acts like Cloneable.clone(parent) for the most part, but after creating the clone, calls its __Cloneable.initialize(...)__ function. This essentially means this clone has been initialized for use in a practical environment. As such, we call this an "instance-style" clone, and they generally act like object instances in other languages.

 * __Cloneable.initialize(...)__ merely performs operations that every instance of a clone should have. Usually this means assigning unique values, or preparing stock values.

 * The Game singleton uses an event scheduler (__obj/Scheduler.lua__). The Game's scheduler uses timestamps based on __os.clock()__. This can be changed as needed.

 * A Map class is included. In the current implementation, it's just a Cloneable that contains a 3 dimensional grid in the format of layer->column->row or (z->y->x), though most references to locations will take arguments in the order of row,column,layer (or x,y,z). By default, The Game generates a 100x100x1 Map and fills it with generic MapTile instances, mostly just for demonstration purposes.