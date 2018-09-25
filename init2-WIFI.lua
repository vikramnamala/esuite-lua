local APlist = {
   {"theRiver", "jaxplase"},
   {"bluerat", "XX78%sg6"}
}
-- or simply APlist = { "ap", "pw" }

-- wifi.sta.disconnect()   -- uncommect to FORCE connection attempts from the APlist

if #APlist == 2 and APlist[1][1] == nil then APlist = {APlist} end  -- if simple mode, reformat correctly

local stationap_cfg={}

-- Create HOTSPOT
local function connecting()
    -- local apnum = 1  -- start with first AP listed
    print("Initialising AP")
    if wifi.ap.getip()==nil then
        stationap_cfg.ssid="TelnetConfig1"
        stationap_cfg.pwd="12345678"
        stationap_cfg.auth=wifi.WPA_PSK
        -- wifi.sta.config(stationap_cfg)
        wifi.ap.config(stationap_cfg)
        wifi.setmode(wifi.SOFTAP)
    end
    print("Creating an AP " .. stationap_cfg.ssid  .. " ...")
    tmr.alarm(0, 5000, 1, function()
        if wifi.ap.getip()~=nil then
          tmr.stop(1)
          tmr.stop(0)
          print("AP Created: " .. wifi.ap.getip())
          if not Time then node.task.post( function() stationap_cfg=nil dofile("init3-TIME.lua")  end) end
        end
    end)

  tmr.alarm(1, 30000, 1, function()  -- if not connecting after 30 secs, cycle to next AP in list
      if #APlist > 1 then
          apnum = apnum+1
          if apnum > #APlist then apnum = 1 end
          if wifi.ap.getip()==nil then
              stationap_cfg.ssid="TelnetConfig1"
              stationap_cfg.pwd="12345678"
              wifi.ap.config(stationap_cfg)
              print("Trying AP " .. stationap_cfg.ssid .. " ...")
          end
      else
          print("Still trying to connect ...")
      end
  end)
end


if wifi.ap.getip()~=nil then
      -- easy: from prev credentials, it has autoconnected.  We did nothing!
      -- local ssid = wifi.ap.getconfig()
      stationap_cfg.ssid="TelnetConfig1"
      stationap_cfg.pwd="12345678"
      stationap_cfg.auth=wifi.WPA_PSK
      wifi.ap.config(stationap_cfg)
      wifi.setmode(wifi.SOFTAP)
      print ("Auto-connected "  .. wifi.ap.getip())
      if not Time then node.task.post( function() dofile("init3-TIME.lua")  end) end
else
      connecting() -- Not autoconnected, so we need formal connection process
end

-- Note that "normally", any later wifi disconnect (once first connected) will auto-reconnect as available,
--    but only to the earlier used AP, not to any of the alternatives.
-- It is legitimate to "RE"-load this file later, to rescan all AP credentials.
--    Then it's just for wifi resetting,
--    IE, Doesn't go on again to time & proj sequence on reconnect. Those are already loaded.
-- But there is nothing automatic about invoking such a reload. A "project"-level possibility only.
