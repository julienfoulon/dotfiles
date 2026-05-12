local f = io.open("/etc/hostname", "r")
local hostname = f and f:read("*l") or ""
if f then f:close() end

return {
    is_work_laptop = (hostname == "magneto"),
    work_left  = "desc:Dell Inc. DELL P2217H 0G2TG68C266T",
    work_right = "desc:Dell Inc. DELL UZ2315H 0J4PM66NA36S",
}
