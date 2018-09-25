-- a simple telnet server
-- https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/telnet.lua
print("Creating telnet server\n")


uart.setup(1,9600,8,0,1)

-- uart.setup(id, baud, databits, parity, stopbits[, echo])
tport = tport or 2323
_telnet_srv = net.createServer(net.TCP, 180)
global_socket = nil
print("Telnet server created\n")
print("Telnet port: " .. (tport))
_telnet_srv:listen(tport, function(socket)
    print("Listening to Telnet server\n")
    if global_socket~=nil then
      global_socket:close()
      print("global_socket closed\n")
    end
    global_socket=socket
    local fifo = {}
    local fifo_drained = true

    local function sender(c)
        if #fifo > 0 then
            str=table.remove(fifo, 1)
            if #str ==0 then
                str = " "
            end
            c:send(str)
        else
            fifo_drained = true
        end
    end

    local function s_output(str)
        table.insert(fifo, str)
        if socket ~= nil and fifo_drained then
            fifo_drained = false
            sender(socket)
        end
    end

    node.output(s_output, 1)   -- re-direct output to function s_ouput.

    socket:on("receive", function(c, l)
        -- node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
        uart.alt(1)
        -- uart.write(1, l, "\n")
        print(l)
    end)
    socket:on("disconnection", function(c)
        node.output(nil)        -- un-regist the redirect output function, output goes to serial
        global_socket=nil
        print("Telnet fin")
    end)
    socket:on("sent", sender)
    socket:on("connection", function(c)
        print("ESP8266 Telnet on")
    end )

--    uart.on("data",4, function(data)
--    	if global_socket~=nil then
--    		node.output(data)
--    	end
--    end, 0)


    print("Welcome.")
end)
