-- An example for the Lua MML module.
-- This example uses SoX's "play" utility for synthesising notes (http://sox.sourceforge.net/).

-- Load the module.
local mml = require("mml")

-- Sample songs!
local twinkle = "t120 l4 o4  ccggaag2 ffeeddc2 ggffeed2 ggffeed2 ccggaag2 ffeeddc2"
local canon = "t110 l16 o5  a8f#g a8f#g a<ab>c#def#g f#8de f#8<f#gabagaf#ga"

-- http://mabimml.net/mml.php?id=94
local entertainer = "v14t100l16o5deco4a&abg8v13deco3a&abg8v12deco2a&abag#g8r8v15o5g8v12o4dd#eo5c8o4eo5c8o4eo5c&c4&v14ccdd#ecde&eo4bo5d8c4&c8v12o4dd#eo5c8o4eo5c8o4eo5c&c4&c8o4v13agf#ao5ce&edco4ao5d4&d8v12o4dd#eo5c8o4eo5c8o4eo5c&c4&cv14cdd#ecde&eo4bo5d8c4&c8v15cdecde&ecdcecde&ecdcgefg&gdf8e4o6c8"

-- http://mabimml.net/mml.php?id=98
local banana = "t96l8v15>eeeeeeer16l64rara+b16&bg8e4r2drd+e8e8e8e16&ed+32.e8e8e8r16rara+b16&bb8b4r2r8ara+b8a8g8a+b8&b32.a4r8rgrg+l8agf+l16a&a64g4r4r32.l64g16&gf+rgf+8e8g8e8b16&be8drd+e16&el32.d+e16&e64re16&e64d+e16&e64re16&e64d+e16&e64ge16&e64d+l8eeeeeel64e16&ed+32.e8r16rara+b16&bg8e4>crc+d8d16&de32.derd32<b32.a16&ag32.e8e8e8e16&ed+32.e8e8e8r16rara+b16&bb+rba+16&a+b4r2r8r32.b16&barba8g8bbrb8&baa8.&a32.r8r32.bbb16.&ba+8b8>c16&c<b4&b32.e8g16&gf+rfe16&eg8&g32.r8.r>crc+d16&dd8<a+32.b8g1"

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
    -- If "note" is nil, it's a rest.
		delay(time)
	end
end
