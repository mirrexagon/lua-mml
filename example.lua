-- An example for the Lua MML module.
-- It relies on the "play" from SoX (http://sox.sourceforge.net/).

-- Load the module.
local mml = require("mml")

-- Sample songs!
local twinkle = "t120 l4 o4  ccggaag2 ffeeddc2 ggffeed2 ggffeed2 ccggaag2 ffeeddc2"
local canon = "t110 l16 o5  a8f#g a8f#g a<ab>c#def#g f#8de f#8<f#gabagaf#ga"

-- A simple busy-wait delay function.
local clock = os.clock
function delay(n)
	local start = clock()
	repeat until (clock() - start) >= n
end

-- Create the player. Since SoX's synth effect uses frequencies, output the frequency of each note.
local player = mml.newPlayer(canon, "frequency")


while true do
  -- Resume the coroutine to get the next note or rest.
	local ok, note, time, vol = coroutine.resume(player)

  -- If it's finished, the coroutine will raise an error,
  -- which is caught by coroutine.resume and makes "ok" false.
	-- The error message goes to "note".
	if not ok then
		print(note)
		break
	end

	if note then
    -- Use SoX's synth effect to sound the note.
		os.execute( string.format(
			"play -qn -V0 synth %.2f pluck %.2f",
			time, note
		))
	else
    -- If "note" is nil, it"s a rest.
		delay(time)
	end
end
