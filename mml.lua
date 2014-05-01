local mml = {
	_VERSION = "Lua MML",
	_DESCRIPTION = "A Music Macro Language interpreter",
	_URL = "https://github.com/legospacy/lua-mml",
	_LICENSE = [[
		Copyright (c) 2014 Andrew Abbott

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in
		all copies or substantial portions of the Software.

		Except as contained in this notice, the name(s) of the above copyright holders
		shall not be used in advertising or otherwise to promote the sale, use or
		other dealings in this Software without prior written authorization.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
		THE SOFTWARE.
	]]
}

-------------------------------------------------------
mml.outputType = "frequency"

-- If "steps", outputs the number of semitones
-- away from A 440 the note is.

-- If "frequency", outputs the frequency of the note.

-- If "multiplier", outputs frequency/440.

-- Set it in your code to whatever you need!
-------------------------------------------------------

-- Using A as a base note, these are how many
-- semitones/steps away a note on the same octave is.
local steps = {
  a = 0,
  b = 2,
  c = -9,
  d = -7,
  e = -5,
  f = -4,
  g = -2
}

local REF_FREQ = 440 -- A4
local REF_OCTAVE = 4
local ROOT_MULT = 2^(1/12) -- A constant: the twelfth root of two.

-- See http://www.phy.mtu.edu/~suits/NoteFreqCalcs.html
-- for information on calculating note frequencies.

local function calculateNoteFrequency(n)
  return REF_FREQ * (ROOT_MULT ^ n)
end

local function calculateNoteSteps(str)
  local note, sharp, octave = string.match(str, "(%a)(#?)(%d)")
  if sharp == "" then
    sharp = 0
  else
    sharp = 1
  end

  local steps = (octave - REF_OCTAVE)*12 + steps[note] + sharp
  return steps
end

-- Calculates how long a note is in seconds given a note fraction
-- (quarter note = 1/4, half note = 1/2, etc.) and a tempo (in beats per minute).
local function calculateNoteTime(notefrac, bpm)
  return (240/notefrac) / bpm
end

function mml:calculateNote(note, outputType)
  local steps = calculateNoteSteps(note)
  if outputType == "frequency" then
    return calculateNoteFrequency(steps)
  elseif outputType == "steps" then
    return steps
  elseif outputType == "multiplier" then
    return ROOT_MULT ^ steps
  end
end


-- Receives a string of MML and returns a player.

-- When resumed, the player yields with the note (output set by outputType),
-- the time in seconds the note is to be played and the volume it should be played at.
-- It also yields for rests, with nil as the note and for the volume.
-- When the player reaches the end of the song, it will raise an error which
-- will be caught by coroutine.resume.

function mml:newPlayer(str, outputType)
  return coroutine.create(function()
    local octave = 4
    local tempo = 60
    local notelength = 4
    local volume = 10

    for i=1,#str do
      local c = str:sub(i, i):lower()
      -- Set octave
      if c == "o" then
        octave = str:sub(i+1, i+1)
      -- Set tempo
      elseif c == "t" then
        tempo = str:sub(i+1):match("^%d+")
      -- Set volume
      elseif c == "v" then
        volume = str:sub(i+1):match("^%d+")
      -- Rest
      elseif c == "r" then
        local delay
        if str:sub(i+1):find("^%d+") then
          delay = calculateNoteTime( tonumber( str:sub(i+1):match("^%d+") ), tempo )
        else
          delay = calculateNoteTime(notelength, tempo)
        end
        coroutine.yield(nil, delay, nil)
      -- Set note length
      elseif c == "l" then
        notelength = tonumber( str:sub(i+1):match("^%d+") )
      -- Increase octave
      elseif c == ">" then
        octave = octave + 1
      -- Decrease octave
      elseif c == "<" then
        octave = octave - 1
      -- Play note
      elseif c:find("[a-g]") then
        local note
        if str:sub(i+1,i+1) == "#" or str:sub(i+1, i+1) == "+" then
          note = c .. "#" .. octave
        else
          note = c .. octave
        end

        local notetime
        local timeset = 1
        if str:sub(i+1, i+1) == "#" then timeset = 2 end
        if str:sub(i+timeset):find("^%d+") then
          local notefrac = tonumber( str:sub(i+timeset):match("^%d+") )
          notetime = calculateNoteTime(notefrac, tempo)
        else
          notetime = calculateNoteTime(notelength, tempo)
        end
        -- Dotted notes
        if str:sub(i+timeset+1, i+timeset+1)== "." then
          notetime = notetime * 1.5
        end
        local output = self:calculateNote(note, outputType)
        coroutine.yield(output, notetime, volume)
      end
    end
    -- The coroutine deliberately raises an error when it
    -- finishes so coroutine.resume returns false as
    -- its first argument.
    error("Player finished.")
  end)
end

return mml
