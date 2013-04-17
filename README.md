#Features and Explanations:#
 * The project is split into individual packages, with *singletons* defined in the source directory, and *classes* defined in the **obj/** directory.

 * When a *singleton* is loaded with **require()** or **dofile()**, it is stored in the global context in an entry of the same name as the file. For example, the *Game singleton*, found in **Game.lua**, is stored in *_G.Game*. (I **require()** all singletons in **Game.lua** to ensure access to this information for all processes.)

 * When a *class* is included, is returned by the **require()** call for use locally.

 * A special table, called *Cloneable* (stored in **obj/Cloneable.lua**), provides psuedo-inheritance across tables. If you check the documentation, a *Cloneable* has three fundamental functions. **Cloneable.clone()**, **Cloneable.new()**, and **Cloneable.initialize()**.

 * **Cloneable.clone(parent)** provides an interface to create a new table with its metatable index set to the given parent, which should generally be a *Cloneable*. We call this new table a *Cloneable*, as it is a clone of the parent, which should be a clone of *Cloneable*. In essence, it inherets the functions and attributes of every clone in the heirarchy all the way up to *Cloneable*. We call this a "pure" clone, and they generally act like classes in other languages.

 * **Cloneable.new(parent, ...)** acts like **Cloneable.clone(parent)** for the most part, but after creating the clone, calls its **Cloneable.initialize(...)** function. This essentially means this clone has been initialized for use in a practical environment. As such, we call this an "instance-style" clone, and they generally act like object instances in other languages.

 * **Cloneable.initialize(...)** merely performs operations that every instance of a clone should have performed. Usually this means assigning unique values, or preparing stock values.

 * The *Game singleton* uses an event scheduler (**obj/Scheduler.lua**). The *Game*'s scheduler uses timestamps based on **os.clock()**. This can be changed as needed.

 * A *Map* class is included. In the current implementation, it's just a *Cloneable* that contains a 3 dimensional grid in the format of layer->column->row (or z->y->x), though most references to locations will take arguments in the order of row,column,layer (or x,y,z). By default, The Game generates a 100x100x1 Map and fills it with generic MapTile instances, mostly just for demonstration purposes.

---

#Using lama:#
 1. Install Lua (only tested on 5.2).
 2. Install libraries listed below in your Lua implementation.
 3. Run main.lua.
    * Run '`lua main.lua [optional port to host server on]`'
 4. ???
 5. Profit.

---

#Dependencies:#
 * [LuaSocket](http://w3.impa.br/~diego/software/luasocket/)
 * [LuaLogging](http://www.keplerproject.org/lualogging/)