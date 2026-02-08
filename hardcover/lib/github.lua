local http = require("socket.http")
local json = require("json")
local socketutil = require("socketutil")

local NetworkManager = require("ui/network/manager")

local VERSION = require("hardcover_version")

local RELEASE_API = "https://api.github.com/repos/billiam/hardcoverapp.koplugin/releases?per_page=1"

local Github = {}

function Github:newestRelease()
  if not NetworkManager:isConnected() then
    return nil
  end

  local responseBody = {}
  socketutil:set_timeout(3, 6)
  local res, code, responseHeaders = http.request {
    url = RELEASE_API,
    sink = socketutil.table_sink(responseBody),
  }
  socketutil:reset_timeout()

  if code == 200 or code == 304 then
    local data = json.decode(table.concat(responseBody), json.decode.simple)
    if data and #data > 0 then
      local tag = data[1].tag_name
      local index = 1
      for str in string.gmatch(tag, "([^.]+)") do
        local part = tonumber(str)

        if part < VERSION[index] then
          return nil
        elseif part > VERSION[index] then
          return tag
        end
        index = index + 1
      end
    end
  end
end

return Github
