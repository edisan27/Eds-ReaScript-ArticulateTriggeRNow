local articulation_note = 11 -- B-1 Slide Trigger
local articulation_velocity = 127

-- Offset in beats (adjust visually)
local beat_offset = 0.25  

local editor = reaper.MIDIEditor_GetActive()
if not editor then return end
local take = reaper.MIDIEditor_GetTake(editor)
if not take or not reaper.TakeIsMIDI(take) then return end

reaper.Undo_BeginBlock()

local _, noteCount, _, _ = reaper.MIDI_CountEvts(take)

local earliest = math.huge
local latest = -math.huge
local channel = nil

-- Find selected notes (range + channel)
for i = 0, noteCount - 1 do
    local ret, sel, _, startppqpos, endppqpos, chan = reaper.MIDI_GetNote(take, i)
    if sel then
        if startppqpos < earliest then earliest = startppqpos end
        if endppqpos > latest then latest = endppqpos end
        if not channel then channel = chan end
    end
end

if earliest == math.huge then return end

-- Beat offset → PPQ
local start_offset_ppq = reaper.MIDI_GetPPQPosFromProjQN(take, beat_offset)
                        - reaper.MIDI_GetPPQPosFromProjQN(take, 0)
local end_offset_ppq = start_offset_ppq

local slide_start = earliest + start_offset_ppq
local slide_end = latest - end_offset_ppq

if slide_end <= slide_start then
    slide_end = earliest + 10
end

-- ✅ Remove only overlapping Slide Trigger keyswitches
local notes_to_delete = {}
for i = 0, noteCount - 1 do
    local ret, _, _, s, e, chan, pitch = reaper.MIDI_GetNote(take, i)
    if pitch == articulation_note and chan == channel then
        if not (e <= slide_start or s >= slide_end) then
            table.insert(notes_to_delete, i)
        end
    end
end
table.sort(notes_to_delete, function(a, b) return a > b end)
for _, i in ipairs(notes_to_delete) do
    reaper.MIDI_DeleteNote(take, i)
end

-- ✅ Insert new slide articulation note
reaper.MIDI_InsertNote(
    take, false, false,
    slide_start,
    slide_end,
    channel,
    articulation_note,
    articulation_velocity,
    false
)

reaper.MIDI_Sort(take)
reaper.Undo_EndBlock("Insert TruBass - Slide Trigger Articulation (beat-offset)", -1)
