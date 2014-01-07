-- An example for the Lua MML module.
-- It relies on beep (found on Linux systems) to make sounds.
-- If you have beep and it doesn't work, try 'sudo modprobe pcspkr'
-- That will try to load the 'pcspkr' kernel module.

-- Load the module.
local mml = require('mml')

-- Sample songs!
local twinkle = 't120 l4 o4  ccggaag2 ffeeddc2 ggffeed2 ggffeed2 ccggaag2 ffeeddc2'
local canon = 't90 l16 o5  a8f#g a8f#g a<ab>c#def#g f#8de f#8<f#gabagaf#ga'

-- A simple busy-wait delay function.
local clock = os.clock
function delay(n)
	local start = clock()
	repeat until (clock() - start) >= n
end

-- Since beep uses frequencies, output the frequency of each note.
mml.outputType = 'frequency'

-- Create the player.
-- Change the song if you want!
local player = mml:newPlayer(canon)

-- And loop!
while true do
  -- Resume the coroutine to get the next note or rest.
	local ok,note,time,vol = coroutine.resume(player)

  -- If it's finished, the coroutine will raise an error,
  -- which is caught by coroutine.resume and makes 'ok' false.
	if not ok then break end

	if note then
    -- Use beep to sound the note!
		os.execute('beep -f ' .. note .. ' -l ' .. time * 1000)
	else
    -- If 'note' is nil, it's a rest.
		delay(time)
	end
end
