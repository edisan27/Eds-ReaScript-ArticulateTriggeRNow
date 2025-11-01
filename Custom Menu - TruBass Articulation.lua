-- Get the full path of the current script
local script_path = debug.getinfo(1, "S").source:match("^@(.+)$")

-- Remove the .lua extension to get the folder path
local base_path = script_path:match("^(.*[\\/])")

-- Menu options with labels and filenames being the same
local menu_items = {
    { "01 - TruBass - Finger-Pick Alt" },
    { "02 - TruBass - Finger-Pick Up" },
    { "03 - TruBass - Finger-Pick Down" },
    { "04 - TruBass - Dead Note" },
    { "05 - TruBass - Slap" },
    { "06 - TruBass - Dead Slap" },
    { "07 - TruBass - Pop" },
    { "08 - TruBass - Dead Pop" },
    { "09 - TruBass - Harmonic" },
    { "10 - TruBass - HammerPull" },
    { "11 - TruBass - Tapping" },
    { "12 - TruBass - Slide Trigger" },
    { "13 - TruBass - Thump Up" },
    { "14 - TruBass - Thump Down" },
    { "15 - TruBass - Dead Thump Up" },
    { "16 - TruBass - Dead Thump Down" },
    { "17 - TruBass - Fret Hand Mute" },
    { "18 - TruBass - Palm Mute Alt" },
    { "19 - TruBass - Palm Mute Up" },
    { "20 - TruBass - Palm Mute Down" },
    { "21 - TruBass - Harm Thump Up" },
    { "22 - TruBass - Harm Thump Down" },
    { "23 - TruBass - Harmonic Slap" },
    { "24 - TruBass - Harmonic Pop" },
    { "25 - TruBass - Dead Palm Rest" },
    { "26 - TruBass - Force B String" },
    { "27 - TruBass - Force E String" },
    { "28 - TruBass - Force A String" },
    { "29 - TruBass - Force D String" },
    { "30 - TruBass - Force G String" }
}



-- Build menu string
local menu_str = ""
for i, item in ipairs(menu_items) do
    menu_str = menu_str .. item[1] .. "|"
end

-- Show menu at mouse cursor
local x, y = reaper.GetMousePosition()
gfx.init("Articulation Menu", 0, 0, 0, x, y)
gfx.x, gfx.y = 0, 0
local choice = gfx.showmenu(menu_str)
gfx.quit()

-- Run the chosen script
if choice > 0 then
    local script_name = base_path .. menu_items[choice][1] .. ".lua"
    dofile(script_name)
end