local f = io.open("/etc/hostname", "r")
local hostname = f and f:read("*l") or ""
if f then f:close() end

return {
    is_work_laptop = (hostname == "magneto"),
}
