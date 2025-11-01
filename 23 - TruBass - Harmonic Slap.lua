local articulation_note = 96
local articulation_velocity = 127

local editor = reaper.MIDIEditor_GetActive()
if not editor then return end
local take = reaper.MIDIEditor_GetTake(editor)
if not take or not reaper.TakeIsMIDI(take) then return end

reaper.Undo_BeginBlock()

local _, noteCount, _, _ = reaper.MIDI_CountEvts(take)

-- Step 1: Collect selected note ranges
local selected_ranges = {}
for i = 0, noteCount - 1 do
    local ret, sel, _, startppqpos, endppqpos, chan, _, _ = reaper.MIDI_GetNote(take, i)
    if sel then
        table.insert(selected_ranges, {
            startppqpos = startppqpos,
            endppqpos = endppqpos,
            chan = chan
        })
    end
end

-- Step 2: Identify overlapping articulation notes (pitch 2)
local notes_to_delete = {}
for i = 0, noteCount - 1 do
    local ret, _, _, ks_start, ks_end, ks_chan, ks_pitch, _ = reaper.MIDI_GetNote(take, i)
    if ks_pitch == articulation_note then
        for _, sel in ipairs(selected_ranges) do
            local sel_start = sel.startppqpos
            local sel_end = sel.endppqpos
            if ks_chan == sel.chan and not (ks_end <= sel_start or ks_start >= sel_end) then
                table.insert(notes_to_delete, i)
                break
            end
        end
    end
end

-- Step 3: Delete collected notes in REVERSE order
table.sort(notes_to_delete, function(a, b) return a > b end)
for _, i in ipairs(notes_to_delete) do
    reaper.MIDI_DeleteNote(take, i)
end

-- Step 4: Insert new articulation notes
for _, sel in ipairs(selected_ranges) do
    reaper.MIDI_InsertNote(
        take,
        false, -- not selected
        false, -- not muted
        sel.startppqpos,
        sel.endppqpos,
        sel.chan,
        articulation_note,
        articulation_velocity,
        false
    )
end

reaper.MIDI_Sort(take)
reaper.Undo_EndBlock("Insert TruBass - Harmonic Slap articulation", -1)

