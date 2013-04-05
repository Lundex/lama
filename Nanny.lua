--[[	Author:	Milkmanjack
		Date:	4/4/13
		Package that handles processing of new clients.
]]

local Nanny			= {}

--[[
	Processes input from a client.
	@param client	The client to process.
	@param input	The input to process.
]]
function Nanny.process(client, input)
	Nanny.messageNameIsInvalid(client)
	client:sendLine("")
	Nanny.askForName(client)
end

--[[
	Ask the client for a name.
	@param client	The client to ask.
]]
function Nanny.askForName(client)
	client:sendString("What is your name? ")
end

--[[
	Tell them their name input was invalid.
	@param client	The client to message.
]]
function Nanny.messageNameIsInvalid(client)
	client:sendLine("It was a rhetorical question!")
end

--[[
	Greet the client.
	@param client	The client to message.
]]
function Nanny.greet(client)
	client:sendLine(Nanny.getGreeting())
end

--[[
	Get the greeting message.
	@return The message.
]]
function Nanny.getGreeting()
	return "      __            /^\\\
    .'  \\          / :.\\\
   /     \\         | :: \\\
  /   /.  \\       / ::: |\
 |    |::. \\     / :::'/\
 |   / \\::. |   / :::'/\
 `--`   \\'  `~~~ ':'/`\
         /         (\
        /   0 _ 0   \\\
      \\/     \\_/     \\/ Welcome to\
    -== '.'   |   '.' ==-     lama v0.0a!\
      /\\    '-^-'    /\\\
        \\   _   _   /\
       .-`-((\\o/))-`-.\
  _   /     //^\\\\     \\   _\
."o".(    , .:::. ,    )."o".\
|o  o\\\\    \\:::::/    //o  o|\
 \\    \\\\   |:::::|   //    /\
  \\    \\\\__/:::::\\__//    /\
   \\ .:.\\  `':::'`  /.:. /\
    \\':: |_       _| ::'/\
 jgs `---` `"""""` `---`"
end

return Nanny
