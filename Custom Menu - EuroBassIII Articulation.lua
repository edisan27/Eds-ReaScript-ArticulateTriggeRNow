-- Get the full path of the current script
local script_path = debug.getinfo(1, "S").source:match("^@(.+)$")

-- Remove the .lua extension to get the folder path
local base_path = script_path:match("^(.*[\\/])")

-- Menu options with labels and filenames being the same
local menu_items = {
    { "EuroBassIII - 01 Pick Alt" },
    { "EuroBassIII - 02 Pick Up" },
    { "EuroBassIII - 03 Pick Down" },
    { "EuroBassIII - 04 Dead Note" },
    { "EuroBassIII - 05 Slap" },
    { "EuroBassIII - 06 Dead Slap" },
    { "EuroBassIII - 07 Pop" },
    { "EuroBassIII - 08 Dead Pop" },
    { "EuroBassIII - 09 Harmonic" },
    { "EuroBassIII - 10 HammerPull" },
    { "EuroBassIII - 11 Tapping" },
    { "EuroBassIII - 12 Slide Trigger" },
    { "EuroBassIII - 13 Palm Mute Alt" },
    { "EuroBassIII - 14 Palm Mute Up" },
    { "EuroBassIII - 15 Palm Mute Down" },
    { "EuroBassIII - 16 Force B String" },
    { "EuroBassIII - 17 Force E String" },
    { "EuroBassIII - 18 Force A String" },
    { "EuroBassIII - 19 Force D String" },
    { "EuroBassIII - 20 Force G String" },
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