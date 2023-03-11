local msg = require "mp.msg"
local utils = require "mp.utils"
local options = require "mp.options"

local cut_pos = nil
local copy_audio = true
local o = {
    target_dir = "E:\\Downloads",
    codec = "copy",
    opts = "",
    ext = ".mp4",
    command_template = [[
        ffmpeg -v warning -y -stats
        -ss $shift -i "$in" -t $duration
        -c:v $codec
        -map 0
        $audio
        "$out$ext"
    ]],
}
options.read_options(o)

function timestamp(duration)
    local hours = duration / 3600
    local minutes = duration % 3600 / 60
    local seconds = duration % 60
    return string.format("%02d-%02d-%02.03f", hours, minutes, seconds)
end

function osd(str)
    return mp.osd_message(str, 3)
end

function get_homedir()
  -- It would be better to do platform detection instead of fallback but
  -- it's not that easy in Lua.
  return os.getenv("HOME") or os.getenv("USERPROFILE") or ""
end

function escape(str)
    -- FIXME(Kagami): This escaping is NOT enough, see e.g.
    -- https://stackoverflow.com/a/31413730
    -- Consider using `utils.subprocess` instead.
    return str:gsub("\\", "\\\\"):gsub('"', '\\"')
end

function trim(str)
    return str:gsub("^%s+", ""):gsub("%s+$", "")
end

function get_extension()
    local name = mp.get_property("filename")
    return name:match("^.+(%..+)$")
end

function get_outname(shift, endpos)
    local name = mp.get_property("filename")
    local dotidx = name:reverse():find(".", 1, true)
    if dotidx then name = name:sub(1, -dotidx-1) end
    name = name:gsub(" ", "_")
    name = name:gsub(":", "-")
    name = name .. string.format(".%s-%s", timestamp(shift), timestamp(endpos))
    return name
end

function ternary(cond, T, F)
    if cond then return T else return F end
end

function set_if_exists(opt, para)
    if opt ~= nil and opt ~= "" then
        return para .. opt
    else
        return ""
    end
end

function cut(shift, endpos)
    local cmd = trim(o.command_template:gsub("%s+", " "))

    local inpath = escape(utils.join_path(
        utils.getcwd(),
        mp.get_property("stream-path")))

    local outpath = escape(utils.join_path(
        o.target_dir:gsub("~", get_homedir()),
        get_outname(shift, endpos)))

    local duration = (endpos - shift)

    local extension = get_extension()

    cmd = cmd:gsub("$shift", shift)

    cmd = cmd:gsub("$duration", duration)

    cmd = cmd:gsub("$codec", o.codec)

    cmd = cmd:gsub("$audio", copy_audio and "" or " -an")

    cmd = cmd:gsub("$opts", set_if_exists(o.opts, " "))

    cmd = cmd:gsub("$ext", extension and extension or o.ext)

    cmd = cmd:gsub("$out", outpath)

    cmd = cmd:gsub("$in", inpath, 1)

    osd(string.format(
        "[Raw-Slicing] Fragment: %s to %s (%s seconds)\n\nSaving clip to:\n%s.%s",
        shift, endpos, duration, outpath, o.ext
    ))

    msg.info(cmd)
    os.execute(cmd)
end

function toggle_mark()
    local pos = mp.get_property_number("time-pos")
    if cut_pos then
        local shift, endpos = cut_pos, pos
        if shift > endpos then
            shift, endpos = endpos, shift
        end
        if shift == endpos then
            osd("[Raw-Slicing] Cut fragment is empty")
        else
            cut_pos = nil
            osd(string.format("[Raw-Slicing] Cut fragment: %s - %s",
                timestamp(shift),
                timestamp(endpos)))
            cut(shift, endpos)
        end
    else
        cut_pos = pos
        osd(string.format("[Raw-Slicing] Marked %s as start position", timestamp(pos)))
    end
end

function toggle_audio()
    copy_audio = not copy_audio
    osd("[Raw-Slicing] Audio capturing is " .. (copy_audio and "enabled" or "disabled"))
end

mp.add_key_binding("p", "slicing_mark", toggle_mark)
mp.add_key_binding("å", "slicing_audio", toggle_audio)