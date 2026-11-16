local ZigbeeDriver = require "st.zigbee"
local capabilities = require "st.capabilities"
local clusters = require "st.zigbee.zcl.clusters"
local mqtt = require "mqtt_pub"

local function send(device, key, value)
  local p = device.preferences
  local host = p.mqttHost
  if not host or host == "" then return end
  local port = p.mqttPort or 1883
  local user = p.mqttUser or ""
  local pass = p.mqttPass or ""
  local name = (device.label or device.id)
  local payload = "{ \"" .. key .. "\": " .. tostring(value) .. ", \"label\": \"" .. name .. "\" }"
  mqtt.publish(host, port, "tele/smartthings/SENSOR", payload, user, pass)
end

local function temp_handler(driver, device, value, zb_rx)
  local t = value.value / 100
  device:emit_event(capabilities.temperatureMeasurement.temperature({ value = t, unit = "C" }))
  send(device, "temperature", t)
end

local function humi_handler(driver, device, value, zb_rx)
  local h = value.value / 100
  device:emit_event(capabilities.relativeHumidityMeasurement.humidity(h))
  send(device, "humidity", h)
end

local driver = ZigbeeDriver("zigbee-temphumi-mqtt", {
  health_check = false,
  supported_capabilities = {
    capabilities.temperatureMeasurement,
    capabilities.relativeHumidityMeasurement,
    capabilities.battery,
    capabilities.refresh,
  },
  zigbee_handlers = {
    attr = {
      [clusters.TemperatureMeasurement.ID] = {
        [clusters.TemperatureMeasurement.attributes.MeasuredValue.ID] = temp_handler,
      },
      [clusters.RelativeHumidity.ID] = {
        [clusters.RelativeHumidity.attributes.MeasuredValue.ID] = humi_handler,
      },
    },
  },
})
driver:run()

