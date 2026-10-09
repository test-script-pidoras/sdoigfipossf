_G.Config = {
      PetFarm = {
        Enabled = true,

        OppositeFarm = true, -- reccomended
        Detect2D_Kitty = true,
        PotionFarm = true,
        FarmPriority = "pets", -- pets / eggs
        PetsToExcludeFromFarm = "", -- sep by ";" / names
        UseBonusBucksPotions = false,
        UseBonusAgingPotions = false,
    },
    
    BabyFarm = true,
    LureboxFarm = true,
    AutoClaimDailies = true,

    Webhook = {
        Discord = {
            Enabled = true,
            URL = "https://discord.com/api/webhooks/1540734655991386273/o4_9CIOHMFizJCrmb0NDwXCNdtRd-oaWJiRAWvqgbYqLehviP8YwMDD4LvRZbnDa_qKt",
            SendDelay = 3600, 
        },
        Telegram = {
            Enabled = false,
            BotAPIKey = "",
            ChatID = "",
            SendDelay = 3600
        }
    },

    Optimization = {
        FPSCap = 10,
        Rendering = false,
    },
    Utilities = {
        AutoReconnect = true,
        WriteConsoleLogs = false, -- debug
        WriteFileLogs = false, -- debug
        GUINotifications = false,
    },

    Event = {
        AutoCollectDailies = true,
        AutoUseCryptKeys = true,
        FeedStrayCat = true,
        AutoUseTwigs = true,
        PlayGhostClustersMinigame = true,
    }

}
--[[
  CODE STYLE

  functions: (PascalCase) - FuncName
  tables: (PascalCase) - TableName = { (snake_case) - lower_case_elements }
  variables: (snake_case) - lover_case_variables
  strings: 1 word - '', else ""
  types: (Pascal_Case) - Callback, Str_I
  ingame required modules: (their real name) - if UiManager then var name UiManager
  executor containing UNC functions: (their real name) - if http then var name http
  function parameter types passed as: param: type
  string formatting: string:format instead of ``
  function params: (snake_case) - debug_nessage
]]
if not game:IsLoaded() then
  game.Loaded:Wait()
end
task.wait(1) 
_G.EXEC = _G.EXEC or 0
_G.EXEC += 1

local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local request = request or http_request or (syn and syn.request) or (http and http.request) or function(...) return end

local function __Notify(title: string, text: string, duration: number, force: boolean)
  if force or _G.InternalConfig.UtilitiesDLib.GUINotifications then 
    pcall(function() 
      StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 14
      })
    end)
  end
end

local function WebRequest(url: string, method: string, headers: { [string]: string }?, body: string?): (boolean, any)
  local ok
  local result
  local decoded = {}
  ok, result = pcall(function()
    return request({
        Url = url,
        Method = method,
        Headers = headers and headers or {},
        Body = body and body or ""
      })
    end
  )
  if not ok then 
    return false, {} 
  end

  local dok, ddata = pcall(function() 
    decoded = HttpService:JSONDecode(result.Body)
  end)

  if dok and type(ddata) == "table" then decoded = ddata end
  
  local code = tonumber(result.StatusCode) or 0
  ok = ok and code >= 200 and code < 300

  return ok, decoded
end

local _script = coroutine.create(function() 
  
  print('[+] Loading..')

  type Callback = () -> ()
  type Str_T <V> = { [string]: V }
  type Int_T <V> = { [number]: V }
  
  type Inv_Cat = Str_T<string | number | { any }>
  type Inv = Str_T<Inv_Cat>
  type P_C_Wrapper = Str_T<string | number | boolean | { any }>

  type Unique = string
  type ID = string
  type Name = string

  type Ailments = Str_T<Str_T<string | number>>
  type Ailment = Str_T<string | number>

  type Task_T = {
    callback: Callback,
    completed: boolean,
    resume: thread?,
  }

  type Log_Status = 'DEBUG' | 'ERROR'
  type Inv_Category = 'pets' | 'food' | 'strollers' | 'toys' | 'pet_accessories' | 'gifts' | 'transport' | 'stickers'
  type PlatformPart = 'main' | '_camp' | '_playground' | '_beach'

  local Constant: { 
    EggRemotes: Str_T<string | number>,
    GiftRemotes: Str_T<string | number>,
    FormattedPet: Str_T<string>,
    FormattedBaby: Str_T<string>,
    ReversedRarities: Int_T<string>,
    XPThresholds: Str_T<number>,
    Parts: Str_T<number>,
    TasksByRarity: Str_T<number>,
    NotifyDuration: Str_T<number>,
    __version: string,
    __attempts: number,
    debug: {Callback?},
    syn: {Callback?},
    http: {Callback?},
  } = {
    EggRemotes = {
      ["endangered_egg"] = {"endangered_2026_endangered_egg", 750},
      ["pet_egg"] = {"regular_pet_egg", 600},
      ["royal_egg"] = {"royal_egg", 1450},
      ["cracked_egg"] = {"cracked_egg", 350},
    },
    
    GiftRemotes = {
      ['smallgift'] = {"smallgift", 70},
      ['biggift'] = {"biggift", 199},
      ["massivegift"] = {"massivegift", 499},
    },

    FormattedPet = {
      ["camping"] = "🏕️ Task [camping] detected for:",
      ["hungry"] = "🍔 Task [hungry] detected for:",
      ["thirsty"] = "🍼 Task [thirsty] detected for:",
      ["sick"] = "💊 Task [sick] detected for:",
      ["bored"] = "🛝 Task [bored] detected for:",
      ["salon"] = "✂️ Task [salon] detected for:",
      ["play"] = "🏓 Task [play] detected for:",
      ["toilet"] = "🚽 Task [toilet] detected for:",
      ["beach_party"] = "🏖️ Task [beach-party] detected for:",
      ["ride"] = "🏎️ Task [ride] detected for:",
      ["dirty"] = "🚿 Task [dirty] detected for:",
      ["walk"] = "🥾 Task [walk] detected for:",
      ["school"] = "🏫 Task [school] detected for:",
      ["sleepy"] = "🛏️ Task [sleepy] detected for:",
      ["mystery"] = "❓ Task [mystery] detected for:",
      ["pizza_party"] = "🍕 Task [pizza-party] detected for:",
      ["pet_me"] = "🐾 Task [pet-me] detected for:",
      ["cat_cafe"] = "☕ Task [cat-cafe] detected for:"
    },

    FormattedBaby = {
      ["camping"] = "🏕️ Task [camping] detected for baby!",
      ["hungry"] = "🍔 Task [hungry] detected for baby!",
      ["thirsty"] = "🍼 Task [thirsty] detected for baby!",
      ["sick"] = "💊 Task [sick] detected for baby!",
      ["bored"] = "🛝 Task [bored] detected for baby!",
      ["salon"] = "✂️ Task [salon] detected for baby!", 
      ["beach_party"] = "🏖️ Task [beach-party] detected for baby!",
      ["dirty"] = "🚿 Task [dirty] detected for baby!",
      ["school"] = "🏫 Task [school] detected for baby!",
      ["sleepy"] = "🛏️ Task [sleepy] detected for baby!",
      ["pizza_party"] = "🍕 Task [pizza-party] detected for baby!",
      ["cat_cafe"] = "☕ Task [cat-cafe] detected for baby!"
    },

    ReversedRarities = {
      [1] = "common",
      [2] = "uncommon",
      [3] = "rare",
      [4] = "ultra_rare",
      [5] = "legendary",
    },

    XPThresholds = {
      ["common"]     = { 200, 500, 900, 1500, 2500 },    
      ["uncommon"]   = { 300, 800, 1500, 2400, 3600 },
      ["rare"]       = { 500, 1200, 2100, 3400, 5400 },
      ["ultra_rare"] = { 700, 1700, 3400, 6100, 10700 },
      ["legendary"]  = { 1000, 2700, 5600, 10400, 18300 },
    },

    Parts = {
      ["main"] = {0,100,0},
      ["_camp"] = {-25, 30, -1054},
      ["_playground"] = {-387, 31, -1750},
      ["_beach"] = {-670, 37, -1413},
      ["_stray_cat"] = {-244, 90, -1123},
      ['_ghost_cluster'] = {-5976.9, 10010.6, 9001.5}
    },
    
    TasksByRarity = {
      ['common'] = 25,
      ['uncommon'] = 36,
      ['rare'] = 54,
      ['ultra_rare'] = 107,
      ['legendary'] = 183,
    }, 

    NotifyDuration = {
      ['WARNING'] = 7,
      ['INFO'] = 6,
      ['SUCCESS'] = 6,
      ['ERROR'] = 8,
    },

  __version = "1.0.0",
  __attempts = 8,

    debug = debug or {},
    syn = syn or {},
    http = http or {},
  }

  local Mutable: {
    Cooldown: Str_T<Str_T<Int_T<number | string>>?>,
    Registry: Str_T<{} | Callback>,
    LocationQueue: Str_T<{} | Callback | boolean>,
    TaskQueue: Str_T<{} | Callback | boolean>,
    Connections: Str_T<RBXScriptSignal>,
    StateDB: Str_T<{} | number>,
    ActualPet: Str_T<boolean>,
    Farmed: Str_T<Str_T<number> | number>,
    Furn: Str_T<Str_T<string>>,
    head_cached: string?,
    Modules: Str_T<Script>,
    Event: Str_T<any>
  } = {
    Cooldown = {
      ['Main'] = {},
      ['AutoFarm'] = {},
      ['AutoTrade'] = {},
      ['Webhooks'] = {},
      ['Other'] = {},
      ['Event'] = {},
    },

    Registry = {
      ['Tasks'] = {},
      ['DisposableTasks'] = {}
    },

    LocationQueue = {
      ['_Queue'] = {},
      ['_running'] = false
    },

    TaskQueue = {
      ['_Queue'] = {},
      ['_running'] = false
    },

    Connections = {},
    
    StateDB = {
      ['total_fullgrowned'] = {},
      ['starter_value'] = 0, 
      ['event_starter_value'] = 0,
    },

    ActualPet = {
      ['unique'] = false :: Unique?,
      ['remote'] = false :: ID?,
      ['model'] = false :: Instance?,
      ['wrapper'] = false :: P_C_Wrapper?,
      ['is_egg'] = false :: boolean,
    },

    Farmed = {
      ['money'] = 0,
      ['pets_fullgrown'] = 0,
      ['ailments'] = 0,
      ['potions'] = 0,
      ['friendship_levels'] = 0,
      ['baby_ailments'] = 0,
      ['eggs_hatched'] = 0,
      ['tickets'] = 0,
      ['time'] = 0,
      ['total_money'] = 0,
      ['total_eggs_bought'] = 0,
      ['total_gifts_bought'] = 0,
    },

    Furn = { 
      Bed = { 
        ['id']='basicbed', 
        ['usepart']='Seat1', 
      }, 
      Bath = { 
        ['id']='cheap_pet_bathtub', 
        ['usepart']='UseBlock', 
      }, 
      Toilet = { 
        ['id']='ailments_refresh_2024_litter_box', 
        ['usepart']='UseBlock', 
      }, 
      Lurebox = { 
        ['id']='lures_2023_normal_lure', 
        ['usepart']='UseBlock', 
      }, 
    },

    head_cached = nil,

    Modules = {},

    Event = {},
  }

  --[[=====================]]
  --[[=====================]]
  --[[====-Lua Helpers-====]]

  local function IntegrityCheck(func_set: {Callback}, on_fallback: Callback, replace: Callback, on_success: Callback)
    for _,v in pairs(func_set) do
      if v then 
        pcall(on_success)
        return v 
      end
    end
    pcall(on_fallback)
    return replace
  end

  print("[+] Starting UNC integrity check..")

  local getupvalue = IntegrityCheck({getupvalue, Constant.debug.getupvalue, Constant.syn.getupvalue, get_upvalue, Constant.debug.get_upvalue, Constant.syn.get_upvalue}, function() __Notify("sUNC Integrity Check", "getupvalue function is not supported by executor. Mystery task cannot be completed.", 14, true) print("[❌] [getupvalue] function failed integrity check.") end, function(...) return end, function() print("[✅] [getupvalue] function successfully completed integrity check.") end)
  local request = IntegrityCheck({request, Constant.syn.request, http_request, Constant.http.request}, function() __Notify("sUNC Integrity Check", "request function is not supported by executor. Script won't fetch status info from github. Script will not work.", 14, true) print("[❌] [request] function failed integrity check.") end, function(...) return end, function() print("[✅] [request] function successfully completed integrity check.") end)
  local makefolder = IntegrityCheck({Constant.syn.makefolder, makefolder, Constant.syn.make_folder, make_folder}, function() __Notify("sUNC Integrity Check", "makefolder function is not supported by executor. Doesn't impact on script proper work.", 14, true) print("[❌] [makefolder] function failed integrity check.") end, function(...) return end, function() print("[✅] [makefolder] function successfully completed integrity check.") end)
  local writefile = IntegrityCheck({writefile, Constant.syn.writefile, Constant.syn.write_file, write_file}, function() __Notify("sUNC Integrity Check", "writefile function is not supported by executor. Doesn't impact on script proper work.", 14, true) print("[❌] [writefile] function failed integrity check.") end, function(...) return end, function() print("[✅] [writefile] function successfully completed integrity check.") end)
  local appendfile = IntegrityCheck({appendfile, append_file, Constant.syn.appendfile, Constant.syn.append_file}, function() __Notify("sUNC Integrity Check", "appendfile function is not supported by executor. Options: {Write File Logs} won't work.", 14, true) print("[❌] [appendfile] function failed integrity check.") end, function(...) return end, function() print("[✅] [appendfile] function successfully completed integrity check.") end)
  local getcustomasset = IntegrityCheck({getcustomasset, Constant.syn.getcustomasset, get_custom_asset, Constant.syn.get_custom_asset}, function() __Notify("sUNC Integrity Check", "getcustomasset function is not supported by executor. Doesn't impact on script proper work.", 14, true) print("[❌] [getcustomasset] function failed integrity check.") end, function(...) return end, function() print("[✅] [getcustomasset] function successfully completed integrity check.") end)
  local gethui = IntegrityCheck({gethui, get_hui, Constant.syn.gethui, Constant.syn.get_hui}, function() __Notify("sUNC Integrity Check", "gethui function is not supported by executor. Doesn't impact on script proper work.", 14, true) print("[❌] [gethui] function failed integrity check, but script has own implementation of function.") end, function(...) return game:GetService("Players").LocalPlayer.PlayerGui end, function() print("[✅] [gethui] function successfully completed integrity check.") end)
  local setfpscap = IntegrityCheck({setfpscap, set_fps_cap, Constant.syn.setfpscap, Constant.syn.set_fps_cap, set_fpscap, Constant.syn.set_fpscap}, function() __Notify("sUNC Integrity Check", "setfpscap function is not supported by executor. Options: {FPS Cap} won't work.", 14, true) print("[❌] [setfpscap] function failed integrity check.") end, function(...) return end, function() print("[✅] [setfpscap] function successfully completed integrity check.") end)
  local queue_on_teleport = IntegrityCheck({queue_on_teleport, queueonteleport, Constant.syn.queue_on_teleport, Constant.syn.queueonteleport}, function() __Notify("sUNC Integrity Check", "queue_on_teleport function is not supported by executor. Option: {Auto Reconnect} will not run script after rejoin, you will be just teleported.", 14, true) print("[❌] [queue_on_teleport] function failed integrity check, but script has own implementation of function") end, nil, function() print("[✅] [queue_on_teleport] function successfully completed integrity check.") end) -- dla proverok est li funkcija v dalnejsem

  local RunService = game:GetService("RunService")
  local NetworkClient = game:GetService("NetworkClient")
  local TeleportService = game:GetService("TeleportService")
  local ReplicatedStorage = game:GetService("ReplicatedStorage")
  local VirtualUser = game:GetService("VirtualUser")
  local HttpService = game:GetService("HttpService")
  local LocalizationService = game:GetService("LocalizationService")
  local UIS = game:GetService("UserInputService")
  local LocalPlayer = game:GetService("Players").LocalPlayer

  local function WriteConsoleLog(debug_msg: string , default_msg: string?, status: Log_Status)
    if _G.InternalConfig.UtilitiesDLib.WriteConsoleLogs then 
      print(string.format("[# %s | %s | %s | %s. #]", status, os.date("%d.%m.%Y"), os.date("%H:%M:%S"), debug_msg))
    else
      if default_msg then
        print(default_msg)
      end
    end
  end
  
  local function WriteFileLog(debug_msg: string, status: Log_Status)
    if _G.InternalConfig.UtilitiesDLib.WriteFileLogs then
      appendfile("Arcanic/logs.txt", string.format("[# %s | %s | %s | %s. #]\n", status, os.date("%d.%m.%Y"), os.date("%H:%M:%S"), debug_msg))
    end
  end

  function Mutable.Registry.RegisterTask(flag: string, callback: Callback, condition: Callback, fallback: Callback)
    local _flag = flag
    local Registry = Mutable.Registry
    if Registry.Tasks[_flag] then
      return
    end

    local _callback =  callback
    local _condition = condition
    local _fallback = fallback
    WriteConsoleLog(string.format("[Registry]: Task registered. [%s]", _flag), nil, "DEBUG")
    WriteFileLog(string.format("[Registry]: Task registered. [%s]", _flag), "DEBUG")
    Registry.Tasks[_flag] = {['_flag'] = _flag, ["_callback"] = _callback, ["_condition"] = _condition, ["_fallback"] = _fallback, _active = true}
  end

  function Mutable.Registry.RunTask(flag: string, callback: Callback)
    local _flag = flag
    local Registry = Mutable.Registry
    if Registry.DisposableTasks[_flag] then
      return
    end

    WriteConsoleLog(string.format("[Registry]: Disposable task registered. [%s]", _flag), nil, "DEBUG")
    WriteFileLog(string.format("[Registry]: Disposable task registered. [%s]", _flag), "DEBUG")
    Registry.DisposableTasks[_flag] = {["_flag"] = _flag, ["_callback"] = callback}
    task.spawn(function() 
      xpcall(callback, function(err) 
        WriteConsoleLog(string.format("[Registry]: Disposable task crashed. [%s] : [%s]", _flag, err), nil, "DEBUG")
        WriteFileLog(string.format("[Registry]: Disposable task crashed. [%s] : [%s]", _flag, err), "DEBUG")      
      end)
      Registry.DisposableTasks[_flag] = nil
    end)
  end

  function Mutable.Registry.Exists(flag: string) 
    local Registry = Mutable.Registry
    return Registry.Tasks[flag] or Registry.DisposableTasks[flag]
  end

  function Mutable.Registry.Dispatch(_task: {}) -- registry task
    WriteConsoleLog(string.format("[Registry]: Task condition reached. [%s]", _task._flag), nil, "DEBUG")
    WriteFileLog(string.format("[Registry]: Task condition reached. [%s]", _task._flag), "DEBUG")
     local ok, err = xpcall(_task._callback, function(e)
      if e == "" then return e end
      return debug.traceback(tostring(e), 2)
    end)
    if not ok then
      if err ~= '' then 
        WriteConsoleLog(string.format("[Registry]: Task crashed. [%s] : [%s]", _task._flag, tostring(err)), nil, "DEBUG")
        WriteFileLog(string.format("[Registry]: Task crashed. [%s] : [%s]", _task._flag, tostring(err)), "DEBUG")
      end
    end
  end
  
  function Mutable.Registry.UnregisterTask(flag: string)
    local Registry = Mutable.Registry
    local _task = Registry.Tasks[flag]
    if _task then
      Registry.Tasks[flag] = nil
      WriteConsoleLog(string.format("[Registry]: Task unregistered. [%s]", flag), nil, "DEBUG")
      WriteFileLog(string.format("[Registry]: Task unregistered. [%s]", flag), "DEBUG")
    end
  end

  function Mutable.Registry.EmergencyStop(): number
    local _int = 0
    for _,v in Mutable.Registry.Tasks do
      if v._active then
        v._active = false
        _int += 1
      end
    end
    return _int
  end

  function Mutable.Registry.MarkTaskAsActive(flag: string)
    local _task = Mutable.Registry.Tasks[flag]
    if _task then
      _task._active = true
    end  
  end

  function Mutable.Registry.EmergencyResume(): number
    local _int = 0
    for _,v in Mutable.Registry.Tasks do
      if not v._active then
        v._active = true
        _int += 1
      end
    end
    return _int
  end

  function Mutable.Registry.MarkTaskAsInactive(flag: string)
    local _task = Mutable.Registry.Tasks[flag]
    if _task then
      _task._active = false
    end
  end

  function Mutable.LocationQueue.CreateTask(callback: Callback): Task_T
    return {
      callback = callback,
      completed = false,
      resume = nil,
    }
  end

  function Mutable.LocationQueue._process()
    local LocationQueue = Mutable.LocationQueue
    if LocationQueue._running then return end
    LocationQueue._running = true
    while #LocationQueue._Queue > 0 do
      local _task = table.remove(LocationQueue._Queue, 1)
      local ok, err = xpcall(_task.callback, function(e) 
        if e == "" then return e end
        return debug.traceback(tostring(e), 2)
      end)
      if not ok then
        if err ~= '' then 
          WriteConsoleLog(string.format("LocationQueue]: Task crashed.[%s]", tostring(err)), nil, "DEBUG")
          WriteFileLog(string.format("[LocationQueue]: Task crashed. [%s]", tostring(err)), "DEBUG")
        end
      end
      _task.completed = true
      _task.resume = coroutine.running()
    end
    LocationQueue._running = false
  end

  function Mutable.LocationQueue.Enqueue(callback: Callback): Task_T
    local LocationQueue = Mutable.LocationQueue
    local _task = LocationQueue.CreateTask(callback)
    table.insert(LocationQueue._Queue, _task)
    coroutine.wrap(LocationQueue._process)()
    return _task
  end

  function Mutable.TaskQueue.CreateTask(callback: Callback): Task_T
    return {
      callback = callback,
      completed = false,
      resume = nil,
    }
  end

  function Mutable.TaskQueue._process()
    local TaskQueue = Mutable.TaskQueue
    if TaskQueue._running then return end
    TaskQueue._running = true
    while #TaskQueue._Queue > 0 do
      local _task = table.remove(TaskQueue._Queue, 1)
      local ok, err = xpcall(_task.callback, function(e) 
        if e == "" then return e end
        return debug.traceback(tostring(e), 2)
      end)
      if not ok then
        if err ~= '' then 
          WriteConsoleLog(string.format("TaskQueue]: Task crashed.[%s]", tostring(err)), nil, "DEBUG")
          WriteFileLog(string.format("[TaskQueue]: Task crashed. [%s]", tostring(err)), "DEBUG")
        end
      end      
      _task.completed = true
      _task.resume = coroutine.running()
    end
    TaskQueue._running = false
  end

  function Mutable.TaskQueue.Enqueue(callback: Callback): Task_T
    local TaskQueue = Mutable.TaskQueue
    local _task = TaskQueue.CreateTask(callback)
    table.insert(TaskQueue._Queue, _task)
    coroutine.wrap(TaskQueue._process)()
    return _task
  end

  local function Count(t: Str_T<any>): number
    local n = 0
    for _ in pairs(t) do
      n +=1 
    end
    return n
  end

  local function __InitCooldownHandler()
    while task.wait(1) do
      for _,v in pairs(Mutable.Cooldown) do -- v: table
        for _,b in pairs(v) do -- a: cooldown flag, b: table: [ [1]: cooldown, [2]: registry_flag ]
          if b[1] == nil then continue end

          b[1] = b[1] and math.max(0, b[1] - 1)
            
          if b[1] > 0 then continue end 
          
          local _task = Mutable.Registry.Tasks[b[2]]
          if _task and _task._active then
            local ok, ready = pcall(_task._condition)
            if ok and ready then
              task.spawn(function() 
                if _task and _task._condition() then
                  b[1] = nil
                  task.spawn(Mutable.Registry.Dispatch, _task)
                end
              end)
            end
          end
        end
      end
    end
  end

  local function InitCooldown(category: string, flag: string, reg_caller_flag: string)
    Mutable.Cooldown[category][flag] = {0, reg_caller_flag}
  end

  local function SetCooldown(category: string, flag: string, value: number)
    if Mutable.Cooldown[category] and Mutable.Cooldown[category][flag] then
      Mutable.Cooldown[category][flag][1] = value
    end
  end

  local function _InitHandler(_task: Callback, ...)
    local att = Constant.__attempts
    local args = {...} or {}
    while att > -1 do
      local call_res, call_err = pcall(_task, unpack(args))
      if not call_res then
        if att == 0 then
          error(call_err or "Undefined error.", 2)
        end
        att -= 1
        task.wait(.3)
      else
        return
      end
    end
  end
  --[[=====================]]
  --[[=====================]]
  --[[===-Ingame Helpers-===]]

  local function LoadModules()
    local Modules = Mutable.Modules
    Modules.API = ReplicatedStorage.API
    Modules.UIManager = require(ReplicatedStorage.ClientModules.Core.UIManager.UIManager)
    Modules.ClientData = require(ReplicatedStorage.ClientModules.Core.ClientData)
    Modules.InventoryDB = require(ReplicatedStorage.ClientDB.Inventory.InventoryDB)
    Modules.PetEntityManager = require(ReplicatedStorage.ClientModules.Game.PetEntities.PetEntityManager)
    Modules.InteriorsM = require(ReplicatedStorage.ClientModules.Core.InteriorsM.InteriorsM)
    Modules.HouseClient = require(ReplicatedStorage.ClientModules.Game.HouseClient)
    Modules.PetActions = require(ReplicatedStorage.ClientModules.Game.PetActions)
    Modules.LiveOpsTime = require(ReplicatedStorage.SharedModules.Game.LiveOpsTime)
    Modules.CloudValues = require(ReplicatedStorage.ClientModules.CloudValues)  
    Modules.TradeLicenseHelper = require(ReplicatedStorage.SharedModules.TradeLicenseHelper)
    Modules.ClientGamepassHelper = require(ReplicatedStorage.ClientModules.Game.ClientGamepassHelper)    
    Modules.AilmentsClient = require(game.ReplicatedStorage.new.modules.Ailments.AilmentsClient)
    Modules.MysteryHelper = require(ReplicatedStorage.new.modules.Ailments.Helpers.MysteryHelper).get_action
    Modules.ItemHider = require(ReplicatedStorage.SharedModules.Game.ItemHider)
    Modules.get_ailment_slots = getupvalue(Modules.MysteryHelper, 2)
    Modules.SharedConstants = require(ReplicatedStorage.ClientDB.SharedConstants)
    Modules.CryptLayout = require(game.ReplicatedStorage.SharedModules.ContentPacks.Halloween2026.Game.TheCrypt.CryptLayout)
    Modules.MinigameClientManager = require(ReplicatedStorage.ClientModules.Game.MinigameClientManager)
  end
  
  local function SafeInvoke(api, ...): (boolean, any)
    local args = table.pack(...)
    local ok, res = pcall(function() return Mutable.Modules.API[api]:InvokeServer(table.unpack(args)) end)
    if not ok then
      WriteConsoleLog("Failed to call Remote Function: " .. api, nil, 'ERROR')
      WriteFileLog("Failed to call Remote Function: " .. api, 'ERROR')
    end
    return ok, res
  end

  local function SafeFire(api: string, ...): boolean
    local args = table.pack(...)
    local ok = pcall(function() Mutable.Modules.API[api]:FireServer(table.unpack(args)) end)
    if not ok then
      WriteConsoleLog("Failed to call Remote Event: " .. api, nil, 'ERROR')
      WriteFileLog("Failed to call Remote Event: " .. api, 'ERROR')
    end
    return ok	
  end
  
  local function InitPart(name: string, xyz: Int_T<number>) 
    if game.Workspace:FindFirstChild(name) then return end
    local main = Instance.new("Part")
    main.Size = Vector3.new(150, 1, 150)
    main.Position = Vector3.new(table.unpack(xyz))
    main.Anchored = true
    main.Name = name
    main.Parent = workspace
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Top
    gui.Parent = main
    
    if _G.asset then
      local img = Instance.new("ImageLabel")
      img.Size = UDim2.new(1, 0, 1, 0)
      img.BackgroundTransparency=  1
      img.Image = _G.asset
      img.Parent = gui
    end
  end

  local function GetLocation(): Str_T<string>
    local char_wrapper = Mutable.Modules.ClientData.get("char_wrapper")
    return char_wrapper.location.destination_id 
  end

  local function ExpectLocation(location: string): boolean
    local _att = Constant.__attempts
    for i=0, _att do
      if (GetLocation() or "") == location then
        return true
      end
      task.wait(1)
    end
    return false
  end

  local function EmulateLocation(dest: string, house_owner: string, subdest: string): boolean	
    SafeFire("LocationAPI/SetLocation", dest, house_owner or LocalPlayer, subdest)
    return ExpectLocation(dest)
  end
    
  local function InitFurniture() 
    SafeFire("HousingAPI/SubscribeToHouse", LocalPlayer)
    EmulateLocation('housing', LocalPlayer)
    task.wait(3)
    
    local furn = Mutable.Furn
    local bed = furn.Bed
    local bath = furn.Bath 
    local toilet = furn.Toilet
    local lurebox = furn.Lurebox

    for k,v in pairs(Mutable.Modules.ClientData.get("house_interior")['furniture'] :: Str_T<string>) do
      local id = v.id:lower()

      if id:match("basicbed") and not bed.unique then 
        print("[+] Bed found.")
        bed.unique = k
      elseif id:match("cheap_pet_bathtub") and not bath.unique then
        print("[+] Bath found.")
        bath.unique = k
      elseif id:match("ailments_refresh_2024_litter_box") and not toilet.unique then
        print("[+] Toilet found.")
        toilet.unique = k
      elseif id:match("lures_2023_normal_lure") and not lurebox.unique then
        print("[+] Lurebox found.")
        lurebox.unique = k
      end
      if bed.unique and bath.unique and toilet.unique and lurebox.unique then break end
    end
    if not bed.unique then
      print("[-] Bed not found. Buying..")
      SafeInvoke("HousingAPI/BuyFurnitures",
        {
          {
            kind = "basicbed",
            properties = {
              cframe = CFrame.new(11.89990234375, 0, -27.10009765625, 1, -3.8213709303294e-15, 8.7422776573476e-08, 3.8213709303294e-15, 1, 0, -8.7422776573476e-08, 0, 1)
            }
          }
        }
      )
    end
    if not bath.unique then
      print("[-] Bath not found. Buying..")
      SafeInvoke("HousingAPI/BuyFurnitures",
        {
          {
            kind = "cheap_pet_bathtub",
            properties = {
              cframe = CFrame.new(31.300048828125, 0, -3.5, 1, -3.8213709303294e-15, 8.7422776573476e-08, 3.8213709303294e-15, 1, 0, -8.7422776573476e-08, 0, 1)
            }
          }
        }
      )
    end
    if not toilet.unique then
      print("[-] Toilet not found. Buying..")
      SafeInvoke("HousingAPI/BuyFurnitures",
        {
          {
            kind = "ailments_refresh_2024_litter_box",
            properties = {
              cframe = CFrame.new(3.199951171875, 0, -24.2998046875, 1, -3.8213709303294e-15, 8.7422776573476e-08, 3.8213709303294e-15, 1, 0, -8.7422776573476e-08, 0, 1)
            }
          }
        }
      )
    end
    if not lurebox.unique then
      print("[-] Lurebox not found. Buying..")
      SafeInvoke("HousingAPI/BuyFurnitures",
        {
          {
            kind = "lures_2023_normal_lure",
            properties = {
              cframe = CFrame.new(-0.5, 2.5, -18.5, 5.960464477539063e-08, 1, -1.910685465164705e-15, -1, 5.960464477539063e-08, -4.371138828673793e-08, -4.371138828673793e-08, 4.516087448393127e-15, 1)
            }
          }
        }
      )
    end
    task.wait(.8)
    if not bed.unique or not bath.unique or not toilet.unique or not lurebox.unique then
      for k,v in pairs(Mutable.Modules.ClientData.get("house_interior")['furniture'] :: Str_T<string>) do
        if not bed.unique and v.id == "basicbed" then
          bed.unique = k
        end
        if not bath.unique and v.id == "cheap_pet_bathtub" then
          bath.unique = k
        end
        if not toilet.unique and v.id == "ailments_refresh_2024_litter_box" then
          toilet.unique = k
        end
        if not lurebox.unique and v.id == "lures_2023_normal_lure" then
          lurebox.unique = k
        end
      end
    end
    WriteConsoleLog("Furniture init done", "[🪑]:[✅] Furniture init done!", 'DEBUG')
    WriteFileLog("Furniture init done", 'DEBUG')
    __Notify('Info', "Furniture init done.", Constant.NotifyDuration['INFO'])
  end

  local function License() 
    if Mutable.Modules.TradeLicenseHelper.player_has_trade_license(LocalPlayer) then
      WriteConsoleLog("Trade license found", "[📜]:[✅] Trade license found", "DEBUG")
      WriteFileLog("Trade license found", "DEBUG")
      __Notify("Info", "Trade license found.", Constant.NotifyDuration["INFO"])
    else
      WriteConsoleLog("License not found, trying to get.", "[📜] License not found, trying to get..", "DEBUG")
      WriteFileLog("License not found, trying to get.", "DEBUG")
      __Notify("Info", "License not found, trying to get..", Constant.NotifyDuration["INFO"])
      SafeFire("SettingsAPI/SetBooleanFlag", "has_talked_to_trade_quest_npc", true)
      task.wait(.2)
      SafeFire("TradeAPI/BeginQuiz")
      task.wait(.2)
      for _,v in pairs(Mutable.Modules.ClientData.get("trade_license_quiz_manager").quiz) do
        SafeFire("TradeAPI/AnswerQuizQuestion", v.answer)
      end
      WriteConsoleLog("Trade license received", "[📜]:[✅] Trade license received", "DEBUG")
      WriteFileLog("Trade license received", "DEBUG")
      __Notify("Success", "Trade license received.", Constant.NotifyDuration["SUCCESS"])
    end
  end 

  local function Avatar()
    local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="
      .. LocalPlayer.UserId
      .. "&size=420x420&format=Png&isCircular=false"       

    local ok, data = WebRequest(url, 'GET')
    local entry = ok and data.data and data.data[1]
    Mutable.head_cached = (entry and (entry.imageUrl or entry.ImageUrl)) or "https://i.imageupload.app/936d8d1617445f2a3fbd.png"  
  end

  local function CheckInternet(): boolean
    local ok, _ = WebRequest(
      "https://google.com",
      'GET'
    )
    if ok then
      return true
    end
    return false
  end

  local function FormatTime(sec: number): string
    local hours = math.floor(sec / 3600)
    local minutes = math.floor((sec % 3600) / 60)
    local seconds = sec % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
  end

  local function TelegramWebhook(msg: string): boolean
    local ok, data = WebRequest(
      "https://api.telegram.org/bot" .. _G.InternalConfig.WebhookDLib.TelegramDLib.BotAPIKey .. "/sendMessage",
      "POST",
      { ["Content-Type"] = "application/json" },
      HttpService:JSONEncode({
        chat_id=_G.InternalConfig.WebhookDLib.TelegramDLib.ChatID,
        text = msg,
        parse_mode = "HTML"
      })
    )
    if not ok then
      WriteConsoleLog("Failed to send telegram webhook", "[❌] Failed to send telegram webhook.", "ERROR")
      WriteFileLog("Failed to send telegram webhook", "ERROR")
    end
    if not data.ok then   
      local err_desc = tostring(data and data.description or "Unknown error")
      WriteConsoleLog(string.format("Telegram error while trying to send webhook: %s", err_desc), string.format("[❌] Telegram error while trying to send webhook: %s", err_desc), "DEBUG")
      WriteFileLog(string.format("Telegram error while trying to send webhook: %s", err_desc), "DEBUG")
      return false
    end
    WriteConsoleLog("Telegram webhook sent", "[✅] Telegram webhook sent.", "DEBUG")
    WriteFileLog("Telegram webhook sent", "DEBUG")
    return true  
end

  local function Webhook(title: string, description: string): boolean
    local payload = {
      content = nil,
      embeds = {
        {
          title = "`              "..title.."              `",				
          description = description,
          color = 0,
          author = {
            name = LocalPlayer.Name,
            url = "https://discord.gg/E8BVmZWnHs",
            icon_url = Mutable.head_cached
          },
          footer = {
            text = os.date("%d.%m.%Y") .. " " .. os.date("%H:%M:%S")
          }
        }
      },
      username = "Arcanic Pro",
      avatar_url = "https://i.imageupload.app/936d8d1617445f2a3fbd.png",
      attachments = {}
    }
    local ok, res = WebRequest(
      _G.InternalConfig.WebhookDLib.DiscordDLib.URL,
      'POST',
      { ["Content-Type"] = "application/json" },
      HttpService:JSONEncode(payload)
    )
    if not ok then
      local err = res.code or 'missing error'
      WriteConsoleLog("Failed to send discord webhook: " .. err, "[❌] Failed to send discord webhook: " .. err .. ".", "ERROR")
      WriteFileLog("Failed to send discord webhook: " .. err, "ERROR")
      return false
    end
    WriteConsoleLog("Discord webhook sent", "[✅] Discord webhook sent.", "DEBUG")
    WriteFileLog("Discord webhook sent", "DEBUG")
    return true
  end

  --[[=====================]]
  --[[=====================]]
  --[[=-Adopt Me Backend-=]]

  local function Equipped(): P_C_Wrapper? 
    return Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper?
  end


  local function GetEquippedModel(): Str_T<string>?
    local model 
    for _, v in ipairs(workspace.Pets:GetChildren()) do
      local entity = Mutable.Modules.PetEntityManager.get_pet_entity(v) :: Str_T<{ any } | boolean>? 
      if entity and entity.session_memory and entity.session_memory.meta.owned_by_local_player then
        model = v
        break
      end
    end
    return model
  end

  local function CurUnique(): Unique
    local w = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper? 
    return w and w.pet_unique or ""
  end

  local function GetOwnedPets(): Str_T<Str_T<string | number | boolean>>
    local inv = Mutable.Modules.ClientData.get("inventory") :: Inv
    local pets = inv and inv.pets 
    if not pets then return {} end
    local result = {}
    for unique,v in pairs(pets) do
      local info = Mutable.Modules.InventoryDB.pets[v.id] :: Str_T<string | number | {} | boolean>
      if info then
        result[unique] = {
          unique = unique,
          remote = v.id,
          age = v.properties.age,
          friendship = v.properties.friendship_level or 0,
          name = info.name,
          rarity = info.rarity,
          neon = v.properties.neon or false,
          mega_neon = v.properties.mega_neon or false,
          rideable = v.properties.rideable or false,
          flyable = v.properties.flyable or false,
          xp = v.properties.xp
        }
      end
    end
    return result
  end

  local function Gotopart(name: string)
    if not workspace:FindFirstChild(name) then
      InitPart(name, Constant.Parts[name])
    end
    
    local part = game.Workspace:FindFirstChild(name)

    if Mutable.ActualPet.unique and Mutable.ActualPet.wrapper and Equipped() then
      local model = GetEquippedModel()
      SafeInvoke("AdoptAPI/HoldBaby", model)
      LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
      task.wait(0.5)
      SafeFire("AdoptAPI/EjectBaby", model)
      return
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(part.Position + Vector3.new(0, 5, 0))
  end

  local function IsOnPlatform(target_part: PlatformPart, teleport_on_false: boolean): boolean
    local _part = workspace:FindFirstChild(target_part) 
    local hrp = LocalPlayer.Character.HumanoidRootPart    

    local ray_params = RaycastParams.new()
    ray_params.FilterDescendantsInstances = {LocalPlayer.Character}
    ray_params.FilterType = Enum.RaycastFilterType.Exclude
    
    local res_result = workspace:Raycast(hrp.Position, Vector3.new(0, -4, 0), ray_params)
    if res_result and res_result.Instance == _part then
      return true
    end
    if teleport_on_false then
      Gotopart(target_part)
    else
      return false
    end
  end

  local function GetEquippedPetAilments(): Str_T<boolean>
    local ailments = {}
    if Mutable.ActualPet.unique then
      local path = Mutable.Modules.ClientData.get("ailments_manager")["ailments"][Mutable.ActualPet.unique] :: Ailments
      if not path then return {} end
      for k,_ in pairs(path) do
        ailments[k] = true
      end
    end
    return ailments 
  end

  local function GetOwnedCategory(category: Inv_Category): Str_T<Str_T<string>>
    local inv = Mutable.Modules.ClientData.get("inventory") :: Inv
    local cat = inv and inv[category] :: Inv_Cat
    if not cat then return {} end
    local result = {}
    for unique, v in pairs(cat) do
      result[unique] = { remote = v.id, unique = unique }
    end
    return result
  end

  local function HasAilment(ailment: string): Ailment?
    local ail = Mutable.Modules.ClientData.get("ailments_manager")["ailments"][Mutable.ActualPet.unique] :: Ailments
    return ail and ail[ailment] ~= nil
  end

  local function HasAilmentBaby(ailment: string): Ailment? 
    local ail = Mutable.Modules.ClientData.get("ailments_manager")["baby_ailments"] :: Ailments
    return ail and ail[ailment] ~= nil
  end	

  local function GetBabyAilments(): Str_T<boolean>
    local ailments = {}
    for k, _ in pairs(Mutable.Modules.ClientData.get("ailments_manager")["baby_ailments"] :: Ailments) do
      ailments[k] = true
    end 
    return ailments 
  end

  local function InvGetCategoryUnique(category: Inv_Category, remote: ID): Unique
    local inv = Mutable.Modules.ClientData.get("inventory") :: Inv
    local cat = inv and inv[category] :: Inv_Cat
    for unique, v in pairs(cat) do
      if v.id == remote then
        return unique
      end
    end
  end

  local function InvGetNameFromUnique(category: Inv_Category, unique: Unique): Name
    local remote = Mutable.Modules.ClientData.get("inventory")[category][unique].id :: ID or "ZALUPA HITLERA" 
    local cat = Mutable.Modules.InventoryDB[category][remote]
    return cat and cat.name or "Name not found"
  end

  local function CountOfProduct(category: Inv_Category, remote: ID): number
    local inv = Mutable.Modules.ClientData.get("inventory") :: Inv
    local cat = inv and inv[category] :: Inv_Cat
    if not cat then return 0 end
    local count = 0
    for _, v in pairs(cat) do
      if v.id == remote then
        count += 1
      end
    end
    return count
  end

  local function PetExists(unique: Unique): Str_T<any>?
    return Mutable.Modules.ClientData.get("inventory")['pets'][unique] :: Str_T<any>?
  end

  local function CountOfPets(): number
    local _count = 0
    for _,__ in Mutable.Modules.ClientData.get("inventory")['pets'] :: Inv_Cat do
      _count += 1
    end
    return _count
  end

  local function GetBonusBucksPotionToPet()
    local _pet_props = Mutable.Modules.ClientData.get("inventory")["pets"][Mutable.ActualPet.unique].properties
    if _pet_props.timed_flags and _pet_props.timed_flags.bucks_multiplier then
      local __time = _pet_props.timed_flags.bucks_multiplier.time_left or 0
      if __time > 0 then
        return 
      end
    end
    local potion
    local _count = 0
    for k,v in GetOwnedCategory("food") do
      if v.remote == "pet_bonus_bucks_potion" then
        _count += 1
        potion = k        
      end
    end
    if not potion then return end
    local args = {
      "__Enum_PetObjectCreatorType_2",
      {
        additional_consume_uniques = {},
        pet_unique = Mutable.ActualPet.unique,
        unique_id = potion
      }
    }
    SafeInvoke("PetObjectAPI/CreatePetObject", unpack(args))
    task.wait(3)
    local deadline = os.clock() + 7
    repeat
      task.wait(1)
      local _pet_props = Mutable.Modules.ClientData.get("inventory")["pets"][Mutable.ActualPet.unique].properties
    until _pet_props and _pet_props.timed_flags and _pet_props.timed_flags.bucks_multiplier and _pet_props.timed_flags.bucks_multiplier.time_left or os.clock() > deadline 
    if os.clock() < deadline then
      WriteConsoleLog("Bonus bucks potion was given to pet", "[🐶]:[✅] Bonus bucks potion was given to pet.", 'DEBUG')
      WriteFileLog("Bonus bucks potion was given to pet", 'DEBUG')
      __Notify("Info", "Bonus bucks potion was given to pet.", Constant.NotifyDuration['INFO'])
    else
      WriteConsoleLog("Failed to give bonus bucks potion for pet", "[🐶]:[❌] Failed to give bonus bucks potion for pet.", 'DEBUG')
      WriteFileLog("Failed to give bonus bucks potion for pet", 'DEBUG')
      __Notify("Warning", "Failed to give bonus bucks potion for pet.", Constant.NotifyDuration['WARNING'])
    end
  end

  local function GetBonusAgingPotionToPet()
    local _pet_props = Mutable.Modules.ClientData.get("inventory")["pets"][Mutable.ActualPet.unique].properties
    if _pet_props.timed_flags and _pet_props.timed_flags.aging_multiplier then
      local __time = _pet_props.timed_flags.aging_multiplier.time_left or 0
      if __time > 0 then
        return 
      end
    end
    local potion
    local _count = 0
    for k,v in GetOwnedCategory("food") do
      if v.remote == "pet_bonus_aging_potion" then
        _count += 1
        potion = k        
      end
    end
    if not potion then return end
    local args = {
      "__Enum_PetObjectCreatorType_2",
      {
        additional_consume_uniques = {},
        pet_unique = Mutable.ActualPet.unique,
        unique_id = potion
      }
    }
    SafeInvoke("PetObjectAPI/CreatePetObject", unpack(args))
    task.wait(3)
    local deadline = os.clock() + 7
    repeat
      task.wait(1)
      local _pet_props = Mutable.Modules.ClientData.get("inventory")["pets"][Mutable.ActualPet.unique].properties
    until _pet_props and _pet_props.timed_flags and _pet_props.timed_flags.aging_multiplier and _pet_props.timed_flags.aging_multiplier.time_left or os.clock() > deadline 
    if os.clock() < deadline then
      WriteConsoleLog("Bonus aging potion was given to pet", "[🐶]:[✅] Bonus aging potion was given to pet.", 'DEBUG')
      WriteFileLog("Bonus aging potion was given to pet", 'DEBUG')
      __Notify('Info', "Bonus aging potion was given to pet.", Constant.NotifyDuration['INFO'])
    else
      WriteConsoleLog("Failed to give bonus aging potion for pet", "[🐶]:[❌] Failed to give bonus aging potion for pet.", 'DEBUG')
      WriteFileLog("Failed to give bonus aging potion for pet", 'DEBUG')
      __Notify('Warning', "Failed to give bonus aging potion for pet.", Constant.NotifyDuration['WARNING'])
    end
  end

  local function ClearPetFarmCache()
    _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = false
    _G.InternalConfig.PetFarmDLib.random_farm = false
    for k,_ in Mutable.ActualPet do
      Mutable.ActualPet[k] = nil
    end
  end

  local function UpdateGui(label: string, val: string | number) 
    task.spawn(function()
      local hui = gethui()
      local overlay = hui:FindFirstChild("StatsOverlay")
      if not overlay then return end
      local frame = overlay:FindFirstChild("StatsFrame")
      if not frame then return end
      local lbl = frame:FindFirstChild(label)
      if not lbl then return end
      local prefix = lbl.Text:match("^[^:]+") or lbl.Name
      if prefix then
        lbl.Text = prefix .. ": " .. tostring(val)
      end		
    end)
  end  

  local function GetPetPenSlots() 
    local maxTotalPets = Mutable.Modules.CloudValues:getValue("idle_progression", "maxTotalPets") --or 0
    local extraSlotGamepassIds = Mutable.Modules.CloudValues:getValue("idle_progression", "extraSlotGamepassIds") --or {}
    local purchasedExtraSlots = 0
    for _, gamepassId in ipairs(extraSlotGamepassIds) do
      if Mutable.Modules.ClientGamepassHelper.owns_gamepass(gamepassId) then
        purchasedExtraSlots = purchasedExtraSlots + 1
      end
    end
    return maxTotalPets + purchasedExtraSlots
  end

  local function IsTradeable(category: Inv_Category, remote, unique): boolean
    local item = Mutable.Modules.InventoryDB[category][remote] :: ID
    local _inv = Mutable.Modules.ClientData.get("inventory")[category] :: Inv_Cat
    local _table 
    for k,v in pairs(_inv) do
      if v.id == item.kind then
        _table = _inv[k]
      end
    end
    return Mutable.Modules.ItemHider.is_item_tradeable(item, _table)
  end

  local function CalculateMoney()
    Mutable.Farmed.money = (Mutable.Modules.ClientData.get("money") or 0) - Mutable.StateDB.starter_value
    Mutable.Farmed.total_money = Mutable.Modules.ClientData.get("money") or 0
    Mutable.Farmed.tickets = (Mutable.Modules.ClientData.get("pet_recycler_tickets_2026") or 0) + (Mutable.Modules.ClientData.get("pet_recycler_manager").saved_tickets or 0)
    UpdateGui("bucks", Mutable.Farmed.money)
    UpdateGui("total_bucks", Mutable.Farmed.total_money)
    UpdateGui("tickets", Mutable.Farmed.tickets)
  end

  local function CalcStage(rarity: string, xp: number): number
    local thresholds = Constant.XPThresholds[rarity]
    if not thresholds then return 1 end
    for stage = 1, #thresholds do
      if xp < thresholds[stage] then
        return stage
      end
    end
    return 6 
  end

  local function GetExpectedAge(current_xp: number, rarity: string, selected_age: {}, selected_tiny: {}): (number, number)
    local xp_after_age = current_xp + (Count(selected_age) * 3000)
    local age_stage = CalcStage(rarity, xp_after_age)
    local xp_after_tiny = current_xp + (Count(selected_tiny) * 300)
    local tiny_stage = CalcStage(rarity, xp_after_tiny)

    return age_stage, tiny_stage
  end

  local function GetPotions(): Int_T<{Str_T<boolean>}> 
    local big = {}
    local tiny = {}
    for k,v in pairs(GetOwnedCategory("food")) do
      if (v.remote:lower()):match("tiny_pet_age_potion") then
        tiny[k] = true
      elseif (v.remote:lower()):match("pet_age_potion") then
        big[k] = true
      end
    end
    if Count(big) == 0 then big = nil end
    if Count(tiny) == 0 then tiny = nil end
    return { big, tiny }
  end

  local function TakeN(_table: {}, n: number): {}
      local result = {}
      local c = 0
      for k, v in pairs(_table or {}) do
          if c >= n then break end
          result[k] = v
          c += 1
      end
      return result
  end

  local function CalculateOptimalPotionsByRarity(current_xp: number, rarity: string, potions: Str_T<boolean>)
    local total_tasks = Constant.TasksByRarity[rarity]
    local remaining = total_tasks - math.floor(current_xp / 100)
    if remaining <= 0 then return { {}, {}, }, { {}, {}, } end

    local _age = potions[1] or {}
    local _tiny = potions[2] or {}
    local big_avail, tiny_avail = Count(_age), Count(_tiny)

    local use_big = math.min(math.floor(remaining / 30), big_avail)
    local rem_after_big = remaining - (use_big * 30)
    local use_tiny = 0

    if rem_after_big > 0 then
      local tiny_needed = math.ceil(rem_after_big / 3)
      if (tiny_needed <= tiny_avail and rem_after_big <= 9) or (use_big >= big_avail) then
        use_tiny = math.min(tiny_needed, tiny_avail)
      elseif use_big < big_avail then
        use_big += 1 
      else
        use_tiny = tiny_avail 
      end
    end
    local selected_age = TakeN(_age, use_big)
    local selected_tiny = TakeN(_tiny, use_tiny)

    local expected_big_age, expected_tiny_age = GetExpectedAge(current_xp, rarity, selected_age, selected_tiny)

    return { selected_age, selected_tiny, }, { expected_big_age, expected_tiny_age, }
  end

  local function Translate(text: string): string
    local translator = LocalizationService:GetTranslatorForLocaleAsync('en')
    return translator:Translate(game, text)
  end

  local function SendTradeRequest(user: Player): string?  
    local deadline = os.clock() + 120
    local declined = false
    local cooldown = false
    local doesnt_accept = false
    local ev = Mutable.Modules.API["MsgAPI/HintSent"].OnClientEvent:Connect(function(...)
      local text = Translate(select(1, ...)["text"])
      if text:match("declined your trade request.") then
        declined = true
      elseif text:match("Try again in ") then
        local seconds = text:match("(%d+)")
        cooldown = seconds and tonumber(seconds) or 10
      elseif text:match("does not accept trade requests") or text:match("only trades with friends") then
        doesnt_accept = true
      end
    end)
    SafeFire("TradeAPI/SendTradeRequest", game.Players[user])
    WriteConsoleLog(string.format("Trade request to %s sent", user), string.format("⚙️ Trade request to %s sent!", user), "DEBUG")
    WriteFileLog(string.format("Trade request to %s sent", user), "DEBUG")
    __Notify("Info", "Trade request to user sent.", Constant.NotifyDuration['INFO'])
    while not Mutable.Modules.UIManager.apps.TradeApp.visible and os.clock() < deadline and not declined and not cooldown do
      task.wait(1)
    end
    ev:Disconnect()
    if doesnt_accept then
      return "does not accept trade requests"
    end
    if cooldown then
      return cooldown
    end
    if declined then 
      return "declined"
    end
    if not Mutable.Modules.UIManager.apps.TradeApp.visible or os.clock() > deadline then
      return "No response"
    end
  end 
  
  local function PetUpdate()
    local deadline = os.clock() + 2.5
    repeat
      task.wait(.2) 
    until Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper? or deadline < os.clock()
    if deadline < os.clock() then
      return 
    end
    local wrapper = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper?
    local unique = wrapper.pet_unique
    local remote = wrapper.pet_id
    local pet_info = Mutable.Modules.InventoryDB.pets[remote]
    local name = pet_info and pet_info.name
    Mutable.ActualPet.unique = unique 
    Mutable.ActualPet.remote = remote
    Mutable.ActualPet.wrapper = wrapper
    Mutable.ActualPet.is_egg = (name:lower()):match("egg") ~= nil
    Mutable.ActualPet.name = name
  end

  local function CheckDualPetSub()
    local subm = Mutable.Modules.ClientData.get("subscription_manager") :: Str_T<Str_T<boolean>> 
    _G.InternalConfig.DualFarm = subm and subm["equip_2x_pets"] and subm["equip_2x_pets"].active or false
  end

  local function ToggleStatsPopup()
    local hui = gethui()
    if not hui:FindFirstChild("StatsOverlay") then 
      local gui = Instance.new("ScreenGui") 
      local frame = Instance.new("Frame")
      gui.Name = "StatsOverlay" 
      gui.ResetOnSpawn = false 
      gui.Parent = hui
      frame.Name = "StatsFrame"
      frame.Size = UDim2.new(0, 250, 0, 310)
      frame.Position = UDim2.new(0, 5, 0, 5)
      frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
      frame.BackgroundTransparency = 0.3
      frame.Parent = gui

      local function CreateLabel(name, text, order, flag)
        local label = Instance.new("TextLabel")
        label.Name = name
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, order * 22)
        label.BackgroundTransparency = 1
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextColor3 = Color3.fromRGB(156, 136, 136)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 18
        label.TextXAlignment = Enum.TextXAlignment.Left

        if not flag then
          label.Text = text .. ": 0"
        else
          label.Text = text 
        end  	
     
        label.Parent = frame
        return label
      end

      CreateLabel("bucks", "💸 Bucks earned", 0)
      CreateLabel("fullgrown", "📈 Pets full-grown", 1)
      CreateLabel("pet_needs", "🐶 Pet needs completed", 2)
      CreateLabel("potions", "🧪 Potions farmed", 3)
      CreateLabel("friendship", "🧸 Friendship levels farmed", 4)
      CreateLabel("baby_needs", "👶 Baby needs completed", 5)
      CreateLabel("eggs", "🥚 Eggs hatched", 6)
      CreateLabel("tickets", "🎫 Tickets", 7)
      CreateLabel("event_currency", "🍬 Candies farmed", 8)
      CreateLabel("_", "---------------------------------------", 9, true)
      CreateLabel("total_bucks", "💸 Total bucks", 10)
      CreateLabel("total_event_currency", "🍬 Total candies", 11)
      CreateLabel("__", "---------------------------------------", 12, true)
      CreateLabel("timer", "⏰ Runtime", 13)    

      UpdateGui("bucks", Mutable.Farmed.money)
      UpdateGui("fullgrown", Mutable.Farmed.pets_fullgrown)
      UpdateGui("pet_needs", Mutable.Farmed.ailments)
      UpdateGui("potions", Mutable.Farmed.potions)
      UpdateGui("friendship", Mutable.Farmed.friendship_levels)
      UpdateGui("baby_needs", Mutable.Farmed.baby_ailments)
      UpdateGui("eggs", Mutable.Farmed.eggs_hatched)
      UpdateGui("tickets", Mutable.Farmed.tickets)
      UpdateGui("event_currency", (Mutable.Modules.ClientData.get("candy_2026") or 0) - Mutable.StateDB.event_starter_value)
      UpdateGui("total_bucks", Mutable.Farmed.total_money)
      UpdateGui("total_event_currency", Mutable.Modules.ClientData.get("candy_2026") or 0)
      UpdateGui("timer", FormatTime(Mutable.Farmed.time))
    else
      hui:FindFirstChild("StatsOverlay").Enabled = not hui:FindFirstChild("StatsOverlay").Enabled
    end
  end

  --[[=====================]]
  --[[=====================]]
  --[[===-Halloween2026-===]]

  function Mutable.Event.CalculateCurrency()
    local cur = (Mutable.Modules.ClientData.get("candy_2026") or 0) - Mutable.StateDB.event_starter_value
    local total_cur = Mutable.Modules.ClientData.get("candy_2026") or 0
    UpdateGui('event_currency', cur)
    UpdateGui('total_event_currency', total_cur)
  end
      
  function Mutable.Event.GetRustyCryptKeys(): number
    local keys = 0
    for k,v in pairs(Mutable.Modules.ClientData.get('inventory').toys) do 
      if v.id == "halloween_2026_rusty_key" then 
        keys += 1
      end
    end
    return keys
  end

  function Mutable.Event.GetCryptTwigs() 
    local twigs = {}
    for k,v in pairs(Mutable.Modules.ClientData.get('inventory').toys) do 
      if v.id == "halloween_2026_twig" then 
        twigs[k] = true      
      end
    end
    return twigs
  end

  function Mutable.Event.EquipRustyCryptKey()
    for k,v in pairs(Mutable.Modules.ClientData.get('inventory').toys) do 
      if v.id == "halloween_2026_rusty_key" then 
        SafeInvoke("ToolAPI/Equip", k, {
          use_sound_delay = true,
          equip_as_last = false
        })
        break
      end
    end
    task.wait(.3)
  end

  function Mutable.Event.GetNextStrayCatCycle()
    local cycle_length = Mutable.Modules.SharedConstants.day_length + Mutable.Modules.SharedConstants.night_length  
    local now = Mutable.Modules.LiveOpsTime.now()
    local seconds_into_cycle = now % cycle_length
    return cycle_length - seconds_into_cycle  
  end

  function Mutable.Event.ClaimTombSpider(): Str_T<boolean | string>
    local count_of_spiders = CountOfProduct('pets', 'halloween_2026_tomb_spider')    

    local res = ReplicatedStorage.adoptme_new_net["Halloween2026/ClaimTombSpider"]:InvokeServer()
    local deadline = os.clock() + 5

    repeat 
      task.wait(1)
    until CountOfProduct('pets', 'halloween_2026_tomb_spider') > count_of_spiders or os.clock() > deadline 

    return res
  end

  function Mutable.Event.GetCurrentFloor(): number 
    local manager = Mutable.Modules.ClientData.get('halloween_2026_crypt_manager')
    local opened =  Mutable.Modules.CryptLayout.opened_set(manager['opened'])
    local c_floor = 0
    for i=1, 5 do 
      if Mutable.Modules.CryptLayout.is_floor_reached(manager.floors, opened, i) then
        c_floor = i
      end
    end
    return c_floor
  end

  function Mutable.Event.GetLadderAndTwingsOnFloor(floor: number): (Int_T<number>, number)
    local twings = {}
    local ladder = 0
    local floors = Mutable.Modules.ClientData.get('halloween_2026_crypt_manager')['floors']
    for caffin,t in Mutable.Modules.CryptLayout.floor_contents(floors[floor]) do
      if t.type == 'reward' then
        if t.reward_id == "twig" then
          table.insert(twings, caffin) 
        end
      end
      if t.type == "ladder" then
        ladder = caffin
      end
    end
    return twings, ladder
  end

  function Mutable.Event.EnsureModel(model, folder)
    return folder and model and model.Parent and model:IsDescendantOf(folder) 
  end

  function Mutable.Event.EnsureGhostRange(model, folder)
    if not Mutable.Event.EnsureModel(model, folder) then return false end

    local hrp = LocalPlayer.Character.HumanoidRootPart
    local model_position = model:GetPivot().Position  
    local distance = (hrp.Position - model_position).Magnitude

    if distance >= 22 then
      local character = hrp.Parent
      local target_cframe = model:GetPivot() + Vector3.new(0, 3, 0)
      character:PivotTo(target_cframe) 
    end
    return true
  end

  function Mutable.Event.GetGhost(folder)
    for _, model in pairs(folder:GetChildren()) do
      if model:IsA("Model") and model:GetAttribute("GhostClustersId") then 
        return model
      end
    end
  end

  --[[=====================]]
  --[[=====================]]
  --[[=======Backend=======]]

  local function __BabyCallback() 
    Mutable.Farmed.baby_ailments += 1 
    UpdateGui("baby_needs", Mutable.Farmed.baby_ailments)
  end

  local function Enstat(age: number, friendship: number, money: number, ailment: string, baby_has_ailment: boolean)  
    if baby_has_ailment and not HasAilmentBaby(ailment) then
      __BabyCallback()
    end
    if Mutable.ActualPet.is_egg then
      task.wait(.5)
      if GetOwnedPets()[Mutable.ActualPet.unique].xp == 0 then
        Mutable.Farmed.eggs_hatched += 1 
        Mutable.Farmed.ailments += 1
        UpdateGui("eggs", Mutable.Farmed.eggs_hatched)
        UpdateGui("pet_needs", Mutable.Farmed.ailments)
        if not _G.InternalConfig.PetFarmDLib.PotionFarm then 
          ClearPetFarmCache()
        else
          task.wait(3.2)
          PetUpdate()
          local _pet = GetOwnedPets()[Mutable.ActualPet.unique]
          _G.InternalConfig.PetFarmDLib.ManualPetsToFarm = _pet.unique
        end
      else
        Mutable.Farmed.ailments +=1
        UpdateGui("pet_needs", Mutable.Farmed.ailments)
      end
      return
    end
    task.wait(.5)
    if friendship < Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level then
      Mutable.Farmed.friendship_levels += 1
      Mutable.Farmed.potions += 1
      UpdateGui("friendship", Mutable.Farmed.friendship_levels)
      UpdateGui("potions", Mutable.Farmed.potions)
    end
    if age < 6 and Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age == 6 then
      Mutable.Farmed.pets_fullgrown += 1
      UpdateGui("fullgrown", Mutable.Farmed.pets_fullgrown)
      Mutable.StateDB.total_fullgrowned[Mutable.ActualPet.unique] = true
      if not _G.InternalConfig.PetFarmDLib.PotionFarm then
        if not _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then
          Mutable.ActualPet.unique = false
        end
      end
    end
    if money then 
      CalculateMoney() 
      Mutable.Event.CalculateCurrency()
    end
    Mutable.Farmed.ailments += 1
    UpdateGui("pet_needs", Mutable.Farmed.ailments)
  end

  local function __PetCallback(age: number, friendship: number, ailment: string) 
    if not Mutable.ActualPet.unique then -- проверка на то, фармим ли мы паралельно пета, если нет, то просто + ailment
      Mutable.Farmed.ailments += 1
      UpdateGui("pet_needs", Mutable.Farmed.ailments) 
    else
      Enstat(age, friendship, nil, ailment)
    end
  end

  local function EnstatBaby(money: number, ailment: string, pet_has_ailment: boolean, pet_data) 
    Mutable.Farmed.baby_ailments += 1  
    if pet_has_ailment and Equipped() and not HasAilment(ailment) then
      __PetCallback(pet_data[1], pet_data[2], ailment)
    end
    CalculateMoney() 
    Mutable.Event.CalculateCurrency()
    UpdateGui("baby_needs", Mutable.Farmed.baby_ailments)
  end

  Constant.PetAilments = { 
    ["camping"] = function()
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("camping")
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("_camp", true)
        EmulateLocation("MainMap", LocalPlayer, "Default") 
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilment("camping") or os.clock() > deadline  
        Gotopart("main")
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task camping for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task camping for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task camping for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
          return
        end        
        WriteConsoleLog(string.format("Task camping for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task camping for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task camping for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "camping", baby_has_ailment)
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["hungry"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      if CountOfProduct("food", "apple") == 0 then
        if money == 0 then 
          WriteConsoleLog("No money to buy food", "⚠️ No money to buy food!", "DEBUG") 
          WriteFileLog("No money to buy food", "DEBUG") 
          return
        end
        local bc = if money > 20 then 20 else money 

        SafeInvoke("ShopAPI/BuyItem",
          "food",
          "apple",
          {
            buy_count = bc
          }
        )
      end
      IsOnPlatform("main", true)
      local deadline = os.clock() + 14
      local money = Mutable.Modules.ClientData.get("money")
      SafeInvoke("PetObjectAPI/CreatePetObject",
        "__Enum_PetObjectCreatorType_2",
        {
          additional_consume_uniques={},
          pet_unique = Mutable.ActualPet.unique,
          unique_id = InvGetCategoryUnique("food", "apple")
        }
      )
      repeat 
        task.wait(1)
      until not HasAilment("hungry") or os.clock() > deadline
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task hungry for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task hungry for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task hungry for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
        return		
      end        
      WriteConsoleLog(string.format("Task hungry for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task hungry for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task hungry for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "hungry")  
    end,
    ["thirsty"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      if CountOfProduct("food", "water") == 0 then
        if money == 0 then 
          WriteConsoleLog("No money to buy food", "⚠️ No money to buy food!", "DEBUG") 
          WriteFileLog("No money to buy food", "DEBUG") 
          return
        end
        local bc = if money > 20 then 20 else money

        SafeInvoke("ShopAPI/BuyItem",
          "food",
          "water",
          {
            buy_count = bc
          }
        )
      end
      IsOnPlatform("main", true)
      local deadline = os.clock() + 14
      local money = Mutable.Modules.ClientData.get("money")
      SafeInvoke("PetObjectAPI/CreatePetObject",
        "__Enum_PetObjectCreatorType_2",
        {
          additional_consume_uniques={},
          pet_unique = Mutable.ActualPet.unique,
          unique_id = InvGetCategoryUnique("food", "water")
        }
      )
      repeat 
        task.wait(1)
      until not HasAilment("thirsty") or os.clock() > deadline
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task thirsty for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task thirsty for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task thirsty for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
        return		
      end            	
      WriteConsoleLog(string.format("Task thirsty for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task thirsty for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task thirsty for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "thirsty")  
    end,
    ["sick"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("sick")
      local _task = Mutable.LocationQueue.Enqueue(function() 
        IsOnPlatform("main", true)
        EmulateLocation("Hospital")
        SafeInvoke("HousingAPI/ActivateInteriorFurniture",
          "f-14",
          "UseBlock",
          "Yes",
          LocalPlayer.Character
        )
        local deadline = os.clock() + 5
        repeat 
          task.wait(1)
        until not HasAilment('sick') or os.clock() > deadline 
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task sick for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task sick for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task sick for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
          return		
        end    
        WriteConsoleLog(string.format("Task sick for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task sick for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task sick for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "sick", baby_has_ailment)
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["bored"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("bored")
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("_playground", true)
        EmulateLocation("MainMap", LocalPlayer, "Default")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilment("bored") or os.clock() > deadline
        Gotopart("main")
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task bored for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task bored for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task bored for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
          return		
        end        
        WriteConsoleLog(string.format("Task bored for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task bored for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task bored for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "bored", baby_has_ailment)  
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["salon"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("salon")
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("main", true)
        EmulateLocation("Salon")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilment("salon") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task salon for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task salon for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task salon for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
          return		
        end        
        WriteConsoleLog(string.format("Task salon for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task salon for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task salon for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "salon", baby_has_ailment)
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["play"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      IsOnPlatform("main", true)
      SafeInvoke("ToolAPI/Equip", InvGetCategoryUnique("toys", "squeaky_bone_default"), {})
      local deadline = os.clock() + 30
      repeat 
        SafeInvoke("PetObjectAPI/CreatePetObject",
          "__Enum_PetObjectCreatorType_1",
          {
            reaction_name = "ThrowToyReaction",
            unique_id = InvGetCategoryUnique("toys", "squeaky_bone_default")
          }
        )
        task.wait(5) 
      until not HasAilment("play") or os.clock() > deadline
      SafeInvoke("ToolAPI/Unequip", InvGetCategoryUnique("toys", "squeaky_bone_default"), {})
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task play for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task play for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task play for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
        return		
      end        
      WriteConsoleLog(string.format("Task play for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task play for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task play for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "play") 
    end,
    ["toilet"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      IsOnPlatform("main", true)
      SafeInvoke('HousingAPI/ActivateFurniture',
        LocalPlayer,
        Mutable.Furn.Toilet.unique,
        Mutable.Furn.Toilet.usepart,
        {
          cframe = CFrame.new(LocalPlayer.Character.HumanoidRootPart.CFrame.Position)
        },
        GetEquippedModel()
      )
      local deadline = os.clock() + 20
      repeat 
        task.wait(1)
      until not HasAilment("toilet") or os.clock() > deadline
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task toilet for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task toilet for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task toilet for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG")
        return		
      end        
      WriteConsoleLog(string.format("Task toilet for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task toilet for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task toilet for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "toilet")
    end,
    ["beach_party"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("beach_party")
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("_beach", true)
        EmulateLocation("MainMap", LocalPlayer, "Default")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilment("beach_party") or os.clock() > deadline
        Gotopart("main")
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task beach-party for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task beach-party for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task beach-party for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
          return		
        end        
        WriteConsoleLog(string.format("Task beach-party for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task beach-party for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task beach-party for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "beach_party", baby_has_ailment)  
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["ride"] = function()
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local deadline = os.clock() + 60
      IsOnPlatform("main", true)
      task.wait(.25)
      SafeInvoke("ToolAPI/Equip", InvGetCategoryUnique("strollers", "stroller-default"), {})
      local hrp = LocalPlayer.Character.HumanoidRootPart
      local lockedpos = hrp.Position
      Mutable.Connections.RideLock = RunService.RenderStepped:Connect(function()
        hrp.CFrame = CFrame.new(lockedpos) * (hrp.CFrame - hrp.CFrame.Position)
        LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 0, -.1), false) 
      end)
      while os.clock() < deadline and HasAilment("ride") do
        task.wait(1)
      end
      Mutable.Connections.RideLock:Disconnect()
      Mutable.Connections.RideLock = nil
      SafeInvoke("ToolAPI/Unequip", InvGetCategoryUnique("strollers", "stroller-default"), {})
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task ride for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task ride for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task ride for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
        return		
      end        
      WriteConsoleLog(string.format("Task ride for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task ride for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task ride for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "ride") 
    end,
    ["dirty"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      IsOnPlatform("main", true)
      SafeInvoke('HousingAPI/ActivateFurniture',
        LocalPlayer,
        Mutable.Furn.Bath.unique,
        Mutable.Furn.Bath.usepart,
        {
          cframe = CFrame.new(LocalPlayer.Character.HumanoidRootPart.CFrame.Position)
        }, 
        GetEquippedModel()
      )
      local deadline = os.clock() + 20
      repeat 
        task.wait(1)
      until not HasAilment("dirty") or os.clock() > deadline
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task dirty for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task dirty for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task dirty for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
        return		
      end        
      WriteConsoleLog(string.format("Task dirty for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task dirty for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task dirty for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "dirty")  
    end,
    ["walk"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local model = GetEquippedModel()
      local deadline = os.clock() + 60
      IsOnPlatform("main", true)
      task.wait(.25)
      SafeInvoke("AdoptAPI/HoldBaby", model)
      local hrp = LocalPlayer.Character.HumanoidRootPart
      local lockedpos = hrp.Position
      Mutable.Connections.WalkLock = RunService.RenderStepped:Connect(function()
        hrp.CFrame = CFrame.new(lockedpos) * (hrp.CFrame - hrp.CFrame.Position)
        LocalPlayer.Character.Humanoid:Move(Vector3.new(0, 0, -.1), false)  
      end)
      while os.clock() < deadline and HasAilment("walk") do
        task.wait(1)
      end
      Mutable.Connections.WalkLock:Disconnect()
      Mutable.Connections.WalkLock = nil
      SafeFire("AdoptAPI/EjectBaby", model)
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task walk for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task walk for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task walk for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
        return		
      end      
      WriteConsoleLog(string.format("Task walk for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task walk for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task walk for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "walk") 
    end,
    ["school"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("school")
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("main", true)
        EmulateLocation("School")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilment("school") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task school for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task school for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task school for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
          return		
        end        
        WriteConsoleLog(string.format("Task school for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task school for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task school for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "school", baby_has_ailment)
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["sleepy"] = function()
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      IsOnPlatform("main", true)
      SafeInvoke('HousingAPI/ActivateFurniture',
        LocalPlayer,
        Mutable.Furn.Bed.unique,
        Mutable.Furn.Bed.usepart,
        {
          cframe = CFrame.new(LocalPlayer.Character.HumanoidRootPart.CFrame.Position)
        },
        GetEquippedModel()
      )
      local deadline = os.clock() + 20
      repeat 
        task.wait(1)
      until not HasAilment("sleepy") or os.clock() > deadline
      if os.clock() > deadline then 
        WriteConsoleLog(string.format("Task sleepy for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task sleepy for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task sleepy for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
        return		
      end        
      WriteConsoleLog(string.format("Task sleepy for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task sleepy for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task sleepy for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "sleepy")  	
    end,
    ["mystery"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local ailments = Mutable.Modules.AilmentsClient.get_ailments_for_pet(pet)
      local seed = ailments.mystery.components.mystery.random_seed :: number
      SafeFire("AilmentsAPI/ChooseMysteryAilment", unpack({
        [1] = Mutable.ActualPet.unique,
        [2] = "mystery",
        [3] = 1,
        [4] = Mutable.Modules.get_ailment_slots(seed, ailments, pet)[1]
      }))
      task.wait(1)
      if not HasAilment("mystery") then
        WriteConsoleLog(string.format("Task mystery for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task mystery for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task mystery for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      end
    end,
    ["pizza_party"] = function() 
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("pizza_party")
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("main", true)
        EmulateLocation("PizzaShop")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilment("pizza_party") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task pizza-party for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task pizza-party for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task pizza-party for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
          return		
        end       
        WriteConsoleLog(string.format("Task pizza-party for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task pizza-party for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task pizza-party for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "pizza_party", baby_has_ailment)  
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["pet_me"] = function()
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      SafeFire("PetAPI/ReplicateActivePerformances", GetEquippedModel(), { ["FocusPet"] = true })
      task.wait(.15)
      SafeFire("AilmentsAPI/ProgressPetMeAilment", Mutable.ActualPet.unique)
      WriteConsoleLog(string.format("Task pet-me for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task pet-me for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
      WriteFileLog(string.format("Task pet-me for %s - Done", Mutable.ActualPet.remote), "DEBUG")
      Enstat(age, friendship, money, "pet_me")  
    end,
    -- ["snowman"] = function() end
    -- ["party_zone"] = function() end
    ['cat_cafe'] = function() -- also for baby
      local pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
      local cdata = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique] :: Str_T<string | number | boolean | { any }>
      local friendship = cdata.properties.friendship_level :: number
      local money = Mutable.Modules.ClientData.get("money") :: number
      local age = pet.pet_progression.age :: number
      local baby_has_ailment = HasAilmentBaby("cat_cafe")
      local _task = Mutable.LocationQueue.Enqueue(function()
        EmulateLocation("CatCafe")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilment("cat_cafe") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task cat-cafe for %s - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task cat-cafe for %s - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task cat-cafe for %s - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
          return		
        end       
        WriteConsoleLog(string.format("Task cat-cafe for %s - Done", Mutable.ActualPet.remote), string.format("🟩 Task cat-cafe for %s - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task cat-cafe for %s - Done", Mutable.ActualPet.remote), "DEBUG")
        Enstat(age, friendship, money, "cat_cafe", baby_has_ailment)  
      end)
      while not _task.completed do
        task.wait(1)
      end
    end
    -- ['diving_board'] = function() end
    -- ['leaf_pile'] = function() end
    -- ["rain_puddle"] = function() end 
    -- ['at_work'] = function() end
  }

  Constant.BabyAilments = {
    ["camping"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("camping")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("_camp", true)
        EmulateLocation("MainMap", LocalPlayer, "Default")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilmentBaby("camping") or os.clock() > deadline
        Gotopart("main")
        if os.clock() > deadline then 
          WriteConsoleLog("Task camping for baby - Out of limits", "🟥 Task camping for baby - Out of limits!", "DEBUG")
          WriteFileLog("Task camping for baby - Out of limits", "DEBUG")
          return		
        end		
        WriteConsoleLog("Task camping for baby - Done", "🟩 Task camping for baby - Done!", "DEBUG")
        WriteFileLog("Task camping for baby - Done", "DEBUG")
        EnstatBaby(money, "camping", pet_has_ailment, { age, friendship, })
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["hungry"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      if CountOfProduct("food", "apple") < 3 then
        if money == 0 then  
          WriteConsoleLog("No money to buy food", "⚠️ No money to buy food!", "DEBUG")
          WriteFileLog("No money to buy food", "DEBUG")
          return
        end
        local bc = if money > 20 then 20 else money

        SafeInvoke("ShopAPI/BuyItem",
          "food",
          "apple",
          {
            buy_count = bc
          }
        )
      end
      IsOnPlatform("main", true)
      local money = Mutable.Modules.ClientData.get("money") :: number
      local deadline = os.clock() + 14
      repeat 
        SafeInvoke("ToolAPI/ServerUseTool",
        InvGetCategoryUnique("food", "apple"),
          "END"
        )
        task.wait(.5)
      until not HasAilmentBaby("hungry") or os.clock() > deadline
      if os.clock() > deadline then 
        WriteConsoleLog("Task hungry for baby - Out of limits", "🟥 Task hungry for baby - Out of limits!", "DEBUG")
        WriteFileLog("Task hungry for baby - Out of limits", "DEBUG")
        return		
      end	
      WriteConsoleLog("Task hungry for baby - Done", "🟩 Task hungry for baby - Done!", "DEBUG")
      WriteFileLog("Task hungry for baby - Done", "DEBUG")
      EnstatBaby(money, "hungry")  
    end,
    ["thirsty"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      if CountOfProduct("food", "water") == 0 then
        if money == 0 then 
          WriteConsoleLog("No money to buy food", "⚠️ No money to buy food!", "DEBUG")
          WriteFileLog("No money to buy food", "DEBUG")
          return
        end			
        local bc = if money > 20 then 20 else money

        SafeInvoke("ShopAPI/BuyItem",
          "food",
          "water",
          {
            buy_count = bc
          }
        )
      end
      IsOnPlatform("main", true)
      local money = Mutable.Modules.ClientData.get("money") :: number
      local deadline = os.clock() + 14
      repeat			
        SafeInvoke("ToolAPI/ServerUseTool",
          InvGetCategoryUnique("food", "water"),
          "END"
          )
        task.wait(.5)
      until not HasAilmentBaby("thirsty") or os.clock() > deadline  
      if os.clock() > deadline then 
        WriteConsoleLog("Task thirsty for baby - Out of limits", "🟥 Task thirsty for baby - Out of limits!", "DEBUG")
        WriteFileLog("Task thirsty for baby - Out of limits", "DEBUG")
        return		
      end		
      WriteConsoleLog("Task thirsty for baby - Done", "🟩 Task thirsty for baby - Done!", "DEBUG")
      WriteFileLog("Task thirsty for baby - Done", "DEBUG")
      EnstatBaby(money, "thirsty")  
    end,
    ["sick"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("sick")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("main", true)
        EmulateLocation("Hospital")
        SafeInvoke("HousingAPI/ActivateInteriorFurniture",
          "f-14",
          "UseBlock",
          "Yes",
          LocalPlayer.Character
        )
        task.wait(3)
        local deadline = os.clock() + 5
        repeat 
          task.wait(1)
        until not HasAilmentBaby('sick') or os.clock() > deadline 
        if os.clock() > deadline then 
          WriteConsoleLog("Task sick for baby - Out of limits", "🟥 Task sick for baby - Out of limits!", "DEBUG")
          WriteFileLog("Task sick for baby - Out of limits", "DEBUG")
          return		
        end    
        WriteConsoleLog("Task sick for baby - Done", "🟩 Task sick for baby - Done!", "DEBUG")
        WriteFileLog("Task sick for baby - Done", "DEBUG")
        EnstatBaby(money, "sick", pet_has_ailment, { age, friendship, }) 
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["bored"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("bored")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("_playground", true)
        EmulateLocation("MainMap", LocalPlayer, "Default")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilmentBaby("bored") or os.clock() > deadline
        Gotopart("main")
        if os.clock() > deadline then 
          WriteConsoleLog("Task bored for baby - Out of limits", "🟥 Task bored for baby - Out of limits!", "DEBUG")
          WriteFileLog("Task bored for baby - Out of limits", "DEBUG")
          return		
        end		
        WriteConsoleLog("Task bored for baby - Done", "🟩 Task bored for baby - Done!", "DEBUG")
        WriteFileLog("Task bored for baby - Done", "DEBUG")
        EnstatBaby(money, "bored", pet_has_ailment, { age, friendship, }) 
      end)
      while not _task.completed do
        task.wait(1)
      end 
    end,
    ["salon"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("salon")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("main", true)
        EmulateLocation("Salon")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilmentBaby("salon") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog("Task salon for baby - Out of limits", "🟥 Task salon for baby - Out of limits!", "DEBUG")
          WriteFileLog("Task salon for baby - Out of limits", "DEBUG")
          return		
        end		
        WriteConsoleLog("Task salon for baby - Done", "🟩 Task salon for baby - Done!", "DEBUG")
        WriteFileLog("Task salon for baby - Done", "DEBUG")
        EnstatBaby(money, "salon", pet_has_ailment, { age, friendship, }) 
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["beach_party"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("beach_party")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("_beach", true)
        EmulateLocation("MainMap", LocalPlayer, "Default")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilmentBaby("beach_party") or os.clock() > deadline
        Gotopart("main")
        if os.clock() > deadline then 
          WriteConsoleLog("Task beach-party for baby - Out of limits", "🟥 Task beach-party for baby - Out of limits!", "DEBUG")
          WriteFileLog("Task beach-party for baby - Out of limits", "DEBUG")
          return		
        end		
        WriteConsoleLog("Task beach-party for baby - Done", "🟩 Task beach-party for baby - Done!", "DEBUG")
        WriteFileLog("Task beach-party for baby - Done", "DEBUG")
        EnstatBaby(money, "beach_party", pet_has_ailment, { age, friendship, })  
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ["dirty"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      task.spawn(function() 
        IsOnPlatform("main", true)
        SafeInvoke('HousingAPI/ActivateFurniture',
          LocalPlayer,
          Mutable.Furn.Bath.unique,
          Mutable.Furn.Bath.usepart,
          {
            cframe = CFrame.new(LocalPlayer.Character.HumanoidRootPart.CFrame.Position)
          },
          LocalPlayer.Character
        )
      end)
      local deadline = os.clock() + 20
      repeat 
        task.wait(1)
      until not HasAilmentBaby("dirty") or os.clock() > deadline
      SafeFire("AdoptAPI/ExitSeatStates")
      if os.clock() > deadline then 
        WriteConsoleLog("Task dirty for baby - Out of limits", "🟥 Task dirty for baby - Out of limits!", "DEBUG")
        WriteFileLog("Task dirty for baby - Out of limits", "DEBUG")
        return		
      end		
      WriteConsoleLog("Task dirty for baby - Done", "🟩 Task dirty for baby - Done!", "DEBUG")
      WriteFileLog("Task dirty for baby - Done", "DEBUG")
      EnstatBaby(money, "dirty")  
    end,
    ["school"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("school")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("main", true)
        EmulateLocation("School")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilmentBaby("school") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog("Task school for baby - Out of limits", "🟥 Task school for baby - Out of limits!", "DEBUG")
          WriteFileLog("Task school for baby - Out of limits", "DEBUG")
          return		
        end		
        WriteConsoleLog("Task school for baby - Done", "🟩 Task school for baby - Done!", "DEBUG")
        WriteFileLog("Task school for baby - Done", "DEBUG")
        EnstatBaby(money, "school", pet_has_ailment, { age, friendship, })  
      end)
      while not _task.completed do
        task.wait(1)
      end        
    end,
    ["sleepy"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      task.spawn(function() 
        IsOnPlatform("main", true)
        SafeInvoke('HousingAPI/ActivateFurniture',
          LocalPlayer,
          Mutable.Furn.Bed.unique,
          Mutable.Furn.Bed.usepart,
          {
            cframe = CFrame.new(LocalPlayer.Character.HumanoidRootPart.CFrame.Position)
          },
          LocalPlayer.Character
        )
      end)
      local deadline = os.clock() + 20
      repeat 
        task.wait(1)
      until not HasAilmentBaby("sleepy") or os.clock() > deadline
      SafeFire("AdoptAPI/ExitSeatStates")
      if os.clock() > deadline then 
        WriteConsoleLog("Task sleepy for baby - Out of limits", "🟥 Task sleepy for baby - Out of limits!", "DEBUG")
        WriteFileLog("Task sleepy for baby - Out of limits", "DEBUG")
        return		
      end		
      WriteConsoleLog("Task sleepy for baby - Done", "🟩 Task sleepy for baby - Done!", "DEBUG")
      WriteFileLog("Task sleepy for baby - Done", "DEBUG")
      EnstatBaby(money, "sleepy")  
    end,
    ["pizza_party"] = function() 
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("pizza_party")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        IsOnPlatform("main", true)
        EmulateLocation("PizzaShop")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilmentBaby("pizza_party") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog("Task pizza-party for baby - Out of limits", "🟥 Task pizza-party for baby - Out of limits!", "DEBUG")
          WriteFileLog("Task pizza-party for baby - Out of limits", "DEBUG")
          return		
        end		
        WriteConsoleLog("Task pizza-party for baby - Done", "🟩 Task pizza-party for baby - Done!", "DEBUG")
        WriteFileLog("Task pizza-party for baby - Done", "DEBUG")
        EnstatBaby(money, "pizza_party", pet_has_ailment, { age, friendship, })  
      end)
      while not _task.completed do
        task.wait(1)
      end
    end,
    ['cat_cafe'] = function() -- also for baby
      local money = Mutable.Modules.ClientData.get("money") :: number
      local pet_has_ailment = HasAilment("pizza_party")
      local age, friendship
      if pet_has_ailment then
        age = Mutable.Modules.ClientData.get("pet_char_wrappers")[1].pet_progression.age :: number
        friendship = Mutable.Modules.ClientData.get("inventory").pets[Mutable.ActualPet.unique].properties.friendship_level :: number
      end      
      local _task = Mutable.LocationQueue.Enqueue(function()
        EmulateLocation("CatCafe")
        local deadline = os.clock() + 60
        repeat 
          task.wait(1)
        until not HasAilmentBaby("cat_cafe") or os.clock() > deadline
        if os.clock() > deadline then 
          WriteConsoleLog(string.format("Task cat-cafe for baby - Out of limits", Mutable.ActualPet.remote), string.format("🟥 Task cat-cafe for baby - Out of limits!", Mutable.ActualPet.remote), "DEBUG")
          WriteFileLog(string.format("Task cat-cafe for baby - Out of limits", Mutable.ActualPet.remote), "DEBUG") 
          return		
        end       
        WriteConsoleLog(string.format("Task cat-cafe for baby - Done", Mutable.ActualPet.remote), string.format("🟩 Task cat-cafe for baby - Done!", Mutable.ActualPet.remote), "DEBUG")
        WriteFileLog(string.format("Task cat-cafe for baby - Done", Mutable.ActualPet.remote), "DEBUG")
        EnstatBaby(money, 'cat_cafe', pet_has_ailment, { age, friendship })  
      end)
      while not _task.completed do
        task.wait(1)
      end
    end
  }

  
  --[[=====================]]
  --[[=====================]]
  --[[-Script Initialization-]]

  ;(function() 
    print("[+] Setting up the client..")
    --[[ Script init & attempt handler]]
    
    pcall(function() -- no InitHandler cuz if function fails script still can work
      makefolder("Arcanic")
      writefile("Arcanic/arcsrcplate.png", game:HttpGet("https://i.imageupload.app/c9bee1997f3764331ed4.png"))
      _G.asset = getcustomasset("Arcanic/arcsrcplate.png") or ""
    end)

    task.spawn(Avatar)
    
    _InitHandler(LoadModules)
    
    Mutable.StateDB.starter_value = Mutable.Modules.ClientData.get("money") or 0
    Mutable.StateDB.event_starter_value = Mutable.Modules.ClientData.get("candy_2026") or 0

    _InitHandler(function() 
      while LocalPlayer.PlayerGui.AssetLoadUI.Enabled do
        task.wait(1)
      end
      if not LocalPlayer.Character then
        SafeInvoke("TeamAPI/ChooseTeam", "Parents", { source_for_logging="intro_sequence" })
        task.wait(1)
        Mutable.Modules.UIManager.set_app_visibility("MainMenuApp", false)
        Mutable.Modules.UIManager.set_app_visibility("NewsApp", false)
        Mutable.Modules.UIManager.set_app_visibility("DialogApp", false)
        task.wait(2)
      end

      Mutable.Modules.UIManager.set_app_visibility("StarRewardsApp", false)
      SafeFire("PayAPI/DisablePopups")

    end)

    _InitHandler(function() 
      SafeFire("SettingsAPI/SetSetting", "tutorial_completed", true)
      SafeFire("SettingsAPI/SetSetting", "pet_radial_menu", true)
      SafeFire("SettingsAPI/SetSetting", "use_ailments_monitor", true)
      SafeFire("SettingsAPI/SetSetting", "pet_can_auto_exit_furniture", true)
      SafeFire("SettingsAPI/SetSetting", "family_requests", 3)
      SafeFire("SettingsAPI/SetSetting", "party_requests", 3)
      SafeFire("SettingsAPI/SetSetting", "trade_requests", 2)
      SafeFire("SettingsAPI/SetSetting", "background_music_volume", 0)
    end)

    _InitHandler(CheckDualPetSub)

    _InitHandler(License)

    _InitHandler(function() 
      InitPart("main", Constant.Parts["main"])
      InitPart("_camp", Constant.Parts["_camp"])
      InitPart("_playground", Constant.Parts["_playground"])
      InitPart("_beach", Constant.Parts["_beach"])
    end)

    pcall(Mutable.Modules.HouseClient.lock_door)

    _InitHandler(InitFurniture)
    
    pcall(ToggleStatsPopup)

    _InitHandler(function() 
      RunService:Set3dRenderingEnabled(_G.InternalConfig.OptimizationDLib.Rendering)  
    end)


    pcall(function()
      UIS.InputBegan:Connect(function(input, is_typing)
      if is_typing then return end
        if input.KeyCode == Enum.KeyCode.U then
          ToggleStatsPopup()
        end
      end)
    end) 

    LocalPlayer.Idled:Connect(function()
      task.spawn(function() 
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
      end)
    end)

    Mutable.Registry.RunTask("runtime_1_s_deadline_updates", function() 
      while task.wait(1) do
        Mutable.Farmed.time += 1.
        UpdateGui("timer", FormatTime(Mutable.Farmed.time))
      end
    end)

    Mutable.Registry.RunTask('looping_currency_update', function()
      while true do
        pcall(CalculateMoney)
        pcall(Mutable.Event.CalculateCurrency)
        task.wait(60)
      end
    end)

    Mutable.Registry.RunTask("__init_cooldown_handler_internal", __InitCooldownHandler)
    _InitHandler(setfpscap, _G.InternalConfig.OptimizationDLib.FPSCap)

    print('[+] Client setup done.')
  end)()


  if _G.InternalConfig.UtilitiesDLib.AutoReconnect then
    NetworkClient.ChildRemoved:Connect(function()
      while not CheckInternet() do
        WriteConsoleLog("No internet. Waiting", "No internet. Waiting..", "DEBUG")
        WriteFileLog("No internet. Waiting", "DEBUG")
        task.wait(5)
      end
      if queue_on_teleport then
        queue_on_teleport([[ 
          repeat task.wait(1) until game:IsLoaded()
          _G.Config = _G.Config
          loadstring(game:HttpGet("https://raw.githubusercontent.com/test-script-pidoras/sdoigfipossf/refs/heads/main/src.lua"))()
        ]])
      end
      TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId  , LocalPlayer)
    end)
  end             
  
  if _G.InternalConfig.Event.PlayGhostClustersMinigame then
    InitCooldown('Event', "play_ghost_clusters_minigame", "ghost_clusters_minigame_handler")
    Mutable.Registry.RegisterTask("ghost_clusters_minigame_handler", function()

      local timestamp = Mutable.Modules.LiveOpsTime.get_time_until(Mutable.Modules.ClientData.get('ghost_clusters_cycle_timestamp').timestamp)
      if timestamp > 40 then
        SetCooldown('Event', 'play_ghost_clusters_minigame', timestamp-35)
        print('[Event] Ghost Clusters starts in: ' .. tostring(timestamp))
        return
      end 
      _G.InternalConfig.MinigameLockdown = true
      local deadline = os.clock() + 60
      repeat
        task.wait(1)
      until Mutable.Modules.MinigameClientManager.get('ghost_clusters').minigame_state:get("players_loading") or deadline < os.clock()
      SafeFire("MinigameAPI/AttemptJoin", "ghost_clusters", true)

      local jdeadline = os.clock() + 20 
      repeat
        task.wait(1)
        local mcm = Mutable.Modules.MinigameClientManager.get('ghost_clusters')
      until mcm and mcm.instanced_minigame and mcm.instanced_minigame.minigame_id or jdeadline < os.clock()

      if jdeadline < os.clock() then
        _G.InternalConfig.MinigameLockdown = false
        Webhook('Event Watchdog', "**[ALERT]:** Failed to join **Ghost Clusters** minigame. (Ghost Clusters Minigame Handler)")
        WriteConsoleLog('[Event] Failed to join Ghost Clusters minigame', "[-]:[Event] Failed to join Ghost Clusters minigame.", "ERROR")
        WriteFileLog('[Event] Failed to join Ghost Clusters minigame', "ERROR")
        SetCooldown('Event', 'play_ghost_clusters_minigame', 300)
        return
      end

      local token = HttpService:GenerateGUID(false) 
      local mcm = Mutable.Modules.MinigameClientManager.get("ghost_clusters")
      local minigame_id = mcm.instanced_minigame.minigame_id
      local folder = workspace:FindFirstChild("GhostClustersVisuals")
      if not folder then 
        repeat 
          task.wait(1)
        until workspace:FindFirstChild("GhostClustersVisuals")
      end
      folder = workspace:FindFirstChild("GhostClustersVisuals")


      SafeInvoke("ToolAPI/Equip",  
        InvGetCategoryUnique('toys', 'halloween_2026_ghost_vacuum'),
        {
          use_sound_delay = true,
          equip_as_last = false
        }
      )
      while task.wait(.5) do
        if GetLocation() == "HauntedManor" then
          break
        end
        local ghost = Mutable.Event.GetGhost(folder)
        if not ghost then continue end
        
        while Mutable.Event.EnsureModel(ghost, folder) do
          Mutable.Event.EnsureGhostRange(ghost, folder)
            SafeFire("MinigameAPI/MessageServer", minigame_id,
              "start_contribute",
              { ghost_id = ghost:GetAttribute("GhostClustersId"), use_token = token }
            )
          task.wait(.05)
        end	
      end
      task.wait(4)
      local cycle_time = Mutable.Modules.LiveOpsTime.get_time_until(Mutable.Modules.ClientData.get('ghost_clusters_cycle_timestamp').timestamp)

      if GetLocation() == "HauntedManor" then
        Webhook('Event Watchdog', "**[SUCCESS]:** Successfully played **Ghost Clusters** minigame. (Ghost Clusters Minigame Handler)")
        WriteConsoleLog('[Event] Successfully played Ghost Clusters minigame', "[+]:[Event] Successfully played Ghost Clusters minigame.", "DEBUG")
        WriteFileLog('[Event] Successfully played Ghost Clusters minigame', "DEBUG")
        SetCooldown('Event', 'play_ghost_clusters_minigame', cycle_time)
      else
        Webhook('Event Watchdog', "**[ALERT]:** Failed to play **Ghost Clusters** minigame. (Ghost Clusters Minigame Handler)")
        WriteConsoleLog('[Event] Failed to play Ghost Clusters minigame', "[-]:[Event] Failed to play Ghost Clusters minigame.", "ERROR")
        WriteFileLog('[Event] Failed to play Ghost Clusters minigame', "ERROR")
        SetCooldown('Event', 'play_ghost_clusters_minigame', cycle_time)
      end
      _G.InternalConfig.MinigameLockdown = false
    end,
    function()
      return Mutable.Cooldown.Event.play_ghost_clusters_minigame[1] == 0
    end,
    function() 
      SetCooldown('Event', 'play_ghost_clusters_minigame', 5)
      _G.InternalConfig.MinigameLockdown = false
    end)
    task.wait(1)
  end

  if _G.InternalConfig.Event.FeedStrayCat then
    InitCooldown('Event', "feed_stray_cat", "feed_stray_cat_handler")
    Mutable.Registry.RegisterTask("feed_stray_cat_handler", function() 
      local manager = Mutable.Modules.ClientData.get("halloween_2026_stray_cat_manager")
      local fed_today = manager.fed_today
      if not fed_today then
        local _task = Mutable.LocationQueue.Enqueue(function() 
          if CountOfProduct("food", "apple") == 0 then
            SafeInvoke("ShopAPI/BuyItem",
              "food",
              "apple",
              {
                buy_count = 1
              }
            )
            task.wait(1)
          end
          local food = InvGetCategoryUnique("food", "apple")

          EmulateLocation("MainMap", LocalPlayer, "Halloween2026")
          IsOnPlatform('_stray_cat', true)
          task.wait(2)

          local res = ReplicatedStorage.adoptme_new_net["Halloween2026/StrayCatGiftFood"]:InvokeServer(
            {
              unique = food
            }
          )
          task.wait(1.5)
          if not res.ok then
            local reason = res.reason or "undefined"
            Webhook('Event Watchdog', string.format("**[ALERT]:** Failed to feed `Stray Cat` **[reason=%s]**. (Feed Stray Cat)", reason))
            WriteConsoleLog(string.format('[Event] Failed to feed stray cat [reason=%s]', reason), string.format("[-]:[Event] Failed to feed stray cat [reason=%s]", reason), "ERROR")
            WriteFileLog(string.format('[Event] Failed to feed stray cat [reason=%s]', reason), "ERROR")
            SetCooldown('Event', 'feed_stray_cat', 5)
          else
            Webhook('Event Watchdog', "**[SUCCESS]:** `Stray Cat` has been fed. (Feed Stray Cat)")
            WriteConsoleLog('[Event] Stray cat has been fed', "[+]:[Event] Stray cat has been fed.", "DEBUG")
            WriteFileLog('[Event] Stray cat has been fed', "DEBUG")
            SetCooldown('Event', 'feed_stray_cat', 2) -- специфально чтобы скрипт пошел до цикла else и там кулдаун GetNextCycle.. 
            Mutable.Event.CalculateCurrency()
          end
        end)
        while not _task.completed do
          task.wait(1)
        end
      else
        local next_cycle = Mutable.Event.GetNextStrayCatCycle() + 5
        print('[Event] Next Stray Cat cycle in ' .. tostring(next_cycle))
        SetCooldown('Event', 'feed_stray_cat', next_cycle)
      end
    end,
    function()
      return Mutable.Cooldown.Event.feed_stray_cat[1] == 0
    end,
    function()
      SetCooldown('Event', 'feed_stray_cat', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.Event.AutoUseCryptKeys then
    InitCooldown('Event', "handle_crypt_keys", "event_coffin_crypt_keys_handler")
    Mutable.Registry.RegisterTask("event_coffin_crypt_keys_handler", function() 
      if Mutable.Event.GetRustyCryptKeys() == 0 then
        WriteConsoleLog("[Event] No rusty keys found", "[Event] No rusty keys found.", "DEBUG")
        WriteFileLog("[Event] No rusty keys found" ,"DEBUG")
        SetCooldown('Event', 'handle_crypt_keys', 120)
        return 
      end

      local _task = Mutable.LocationQueue.Enqueue(function()
        EmulateLocation('TheCrypt')

        while true do
          
          local cur_floor = Mutable.Event.GetCurrentFloor()
          if cur_floor == 5 then
            break
          end
          
          if Mutable.Event.GetRustyCryptKeys() == 0 then
            SetCooldown('Event', 'handle_crypt_keys', 120)
            return 
          end

          local twing_caffins, ladder
          if Count(Mutable.Event.GetCryptTwigs()) then
            twing_caffins, ladder = Mutable.Event.GetLadderAndTwingsOnFloor(cur_floor)
          else
            ladder = Mutable.Modules.CryptLayout.get_ladder_slot(cur_floor)
          end
          
          if twing_caffins and #twing_caffins > 0 then
            for _, index in ipairs(twing_caffins) do
              if Mutable.Event.GetRustyCryptKeys() == 0 then 
                break 
              end

              Mutable.Event.EquipRustyCryptKey()
              local res = ReplicatedStorage.adoptme_new_net["Halloween2026/UnlockPadlock"]:InvokeServer({
                padlock_index = index, 
                floor_index = cur_floor 
              })
              task.wait(0.4) 
              if res and res.ok then
                Webhook('Event Watchdog', ("**[SUCCESS]:** Padlock opened [floor=**%d** / caffin=**%d** / reward=**twig** ]. (Crypt Keys Handler)"):format(cur_floor, index))
                WriteConsoleLog(("[Event] Padlock opened [floor=%d / caffin=%d / reward=twig]"):format(cur_floor, index), ("[+]:[Event] Padlock opened [floor=%d / caffin=%d / reward=twig]."):format(cur_floor, index), 'DEBUG')
                WriteFileLog(("[Event] Padlock opened [floor=%d / caffin=%d / reward=twig]"):format(cur_floor, index), 'DEBUG')
              else
                local reason = res.reason or "undefined"
                if reason == "too_far" then
                  EmulateLocation("TheCrypt")
                end
                Webhook('Event Watchdog', ("**[ALERT]:** Failed to open padlock [floor=%d / caffin=%d / reward=twig / reason=%s]. (Crypt Keys Handler)"):format(cur_floor, index, reason))
                WriteConsoleLog(("**[Event]:** Failed to open padlock [floor=%d / caffin=%d / reward=twig / reason=%s]"):format(cur_floor, index, reason), ("[-]:[Event]: Failed to open padlock [floor=%d / caffin=%d / reward=twig / reason=%s]"):format(cur_floor, index, reason), 'DEBUG')
                WriteFileLog(("**[Event]:** Failed to open padlock [floor=%d / caffin=%d / reward=twig / reason=%s]"):format(cur_floor, index, reason), 'DEBUG')
              end
            end
          end

          Mutable.Event.EquipRustyCryptKey()
          if Mutable.Event.GetRustyCryptKeys() > 0 then
            local res = ReplicatedStorage.adoptme_new_net["Halloween2026/UnlockPadlock"]:InvokeServer({
              padlock_index = ladder, 
              floor_index = cur_floor 
            })
            if res and res.ok then
              Webhook('Event Watchdog', ("**[SUCCESS]:** Padlock opened [floor=**%d** / caffin=**%d** / reward=**ladder**]. (Crypt Keys Handler)"):format(cur_floor, ladder))
              WriteConsoleLog(("[Event] Padlock opened [floor=%d / caffin=%d / reward=ladder]"):format(cur_floor, ladder), ("[+]:[Event] Padlock opened [floor=%d / caffin=%d / reward=ladder]."):format(cur_floor, ladder), 'DEBUG')
              WriteFileLog(("[Event] Padlock opened [floor=%d / caffin=%d / reward=ladder]"):format(cur_floor, ladder), 'DEBUG')
            else
              local reason = res.reason or "undefined"
              if reason == "too_far" then
                EmulateLocation("TheCrypt")
              end
              Webhook('Event Watchdog', ("**[ALERT]:** Failed to open padlock [floor=**%d** / caffin=**%d** / reward=**ladder** / reason=**%s**]. (Crypt Keys Handler)"):format(cur_floor, ladder, reason))
              WriteConsoleLog(("[Event] Failed to open padlock [floor=%d / caffin=%d / reward=ladder / reason=%s]"):format(cur_floor, ladder, reason), ("[-]:[Event] Failed to open padlock [floor=%d / caffin=%d / reward=ladder / reason=%s]"):format(cur_floor, ladder, reason), 'DEBUG')
              WriteFileLog(("[Event] Failed to open padlock [floor=%d / caffin=%d / reward=ladder / reason=%s]"):format(cur_floor, ladder, reason), 'DEBUG')
            end
            task.wait(1.5)
          end
        end
        task.wait(1)
        if Mutable.Event.GetCurrentFloor() == 5 then
          local res = Mutable.Event.ClaimTombSpider()
          if res and res.ok then 
            Webhook('Event Watchdog', "**[SUCCESS]:** `Tomp Spider` successfully claimed. (Crypt Keys Handler)")
            WriteConsoleLog("[Event] <Tomp Spider> successfully claimed", "[+]:[Event] <Tomp Spider> successfully claimed.", 'DEBUG')
            WriteFileLog("[Event] <Tomp Spider> successfully claimed", 'DEBUG')
            SetCooldown('Event', 'handle_crypt_keys', 2)
          else
            local reason = res.reason or "undefined"
            Webhook('Event Watchdog', ("**[ALERT]:** Failed to claim `Tomb Spider` [reason=**%s**]. (Crypt Keys Handler)"):format(reason))
            WriteConsoleLog(("[Event] Failed to claim <Tomb Spider> [reason=%s]"):format(reason), ("[-]:[Event] Failed to claim <Tomb Spider> [reason=%s]."):format(reason):format(reason), 'DEBUG')
            WriteFileLog(("[Event] Failed to claim <Tomb Spider> [reason=%s]"):format(reason), 'DEBUG')
            SetCooldown('Event', 'handle_crypt_keys', 5)
          end
        end
        SetCooldown('Event', 'handle_crypt_keys', 120)
      end)
      while not _task.completed do
        task.wait(1)
      end
      SetCooldown('Event', 'handle_crypt_keys', 30)
    end,
    function() 
      return Mutable.Cooldown.Event.handle_crypt_keys[1] == 0
    end,
    function() 
      SetCooldown('Event', 'handle_crypt_keys', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.Event.AutoUseTwigs then
    InitCooldown('Event', "try_use_twigs_after", "event_hotel_twigs_handler")
    Mutable.Registry.RegisterTask("event_hotel_twigs_handler", function()
      local twigs_contributed = Mutable.Modules.ClientData.get("halloween_2026_jacobean_pigeon_nest_manager")['twigs_contributed']
      
      if twigs_contributed == 8 then 
        Mutable.Registry.UnregisterTask("event_hotel_twigs_handler")
        Mutable.Cooldown.Event.try_use_twigs_after = nil
        return
      end
      local twigs = Mutable.Event.GetCryptTwigs()
    
      if Count(twigs) == 0 then
        WriteConsoleLog("[Event] No twigs found", "[Event] No twigs found.", "DEBUG")
        WriteFileLog("[Event] No twigs found" ,"DEBUG")
        SetCooldown('Event', 'try_use_twigs_after', 120)
        return 
      end  

      local _task = Mutable.LocationQueue.Enqueue(function()
        EmulateLocation("HauntedHotel")
                
        for k,_ in twigs do
          local count = Mutable.Modules.ClientData.get("halloween_2026_jacobean_pigeon_nest_manager")['twigs_contributed']
          if count == 8 then 
            break 
          end
          local res = ReplicatedStorage.adoptme_new_net["Halloween2026/JacobeanPigeonNestContributeTwig"]:InvokeServer(
            {
              unique = k
            }
          )
          task.wait(.2)
          if not res.ok then
            local reason = res.reason or "undefined"
            if reason == "too_far" then
              EmulateLocation("HauntedHotel")
            end
            Webhook('Event Watchdog', string.format("**[ALERT]:** Failed to contribute twig **[reason=%s]**. (Hotel Twigs Handler)", reason))
            WriteConsoleLog(string.format('[Event] Failed to contribute twig [reason=%s]', reason), string.format("[-]:[Event] Failed to contribute twig [reason=%s]", reason), "ERROR")
            WriteFileLog(string.format('[Event] Failed to contribute twig [reason=%s]', reason), "ERROR")
          else
            Webhook('Event Watchdog', "**[SUCCESS]:** twig placed. (Hotel Twigs Handler)")
            WriteConsoleLog('[Event] twig placed', "[+]:[Event] Stray cat has been fed.", "DEBUG")
            WriteFileLog('[Event] twig placed', "DEBUG")
          end
        end
      end)
      while not _task.completed do
        task.wait(1)
      end      
      SetCooldown('Event', 'try_use_twigs_after', 2)
    end,
    function() 
      return Mutable.Cooldown.Event.try_use_twigs_after[1] == 0
    end,  
    function() 
      SetCooldown('Event', 'try_use_twigs_after', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.Event.AutoCollectDailies then
    InitCooldown('Event', "try_collect_dailies", "event_dailies_autocollect_handler")
    Mutable.Registry.RegisterTask("event_dailies_autocollect_handler", function()
      local dailies_count = Count(Mutable.Modules.ClientData.get("dailies_manager")['serialized_tabs']['halloween_2026'].active_dailies)

      ReplicatedStorage.adoptme_new_net["adoptme_new.modules.Dailies.DailiesNetService:9"]:FireServer("halloween_2026")  
      ReplicatedStorage.adoptme_new_net["adoptme_new.modules.Dailies.DailiesNetService:15"]:FireServer("halloween_2026")  
      task.wait(1)
      
      local halloween = Mutable.Modules.ClientData.get("dailies_manager")['serialized_tabs']['halloween_2026']
      local new_dailies_count = Count(halloween.active_dailies)
      local d_count = dailies_count - new_dailies_count
      if dailies_count > new_dailies_count then
        local text = ""

        if new_dailies_count == 0 then
          text = "All halloween dailies completed"
        else
          text = ("%d %s completed"):format(d_count, if d_count > 1 then 'halloween dailies' else 'halloween daily')
        end
        WriteConsoleLog(text, "[📋] " .. text .. '.', "DEBUG")
        WriteFileLog(text, "DEBUG")
        Webhook("Event Watchdog", text)
      end

      if not halloween.active_dailies or new_dailies_count == 0 then
        local tms = Mutable.Modules.LiveOpsTime.get_time_until(halloween.next_distribution_timestamp) or 3600
        SetCooldown('Event', 'try_collect_dailies', tms + 5)
        return
      end
      SetCooldown('Event', 'try_collect_dailies', 120)
    end,
    function() 
      return Mutable.Cooldown.Event.try_collect_dailies[1] == 0
    end,  
    function() 
      SetCooldown('Event', 'try_collect_dailies', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.PetFarmDLib.Enabled then
    InitCooldown('AutoFarm', 'pet_auto_farm', 'pet_auto_farm_handler')
    Mutable.Registry.RegisterTask("pet_auto_farm_handler", function()
      if Count(Mutable.Modules.ClientData.get("inventory").pets :: Inv_Cat) < 1 or _G.InternalConfig.MinigameLockdown then
        SetCooldown('AutoFarm', 'pet_auto_farm', 50)
        return
      end
      local _task = Mutable.TaskQueue.Enqueue(function()
        local flag = false
        local kitty_unique = InvGetCategoryUnique("pets", "2d_kitty")          
        if _G.InternalConfig.PetFarmDLib.Detect2D_Kitty and kitty_unique then
          if kitty_unique == Mutable.ActualPet.unique and kitty_unique == CurUnique() then
            flag = true
          else
            SafeInvoke("ToolAPI/Equip",  
              kitty_unique,
              {
                use_sound_delay = true,
                equip_as_last = false
              }
            )
            WriteConsoleLog("2D-kitty detected and equiped", "[🐱] 2D-kitty detected and equiped.", "DEBUG")
            WriteFileLog("2D-kitty detected and equiped", "DEBUG")
            __Notify("Info", "2D-kitty detected and equiped", Constant.NotifyDuration['INFO'])
            flag = true
            _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = false
            _G.InternalConfig.PetFarmDLib.KittyInUse = true
            task.wait(1)
            PetUpdate() 
          end
        else
          _G.InternalConfig.PetFarmDLib.KittyInUse = false
        end
        if not PetExists(Mutable.ActualPet.unique or "") then
          ClearPetFarmCache()
        end
        if not _G.InternalConfig.PetFarmDLib.KittyInUse then
          if Mutable.ActualPet.unique and (not Equipped() or Mutable.ActualPet.unique ~= CurUnique()) then
            if Mutable.ActualPet.remote == "practice_dog" and _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then 
              ClearPetFarmCache() 
            else
              SafeInvoke("ToolAPI/Equip",
                Mutable.ActualPet.unique, 
                {
                  use_sound_delay = true,
                  equip_as_last = false
                }
              )
              WriteConsoleLog(string.format("Pet has been changed. Switching back to: %s", Mutable.ActualPet.remote or "no pet info"), string.format("[🐶] Pet has been changed. Switching back to: %s", Mutable.ActualPet.remote or "no pet info"), "DEBUG")
              WriteFileLog(string.format("Pet has been changed. Switching back to: %s", Mutable.ActualPet.remote or "no pet info"), "DEBUG")
              __Notify("Warning", string.format("Pet has been changed. Switching back to: %s", Mutable.ActualPet.remote or "no pet info"), Constant.NotifyDuration['WARNING'])
              flag = true
              task.wait(.5)
              Mutable.ActualPet.wrapper = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper
            end
          end
        end
        if _G.InternalConfig.PetFarmDLib.UseBonusBucksPotions and Mutable.ActualPet.unique and not Mutable.ActualPet.is_egg then
          pcall(GetBonusBucksPotionToPet)
        end
        if _G.InternalConfig.PetFarmDLib.UseBonusAgingPotions and Mutable.ActualPet.unique and not Mutable.ActualPet.is_egg then
          pcall(GetBonusAgingPotionToPet)
        end
        if not Mutable.ActualPet.unique or _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then
          local owned_pets = GetOwnedPets()
          if _G.InternalConfig.PetFarmDLib.FarmPriority == "pets" then	
            if _G.InternalConfig.PetFarmDLib.PotionFarm then
              for _, r in ipairs(Constant.ReversedRarities) do
                for k,v in pairs(owned_pets) do
                  if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and not (v.name:lower()):match("egg") and v.age == 6 and v.rarity == r then
                    SafeInvoke("ToolAPI/Equip",
                      k,
                      {
                        use_sound_delay = true,
                        equip_as_last = false
                      }
                    )
                    flag = true
                    _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = false
                    break
                  end
                end
                if flag then break end
              end
            end
            if not flag then
              for _,r in ipairs(Constant.ReversedRarities) do
                for k,v in pairs(owned_pets) do
                  if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and not (v.name:lower()):match("egg") and v.age < 6 and v.rarity == r then
                    SafeInvoke("ToolAPI/Equip",
                      k,
                      {
                        use_sound_delay = true,
                        equip_as_last = false
                      }
                    )
                    flag = true
                    _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = false
                    break
                  end
                end
                if flag then break end
              end
            end 
            if not flag then 
              if _G.InternalConfig.PetFarmDLib.OppositeFarm then
                if not _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then
                  WriteConsoleLog("No pets to farm depending on filter. Running opposite farm filter", "⚙️ No pets to farm depending on filter. Running opposite farm filter.", "DEBUG")
                  WriteFileLog("No pets to farm depending on filter. Running opposite farm filter", "DEBUG")
                  __Notify("Info", "No pets to farm depending on filter. Running opposite farm filter.", Constant.NotifyDuration['INFO'])
                  for _, r in ipairs(Constant.ReversedRarities) do
                    for k,v in pairs(owned_pets) do
                      if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and not (v.name:lower()):match("egg") and v.age == 6 and v.rarity == r then
                        SafeInvoke("ToolAPI/Equip",
                          k,
                          {
                            use_sound_delay = true,
                            equip_as_last = false
                          }
                        )
                        flag = true
                        _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = false
                        _G.InternalConfig.PetFarmDLib.random_farm = true
                        break
                      end
                    end
                    if flag then break end
                  end
                  if not flag then
                    for _, r in ipairs(Constant.ReversedRarities) do
                      for k,v in pairs(owned_pets) do
                        if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and (v.name:lower()):match("egg") and v.rarity == r then
                          SafeInvoke("ToolAPI/Equip",
                            k,
                            {
                              use_sound_delay = true,
                              equip_as_last = false
                            }
                          )
                          flag = true
                          _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = true
                          _G.InternalConfig.PetFarmDLib.random_farm = true
                          break             
                        end
                      end
                      if flag then break end
                    end
                  end
                  if not flag then
                    for _, r in ipairs(Constant.ReversedRarities) do
                      for k,v in pairs(owned_pets) do
                        if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and v.rarity == r then
                          SafeInvoke("ToolAPI/Equip",
                            k,
                            {
                              use_sound_delay = true,
                              equip_as_last = false
                            }
                          )
                          flag = true
                          _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = true
                          _G.InternalConfig.PetFarmDLib.random_farm = true
                          break                          
                        end
                      end
                      if flag then break end
                    end
                  end
                end
              end
            end          
          else
            for _, r in ipairs(Constant.ReversedRarities) do
              for k,v in pairs(owned_pets) do
                if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and (v.name:lower()):match("egg") and v.rarity == r then
                  SafeInvoke("ToolAPI/Equip",
                    k,
                    {
                      use_sound_delay = true,
                      equip_as_last = false
                    }
                  )
                  flag = true
                  _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = false
                  break   
                end
              end
              if flag then break end
            end
            if not flag then
              if _G.InternalConfig.PetFarmDLib.OppositeFarm then
                if not _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then
                  WriteConsoleLog("No pets to farm depending on filter. Running opposite farm filter", "⚙️ No pets to farm depending on filter. Running opposite farm filter.", "DEBUG")
                  WriteFileLog("No pets to farm depending on filter. Running opposite farm filter", "DEBUG")
                  __Notify("Info", "No pets to farm depending on filter. Running opposite farm filter.", Constant.NotifyDuration['INFO'])
                  if _G.InternalConfig.PetFarmDLib.PotionFarm then
                    for _, r in ipairs(Constant.ReversedRarities) do
                      for k,v in pairs(owned_pets) do
                        if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and v.age == 6 and v.rarity == r then
                          SafeInvoke("ToolAPI/Equip",
                            k,
                            {
                              use_sound_delay = true,
                              equip_as_last = false
                            }
                          )
                          flag = true
                          _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = true
                          _G.InternalConfig.PetFarmDLib.random_farm = true
                          break
                        end
                      end
                      if flag then break end
                    end
                  end
                  if not flag then
                    for _, r in ipairs(Constant.ReversedRarities) do
                      for k,v in pairs(owned_pets) do
                        if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and v.rarity == r then
                          SafeInvoke("ToolAPI/Equip",
                            k,
                            {
                              use_sound_delay = true,
                              equip_as_last = false
                            }
                          )
                          flag = true
                          _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = true
                          _G.InternalConfig.PetFarmDLib.random_farm = true
                          break             
                        end
                      end
                      if flag then break end
                    end
                  end
                  if not flag then 
                    for _, r in ipairs(Constant.ReversedRarities) do
                      for k,v in pairs(owned_pets) do
                        if v.remote ~= "practice_dog" and not (_G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm and _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v.name:lower()]) and v.age == 6 and v.rarity == r then
                          SafeInvoke("ToolAPI/Equip",
                            k,
                            {
                              use_sound_delay = true,
                              equip_as_last = false
                            }
                          )
                          flag = true
                          _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = true
                          _G.InternalConfig.PetFarmDLib.random_farm = true
                          break
                        end
                      end
                      if flag then break end
                    end
                  end
                end
              end
            end
          end
          if not flag then
            if _G.InternalConfig.PetFarmDLib.OppositeFarm then
              if not _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then
                local practice_dog = InvGetCategoryUnique("pets", "practice_dog")
                if practice_dog then
                  SafeInvoke("ToolAPI/Equip",
                    practice_dog,
                    {
                      use_sound_delay = true,
                      equip_as_last = false
                    }
                  )
                  flag = true
                  _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm = true
                  _G.InternalConfig.PetFarmDLib.random_farm = true
                end
              end
            end
          end
          task.wait(1)
          if flag and not Equipped() then
            SetCooldown('AutoFarm', 'pet_auto_farm', 5)
            return
          end
          if _G.InternalConfig.PetFarmDLib.random_farm and not _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then
            _G.InternalConfig.PetFarmDLib.random_farm = false
            WriteConsoleLog("Opposite farm filter disabled", "⚙️ Opposite farm filter disabled.", "DEBUG")
            WriteFileLog("Opposite farm filter disabled", "DEBUG")
            __Notify("Info", "Opposite farm filter disabled.", Constant.NotifyDuration['INFO'])
          end
          if flag then
            task.wait(1)
            PetUpdate()
            if Mutable.ActualPet.unique then
              WriteConsoleLog(string.format("New pet to farm detected: %s", Mutable.ActualPet.remote), string.format("🐶 New pet to farm detected: %s", Mutable.ActualPet.remote), "DEBUG")
              WriteFileLog(string.format("New pet to farm detected: %s", Mutable.ActualPet.remote), "DEBUG")
              __Notify("Info", string.format("New pet to farm detected: %s", Mutable.ActualPet.remote), Constant.NotifyDuration['INFO'])
              if _G.InternalConfig.PetFarmDLib.UseBonusBucksPotions and Mutable.ActualPet.unique and not Mutable.ActualPet.is_egg then
                pcall(GetBonusBucksPotionToPet)
              end
              if _G.InternalConfig.PetFarmDLib.UseBonusAgingPotions and Mutable.ActualPet.unique and not Mutable.ActualPet.is_egg then
                pcall(GetBonusAgingPotionToPet)
              end
            end
          end
          if not flag and not _G.InternalConfig.PetFarmDLib.flag_if_no_one_to_farm then -- если пет не найден, не разрешить коду идти дальше, чтобы просто так не запускать таск детектор
            SetCooldown('AutoFarm', 'pet_auto_farm', 25)
            return
          end
        end
        local eqailments = GetEquippedPetAilments()
        WriteConsoleLog("Pet task detector ran", "⚙️ Pet task detector ran.", "DEBUG")
        WriteFileLog("Pet task detector ran", "DEBUG")
        for k,_ in pairs(eqailments) do 
          if Constant.PetAilments[k] and not _G.InternalConfig.MinigameLockdown then
            local _stdout = string.format("%s %s", Constant.FormattedPet[k], Mutable.ActualPet.remote)
            WriteConsoleLog(_stdout, _stdout, "DEBUG")
            WriteFileLog(_stdout, "DEBUG")
            pcall(Constant.PetAilments[k])
            if Mutable.Connections.WalkLock then Mutable.Connections.WalkLock:Disconnect(); Mutable.Connections.WalkLock = nil end
            if Mutable.Connections.RideLock then Mutable.Connections.RideLock:Disconnect(); Mutable.Connections.RideLock = nil end
          end
        end
        SetCooldown('AutoFarm', 'pet_auto_farm', 25)
      end)
      while not _task.completed do
        task.wait(1)
      end
      if not Mutable.Cooldown.AutoFarm.pet_auto_farm[1] then
        error("", 0)
      end
    end,
    function()
      return Mutable.Cooldown.AutoFarm.pet_auto_farm[1] == 0
    end,
    function()
      SetCooldown('AutoFarm', 'pet_auto_farm', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.LureboxFarm then 
    InitCooldown("AutoFarm", "lurebox_farm", 'lurebox_farm_handler') 
    Mutable.Registry.RegisterTask("lurebox_farm_handler", function()
      local lures_map = Mutable.Modules.ClientData.get("lures_2023_lure_manager").lures_map :: Str_T<Str_T<boolean | string | number>>
      
      if Count(lures_map) == 0 then 
        SafeInvoke("HousingAPI/ActivateFurniture",
          LocalPlayer,
          Mutable.Furn.Lurebox.unique,
          "UseBlock",
          {
            bait_unique = InvGetCategoryUnique("food", "ice_dimension_2025_ice_soup_bait") 
          },
          LocalPlayer.Character
        )

        local deadline = os.clock() + 5
        repeat 
          task.wait(0.5)
        until Count(Mutable.Modules.ClientData.get("lures_2023_lure_manager").lures_map :: Str_T<Str_T<boolean | string | number>>) > 0 or os.clock() > deadline

        if os.clock() > deadline then
          SetCooldown("AutoFarm", "lurebox_farm", 5)
          return
        end

        local l = Mutable.Modules.ClientData.get("lures_2023_lure_manager").lures_map.BasicLure
        
        if l and l.bait_kind then
          WriteConsoleLog(string.format("Lurebox bait placed: %s", l.bait_kind), string.format("[📦]:[✅] Bait placed: %s", l.bait_kind), "DEBUG")
          WriteFileLog(string.format("Lurebox bait placed: %s", l.bait_kind), "DEBUG")
          __Notify("Info", string.format("Lurebox bait placed: %s", l.bait_kind), Constant.NotifyDuration['INFO'])
        else
          WriteConsoleLog(string.format("Failed to place lurebox bait. Next try in [5]s", l.bait_kind), string.format("[📦]:[❌] Failed to place lurebox bait. Next try in [5]s."), "ERROR")
          WriteFileLog(string.format("Failed to place lurebox bait. Next try in [5]s", l.bait_kind), "ERROR")
          SetCooldown("AutoFarm", "lurebox_farm", 5) 
          return
        end
        SetCooldown("AutoFarm", "lurebox_farm", 120) 
      else
        local l = lures_map.BasicLure
        if not l.finished then
          SetCooldown("AutoFarm", "lurebox_farm", 120) 
        else
          local reward = l.reward or {
            kind="Unidentified reward", 
            amount=1
          }
          SafeInvoke("HousingAPI/ActivateFurniture",
            LocalPlayer,
            Mutable.Furn.Lurebox.unique,
            "UseBlock",
            false,
            LocalPlayer.Character
          )
          task.wait(1)
          if Count(Mutable.Modules.ClientData.get("lures_2023_lure_manager").lures_map :: Str_T<Str_T<boolean | string | number>>) == 0 then
            WriteConsoleLog(string.format("{%d %s} Found in lurebox", reward.amount, reward.kind), string.format("[📦]:[🎁] [%d %s] Found in lurebox.", reward.amount, reward.kind), "DEBUG")
            WriteFileLog(string.format("{%d %s} Found in lurebox", reward.amount, reward.kind), "DEBUG")
            __Notify("Info", string.format("[%d %s] Found in lurebox", reward.amount, reward.kind), Constant.NotifyDuration['SUCCESS'])
            SetCooldown("AutoFarm", "lurebox_farm", 5) 
          else
            WriteConsoleLog("Unsucceeded to get lurebox reward. Repeating after {5}s", "[📦]:[❌] Unsucceeded to get lurebox reward. Repeating after [5]s.", "ERROR")
            WriteFileLog("Unsucceeded to get lurebox reward. Repeating after [5]s", "ERROR")
            SetCooldown("AutoFarm", "lurebox_farm", 5) 
          end
        end 
      end
    end,
    function()
      return Mutable.Cooldown.AutoFarm.lurebox_farm[1] == 0
    end,
    function()
      SetCooldown("AutoFarm", "lurebox_farm", 10) 
    end)
    task.wait(1)
  end
  
  if _G.InternalConfig.AutoClaimDailies then
    InitCooldown('AutoFarm', "try_collect_dailies", "dailies_autocollect_handler")
    Mutable.Registry.RegisterTask("dailies_autocollect_handler", function()
      local dailies_count = Count(Mutable.Modules.ClientData.get("dailies_manager")['serialized_tabs']['vanilla'].active_dailies)

      ReplicatedStorage.adoptme_new_net["adoptme_new.modules.Dailies.DailiesNetService:9"]:FireServer("vanilla") -- dailies
      ReplicatedStorage.adoptme_new_net["adoptme_new.modules.Dailies.DailiesNetService:15"]:FireServer("vanilla") --main dailie 
      task.wait(1)      

      local vanilla = Mutable.Modules.ClientData.get("dailies_manager")['serialized_tabs']['vanilla']
      local new_dailies_count = Count(vanilla.active_dailies)
      local d_count = dailies_count - new_dailies_count
      if dailies_count > new_dailies_count then
        local text = ""

        if new_dailies_count == 0 then
          text = "All dailies completed"
        else
          text = ("%d %s completed"):format(d_count, if d_count > 1 then 'dailies' else 'daily')
        end
        WriteConsoleLog(text, "[📋] " .. text .. '.', "DEBUG")
        WriteFileLog(text, "DEBUG")
      end

      if not vanilla.active_dailies or new_dailies_count == 0 then
        local tms = Mutable.Modules.LiveOpsTime.get_time_until(vanilla.next_distribution_timestamp) or 3600
        SetCooldown('AutoFarm', 'try_collect_dailies', tms + 5)
        return
      end
      SetCooldown('AutoFarm', 'try_collect_dailies', 120)
    end, 
    function()
      return Mutable.Cooldown.AutoFarm.try_collect_dailies[1] == 0
    end,
    function()
      SetCooldown('AutoFarm', "try_collect_dailies", 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.BabyFarm then
    InitCooldown('AutoFarm', "baby_auto_farm", "baby_auto_farm_handler")
    Mutable.Registry.RegisterTask("baby_auto_farm_handler", function()
      local _task = Mutable.TaskQueue.Enqueue(function()
        if Mutable.Modules.ClientData.get("team") ~= "Babies" then
          SafeInvoke("TeamAPI/ChooseTeam",
            "Babies",
            {
              dont_respawn = true,
              source_for_logging = "avatar_editor"
            }
          )
        end	
        local active_ailments = GetBabyAilments()
        WriteConsoleLog("Baby task detector ran", "⚙️ Baby task detector ran.", "DEBUG")
        WriteFileLog("Baby task detector ran", "DEBUG")
        for k,_ in pairs(active_ailments) do
          if Constant.BabyAilments[k] and not _G.InternalConfig.MinigameLockdown then
            local _stdout = string.format("%s", Constant.FormattedBaby[k])
            WriteConsoleLog(_stdout, _stdout, "DEBUG")
            WriteFileLog(_stdout, "DEBUG")
            pcall(Constant.BabyAilments[k])
          end
        end
        SetCooldown('AutoFarm', "baby_auto_farm", 25)
      end)
      while not _task.completed do
        task.wait(1)
      end
      if not Mutable.Cooldown.AutoFarm.baby_auto_farm[1] then
        error("", 0)
      end
    end,
    function()
      return Mutable.Cooldown.AutoFarm.baby_auto_farm[1] == 0
    end, 
    function()
      SetCooldown('AutoFarm', "baby_auto_farm", 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.GiftAutoOpenDLib.Enabled then
    InitCooldown('AutoFarm', "auto_open_gifts", "auto_open_gifts_handler")
    Mutable.Registry.RegisterTask("auto_open_gifts_handler", function()
      if Count(GetOwnedCategory("gifts")) < 1 then
        WriteConsoleLog("[Gift AutoOpen]: No gifts detected", "[🎁] No gifts detected.", "DEBUG")
        WriteFileLog("[Gift AutoOpen]: No gifts detected", "DEBUG")
        SetCooldown('AutoFarm', "auto_open_gifts", 120)
        return
      end
      local _opened = 0
      if not _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen then
        for k,v in pairs(GetOwnedCategory("gifts")) do
          SafeInvoke("LootBoxAPI/ExchangeItemForReward", v.remote, k)
          task.wait(.08)
          SafeInvoke("ShopAPI/OpenGift", k)
          task.wait(.08)
          _opened += 1
        end
      else
        if _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen["chests"] then
          for k,v in pairs(GetOwnedCategory("gifts")) do
            SafeInvoke("LootBoxAPI/ExchangeItemForReward", v.remote, k)
            task.wait(.08)
            _opened += 1
          end
        end
        if _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen["massivegift"] or _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen["biggift"] or _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen["smallgift"] then
          for k,v in pairs(GetOwnedCategory("gifts")) do
            if v.remote and _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen[v.remote] then
              SafeInvoke("ShopAPI/OpenGift", k)
              task.wait(.08)
              _opened += 1
            end
          end
        end
      end

      local _type = ("gifts/chests" and not _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen) or ("chests" and _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen["chests"]) or "gifts" 
      if _opened > 0 then 
        __Notify("Info", string.format("Opened %d %s", _opened, _type), Constant.NotifyDuration['INFO'])
        WriteConsoleLog(string.format("Opened %d %s", _opened, _type), string.format("[📦]:[✅] Opened %d %s!", _opened, _type), "DEBUG")
        WriteFileLog(string.format("Opened %d %s", _opened, _type), "DEBUG")
      end
      SetCooldown('AutoFarm', "auto_open_gifts", 120)
    end,
    function()
      return Mutable.Cooldown.AutoFarm.auto_open_gifts[1] == 0
    end,
    function()
      SetCooldown('AutoFarm', "auto_open_gifts", 2)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.Enabled then
    InitCooldown('AutoFarm', "try_buy_egg_after", "egg_auto_buy_handler")
    Mutable.Registry.RegisterTask("egg_auto_buy_handler", function()
      local money = Mutable.Modules.ClientData.get("money") :: number
      local egg = _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.EggToBuy
      local reserve_money = money - (_G.InternalConfig.AutoBuyDLib.MinimumCashReserve or 0) 
      if reserve_money <= 0 then
        __Notify("Warning", "[Egg AutoBuy]: Minimal value of cash reached. Can't buy more eggs. Timeout [120]s.", Constant.NotifyDuration['WARNING'])
        SetCooldown('AutoFarm', "try_buy_egg_after", 120)
        return
      end
      local can_afford = math.floor(reserve_money / Constant.EggRemotes[egg][2]) 
      local bc = math.min(can_afford, _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.BuyCount, 99) 
      Mutable.StateDB.starter_value -= Constant.EggRemotes[egg][2] * bc
      if bc == 0 then
        SetCooldown('AutoFarm', "try_buy_egg_after", 120)
        return
      end
      __Notify("Info", "Buying eggs..", Constant.NotifyDuration["INFO"])
      SafeInvoke("ShopAPI/BuyItem",
        "pets",
        Constant.EggRemotes[egg][1],
        {
          buy_count = bc
        }
      )
      WriteConsoleLog(string.format("%d eggs bought!", bc), string.format("[🥚]:[✅] %d eggs bought!", bc), "DEBUG")
      WriteFileLog(string.format("%d eggs bought!", bc), "DEBUG")
      __Notify("Info", string.format("%d eggs bought!", bc), Constant.NotifyDuration["INFO"])
      _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.BuyCount -= bc
      Mutable.Farmed.total_eggs_bought += bc
      if _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.BuyCount == 0 then
        Mutable.Registry.UnregisterTask("egg_auto_buy_handler")
        Mutable.Cooldown.AutoFarm.try_buy_egg_after = nil
        WriteConsoleLog("[Egg AutoBuy]: Bought all as expected", nil, "DEBUG")
        WriteFileLog("[Egg AutoBuy]: Bought all as expected", "DEBUG")
        return
      end
      if _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.BuyCount > 0 and bc == 99 then
        SetCooldown('AutoFarm', "try_buy_egg_after", 1)
        return
      end
      local after = Mutable.Modules.ClientData.get("money") :: number
      local spent = money - after
      Mutable.StateDB.starter_value = Mutable.StateDB.starter_value - spent
      SetCooldown('AutoFarm', "try_buy_egg_after", 120)
    end,
    function()
      return Mutable.Cooldown.AutoFarm.try_buy_egg_after[1] == 0
    end,
    function()
      SetCooldown('AutoFarm', "try_buy_egg_after", 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.Enabled then
    InitCooldown('AutoFarm', "try_buy_gift_after", "gift_auto_buy_handler")
    Mutable.Registry.RegisterTask("gift_auto_buy_handler", function()
      local money = Mutable.Modules.ClientData.get("money") :: number
      local gift = _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.GiftToBuy
      local reserve_money = money - (_G.InternalConfig.AutoBuyDLib.MinimumCashReserve or 0)
      if reserve_money <= 0 then
        __Notify("Warning", "[Gift AutoBuy]: Minimal value of cash reached. Can't buy more gifts. Timeout [120]s.", Constant.NotifyDuration["WARNING"])
        SetCooldown('AutoFarm', "try_buy_gift_after", 120)
        return
      end
      local can_afford = math.floor(reserve_money / Constant.GiftRemotes[gift][2]) 
      local bc = math.min(can_afford, _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.BuyCount, 99) 
      Mutable.StateDB.starter_value -= Constant.GiftRemotes[gift][2] * bc
      if bc == 0 then
        SetCooldown('AutoFarm', "try_buy_gift_after", 120)
        return
      end
      __Notify("Info", "Buying gifts..", Constant.NotifyDuration["INFO"])
      SafeInvoke("ShopAPI/BuyItem",
        "gifts",
        Constant.GiftRemotes[gift][1],
        {
          buy_count = bc
        }
      )
      WriteConsoleLog(string.format("%d gifts bought!", bc), string.format("[🎁]:[✅] %d gifts bought!", bc), "DEBUG")
      WriteFileLog(string.format("%d gifts bought!", bc), "DEBUG")
      __Notify("Info", string.format("%d gifts bought!", bc), Constant.NotifyDuration["INFO"])
      _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.BuyCount -= bc
      Mutable.Farmed.total_gifts_bought += bc
      if _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.BuyCount == 0 then
        Mutable.Registry.UnregisterTask("gift_auto_buy_handler")
        Mutable.Cooldown.AutoFarm.try_buy_gift_after = nil
        WriteConsoleLog("[Gift AutoBuy]: Bought all as expected", nil, "DEBUG")
        WriteFileLog("[Gift AutoBuy]: Bought all as expected", "DEBUG")
        return
      end
      if _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.BuyCount > 0 and bc == 99 then
        SetCooldown('AutoFarm', "try_buy_gift_after", 1)
        return
      end
      local after = Mutable.Modules.ClientData.get("money") :: number
      local spent = money - after
      Mutable.StateDB.starter_value = Mutable.StateDB.starter_value - spent
      SetCooldown('AutoFarm', "try_buy_gift_after", 120)
    end,
    function()
      return Mutable.Cooldown.AutoFarm.try_buy_gift_after[1] == 0
    end,
    function()
      SetCooldown('AutoFarm', "try_buy_gift_after", 5)
    end)
    task.wait(1)
  end
-- proceed with Cooldown
  if _G.InternalConfig.PetRecyclerDLib.Enabled then
    InitCooldown('AutoFarm', 'pet_recycler', 'pet_recycler_handler')
    Mutable.Registry.RegisterTask("pet_recycler_handler", function()
      local pets_to_exchange = {}
      local owned_pets = GetOwnedPets()
      for k,v in owned_pets do
        if v.remote == "practice_dog" then continue end
        if (v.name:lower()):match("egg") then continue end   
        if (Mutable.ActualPet.unique or "") == k then continue end
        if _G.InternalConfig.PetRecyclerDLib.Blacklist.Rarities and _G.InternalConfig.PetRecyclerDLib.Blacklist.Rarities[v.rarity] then continue end
        if _G.InternalConfig.PetRecyclerDLib.Blacklist.Ages and _G.InternalConfig.PetRecyclerDLib.Blacklist.Ages[v.age] then continue end
        if _G.InternalConfig.PetRecyclerDLib.Blacklist.Properties then 
          if v.neon and _G.InternalConfig.PetRecyclerDLib.Blacklist.Properties["neon"] then continue end
          if v.mega_neon and _G.InternalConfig.PetRecyclerDLib.Blacklist.Properties["meganeon"] then continue end
          if v.flyable and _G.InternalConfig.PetRecyclerDLib.Blacklist.Properties["flyable"] then continue end
          if v.rideable and _G.InternalConfig.PetRecyclerDLib.Blacklist.Properties["rideable"] then continue end
        end        
        if _G.InternalConfig.PetRecyclerDLib.Blacklist.SpecificPets and _G.InternalConfig.PetRecyclerDLib.Blacklist.SpecificPets[v.name:lower()] then continue end     
        pets_to_exchange[k] = true
      end
      if Count(pets_to_exchange) == 0 then
        WriteConsoleLog("No pets to use in pet recycler", "[♻️]:[⚠️] No pets to use in pet recycler.", "DEBUG")
        WriteFileLog("No pets to use in pet recycler", "DEBUG")
        __Notify("Info", "No pets to use in pet recycler.", Constant.NotifyDuration["INFO"])
        SetCooldown('AutoFarm', 'pet_recycler', 120)
        return
      end
      local _task = Mutable.LocationQueue.Enqueue(function()
        EmulateLocation("Nursery")    
        SafeInvoke("HousingAPI/ActivateInteriorFurniture", 
          "f-27",
          "UseBlock",
          {
            ["uniques"] = pets_to_exchange
          },
          LocalPlayer.Character
        )
      end) 
      while not _task.completed do
        task.wait(1)
      end
      task.wait(3)
      local _count = Count(pets_to_exchange)
      WriteConsoleLog(string.format("%d pets have been converted into tickets", _count), string.format("[♻️]:[✅] %d pets have been converted into tickets.", _count), "DEBUG")
      WriteFileLog(string.format("%d pets have been converted into tickets", _count), "DEBUG")
      __Notify("Success", string.format("%d pets have been converted into tickets.", _count), Constant.NotifyDuration['SUCCESS'])
      local _saved_tickets = Mutable.Modules.ClientData.get("pet_recycler_manager").saved_tickets 
      SafeInvoke("PetRecyclerAPI/TicketsCollected")
      task.wait(1.5)
      if _saved_tickets > Mutable.Modules.ClientData.get("pet_recycler_manager").saved_tickets then
        local _total_tickets = Mutable.Modules.ClientData.get("pet_recycler_tickets_2026") or 0
        UpdateGui("tickets", _total_tickets)
        WriteConsoleLog(string.format("Successfully collected %d ticket. You have %d in total now", _saved_tickets, _total_tickets), string.format("[♻️]:[✅] Successfully collected %d ticket. You have %d in total now", _saved_tickets, _total_tickets), "DEBUG")
        WriteFileLog(string.format("Successfully collected %d ticket. You have %d in total now", _saved_tickets, _total_tickets), "DEBUG")
        __Notify("Success", string.format("Successfully collected %d ticket. You have %d in total now", _saved_tickets, _total_tickets), Constant.NotifyDuration['SUCCESS'])
      end
      SetCooldown('AutoFarm', 'pet_recycler', 60)
    end,
    function()
      return Mutable.Cooldown.AutoFarm.pet_recycler[1] == 0
    end,
    function()
      SetCooldown('AutoFarm', 'pet_recycler', 5)
    end)
    task.wait(1)
  end

  
  if _G.InternalConfig.AutoGivePotionDLib.Enabled then
    InitCooldown('AutoFarm', 'try_use_potion_after', "auto_give_potion_handler")
    Mutable.Registry.RegisterTask("auto_give_potion_handler", function()
      local potions = GetPotions()
      if not potions[1] and not potions[2] then 
        WriteConsoleLog("[AutoGivePotion]: No potions detected. Cooldown [180]s", "🧪 No potions detected. Cooldown: [180]s.", "DEBUG")
        WriteFileLog("[AutoGivePotion]: No potions detected. Cooldown [180]s", "DEBUG")
        __Notify("Info", "[AutoGivePotion]: No potions detected. Cooldown [180]s.", Constant.NotifyDuration["INFO"])
        SetCooldown('AutoFarm', 'try_use_potion_after', 120)
        return
      end	
      local pet_to_grow = {}
      local owned_pets = GetOwnedPets()

      for k,v in pairs(owned_pets) do
        if v.age == 6 then continue end
        if v.remote == "practice_dog" then continue end
        if (v.name:lower()):match("egg") then continue end
        if (Mutable.ActualPet.unique or "") == k then continue end
        if _G.InternalConfig.AutoGivePotionDLib.Blacklist.Rarities and _G.InternalConfig.AutoGivePotionDLib.Blacklist.Rarities[v.rarity] then continue end
        if _G.InternalConfig.AutoGivePotionDLib.Blacklist.Ages and _G.InternalConfig.AutoGivePotionDLib.Blacklist.Ages[v.age] then continue end
        if _G.InternalConfig.AutoGivePotionDLib.Blacklist.Properties then 
          if v.neon and _G.InternalConfig.AutoGivePotionDLib.Blacklist.Properties["neon"] then continue end
          if v.mega_neon and _G.InternalConfig.AutoGivePotionDLib.Blacklist.Properties["meganeon"] then continue end
          if v.flyable and _G.InternalConfig.AutoGivePotionDLib.Blacklist.Properties["flyable"] then continue end
          if v.rideable and _G.InternalConfig.AutoGivePotionDLib.Blacklist.Properties["rideable"] then continue end
        end
        if _G.InternalConfig.AutoGivePotionDLib.Blacklist.SpecificPets and _G.InternalConfig.AutoGivePotionDLib.Blacklist.SpecificPets[v.name:lower()] then continue end
        table.insert(pet_to_grow, { k, v.age, v.rarity, v.remote, v.xp})
      end

      if #pet_to_grow == 0 then 
        WriteConsoleLog("[AutoGivePotion]: No pets to grow up. Cooldown [180]s", "🧪 No pets to grow up. Cooldown: [180]s.", "DEBUG")
        WriteFileLog("[AutoGivePotion]: No pets to grow up. Cooldown [180]s", "DEBUG")
        __Notify("Info", "[AutoGivePotion]: No pets to grow up. Cooldown [180]s.", Constant.NotifyDuration["INFO"])
        SetCooldown('AutoFarm', 'try_use_potion_after', 120)
        return
      end

      if _G.InternalConfig.AutoGivePotionDLib.SetHigherPriorityFor then
        local _temp = {} 
        local _used = {}
        for _,v in ipairs(_G.InternalConfig.AutoGivePotionDLib.SetHigherPriorityFor) do
          for _,b in ipairs(pet_to_grow) do
            if b[3] == v then
              table.insert(_temp, { b[1], b[2], b[3], b[4], b[5], })
              _used[b[1]] = true
            end
          end
        end
        for _,v in ipairs(pet_to_grow) do
          if not _used[v[1]] then
            table.insert(_temp, { v[1], v[2], v[3], v[4], v[5], })
          end
        end
        pet_to_grow = _temp
      end

      local equiped_pet = Mutable.Modules.ClientData.get("pet_char_wrappers")[1] :: P_C_Wrapper?
      local _task = Mutable.TaskQueue.Enqueue(function()
        for _,v in ipairs(pet_to_grow) do

          local potions = GetPotions()
          if not potions[1] and not potions[2] then 
            WriteConsoleLog("[AutoGivePotion]: No potions detected. Cooldown [120]s", "🧪 No potions detected. Cooldown: [180]s.", "DEBUG")
            WriteFileLog("[AutoGivePotion]: No potions detected. Cooldown [120]s", "DEBUG")
            __Notify("Info", "[AutoGivePotion]: No potions detected. Cooldown [120]s", Constant.NotifyDuration["INFO"])
            SetCooldown('AutoFarm', 'try_use_potion_after', 120)
            return
          end	

          local pet_unique = v[1]
          local pet_age = v[2]
          local pet_rarity = v[3]
          local pet_name = v[4]
          local pet_xp = v[5]

          local potions_to_give, expected_age = CalculateOptimalPotionsByRarity(pet_xp, pet_rarity, potions)

          WriteConsoleLog(string.format("Optimal count of potions to give has been calculated for [%s]: [%d Age potions] and [%d Tiny age potions]", pet_name, Count(potions_to_give[1]), Count(potions_to_give[2])), string.format("⚙️ Optimal count of potions to give has been calculated for [%s]: [%d Age potions] and [%d Tiny age potions].", pet_name, Count(potions_to_give[1]), Count(potions_to_give[2])), "DEBUG")
          WriteFileLog(string.format("Optimal count of potions to give has been calculated for [%s]: [%d Age potions] and [%d Tiny age potions]", pet_name, Count(potions_to_give[1]), Count(potions_to_give[2])), "DEBUG")
          SafeInvoke("ToolAPI/Equip",
            pet_unique,
            {
              use_sound_delay = true,
              equip_as_last = false
            }
          )
          task.wait(.3)
          if Count(potions_to_give[1]) > 0 then
            local main = nil
            local others = {}
            for k,_ in pairs(potions_to_give[1]) do
              if main then 
                table.insert(others, k)
              else 
                main = k 
              end
            end
            SafeInvoke("PetObjectAPI/CreatePetObject",
              "__Enum_PetObjectCreatorType_2",
              {
                additional_consume_uniques = {
                  table.unpack(others)
                },
                pet_unique = pet_unique,
                unique_id = main
              }
            )
            task.wait(5)
            local deadline = os.clock() + 7
            repeat
              task.wait(1)
            until Mutable.Modules.ClientData.get("inventory").pets[pet_unique].properties.age == expected_age[1] or os.clock() > deadline 
          end
          if Count(potions_to_give[2]) > 0 then
            local main = nil
            local others = {}
            for k,_ in pairs(potions_to_give[2]) do
              if main then 
                table.insert(others, k)
              else 
                main = k 
              end
            end
            SafeInvoke("PetObjectAPI/CreatePetObject",
              "__Enum_PetObjectCreatorType_2",
              {
                additional_consume_uniques = {
                  table.unpack(others)
                },
                pet_unique = pet_unique,
                unique_id = main
              }
            )
            task.wait(5)
            local deadline = os.clock() + 7
            repeat
              task.wait(1)
            until Mutable.Modules.ClientData.get("inventory").pets[pet_unique].properties.age == expected_age[2] or os.clock() > deadline 
          end
          WriteConsoleLog(string.format("[Age potions - %d] & [Tiny age potions - %d] used on: %s", Count(potions_to_give[1]), Count(potions_to_give[2]), pet_name), string.format("🧪 [Age potions - %d] & [Tiny age potions - %d] used on: %s", Count(potions_to_give[1]), Count(potions_to_give[2]), pet_name), "DEBUG")
          WriteFileLog(string.format("[Age potions - %d] & [Tiny age potions - %d] used on: %s", Count(potions_to_give[1]), Count(potions_to_give[2]), pet_name), "DEBUG")
          __Notify("Info", string.format("[Age potions - %d] & [Tiny age potions - %d] used on: %s", Count(potions_to_give[1]), Count(potions_to_give[2]), pet_name), Constant.NotifyDuration["INFO"])
          task.wait(1)
          local new_age = GetOwnedPets()[pet_unique].age
          WriteConsoleLog(string.format("%s age: %d -> %d\n", pet_name, pet_age, new_age), string.format("[🧪]:[✅] %s age: %d -> %d\n", pet_name, pet_age, new_age), "DEBUG")
          WriteFileLog(string.format("%s age: %d -> %d\n", pet_name, pet_age, new_age), "DEBUG")
          __Notify("Info", string.format("%s age: %d -> %d\n", pet_name, pet_age, new_age), Constant.NotifyDuration["INFO"])
          if new_age == 6 then
            Mutable.Farmed.pets_fullgrown += 1
            Mutable.StateDB.total_fullgrowned[pet_unique] = true  
            UpdateGui("fullgrown", Mutable.Farmed.pets_fullgrown)
          end
        end 
        SetCooldown('AutoFarm', 'try_use_potion_after', 120)
      end)
      while not _task.completed do
        task.wait(1)
      end
      SafeInvoke("ToolAPI/Equip",
        Mutable.ActualPet.unique or (equiped_pet and equiped_pet.pet_unique),
        {
          use_sound_delay = true,
          equip_as_last = false
        }
      )
      if not Mutable.Cooldown.AutoFarm.try_use_potion_after[1] then
        error("", 0)
      end
    end,
    function()
      return Mutable.Cooldown.AutoFarm.try_use_potion_after[1] == 0
    end,
    function()
      SetCooldown('AutoFarm', 'try_use_potion_after', 5)
    end)
    task.wait(1)
  end
  
  -- if _G.InternalConfig.PetPenDLib.Enabled then
  --   InitCooldown('AutoFarm', 'auto_collect_progression', 'pet_pen_progression_collection_handler_2')
  --   Mutable.Registry.RegisterTask("pet_pen_progression_collection_handler_2", function()
  --     -- ==============
  --     SafeFire("IdleProgressionAPI/CommitAllProgression", true)
  --     SetCooldown('AutoFarm', 'auto_collect_progression', 300)
  --     -- ==============
  --   end,
  --   function()
  --     return Mutable.Cooldown.AutoFarm.auto_collect_progression[1] == 0
  --   end,
  --   function()
  --     SetCooldown('AutoFarm', 'auto_collect_progression', 5)
  --   end)
  --   InitCooldown('AutoFarm', 'pet_pen_check_after', "pet_pen_handler")
  --   Mutable.Registry.RegisterTask("pet_pen_handler", function()

  --     local slots = GetPetPenSlots()
  --     local active_pets = Mutable.Modules.ClientData.get("idle_progression_manager")['active_pets'] :: Str_T<string>
  --     local owned_pets = GetOwnedPets()
  --     local pets_to_place = {}
  --     if slots > Count(active_pets) then 
  --       for k,v in pairs(owned_pets) do
  --         if v.remote ~= "practice_dog" then
  --           if (Mutable.ActualPet.unique or "") == k then continue end
  --           if v.friendship > 1 and _G.InternalConfig.PetPenDLib.Blacklist.ExcludeFriendly then continue end
  --           if _G.InternalConfig.PetPenDLib.UsePriority == "eggs" and not (v.name:lower()):match("egg") then continue 
  --           elseif _G.InternalConfig.PetPenDLib.UsePriority == "pets" and (v.name:lower()):match("egg") then continue
  --           end

  --           if _G.InternalConfig.PetPenDLib.Blacklist.Rarities and _G.InternalConfig.PetPenDLib.Blacklist.Rarities[v.rarity] then continue end
  --           if _G.InternalConfig.PetPenDLib.Blacklist.Ages and _G.InternalConfig.PetPenDLib.Blacklist.Ages[v.age] then continue end
  --           if _G.InternalConfig.PetPenDLib.Blacklist.Properties then 
  --             if v.neon and _G.InternalConfig.PetPenDLib.Blacklist.Properties["neon"] then continue end
  --             if v.mega_neon and _G.InternalConfig.PetPenDLib.Blacklist.Properties["meganeon"] then continue end
  --             if v.flyable and _G.InternalConfig.PetPenDLib.Blacklist.Properties["flyable"] then continue end
  --             if v.rideable and _G.InternalConfig.PetPenDLib.Blacklist.Properties["rideable"] then continue end
  --           end
  --           if _G.InternalConfig.PetPenDLib.Blacklist.SpecificPets and _G.InternalConfig.PetPenDLib.Blacklist.SpecificPets[v.name:lower()] then continue end

  --           table.insert(pets_to_place, {k, v.rarity})
  --         end
  --       end
  --     else
  --       __Notify("Warning", "[PetPen]: No free places to put pets to pet pen.", Constant.NotifyDuration["WARNING"])
  --       SetCooldown('AutoFarm', 'pet_pen_check_after', 180)
  --       return
  --     end
  --     if #pets_to_place == 0 then
  --       __Notify("Warning", "[PetPen]: No pets to place to pet pen.", Constant.NotifyDuration["WARNING"])
  --       SetCooldown('AutoFarm', 'pet_pen_check_after', 180)
  --       return
  --     end
  --     if _G.InternalConfig.PetPenDLib.PrioritizedRarities then
  --       local _temp = {} 
  --       local _used = {}
  --       for _,v in ipairs(_G.InternalConfig.PetPenDLib.PrioritizedRarities) do
  --         for _,b in ipairs(pets_to_place) do
  --           if b[2] == v then
  --             table.insert(_temp, b[1])
  --             _used[b[1]] = true
  --           end
  --         end
  --       end
  --       for k,v in ipairs(pets_to_place) do
  --         if not _used[v[1]] then
  --           table.insert(_temp, v[1]) 
  --         end
  --       end
  --       pets_to_place = _temp
  --     else
  --       local _temp = {}
  --       for k,v in ipairs(pets_to_place) do
  --         table.insert(_temp, v[1])
  --       end
  --       pets_to_place = _temp
  --     end
  --     local _c = slots - Count(active_pets)
  --     if _c < #pets_to_place then
  --       while #pets_to_place > _c do
  --           table.remove(pets_to_place)
  --       end
  --     end
      
  --     for k,v in ipairs(pets_to_place) do
  --       SafeFire("IdleProgressionAPI/AddPet", v)
  --       __Notify("Info", string.format("%s placed into pet pen!", InvGetNameFromUnique("pets",v)), Constant.NotifyDuration["INFO"])
  --       WriteConsoleLog(string.format("%s placed into pet pen!", InvGetNameFromUnique("pets",v)), string.format("%s placed into pet pen!", InvGetNameFromUnique("pets",v)), "DEBUG")
  --       WriteFileLog(string.format("%s placed into pet pen!", InvGetNameFromUnique("pets",v)), "DEBUG")
  --     end   
  --     SetCooldown('AutoFarm', 'pet_pen_check_after', 180)
  --   end,
  --   function()
  --     return Mutable.Cooldown.AutoFarm.pet_pen_check_after[1] == 0
  --   end,
  --   function()
  --     SetCooldown('AutoFarm', 'pet_pen_check_after', 5)
  --   end)
  --   task.wait(1)
  -- end 

  if _G.InternalConfig.AutoNeonDLib.Enabled then
    InitCooldown('AutoFarm', 'auto_neon', "auto_neon_handler")
    Mutable.Registry.RegisterTask("auto_neon_handler", function() 
      local groups = {}
      local to_use = {}
      for k,v in pairs(GetOwnedPets()) do
        if v.remote == "practice_dog" then continue end
        if (Mutable.ActualPet.unique or "") == k then continue end
        if _G.InternalConfig.AutoNeonDLib.Blacklist.Rarities and _G.InternalConfig.AutoNeonDLib.Blacklist.Rarities[v.rarity] then
          continue
        end
        if _G.InternalConfig.AutoNeonDLib.Blacklist.Ages and _G.InternalConfig.AutoNeonDLib.Blacklist.Ages[v.age] then
          continue
        end
        if _G.InternalConfig.AutoNeonDLib.Blacklist.Properties then
          if v.neon and _G.InternalConfig.AutoNeonDLib.Blacklist.Properties["neon"] then continue end
          if v.mega_neon and _G.InternalConfig.AutoNeonDLib.Blacklist.Properties["meganeon"] then continue end
          if v.flyable and _G.InternalConfig.AutoNeonDLib.Blacklist.Properties["flyable"] then continue end
          if v.rideable and _G.InternalConfig.AutoNeonDLib.Blacklist.Properties["rideable"] then continue end
        end
        if _G.InternalConfig.AutoNeonDLib.Blacklist.SpecificPets and _G.InternalConfig.AutoNeonDLib.Blacklist.SpecificPets[v.name:lower()] then
          continue
        end
        if v.age == 6 and not v.neon and not v.mega_neon then
          groups[v.name] = groups[v.name] or {}
          table.insert(groups[v.name], k)
        end
      end

      for _, list in pairs(groups) do
        if #list >= 4 then 
          table.insert(to_use, { 
            list[1], 
            list[2], 
            list[3], 
            list[4] 
          })
        end
      end

      if #to_use == 0 then
        SetCooldown('AutoFarm', 'auto_neon', 120)
        return
      end

      local _task = Mutable.LocationQueue.Enqueue(function()
        EmulateLocation("Cave")
        for _,v in ipairs(to_use) do
          local k = InvGetNameFromUnique("pets", v[1])

          local pet_count = CountOfPets()
          SafeInvoke("PetAPI/DoNeonFusion", { table.unpack(v) }) 
          task.wait(1.5)
          local pet_new_count = CountOfPets()
          if (pet_count - 4) == pet_new_count or (pet_count - 3) == pet_new_count then 
            WriteConsoleLog(string.format("[AutoNeon]: Pet {%s} is Neon now", k), string.format("[🧿]:[✅] Pet %s is Neon now!", k), "DEBUG")
            WriteFileLog(string.format("[AutoNeon]: Pet {%s} is Neon now", k), "DEBUG") 
            __Notify("Success", string.format("Pet %s is Neon now!", k), Constant.NotifyDuration["SUCCESS"])
          else
            WriteConsoleLog(string.format("[AutoNeon]: Failed to make pet {%s} neon", k), string.format("[🧿]:[❌] Failed to make pet %s neon", k), "DEBUG")
            WriteFileLog(string.format("[AutoNeon]: Failed to make {%s} neon", k), "DEBUG") 
            __Notify("Error", string.format("Failed to make pet %s neon", k), Constant.NotifyDuration["ERROR"])
          end
          task.wait(5)
        end
        SetCooldown('AutoFarm', 'auto_neon', 5)
      end)
      while not _task.completed do
        task.wait(1)
      end
      if not Mutable.Cooldown.AutoFarm.auto_neon[1] then
        error("", 0)
      end
    end, 
    function() 
      return Mutable.Cooldown.AutoFarm.auto_neon[1] == 0
    end, 
    function() 
      SetCooldown('AutoFarm', 'auto_neon', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.AutoMegaNeonDLib.Enabled then
    InitCooldown('AutoFarm', 'auto_mega_neon', "auto_mega_neon_handler")
    Mutable.Registry.RegisterTask("auto_mega_neon_handler", function() 
      local groups = {}
      local to_use = {}
      for k,v in pairs(GetOwnedPets()) do
        if v.remote == "practice_dog" then continue end
        if (Mutable.ActualPet.unique or "") == k then continue end
        if _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Rarities and _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Rarities[v.rarity] then
          continue
        end
        if _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Ages and _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Ages[v.age] then
          continue
        end
        if _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Properties then
          if v.neon and _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Properties["neon"] then continue end
          if v.mega_neon and _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Properties["meganeon"] then continue end
          if v.flyable and _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Properties["flyable"] then continue end
          if v.rideable and _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Properties["rideable"] then continue end
        end
        if _G.InternalConfig.AutoMegaNeonDLib.Blacklist.SpecificPets and _G.InternalConfig.AutoMegaNeonDLib.Blacklist.SpecificPets[v.name:lower()] then
          continue
        end
        if v.neon and v.age == 6 and not v.mega_neon then
          groups[v.name] = groups[v.name] or {}
          table.insert(groups[v.name], k)
        end
      end

      for _, list in pairs(groups) do
        if #list >= 4 then 
          table.insert(to_use, { 
            list[1], 
            list[2], 
            list[3], 
            list[4] 
          })
        end
      end
      
      if #to_use == 0 then
        SetCooldown('AutoFarm', 'auto_mega_neon', 120)
        return
      end

      local _task = Mutable.LocationQueue.Enqueue(function()
        EmulateLocation("Cave")
        for _,v in pairs(to_use) do
          local k = InvGetNameFromUnique("pets", v[1])

          local pet_count = CountOfPets()
          SafeInvoke("PetAPI/DoNeonFusion", {table.unpack(v)}) 
          task.wait(1.5)
          local pet_new_count = CountOfPets()
          if (pet_count - 4) == pet_new_count or (pet_count - 3) == pet_new_count then 
            WriteConsoleLog(string.format("[AutoMegaNeon]: Pet {%s} is Mega Neon now", k), string.format("[🧿]:[✅] Pet %s is Mega Neon now!", k), "DEBUG")
            WriteFileLog(string.format("[AutoMegaNeon]: Pet {%s} is Mega Neon now", k), "DEBUG") 
            __Notify("Success", string.format("Pet %s is Mega Neon now!", k), Constant.NotifyDuration["SUCCESS"])
          else
            WriteConsoleLog(string.format("[AutoMegaNeon]: Failed to make pet {%s} mega neon", k), string.format("[🧿]:[❌] Failed to make pet %s Mega neon", k), "DEBUG")
            WriteFileLog(string.format("[AutoMegaNeon]: Failed to make {%s} mega neon", k), "DEBUG") 
            __Notify("Error", string.format("Failed to make pet %s mega neon", k), Constant.NotifyDuration["ERROR"])
          end
          task.wait(5)
        end
        SetCooldown('AutoFarm', 'auto_mega_neon', 5)
      end)
      while not _task.completed do
        task.wait(1)
      end          
      if not Mutable.Cooldown.AutoFarm.auto_mega_neon[1] then
        error("", 0)
      end
    end, 
    function() 
      return Mutable.Cooldown.AutoFarm.auto_mega_neon[1] == 0
    end, 
    function() 
      SetCooldown('AutoFarm', 'auto_mega_neon', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.TradeDLib.Enabled then
    InitCooldown('AutoTrade', 'next_trade_after', 'auto_trade_handler')
    Mutable.Registry.RegisterTask("auto_trade_handler", function()
      local user = _G.InternalConfig.TradeDLib.PlayerTradeWith 
      local need_repeat = false
      local pets_to_send = {}
      local confirmed = false
      if game.Players:FindFirstChild(user) and not Mutable.Modules.UIManager.apps.TradeApp.visible :: boolean then
        for category,_ in pairs(_G.InternalConfig.TradeDLib.TradeCategories) do
          if category == "pets" then 
            local owned_pets = GetOwnedPets()
            for k,v in pairs(owned_pets) do
              if Count(pets_to_send) == 18 then  
                need_repeat = true
                break
              end                
              if (Mutable.ActualPet.unique or "") == k then continue end
              if not IsTradeable("pets", v.remote) then continue end
              if _G.InternalConfig.TradeDLib.TradeFarmed and Mutable.StateDB.total_fullgrowned[k] then
                pets_to_send[k] = true
                continue
              end
              if _G.InternalConfig.TradeDLib.TradePriority == "eggs" and not (v.name:lower()):match("egg") then
                continue
              elseif _G.InternalConfig.TradeDLib.TradePriority == "pets" and (v.name:lower()):match("egg") then
                continue
              end
              if _G.InternalConfig.TradeDLib.Blacklist.Rarities and _G.InternalConfig.TradeDLib.Blacklist.Rarities[v.rarity] then
                continue
              end
              if _G.InternalConfig.TradeDLib.Blacklist.Ages and _G.InternalConfig.TradeDLib.Blacklist.Ages[v.age] then
                continue
              end
              if _G.InternalConfig.TradeDLib.Blacklist.Properties then
                if v.neon and _G.InternalConfig.TradeDLib.Blacklist.Properties["neon"] then continue end
                if v.mega_neon and _G.InternalConfig.TradeDLib.Blacklist.Properties["meganeon"] then continue end
                if v.flyable and _G.InternalConfig.TradeDLib.Blacklist.Properties["flyable"] then continue end
                if v.rideable and _G.InternalConfig.TradeDLib.Blacklist.Properties["rideable"] then continue end
              end
              if _G.InternalConfig.TradeDLib.Blacklist.ExcludeFriendly and v.friendship > 0 then
                continue
              end
              if _G.InternalConfig.TradeDLib.Blacklist.SpecificPets and _G.InternalConfig.TradeDLib.Blacklist.SpecificPets[v.name:lower()] then
                continue
              end
              pets_to_send[k] = true
            end
          else
            if Count(pets_to_send) < 18 then
              for a,b in Mutable.Modules.ClientData.get("inventory")[category] :: Inv_Cat do
                if Count(pets_to_send) == 18 then
                  need_repeat = true
                  break
                end
                if IsTradeable(category, b.id) then 
                  if _G.InternalConfig.TradeDLib.Blacklist.Rarities and _G.InternalConfig.TradeDLib.Blacklist.Rarities[Mutable.Modules.InventoryDB[category][b.id].rarity :: string] then
                    continue
                  end
                  pets_to_send[a] = true
                end
              end
            end
          end
        end
        if Count(pets_to_send) == 0 then
            SetCooldown('AutoTrade', 'next_trade_after', 60)
            WriteConsoleLog("Internal pet list to trade is empty. Cooldown: [60]s", "[🔄]:[‼️] Internal pet list to trade is empty. Cooldown: [60]s.", "DEBUG")
            WriteFileLog("Internal pet list to trade is empty. Cooldown: [60]s", "DEBUG")          
            __Notify("Warning", "Internal pet list to trade is empty. Cooldown: [60]s.", Constant.NotifyDuration["WARNING"])
          return
        end
        local r = SendTradeRequest(user)
        if r == "No response" then
          __Notify("Warning", string.format("No response from: %s", user), Constant.NotifyDuration["WARNING"])
            SetCooldown('AutoTrade', 'next_trade_after', _G.InternalConfig.TradeDLib.FallbackDelay)
          return
        elseif type(r) == "number" then
            SetCooldown('AutoTrade', 'next_trade_after', r)
          __Notify("Warning", string.format("Trade cooldown has been set by the game. Repeating after it ends: %d", r), Constant.NotifyDuration["WARNING"])
          return 
        elseif r == "declined" then
          __Notify("Warning", string.format("%s declined trade request", user), Constant.NotifyDuration["WARNING"])
          SetCooldown('AutoTrade', 'next_trade_after', _G.InternalConfig.TradeDLib.FallbackDelay)
          return 
        elseif r == "does not accept trade requests" then
          __Notify("Warning", string.format("%s does not accept trade requests!", user), Constant.NotifyDuration["WARNING"])
          SetCooldown('AutoTrade', 'next_trade_after', _G.InternalConfig.TradeDLib.FallbackDelay)
          return 
        end
        task.wait(1)
        local deadline = os.clock() + 180
        local ui = Mutable.Modules.UIManager.apps.TradeApp
        if ui.visible then             

          local btn1 = ui.negotiation_decline_button.mouse_button1_click
          local btn2 = ui.confirmation_decline_button.mouse_button1_click
          local btn3 = ui.negotiation_accept_button.mouse_button1_click
          local btn4 = ui.confirmation_accept_button.mouse_button1_click 
          local btn5 = ui.my_negotiation_offer_pane.add_item_callback 

          ui.negotiation_decline_button.mouse_button1_click = function() __Notify("Warning", "Decline button is locked", Constant.NotifyDuration["WARNING"]) end 
          ui.confirmation_decline_button.mouse_button1_click = function() __Notify("Warning", "Cancel button is locked", Constant.NotifyDuration["WARNING"]) end 
          ui.negotiation_accept_button.mouse_button1_click  = function() __Notify("Warning", "Accept button is locked", Constant.NotifyDuration["WARNING"]) end 
          ui.confirmation_accept_button.mouse_button1_click  = function() __Notify("Warning", "Confirm button is locked", Constant.NotifyDuration["WARNING"]) end 
          ui.my_negotiation_offer_pane.add_item_callback = function() __Notify("Warning", "Add item button is locked", Constant.NotifyDuration["WARNING"]) end 
        
          pcall(function()
            for k,_ in pairs(pets_to_send) do 
              SafeFire("TradeAPI/AddItemToOffer", k)
              task.wait(.25)
            end
          end)
          while task.wait(1) and ui.visible and os.clock() < deadline do
            if ui:_get_current_trade_stage() == "negotiation" then
              if ui:_get_partner_offer().negotiated then
                SafeFire("TradeAPI/AcceptNegotiation")
              else
                continue
              end
            elseif ui:_get_current_trade_stage() == "confirmation" then
              if ui:_get_partner_offer().confirmed then
                SafeFire("TradeAPI/ConfirmTrade")
                confirmed = true
              else
                continue
              end
            end
          end
          if os.clock() > deadline then
            SafeFire("TradeAPI/DeclineTrade")
            local _cdl = _G.InternalConfig.TradeDLib.FallbackDelay
            WriteConsoleLog(string.format("[AutoTrade]: Trade is taking longer than expected. Repeating after [%d]s", _cdl), string.format("[🔄]:[‼️] Trade is taking longer than expected. Repeating after [%d]s.", _cdl), "DEBUG")
            WriteFileLog(string.format("[AutoTrade]: Trade is taking longer than expected. Repeating after [%d]s", _cdl), "DEBUG")
            __Notify("Warning", string.format("Trade is taking longer than expected. Repeating after [%d]s.", _cdl), Constant.NotifyDuration["WARNING"])
            SetCooldown('AutoTrade', 'next_trade_after', _cdl)
            return
          end
          ui.negotiation_decline_button.mouse_button1_click = btn1
          ui.confirmation_decline_button.mouse_button1_click = btn2
          ui.negotiation_accept_button.mouse_button1_click = btn3
          ui.confirmation_accept_button.mouse_button1_click = btn4
          ui.my_negotiation_offer_pane.add_item_callback = btn5
        else
          SetCooldown('AutoTrade', 'next_trade_after', _G.InternalConfig.TradeDLib.FallbackDelay)
          return
        end
        if not confirmed then
          local _cdl = _G.InternalConfig.TradeDLib.FallbackDelay
          WriteConsoleLog("[Auto Trade]: Trade unsuccessed", "[🔄]:[❌] Trade unsuccessed.", "ERROR")
          WriteFileLog("[Auto Trade]: Trade unsuccessed", "ERROR")
          __Notify("Error", "Trade unsuccessed", Constant.NotifyDuration.ERROR)
          if _G.InternalConfig.TradeDLib.DiscordWebhookLog then 
            if _G.InternalConfig.WebhookDLib.DiscordDLib.Enabled then 
              Webhook(
                "Trade-Log",
                "```diff\n- Trade with " 
                .. user 
                .. " unsuccessed. Timeout: [" 
                .. _cdl 
                .. "]s.\n```"
              )
            else
              __Notify("Warning", "Unable to send discord webhook log due to discord logs are disabled.", Constant.NotifyDuration["WARNING"]) 
            end
          end
          if _G.InternalConfig.TradeDLib.TelegramWebhookLog then
            if _G.InternalConfig.WebhookDLib.TelegramDLib.Enabled then
              TelegramWebhook(string.format([[
              <code>Trade-Log</code>
                <b>Trade with %s unsuccessed. Timeout: [%d]s.</b>
              ]], user, _cdl))
            else
              __Notify("Warning", "Unable to send telegram webhook log due to telegram logs are disabled.", Constant.NotifyDuration["WARNING"]) 
            end
          end
          SetCooldown('AutoTrade', 'next_trade_after', _cdl)
          return
        end
        WriteConsoleLog(string.format("[Auto Trade]: Trade with {%s} succeeded", user), string.format("[🔄]:[✅] Trade with %s succeeded.", user), "DEBUG")
        WriteFileLog(string.format("[Auto Trade]: Trade with {%s} succeeded", user), "DEBUG")
        __Notify("Success", string.format("Trade with %s succeeded", user), Constant.NotifyDuration.SUCCESS)
        if _G.InternalConfig.TradeDLib.DiscordWebhookLog then 
          if _G.InternalConfig.WebhookDLib.DiscordDLib.Enabled then 
            Webhook("Trade-Log", "```diff\n+ Trade with " .. user .. " succeeded.\n```")		
          else
            __Notify("Warning", "Unable to send discord webhook log due discord logs are disabled.", Constant.NotifyDuration["WARNING"]) 
          end
        end
        if _G.InternalConfig.TradeDLib.TelegramWebhookLog then
          if _G.InternalConfig.WebhookDLib.TelegramDLib.Enabled then
            TelegramWebhook(string.format([[
            <code>Trade-Log</code>
              <b>Trade with %s succeeded.</b>
            ]], user))
          else
            __Notify("Warning", "Unable to send discord webhook log due telegram logs are disabled.", Constant.NotifyDuration["WARNING"]) 
          end
        end
        SetCooldown('AutoTrade', 'next_trade_after', _G.InternalConfig.TradeDLib.TradeDelay)
        if need_repeat then
          __Notify("Info", "Detected more than 18 pets to trade. Trade will be repeated soon.", Constant.NotifyDuration["INFO"])
          SetCooldown('AutoTrade', 'next_trade_after', 5)
        end
      else
        SetCooldown('AutoTrade', 'next_trade_after', 60)
      end
    end,
    function()
      return Mutable.Cooldown.AutoTrade.next_trade_after[1] == 0
    end,
    function()
      SetCooldown('AutoTrade', 'next_trade_after', _G.InternalConfig.TradeDLib.FallbackDelay)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.WebhookDLib.DiscordDLib.Enabled then
    InitCooldown('Webhooks', 'discord_webhook_send_delay', 'discord_webhook_send_handler')
    SetCooldown('Webhooks', 'discord_webhook_send_delay', _G.InternalConfig.WebhookDLib.DiscordDLib.SendDelay)

    Mutable.Registry.RegisterTask("discord_webhook_send_handler", function() 
      local desc = string.format([[
        > 💸 Money Earned - [ **%d** ]
        > 📈 Pets Full-grown - [ **%d** ]
        > 🐶 Pet Needs Completed - [ **%d** ]
        > 🧪 Potions Farmed - [ **%d** ]
        > 🧸 Friendship Levels Farmed - [ **%d** ]
        > 👶 Baby Needs Completed - [ **%d** ]
        > 🥚 Eggs Hatched - [ **%d** ]
        > 🎫 Tickets - [ **%d** ]
        > 🍬 Candies farmed - [ **%d** ]
        ---------------------------------------
        > 💸 Total Bucks - [ **%d** ]
        > 🍬 Total candies - [ **%d** ]
        ---------------------------------------
        > ⏰ Runtime - [ **%s** ]
        ]],
        Mutable.Farmed.money,
        Mutable.Farmed.pets_fullgrown,
        Mutable.Farmed.ailments,
        Mutable.Farmed.potions,
        Mutable.Farmed.friendship_levels,
        Mutable.Farmed.baby_ailments,
        Mutable.Farmed.eggs_hatched,
        (Mutable.Modules.ClientData.get("pet_recycler_tickets_2026") or 0) + (Mutable.Modules.ClientData.get("pet_recycler_manager").saved_tickets or 0),
        (Mutable.Modules.ClientData.get("candy_2026") or 0) - Mutable.StateDB.event_starter_value,
        Mutable.Modules.ClientData.get("money") :: number,
        Mutable.Modules.ClientData.get("candy_2026") or 0,
        FormatTime(Mutable.Farmed.time)
      )

      if not Webhook(
        "Farm-Log",
        desc
      ) then
        error("", 0)      
      end
      SetCooldown('Webhooks', 'discord_webhook_send_delay', _G.InternalConfig.WebhookDLib.DiscordDLib.SendDelay)
    end,
    function()
      return Mutable.Cooldown.Webhooks.discord_webhook_send_delay[1] == 0  
    end,
    function()
      SetCooldown('Webhooks', 'discord_webhook_send_delay', 5)
    end)
    task.wait(1)
  end

  if _G.InternalConfig.WebhookDLib.TelegramDLib.Enabled then
    InitCooldown('Webhooks', 'telegram_webhook_send_delay', 'telegram_webhook_send_handler')
    SetCooldown('Webhooks', 'telegram_webhook_send_delay', _G.InternalConfig.WebhookDLib.TelegramDLib.SendDelay)

    Mutable.Registry.RegisterTask("telegram_webhook_send_handler", function() 
      local msg = string.format([[
        <b>Farm-Log</b>
        <code>%s</code>
        <b>💸 Money Earned</b> – <code>%d</code>
        <b>📈 Pets Full-grown</b> – <code>%d</code>
        <b>🐶 Pet Needs Completed</b> – <code>%d</code>
        <b>🧪 Potions Farmed</b> – <code>%d</code>
        <b>🧸 Friendship Levels Farmed</b> – <code>%d</code>
        <b>👶 Baby Needs Completed</b> – <code>%d</code>
        <b>🥚 Eggs Hatched</b> – <code>%d</code>
        -----------------------------------------------
        <b>💸 Total Bucks</b> – <code>%d</code>
        -----------------------------------------------
        <b>⏰ Runtime</b> – <code>%s</code>
        ]],
        LocalPlayer.Name,
        Mutable.Farmed.money,
        Mutable.Farmed.pets_fullgrown,
        Mutable.Farmed.ailments,
        Mutable.Farmed.potions,
        Mutable.Farmed.friendship_levels,
        Mutable.Farmed.baby_ailments,
        Mutable.Farmed.eggs_hatched,
        Mutable.Modules.ClientData.get("money"),
        FormatTime(Mutable.Farmed.time)
      )
      if not TelegramWebhook(msg) then
        error('', 0)
      end
      SetCooldown('Webhooks', 'telegram_webhook_send_delay', _G.InternalConfig.WebhookDLib.TelegramDLib.SendDelay)
    end,
    function()
      return Mutable.Cooldown.Webhooks.telegram_webhook_send_delay[1] == 0
    end,
    function()
      SetCooldown('Webhooks', 'telegram_webhook_send_delay', 5)
    end)
    task.wait(1)
  end
end)

if _G.EXEC > 1 then
  __Notify("Warning", "Arcanic is already injected. Relaunch for re-execute.", 6)
  print("Arcanic is already injected. Relaunch for re-execute.")
else
  _G.ERR = false
  local _successed = false
  local HttpService = game:GetService("HttpService")

  local function Count(t)
    local n = 0
    for _ in pairs(t) do
      n +=1 
    end
    return n
  end

  _G.ConfigFilter = {
    ["SpecificGiftFilter"] = {
      ["chests"] = true,
      ["massivegift"] = true,
      ["biggift"] = true,
      ["smallgift"] = true,
    },
    ["RaritiesFilter"] = {
      ["common"] = "common",
      ["uncommon"] = "uncommon",
      ["rare"] = "rare",
      ["ultra-rare"] = "ultra_rare",
      ["legendary"] = "legendary",
    },
    ["AgesFilter"] = {
      ["newborn"] = 1,
      ["junior"] = 2,
      ["pre-teen"] = 3,
      ["teen"] = 4,
      ["post-teen"] = 5,
      ["fullgrown"] = 6,
    },
    ["PropertiesFilter"] = {
      ["neon"] = "neon",
      ["meganeon"] = "meganeon",
      ["flyable"] = "flyable",
      ["rideable"] = "rideable",      
    },
    ["TradeCategoriesFilter"] = {
      ["pets"] = true,
      ["food"] = true,
      ["toys"] = true,
      ["strollers"] = true,
      ["pet_accessories"] = true,
      ["gifts"] = true,
      ["transport"] = true,
    },
    
    EggRemotes = {
      ["endangered_egg"] = {"endangered_2026_endangered_egg", 750},
      ["pet_egg"] = {"regular_pet_egg", 600},
      ["royal_egg"] = {"royal_egg", 1450},
      ["cracked_egg"] = {"cracked_egg", 350},
    },
    
    GiftRemotes = {
      ['smallgift'] = {"smallgift", 70},
      ['biggift'] = {"biggift", 199},
      ["massivegift"] = {"massivegift", 499},
    },
  }
  _G.InternalConfig = { 
    PetFarmDLib = {}, 
    GiftAutoOpenDLib = {}, 
    AutoBuyDLib = { EggAutoBuyDLib = {}, GiftAutoBuyDLib = {}, }, 
    AutoNeonDLib = {}, 
    AutoMegaNeonDLib = {}, 
    TradeDLib = { Blacklist = {}, },
    WebhookDLib = { DiscordDLib = {}, TelegramDLib = {}, },
    PetRecyclerDLib = { Blacklist = {}, },
    AutoGivePotionDLib = { Blacklist = {}, }, 
    PetPenDLib = { Blacklist = {}, }, 
    OptimizationDLib ={}, 
    UtilitiesDLib = {}, 
    Event = {},
  } 
  local ok, err = pcall(function()
    local Config = _G.Config
    if Config.PetFarm then
      if type(Config.PetFarm.Enabled) == "boolean" then
        if Config.PetFarm.Enabled then
          _G.InternalConfig.PetFarmDLib.Enabled = Config.PetFarm.Enabled
          if type(Config.PetFarm.OppositeFarm) == "boolean" then
            _G.InternalConfig.PetFarmDLib.OppositeFarm = Config.PetFarm.OppositeFarm 
          else
            _G.ERR = "Wrong value set to { PetFarm >> OppositeFarm }"
            return
          end
          if type(Config.PetFarm.Detect2D_Kitty) == "boolean" then
            _G.InternalConfig.PetFarmDLib.Detect2D_Kitty = Config.PetFarm.Detect2D_Kitty 
          else
            _G.ERR = "Wrong value set to { PetFarm >> Detect2D_Kitty }"
            return
          end    
          if type(Config.PetFarm.PotionFarm) == "boolean" then
            _G.InternalConfig.PetFarmDLib.PotionFarm = Config.PetFarm.PotionFarm 
          else
            _G.ERR = "Wrong value set to { PetFarm >> PotionFarm }"
            return
          end
          if type(Config.PetFarm.FarmPriority) == "string" and not Config.PetFarm.FarmPriority:match("^%s*$") and (Config.PetFarm.FarmPriority == "pets" or Config.PetFarm.FarmPriority == "eggs") then
            _G.InternalConfig.PetFarmDLib.FarmPriority = Config.PetFarm.FarmPriority 
          else
            _G.ERR = "Wrong value set to { PetFarm >> FarmPriority }"
            return
          end
          if type(Config.PetFarm.PetsToExcludeFromFarm) == "string" then 
            if not Config.PetFarm.PetsToExcludeFromFarm:match("^%s*$") then
              _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm = {}
              for v in Config.PetFarm.PetsToExcludeFromFarm:gmatch("[^;]+") do
                _G.InternalConfig.PetFarmDLib.PetsToExcludeFromFarm[v:lower()] = true
              end
            end
          else
            _G.ERR = "Wrong value set to { PetFarm >> PetsToExcludeFromFarm }"
            return
          end
          if type(Config.PetFarm.UseBonusAgingPotions) == "boolean" then
            _G.InternalConfig.PetFarmDLib.UseBonusAgingPotions = Config.PetFarm.UseBonusAgingPotions
          else
            _G.ERR = "Wrong value set to { PetFarm >> UseBonusAgingPotions }"
            return
          end
          if type(Config.PetFarm.UseBonusBucksPotions) == "boolean" then
            _G.InternalConfig.PetFarmDLib.UseBonusBucksPotions = Config.PetFarm.UseBonusBucksPotions
          else
            _G.ERR = "Wrong value set to { PetFarm >> UseBonusBucksPotions }"
            return
          end
        end
      else
        _G.ERR = "Wrong value set to { PetFarm >> Enabled }"
        return
      end
    end
    if Config.BabyFarm then
      if type(Config.BabyFarm) == "boolean" then
        _G.InternalConfig.BabyFarm = Config.BabyFarm
      else
        _G.ERR = "Wrong value set to { BabyFarm }"
        return
      end
    end
    if Config.LureboxFarm then
      if type(Config.LureboxFarm) == "boolean" then
        _G.InternalConfig.LureboxFarm = Config.LureboxFarm
      else
        _G.ERR = "Wrong value set to { LureboxFarm }"
        return
      end
    end
    if Config.AutoClaimDailies then
      if type(Config.AutoClaimDailies) == "boolean" then
        _G.InternalConfig.AutoClaimDailies = Config.AutoClaimDailies
      else
        _G.ERR = "Wrong value set to { AutoClaimDailies }"
        return
      end
    end
    if Config.GiftAutoOpen then
      if type(Config.GiftAutoOpen.Enabled) == "boolean" then
        if Config.GiftAutoOpen.Enabled then
          _G.InternalConfig.GiftAutoOpenDLib.Enabled = true
          if type(Config.GiftAutoOpen.SpecificGiftsToOpen) == "string" then 
            if not Config.GiftAutoOpen.SpecificGiftsToOpen:match("^%s*$") then
              _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen = {}
              for v in Config.GiftAutoOpen.SpecificGiftsToOpen:gmatch("[^;]+") do
                if _G.InternalConfig.SpecificGiftFilter[v:lower()] then
                  _G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen[_G.InternalConfig.SpecificGiftFilter[v:lower()]] = true
                end
              end
              if Count(_G.InternalConfig.GiftAutoOpenDLib.SpecificGiftsToOpen) == 0 then
                _G.ERR = "Wrong value set to { GiftAutoOpen >> SpecificGiftsToOpen }"
                return
              end
            end
          else
            _G.ERR = "Wrong value set to { GiftAutoOpen >> SpecificGiftsToOpen }"
            return
          end
        end
      else
        _G.ERR = "Wrong value set to { GiftAutoOpen >> Enabled }"
        return
      end
    end
    if Config.AutoBuy then
      if Config.AutoBuy.EggAutoBuy then
        if type(Config.AutoBuy.EggAutoBuy.Enabled) == "boolean" then
          if Config.AutoBuy.EggAutoBuy.Enabled then
            _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.Enabled = true
            if type(Config.AutoBuy.EggAutoBuy.EggToBuy) == "string" and _G.ConfigFilter.EggRemotes[Config.AutoBuy.EggAutoBuy.EggToBuy:lower()] then
              _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.EggToBuy = Config.AutoBuy.EggAutoBuy.EggToBuy:lower()
            else
              _G.ERR = "Wrong value set to { AutoBuy >> EggAutoBuy >> EggToBuy }"
              return
            end
            if type(Config.AutoBuy.EggAutoBuy.BuyCount) == "number" then
              if Config.AutoBuy.EggAutoBuy.BuyCount == 0 then
                _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.Enabled = false
              elseif Config.AutoBuy.EggAutoBuy.BuyCount == -1 then
                _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.BuyCount = 1999999
              elseif Config.AutoBuy.EggAutoBuy.BuyCount < -1 then   
                _G.ERR = "Wrong value set to { AutoBuy >> EggAutoBuy >> BuyCount }"
                return
              else
                _G.InternalConfig.AutoBuyDLib.EggAutoBuyDLib.BuyCount = Config.AutoBuy.EggAutoBuy.BuyCount
              end
            else  
              _G.ERR = "Wrong value set to { AutoBuy >> EggAutoBuy >> BuyCount }"
              return
            end
          end
        else  
          _G.ERR = "Wrong value set to { AutoBuy >> EggAutoBuy >> Enabled }"
          return
        end
      end
      if Config.AutoBuy.GiftAutoBuy then
        if type(Config.AutoBuy.GiftAutoBuy.Enabled) == "boolean" then
          if Config.AutoBuy.GiftAutoBuy.Enabled then
            _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.Enabled = true
            if type(Config.AutoBuy.GiftAutoBuy.GiftToBuy) == "string" and _G.ConfigFilter.GiftRemotes[Config.AutoBuy.GiftAutoBuy.GiftToBuy:lower()] then
              _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.GiftToBuy = Config.AutoBuy.GiftAutoBuy.GiftToBuy:lower()
            else
              _G.ERR = "Wrong value set to { AutoBuy >> GiftAutoBuy >> GiftToBuy }"
              return
            end
            if type(Config.AutoBuy.GiftAutoBuy.BuyCount) == "number" then
              if Config.AutoBuy.GiftAutoBuy.BuyCount == 0 then
                _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.Enabled = false
              elseif Config.AutoBuy.GiftAutoBuy.BuyCount == -1 then
                _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.BuyCount = 1999999
              elseif Config.AutoBuy.GiftAutoBuy.BuyCount < -1 then   
                _G.ERR = "Wrong value set to { AutoBuy >> GiftAutoBuy >> BuyCount }"
                return
              else
                _G.InternalConfig.AutoBuyDLib.GiftAutoBuyDLib.BuyCount = Config.AutoBuy.GiftAutoBuy.BuyCount
              end
            else  
              _G.ERR = "Wrong value set to { AutoBuy >> GiftAutoBuy >> BuyCount }"
              return
            end
          end
        else  
          _G.ERR = "Wrong value set to { AutoBuy >> GiftAutoBuy >> Enabled }"
          return
        end
      end
      if type(Config.AutoBuy.MinimumCashReserve) == "number" then
        if Config.AutoBuy.MinimumCashReserve < 0 then
          _G.ERR = "Wrong value set to { AutoBuy >> MinimumCashReserve }"
          return
        end
        _G.InternalConfig.AutoBuyDLib.MinimumCashReserve = Config.AutoBuy.MinimumCashReserve
      else
        _G.ERR = "Wrong value set to { AutoBuy >> MinimumCashReserve }"
        return
      end
    end
    if Config.AutoGivePotion then
      if type(Config.AutoGivePotion.Enabled) == "boolean" then
        if Config.AutoGivePotion.Enabled then
          _G.InternalConfig.AutoGivePotionDLib.Enabled = true
          if type(Config.AutoGivePotion.SetHigherPriorityFor) == "string" then
            if not Config.AutoGivePotion.SetHigherPriorityFor:match("^%s*$") then
              _G.InternalConfig.AutoGivePotionDLib.SetHigherPriorityFor = {}
              for v in Config.AutoGivePotion.SetHigherPriorityFor:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  table.insert(_G.InternalConfig.AutoGivePotionDLib.SetHigherPriorityFor, _G.ConfigFilter.RaritiesFilter[v])
                else
                  _G.ERR = "Wrong value set to { AutoGivePotion >> SetHigherPriorityFor }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoGivePotion >> SetHigherPriorityFor }"
            return
          end
          if type(Config.AutoGivePotion.Blacklist.Rarities) == "string" then
            if not Config.AutoGivePotion.Blacklist.Rarities:match("^%s*$") then
              _G.InternalConfig.AutoGivePotionDLib.Blacklist.Rarities = {}
              for v in Config.AutoGivePotion.Blacklist.Rarities:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  _G.InternalConfig.AutoGivePotionDLib.Blacklist.Rarities[_G.ConfigFilter.RaritiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoGivePotion >> Blacklist >> Rarities }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoGivePotion >> Blacklist >> Rarities }"
            return
          end
          if type(Config.AutoGivePotion.Blacklist.Ages) == "string" then
            if not Config.AutoGivePotion.Blacklist.Ages:match("^%s*$") then
              _G.InternalConfig.AutoGivePotionDLib.Blacklist.Ages = {}
              for v in Config.AutoGivePotion.Blacklist.Ages:gmatch("[^;]+") do
                if _G.ConfigFilter.AgesFilter[v] then
                  _G.InternalConfig.AutoGivePotionDLib.Blacklist.Ages[_G.ConfigFilter.AgesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoGivePotion >> Blacklist >> Ages }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoGivePotion >> Blacklist >> Ages }"
            return
          end
          if type(Config.AutoGivePotion.Blacklist.Properties) == "string" then
            if not Config.AutoGivePotion.Blacklist.Properties:match("^%s*$") then
              _G.InternalConfig.AutoGivePotionDLib.Blacklist.Properties = {}
              for v in Config.AutoGivePotion.Blacklist.Properties:gmatch("[^;]+") do
                if _G.ConfigFilter.PropertiesFilter[v] then
                  _G.InternalConfig.AutoGivePotionDLib.Blacklist.Properties[_G.ConfigFilter.PropertiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoGivePotion >> Blacklist >> Properties }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoGivePotion >> Blacklist >> Properties }"
            return
          end
          if type(Config.AutoGivePotion.Blacklist.SpecificPets) == "string" then
            if not Config.AutoGivePotion.Blacklist.SpecificPets:match("^%s*$") then
              _G.InternalConfig.AutoGivePotionDLib.Blacklist.SpecificPets = {}
              for v in Config.AutoGivePotion.Blacklist.SpecificPets:gmatch("[^;]+") do
                _G.InternalConfig.AutoGivePotionDLib.Blacklist.SpecificPets[v:lower()] = true
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoGivePotion >> Blacklist >> SpecificPets }"
            return
          end
        end
      else 
        _G.ERR = "Wrong value set to { AutoGivePotion >> Enabled }"
        return
      end
    end
    if Config.PetPen then
      if type(Config.PetPen.Enabled) == "boolean" then
        if Config.PetPen.Enabled then
          _G.InternalConfig.PetPenDLib.Enabled = true
          if type(Config.PetPen.UsePriority) == "string" and not Config.PetPen.UsePriority:match("^%s*$") and (Config.PetPen.UsePriority == "pets" or Config.PetPen.UsePriority == "eggs" or Config.PetPen.UsePriority == "any") then
            _G.InternalConfig.PetPenDLib.UsePriority = Config.PetPen.UsePriority
          else
            _G.ERR = "Wrong value set to { PetPen >> UsePriority }"
            return
          end
          if type(Config.PetPen.PrioritizedRarities) == "string" then
            if not Config.PetPen.PrioritizedRarities:match("^%s*$") then
              _G.InternalConfig.PetPenDLib.PrioritizedRarities = {}
              for v in Config.PetPen.PrioritizedRarities:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  table.insert(_G.InternalConfig.PetPenDLib.PrioritizedRarities, _G.ConfigFilter.RaritiesFilter[v])
                else
                  _G.ERR = "Wrong value set to { PetPen >> PrioritizedRarities }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { PetPen >> PrioritizedRarities }"
            return
          end
          if type(Config.PetPen.Blacklist.Rarities) == "string" then
            if not Config.PetPen.Blacklist.Rarities:match("^%s*$") then
              _G.InternalConfig.PetPenDLib.Blacklist.Rarities = {}
              for v in Config.PetPen.Blacklist.Rarities:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  _G.InternalConfig.PetPenDLib.Blacklist.Rarities[_G.ConfigFilter.RaritiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { PetPen >> Blacklist >> Rarities }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { PetPen >> Blacklist >> Rarities }"
            return
          end
          if type(Config.PetPen.Blacklist.Ages) == "string" then
            if not Config.PetPen.Blacklist.Ages:match("^%s*$") then
              _G.InternalConfig.PetPenDLib.Blacklist.Ages = {}
              for v in Config.PetPen.Blacklist.Ages:gmatch("[^;]+") do
                if _G.ConfigFilter.AgesFilter[v] then
                  _G.InternalConfig.PetPenDLib.Blacklist.Ages[_G.ConfigFilter.AgesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { PetPen >> Blacklist >> Ages }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { PetPen >> Blacklist >> Ages }"
            return
          end
          if type(Config.PetPen.Blacklist.Properties) == "string" then
            if not Config.PetPen.Blacklist.Properties:match("^%s*$") then
              _G.InternalConfig.PetPenDLib.Blacklist.Properties = {}
              for v in Config.PetPen.Blacklist.Properties:gmatch("[^;]+") do
                if _G.ConfigFilter.PropertiesFilter[v] then
                  _G.InternalConfig.PetPenDLib.Blacklist.Properties[_G.ConfigFilter.PropertiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { PetPen >> Blacklist >> Properties }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { PetPen >> Blacklist >> Properties }"
            return
          end
          if type(Config.PetPen.Blacklist.SpecificPets) == "string" then
            if not Config.PetPen.Blacklist.SpecificPets:match("^%s*$") then
              _G.InternalConfig.PetPenDLib.Blacklist.SpecificPets = {}
              for v in Config.PetPen.Blacklist.SpecificPets:gmatch("[^;]+") do
                _G.InternalConfig.PetPenDLib.Blacklist.SpecificPets[v:lower()] = true
              end
            end
          else
            _G.ERR = "Wrong value set to { PetPen >> Blacklist >> SpecificPets }"
            return
          end
          if type(Config.PetPen.Blacklist.ExcludeFriendly) == "boolean" then
            _G.InternalConfig.PetPenDLib.Blacklist.ExcludeFriendly = Config.PetPen.Blacklist.ExcludeFriendly
          else
            _G.ERR = "Wrong value set to { PetPen >> Blacklist >> ExcludeFriendly }"
            return
          end
        end
      else
        _G.ERR = "Wrong value set to { PetPen >> Enabled }"
        return
      end
    end
    if Config.AutoNeon then
      if type(Config.AutoNeon.Enabled) == "boolean" then
        if Config.AutoNeon.Enabled then
          _G.InternalConfig.AutoNeonDLib.Enabled = true

          if type(Config.AutoNeon.Blacklist.Rarities) == "string" then
            if not Config.AutoNeon.Blacklist.Rarities:match("^%s*$") then
              _G.InternalConfig.AutoNeonDLib.Blacklist.Rarities = {}
              for v in Config.AutoNeon.Blacklist.Rarities:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  _G.InternalConfig.AutoNeonDLib.Blacklist.Rarities[_G.ConfigFilter.RaritiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoNeon >> Blacklist >> Rarities }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoNeon >> Blacklist >> Rarities }"
            return
          end
          if type(Config.AutoNeon.Blacklist.Ages) == "string" then
            if not Config.AutoNeon.Blacklist.Ages:match("^%s*$") then
              _G.InternalConfig.AutoNeonDLib.Blacklist.Ages = {}
              for v in Config.AutoNeon.Blacklist.Ages:gmatch("[^;]+") do
                if _G.ConfigFilter.AgesFilter[v] then
                  _G.InternalConfig.AutoNeonDLib.Blacklist.Ages[_G.ConfigFilter.AgesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoNeon >> Blacklist >> Ages }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoNeon >> Blacklist >> Ages }"
            return
          end
          if type(Config.AutoNeon.Blacklist.Properties) == "string" then
            if not Config.AutoNeon.Blacklist.Properties:match("^%s*$") then
              _G.InternalConfig.AutoNeonDLib.Blacklist.Properties = {}
              for v in Config.AutoNeon.Blacklist.Properties:gmatch("[^;]+") do
                if _G.ConfigFilter.PropertiesFilter[v] then
                  _G.InternalConfig.AutoNeonDLib.Blacklist.Properties[_G.ConfigFilter.PropertiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoNeon >> Blacklist >> Properties }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoNeon >> Blacklist >> Properties }"
            return
          end
          if type(Config.AutoNeon.Blacklist.SpecificPets) == "string" then
            if not Config.AutoNeon.Blacklist.SpecificPets:match("^%s*$") then
              _G.InternalConfig.AutoNeonDLib.Blacklist.SpecificPets = {}
              for v in Config.AutoNeon.Blacklist.SpecificPets:gmatch("[^;]+") do
                _G.InternalConfig.AutoNeonDLib.Blacklist.SpecificPets[v:lower()] = true
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoNeon >> Blacklist >> SpecificPets }"
            return
          end
        end
      else
        _G.ERR = "Wrong value set to { AutoNeon >> Enabled }"
        return
      end
    end
    if Config.AutoMegaNeon then
      if type(Config.AutoMegaNeon.Enabled) == "boolean" then
        if Config.AutoMegaNeon.Enabled then
          _G.InternalConfig.AutoMegaNeonDLib.Enabled = true

          if type(Config.AutoMegaNeon.Blacklist.Rarities) == "string" then
            if not Config.AutoMegaNeon.Blacklist.Rarities:match("^%s*$") then
              _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Rarities = {}
              for v in Config.AutoMegaNeon.Blacklist.Rarities:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Rarities[_G.ConfigFilter.RaritiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoMegaNeon >> Blacklist >> Rarities }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoMegaNeon >> Blacklist >> Rarities }"
            return
          end
          if type(Config.AutoMegaNeon.Blacklist.Ages) == "string" then
            if not Config.AutoMegaNeon.Blacklist.Ages:match("^%s*$") then
              _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Ages = {}
              for v in Config.AutoMegaNeon.Blacklist.Ages:gmatch("[^;]+") do
                if _G.ConfigFilter.AgesFilter[v] then
                  _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Ages[_G.ConfigFilter.AgesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoMegaNeon >> Blacklist >> Ages }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoMegaNeon >> Blacklist >> Ages }"
            return
          end
          if type(Config.AutoMegaNeon.Blacklist.Properties) == "string" then
            if not Config.AutoMegaNeon.Blacklist.Properties:match("^%s*$") then
              _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Properties = {}
              for v in Config.AutoMegaNeon.Blacklist.Properties:gmatch("[^;]+") do
                if _G.ConfigFilter.PropertiesFilter[v] then
                  _G.InternalConfig.AutoMegaNeonDLib.Blacklist.Properties[_G.ConfigFilter.PropertiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoMegaNeon >> Blacklist >> Properties }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoMegaNeon >> Blacklist >> Properties }"
            return
          end
          if type(Config.AutoMegaNeon.Blacklist.SpecificPets) == "string" then
            if not Config.AutoMegaNeon.Blacklist.SpecificPets:match("^%s*$") then
              _G.InternalConfig.AutoMegaNeonDLib.Blacklist.SpecificPets = {}
              for v in Config.AutoMegaNeon.Blacklist.SpecificPets:gmatch("[^;]+") do
                _G.InternalConfig.AutoMegaNeonDLib.Blacklist.SpecificPets[v:lower()] = true
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoMegaNeon >> Blacklist >> SpecificPets }"
            return
          end
        end
      else
        _G.ERR = "Wrong value set to { AutoMegaNeon >> Enabled }"
        return
      end
    end
    if Config.PetRecycler then 
      if type(Config.PetRecycler.Enabled) == "boolean" then
        if Config.PetRecycler.Enabled then
          _G.InternalConfig.PetRecyclerDLib.Enabled = true
          if type(Config.PetRecycler.Blacklist.Rarities) == "string" then
            if not Config.PetRecycler.Blacklist.Rarities:match("^%s*$") then
              _G.InternalConfig.PetRecyclerDLib.Blacklist.Rarities = {}
              for v in Config.PetRecycler.Blacklist.Rarities:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  _G.InternalConfig.PetRecyclerDLib.Blacklist.Rarities[_G.ConfigFilter.RaritiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { PetRecycler >> Blacklist >> Rarities }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { PetRecycler >> Blacklist >> Rarities }"
            return
          end
          if type(Config.PetRecycler.Blacklist.Ages) == "string" then
            if not Config.PetRecycler.Blacklist.Ages:match("^%s*$") then
              _G.InternalConfig.PetRecyclerDLib.Blacklist.Ages = {}
              for v in Config.PetRecycler.Blacklist.Ages:gmatch("[^;]+") do
                if _G.ConfigFilter.AgesFilter[v] then
                  _G.InternalConfig.PetRecyclerDLib.Blacklist.Ages[_G.ConfigFilter.AgesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { PetRecycler >> Blacklist >> Ages }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { PetRecycler >> Blacklist >> Ages }"
            return
          end
          if type(Config.PetRecycler.Blacklist.Properties) == "string" then
            if not Config.PetRecycler.Blacklist.Properties:match("^%s*$") then
              _G.InternalConfig.PetRecyclerDLib.Blacklist.Properties = {}
              for v in Config.PetRecycler.Blacklist.Properties:gmatch("[^;]+") do
                if _G.ConfigFilter.PropertiesFilter[v] then
                  _G.InternalConfig.PetRecyclerDLib.Blacklist.Properties[_G.ConfigFilter.PropertiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { PetRecycler >> Blacklist >> Properties }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { PetRecycler >> Blacklist >> Properties }"
            return
          end
          if type(Config.PetRecycler.Blacklist.SpecificPets) == "string" then
            if not Config.PetRecycler.Blacklist.SpecificPets:match("^%s*$") then
              _G.InternalConfig.PetRecyclerDLib.Blacklist.SpecificPets = {}
              for v in Config.PetRecycler.Blacklist.SpecificPets:gmatch("[^;]+") do
                _G.InternalConfig.PetRecyclerDLib.Blacklist.SpecificPets[v:lower()] = true
              end
            end
          else
            _G.ERR = "Wrong value set to { PetRecycler >> Blacklist >> SpecificPets }"
            return
          end
        end
      else
        _G.ERR = "Wrong value set to { PetRecycler >> Enabled }"
        return
      end
    end
    if Config.AutoTrade then
      if type(Config.AutoTrade.Enabled) == "boolean" then
        if Config.AutoTrade.Enabled then
          _G.InternalConfig.TradeDLib.Enabled = true
          if type(Config.AutoTrade.PlayerTradeWith) == "string" then
            local ok, _ = pcall(function() game.Players:GetUserIdFromNameAsync(Config.AutoTrade.PlayerTradeWith) end)
            if not ok then
              _G.ERR = "User with specified name not exists. { AutoTrade >> PlayerTradeWith }"
              return
            end
            if Config.AutoTrade.PlayerTradeWith == game.Players.LocalPlayer.Name then
              _G.ERR = "You are trying to trade with yourself?... { AutoTrade >> PlayerTradeWith }"
              return
            end
            _G.InternalConfig.TradeDLib.PlayerTradeWith = Config.AutoTrade.PlayerTradeWith
          else
            _G.ERR = "Wrong value set to { AutoTrade >> PlayerTradeWith }"
            return
          end
          if type(Config.AutoTrade.TradePriority) == "string" and not Config.AutoTrade.TradePriority:match("^%s*$") and (Config.AutoTrade.TradePriority == "pets" or Config.AutoTrade.TradePriority == "eggs" or Config.AutoTrade.TradePriority == "any") then
            _G.InternalConfig.TradeDLib.TradePriority = Config.AutoTrade.TradePriority
          else
            _G.ERR = "Wrong value set to { AutoTrade >> TradePriority }"
            return
          end
          if type(Config.AutoTrade.TradeFarmed) == "boolean" then
            _G.InternalConfig.TradeDLib.TradeFarmed = Config.AutoTrade.TradeFarmed
          else
            _G.ERR = "Wrong value set to { AutoTrade >> TradeFarmed }"
            return
          end
          if type(Config.AutoTrade.TradeCategories) == "string" and not Config.AutoTrade.TradeCategories:match("^%s*$") then
            _G.InternalConfig.TradeDLib.TradeCategories = {}
            for v in Config.AutoTrade.TradeCategories:gmatch("[^;]+") do
              if _G.ConfigFilter.TradeCategoriesFilter[v:lower()] then 
                _G.InternalConfig.TradeDLib.TradeCategories[v:lower()] = true
              end
            end
            if Count(_G.InternalConfig.TradeDLib.TradeCategories) == 0 then
              _G.ERR = "Wrong value set to { AutoTrade >> TradeCategories }"
              return
            end
          else
            _G.ERR = "Wrong value set to { AutoTrade >> TradeCategories }"
            return
          end
          if type(Config.AutoTrade.TradeDelay) == "number" then
            if Config.AutoTrade.TradeDelay < 60 then
              _G.ERR = "Value cannot be lower than 60! { AutoTrade >> TradeDelay }"
              return
            end
            _G.InternalConfig.TradeDLib.TradeDelay = Config.AutoTrade.TradeDelay
          else
            _G.ERR = "Wrong value set to { AutoTrade >> TradeDelay }"
            return
          end
          if type(Config.AutoTrade.FallbackDelay) == "number" then
            if Config.AutoTrade.FallbackDelay < 1 then
              _G.ERR = "Value cannot be lower than 1! { AutoTrade >> FallbackDelay }"
              return
            end
            _G.InternalConfig.TradeDLib.FallbackDelay = Config.AutoTrade.FallbackDelay
          else
            _G.ERR = "Wrong value set to { AutoTrade >> FallbackDelay }"
            return
          end
          if type(Config.AutoTrade.DiscordWebhookLog) == "boolean" then
            _G.InternalConfig.TradeDLib.DiscordWebhookLog = Config.AutoTrade.DiscordWebhookLog
          else
            _G.ERR = "Wrong value set to { AutoTrade >> DiscordWebhookLog }"
            return
          end
          if type(Config.AutoTrade.TelegramWebhookLog) == "boolean" then
            _G.InternalConfig.TradeDLib.TelegramWebhookLog = Config.AutoTrade.TelegramWebhookLog
          else
            _G.ERR = "Wrong value set to { AutoTrade >> TelegramWebhookLog }"
            return
          end
          if type(Config.AutoTrade.Blacklist.Rarities) == "string" then
            if not Config.AutoTrade.Blacklist.Rarities:match("^%s*$") then
              _G.InternalConfig.TradeDLib.Blacklist.Rarities = {}
              for v in Config.AutoTrade.Blacklist.Rarities:gmatch("[^;]+") do
                if _G.ConfigFilter.RaritiesFilter[v] then
                  _G.InternalConfig.TradeDLib.Blacklist.Rarities[_G.ConfigFilter.RaritiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> Rarities }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> Rarities }"
            return
          end
          if type(Config.AutoTrade.Blacklist.Ages) == "string" then
            if not Config.AutoTrade.Blacklist.Ages:match("^%s*$") then
              _G.InternalConfig.TradeDLib.Blacklist.Ages = {}
              for v in Config.AutoTrade.Blacklist.Ages:gmatch("[^;]+") do
                if _G.ConfigFilter.AgesFilter[v] then
                  _G.InternalConfig.TradeDLib.Blacklist.Ages[_G.ConfigFilter.AgesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> Ages }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> Ages }"
            return
          end
          if type(Config.AutoTrade.Blacklist.Properties) == "string" then
            if not Config.AutoTrade.Blacklist.Properties:match("^%s*$") then
              _G.InternalConfig.TradeDLib.Blacklist.Properties = {}
              for v in Config.AutoTrade.Blacklist.Properties:gmatch("[^;]+") do
                if _G.ConfigFilter.PropertiesFilter[v] then
                  _G.InternalConfig.TradeDLib.Blacklist.Properties[_G.ConfigFilter.PropertiesFilter[v]] = true
                else
                  _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> Properties }"
                  return
                end
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> Properties }"
            return
          end
          if type(Config.AutoTrade.Blacklist.SpecificPets) == "string" then
            if not Config.AutoTrade.Blacklist.SpecificPets:match("^%s*$") then
              _G.InternalConfig.TradeDLib.Blacklist.SpecificPets = {}
              for v in Config.AutoTrade.Blacklist.SpecificPets:gmatch("[^;]+") do
                _G.InternalConfig.TradeDLib.Blacklist.SpecificPets[v:lower()] = true
              end
            end
          else
            _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> SpecificPets }"
            return
          end
          if type(Config.AutoTrade.Blacklist.ExcludeFriendly) == "boolean" then
            _G.InternalConfig.TradeDLib.Blacklist.ExcludeFriendly = Config.AutoTrade.Blacklist.ExcludeFriendly
          else
            _G.ERR = "Wrong value set to { AutoTrade >> Blacklist >> ExcludeFriendly }"
            return
          end
        end
      else
        _G.ERR = "Wrong value set to { AutoTrade >> Enabled }"
        return
      end
    end
    if Config.Webhook then
      if Config.Webhook.Discord then
        if type(Config.Webhook.Discord.Enabled) == "boolean" then
          if Config.Webhook.Discord.Enabled then
            _G.InternalConfig.WebhookDLib.DiscordDLib.Enabled = true
            if type(Config.Webhook.Discord.URL) == "string" then
              local ok, data = WebRequest(
                Config.Webhook.Discord.URL,
                'GET'
              )
              if not ok then
                _G.ERR = "Wrong URL { Webhook >> Discord >> URL }"
                return
              end
              if data.name then
                print("[+] " .. data.name .. " webhook initialized.")
              end
              _G.InternalConfig.WebhookDLib.DiscordDLib.URL = Config.Webhook.Discord.URL            
            else
              _G.ERR = "Wrong value set to { Webhook >> Discord >> URL }"
              return
            end
            if type(Config.Webhook.Discord.SendDelay) == "number" then
              if Config.Webhook.Discord.SendDelay < 60 then
                _G.ERR = "Value cannot be lower than 60! { Webhook >> Discord >> SendDelay }"
                return
              else
                _G.InternalConfig.WebhookDLib.DiscordDLib.SendDelay = Config.Webhook.Discord.SendDelay
              end
            else
              _G.ERR = "Wrong value set to { Webhook >> Discord >> SendDelay }"
              return
            end
          end
        else
          _G.ERR = "Wrong value set to { Webhook >> Discord >> Enabled}"
          return
        end
      end
      if Config.Webhook.Telegram then
        if type(Config.Webhook.Telegram.Enabled) == "boolean" then
          if Config.Webhook.Telegram.Enabled then
            _G.InternalConfig.WebhookDLib.TelegramDLib.Enabled = true 
            if type(Config.Webhook.Telegram.BotAPIKey) == "string" then
              local ok, data = WebRequest(
                "https://api.telegram.org/bot"..Config.Webhook.Telegram.BotAPIKey.."/getMe",
                'POST',
                { ["Content-Type"] = "application/json" }
              )
              if not ok then
                _G.ERR = "Telegram HTTP error occured while checking bot key. Check for key validity. { Webhook >> Telegram >> BotAPIKey }"
                return
              end
              if not data.ok then 
                _G.ERR = "Invalid bot API key! { Webhook >> Telegram >> BotAPIKey }"
                return
              end              
              _G.InternalConfig.WebhookDLib.TelegramDLib.BotAPIKey = Config.Webhook.Telegram.BotAPIKey
            else
              _G.ERR = "Wrong value set to { Webhook >> Telegram >> BotAPIKey}"
              return
            end
            if type(Config.Webhook.Telegram.ChatID) == "string" then
              local ok, data = WebRequest(
                "https://api.telegram.org/bot" .. _G.InternalConfig.WebhookDLib.TelegramDLib.BotAPIKey .. "/sendMessage",
                'POST',
                { ["Content-Type"] = "application/json" },
                HttpService:JSONEncode({
                  chat_id = Config.Webhook.Telegram.ChatID,
                  text = "Arcanic webhook init.."
                })
              )
              if not ok then 
                _G.ERR = "Telegram HTTP error occured while trying to send message to chat. { Webhook >> Telegram >> ChatID }"
                return
              end
              if not data.ok then
                _G.ERR = "Error while trying to send message to chat: " .. (data and data.description) or "Unknown Error" .. " { Webhook >> Telegram >> ChatID }"
                return
              end
              _G.InternalConfig.WebhookDLib.TelegramDLib.ChatID = Config.Webhook.Telegram.ChatID
            else
              _G.ERR = "Wrong value set to { Webhook >> Telegram >> ChatID}"
              return
            end  
            if type(Config.Webhook.Telegram.SendDelay) == "number" then
              if Config.Webhook.Telegram.SendDelay < 60 then
                _G.ERR = "Value cannot be lower than 60! { Webhook >> Telegram >> SendDelay }"
                return
              else
                _G.InternalConfig.WebhookDLib.TelegramDLib.SendDelay = Config.Webhook.Telegram.SendDelay
              end
            else
              _G.ERR = "Wrong value set to { Webhook >> Telegram >> SendDelay }"
              return
            end
          end
        else
          _G.ERR = "Wrong value set to { Webhook >> Telegram >> Enabled}"
          return
        end
      end
    end
    if Config.Optimization then
      if type(Config.Optimization.FPSCap) == "number" and Config.Optimization.FPSCap >= 0 then
        _G.InternalConfig.OptimizationDLib.FPSCap = Config.Optimization.FPSCap
      else
        _G.ERR = "Wrong value set to { Optimization >> FPSCap }"
        return
      end
    else
      _G.ERR = "Block <Optimization> cannot be removed!"
      return
    end
    if type(Config.Optimization.Rendering) == "boolean" then
      _G.InternalConfig.OptimizationDLib.Rendering = Config.Optimization.Rendering
    else
      _G.ERR = "Wrong value set to { Optimization >> Rendering }"
      return
    end
    if Config.Utilities then
      if type(Config.Utilities.WriteConsoleLogs) == "boolean" then
        _G.InternalConfig.UtilitiesDLib.WriteConsoleLogs = Config.Utilities.WriteConsoleLogs
      else  
        _G.ERR = "Wrong value set to { Utilities >> WriteConsoleLogs }"
        return
      end
      if type(Config.Utilities.WriteFileLogs) == "boolean" then
        _G.InternalConfig.UtilitiesDLib.WriteFileLogs = Config.Utilities.WriteFileLogs
      else  
        _G.ERR = "Wrong value set to { Utilities >> WriteFileLogs }"
        return
      end
      if type(Config.Utilities.AutoReconnect) == "boolean" then
        _G.InternalConfig.UtilitiesDLib.AutoReconnect = Config.Utilities.AutoReconnect
      else  
        _G.ERR = "Wrong value set to { Utilities >> AutoReconnect }"
        return
      end
      if type(Config.Utilities.GUINotifications) == "boolean" then
        _G.InternalConfig.UtilitiesDLib.GUINotifications = Config.Utilities.GUINotifications
      else  
        _G.ERR = "Wrong value set to { Utilities >> GUINotifications }"
        return
      end
    else
      _G.InternalConfig.UtilitiesDLib.AutoReconnect = true
      _G.InternalConfig.UtilitiesDLib.GUINotifications = true
    end
    if Config.Event then
      if type(Config.Event.AutoCollectDailies) == 'boolean' then
        _G.InternalConfig.Event.AutoCollectDailies = Config.Event.AutoCollectDailies
      else
        _G.ERR = "Wrong value set to { Event >> AutoCollectDailies }"
        return
      end
      if type(Config.Event.AutoUseCryptKeys) == 'boolean' then
        _G.InternalConfig.Event.AutoUseCryptKeys = Config.Event.AutoUseCryptKeys
      else
        _G.ERR = "Wrong value set to { Event >> AutoUseCryptKeys }"
        return
      end      
      if type(Config.Event.FeedStrayCat) == 'boolean' then
        _G.InternalConfig.Event.FeedStrayCat = Config.Event.FeedStrayCat
      else
        _G.ERR = "Wrong value set to { Event >> FeedStrayCat }"
        return
      end     
      if type(Config.Event.PlayGhostClustersMinigame) == 'boolean' then
        _G.InternalConfig.Event.PlayGhostClustersMinigame = Config.Event.PlayGhostClustersMinigame
      else
        _G.ERR = "Wrong value set to { Event >> PlayGhostClustersMinigame }"
        return
      end
      if type(Config.Event.AutoUseTwigs) == 'boolean' then
        _G.InternalConfig.Event.AutoUseTwigs = Config.Event.AutoUseTwigs
      else
        _G.ERR = "Wrong value set to { Event >> AutoUseTwigs }"
        return
      end
    end
    _successed = true
  end)
  if not _successed and not _G.ERR then
    _G.ERR = "Config init failed. Error: " .. err ..". Do not delete anything from config!"   
  end

  if _G.ERR then
    __Notify("Warning", "Script can't be loaded due to issues in config.", 12, true)
    __Notify("Error", _G.ERR, 12, true)
    print(_G.ERR .. "\n[-] Script can't be loaded due to issues in config.")
    _G.ERR = nil 
    _G.EXEC = 0
  else
    coroutine.resume(_script)
  end
end
