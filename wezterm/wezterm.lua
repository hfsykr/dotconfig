local wezterm = require "wezterm"
local config = wezterm.config_builder()

config.default_prog = { "pwsh.exe" }

config.color_scheme = "Dracula (Official)"

config.font = wezterm.font "JetBrains Mono"
config.font_size = 12
config.initial_rows = 18

config.window_close_confirmation = "NeverPrompt"

config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 30

config.audible_bell = "Disabled"

local process_names = {
    ["wsl"] = "WSL",
    ["wslhost"] = "WSL",
    ["pwsh"] = "PowerShell"
}

local process_icons = {
    ["wsl"] = wezterm.nerdfonts.cod_terminal_linux,
    ["wslhost"] = wezterm.nerdfonts.cod_terminal_linux,
    ["pwsh"] = wezterm.nerdfonts.cod_terminal_powershell
}

local function basename(s)
    return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab.tab_title
    local cwd = tab.active_pane.title
    local index = " [" .. (tab.tab_index + 1) .. "] "
    -- If the tab title is explicitly set, take that.
    if title and #title > 0 then
      return index .. title .. ": " .. basename(cwd) .. " "
    end

    local process_name = tab.active_pane.foreground_process_name:match("([^/\\]+)%.exe$")
    if process_name and #process_name > 0 then
        return index .. process_icons[process_name] .. " " .. process_names[process_name] .. ": " .. basename(tab.active_pane.title) .. " "
    end

    return " " .. tab.active_pane.title .. " "
end)

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local index = ""
    if #tabs > 1 then
      index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
    end

    -- This is working directory for WSL.
    local url = tab.active_pane.current_working_dir
    local cwd = ""
    if url ~= nil then
        cwd = url.file_path
    end

    -- If it's from windows, better using title from OSC for working directory.
    local domain = tab.active_pane.domain_name
    if domain == "local" then
        cwd = tab.active_pane.title
    end

    local process_name = tab.active_pane.foreground_process_name:match("([^/\\]+)%.exe$")
    if process_name and #process_name > 0 then
        return index .. process_names[process_name] .. ": " .. cwd
    end

    return index .. tab.active_pane.title
end)

config.launch_menu = {
    {
        label = "PowerShell",
        args = { "pwsh.exe" },
        domain = "DefaultDomain",
        cwd = "~"
    },
    {
        label = "WSL",
        domain = { DomainName = "WSL:fedoraremix" },
        cwd = "~"
    }
}

config.keys = {
    {
        key = "q",
        mods = "CTRL|SHIFT",
        action = wezterm.action.CloseCurrentTab { confirm = false },
    },
    {
        key = "t",
        mods = "CTRL|SHIFT",
        action = wezterm.action.SpawnCommandInNewTab {
            domain = "CurrentPaneDomain"
        },
    },
    {
        key = "Space",
        mods = "CTRL|SHIFT",
        action = wezterm.action.ShowLauncherArgs { flags = "LAUNCH_MENU_ITEMS" },
    },
    {
        key = "E",
        mods = "CTRL|SHIFT",
        action = wezterm.action.PromptInputLine {
            description = "Enter new name for tab",
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        },
    },
}

return config
