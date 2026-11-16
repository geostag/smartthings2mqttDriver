local cosock = require "cosock"
local socket = cosock.socket
local M = {}

local function str(s) return string.pack(">s2", s) end
local function remlen(n)
  local out = {}
  repeat
    local b = n % 128; n = n // 128
    if n > 0 then b = b | 128 end
    out[#out+1] = string.char(b)
  until n == 0
  return table.concat(out)
end

function M.publish(host, port, topic, payload, user, pass)
  cosock.spawn(function()
    local s = socket.tcp()
    s:settimeout(3)
    local ok, err = s:connect(host, port)
    if not ok then print("MQTT connect failed", err) return end
    local flags = 0x02
    local pl = str("st-edge-" .. math.random(1, 99999))
    if user and user ~= "" then
      flags = flags | 0x80 | 0x40
      pl = pl .. str(user) .. str(pass or "")
    end
    local vh = str("MQTT") .. string.char(4, flags) .. string.pack(">I2", 30)
    local body = vh .. pl
    s:send(string.char(0x10) .. remlen(#body) .. body)
    local ack = s:receive(4)
    if not ack or ack:byte(4) ~= 0 then
      print("MQTT CONNACK error") s:close() return
    end
    local pub = str(topic) .. payload
    s:send(string.char(0x31) .. remlen(#pub) .. pub) -- retain=1
    s:send(string.char(0xE0, 0x00))
    s:close()
  end, "mqtt-publish")
end

return M

