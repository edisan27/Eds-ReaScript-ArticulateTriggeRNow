local articulation_note = 9
local articulation_velocity = 127

-- PPQ offsets (increase these if you want a bigger gap!)
local start_ppq_offset = 120
local end_ppq_offset = 120

local editor = reaper.MIDIEditor_GetActive()
if not editor then return end
local take = reaper.MIDIEditor_GetTake(editor)
if not take or not reaper.TakeIsMIDI(take) then return end

reaper.Undo_BeginBlock()

local _, noteCount, _, _ = reaper.MIDI_CountEvts(take)

local earliest = math.huge
local latest = -math.huge
local channel = nil

-- Collect selected notes range and channel
for i = 0, noteCount - 1 do
    local ret, sel, _, startppqpos, endppqpos, chan = reaper.MIDI_GetNote(take, i)
    if sel then
        if startppqpos < earliest then earliest = startppqpos end
        if endppqpos > latest then latest = endppqpos end
        if not channel then channel = chan end
    end
end

if earliest == math.huge then return end

local slide_start = earliest + start_ppq_offset
local slide_end = latest - end_ppq_offset

-- Avoid negative or zero length
if slide_end <= slide_start then
    slide_end = earliest + 10
end

-- Delete overlapping existing Slide articulations (only same pitch+channel)
local notes_to_delete = {}
for i = 0, noteCount - 1 do
    local ret, _, _, s, e, chan, pitch = reaper.MIDI_GetNote(take, i)
    if pitch == articulation_note and chan == channel then
        if not (e <= slide_start or s >= slide_end) then
            table.insert(notes_to_delete, i)
        end
    end
end

table.sort(notes_to_delete, function(a,b) return a > b end)
for _, idx in ipairs(notes_to_delete) do
    reaper.MIDI_DeleteNote(take, idx)
end

-- Insert new Slide articulation note
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
reaper.Undo_EndBlock("Insert TruBass - HammerPull Articulation (beat-offset)", -1)
