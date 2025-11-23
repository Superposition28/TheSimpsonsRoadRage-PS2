--[[
Extract RCF files using Lucas' Radcore Cement Library Builder
Converts PowerShell script to Lua using RemakeEngine SDK methods
Original PS1: Get-ChildItem -Path $root -Recurse -File -Filter *.rcf | ForEach-Object { ... }
--]]

-- Parse command line arguments
local function parse_args(list)
    local opts = { extras = {} }
    local i = 1
    while i <= #list do
        local arg = list[i]
        if arg:match('^%-%-') then
            local key = arg:sub(3)
            if key:find('=') then
                local eq_pos = key:find('=')
                local k = key:sub(1, eq_pos - 1)
                local v = key:sub(eq_pos + 1)
                opts[k] = v
            elseif i + 1 <= #list and not list[i + 1]:match('^%-%-') then
                i = i + 1
                opts[key] = list[i]
            else
                opts[key] = true
            end
        else
            table.insert(opts.extras, arg)
        end
        i = i + 1
    end
    return opts
end

local opts = parse_args(argv or {...})

-- Configuration (with defaults)
local source_dir = opts.source or opts.src
local dest_dir = opts.dest or opts.destination or opts.output or './extracted'
local module_root = opts.module or opts['module-root'] or opts.module_root or '.'

-- Validate required parameters
if not source_dir then
    sdk.color_print('red', 'ERROR: Source directory is required')
    sdk.color_print('yellow', 'Usage: --source <path> [--dest <path>] [--module <path>]')
    error('Missing required parameter: source')
end

-- Color printing for user feedback
sdk.color_print('white', '=== RCF Extraction Tool ===')
sdk.color_print('cyan', 'Source directory: ' .. source_dir)
sdk.color_print('cyan', 'Destination directory: ' .. dest_dir)

-- Resolve tool path using RemakeEngine's tool resolution
local tool_name = 'Lucas_Radcore_Cement_Library_Builder'

local function resolve_lucas()
    local tool_fn = rawget(_G, "tool")
    local p = tool_fn(tool_name)
    if p and p ~= "" then
        return p
    end
    sdk.color_print("red", "Lucas executable not found via tool('" .. tool_name .. "'); ensure it is installed and configured in the engine.")
end

-- Try to resolve tool from the engine's tool registry
local exe_path = resolve_lucas()

if exe_path then
    sdk.color_print('green', 'Found tool: ' .. exe_path)
else
    sdk.color_print('red', 'ERROR: Could not find Lucas\' Radcore Cement Library Builder executable')
    sdk.color_print('yellow', 'Please ensure the tool is downloaded via "Download Required Tools" operation')
    error('Tool not found: ' .. tool_name)
end

-- Validate source directory
if not sdk.path_exists(source_dir) then
    sdk.color_print('red', 'ERROR: Source directory does not exist: ' .. source_dir)
    error('Source directory not found')
end

if not sdk.is_dir(source_dir) then
    sdk.color_print('red', 'ERROR: Source path is not a directory: ' .. source_dir)
    error('Invalid source directory')
end

-- Ensure destination directory exists
sdk.ensure_dir(dest_dir)

-- Find all files recursively (both RCF and non-RCF)
sdk.color_print('yellow', 'Scanning for files...')

local rcf_files = {}
local other_files = {}
local function scan_directory(dir_path)
    local lfs = require('lfs')
    
    for entry in lfs.dir(dir_path) do
        if entry ~= '.' and entry ~= '..' then
            local full_path = dir_path .. '/' .. entry
            local attr = lfs.attributes(full_path)
            
            if attr then
                if attr.mode == 'directory' then
                    -- Recursively scan subdirectories
                    scan_directory(full_path)
                elseif attr.mode == 'file' then
                    if entry:lower():match('%.rcf$') then
                        -- Found an RCF file to extract
                        table.insert(rcf_files, full_path)
                    else
                        -- Found a regular file to copy
                        table.insert(other_files, full_path)
                    end
                end
            end
        end
    end
end

scan_directory(source_dir)

local total_rcf = #rcf_files
local total_other = #other_files
sdk.color_print('green', string.format('Found %d RCF files to extract and %d other files to copy', total_rcf, total_other))

if total_rcf == 0 and total_other == 0 then
    sdk.color_print('yellow', 'No files found. Exiting.')
    return
end

-- Normalize source root path for relative path calculation
local source_root = source_dir:gsub('[/\\]+$', '') -- Remove trailing slashes

-- Step 1: Copy non-RCF files
if total_other > 0 then
    sdk.color_print('white', '\n=== Copying non-RCF files ===')
    local copy_stage = script_progress(total_other, 'file-copy', 'Copying Files')
    
    for i, file_path in ipairs(other_files) do
        local rel_path = file_path:sub(#source_root + 2)
        local dest_path = dest_dir .. '/' .. rel_path
        
        -- Check if file is .ts (TextStyle XML) and needs to be renamed to .ts.xml
        local is_ts_file = file_path:lower():match('%.ts$')
        if is_ts_file then
            dest_path = dest_path .. '.xml'
        end
        
        -- Ensure destination directory exists
        local dest_dir_part = dest_path:match('(.+)[/\\][^/\\]+$')
        if dest_dir_part then
            sdk.ensure_dir(dest_dir_part)
        end
        
        -- Copy the file
        local success = sdk.copy_file(file_path, dest_path, true)
        if success then
            if i <= 5 or i == total_other then -- Show first 5 and last file
                local display_path = is_ts_file and (rel_path .. ' → ' .. rel_path .. '.xml') or rel_path
                sdk.color_print('cyan', string.format('  [%d/%d] Copied: %s', i, total_other, display_path))
            elseif i == 6 then
                sdk.color_print('gray', '  ... copying remaining files ...')
            end
        else
            sdk.color_print('red', string.format('  [%d/%d] Failed to copy: %s', i, total_other, rel_path))
            warn('Failed to copy: ' .. file_path)
        end
        
        copy_stage:Update()
    end
    
    sdk.color_print('green', string.format('Copied %d files', total_other))
end

-- Step 2: Extract RCF files
if total_rcf > 0 then
    sdk.color_print('white', '\n=== Extracting RCF archives ===')
    local extract_stage = script_progress(total_rcf, 'rcf-extraction', 'Extracting RCF Files')
    
    for i, rcf_path in ipairs(rcf_files) do
        -- Calculate relative path from source root
        local rel_path = rcf_path:sub(#source_root + 2)
        local dir_part = rel_path:match('(.+)[/\\][^/\\]+$') or ''
        local file_name = rel_path:match('[/\\]?([^/\\]+)$')
        local base_name = file_name:gsub('%.rcf$', ''):gsub('%.RCF$', '')
        
        -- Construct output directory path (replace .rcf with _rcf folder)
        local output_subdir = dir_part ~= '' and (dir_part .. '/' .. base_name .. '_rcf') or (base_name .. '_rcf')
        local output_path = dest_dir .. '/' .. output_subdir
        
        sdk.color_print('magenta', string.format('[%d/%d] Extracting: %s', i, total_rcf, file_name))
        sdk.color_print('cyan', '  Source: ' .. rcf_path)
        sdk.color_print('cyan', '  Output: ' .. output_path)
        
        -- Create output directory
        sdk.ensure_dir(output_path)
        
        -- Execute the extractor tool
        local exec_result = sdk.exec({exe_path, '-inputrcf', rcf_path, '-outputdir', output_path}, {
            wait = true,
            new_terminal = false
        })
        
        if exec_result and exec_result.success then
            sdk.color_print('green', '  ✓ Extraction successful')
        else
            local exit_code = exec_result and exec_result.exit_code or 'unknown'
            sdk.color_print('red', '  ✗ Extraction failed (exit code: ' .. tostring(exit_code) .. ')')
            warn('Failed to extract: ' .. rcf_path)
        end
        
        extract_stage:Update()
    end
end

-- Summary
sdk.color_print('white', '\n=================================')
sdk.color_print('green', string.format('Extraction complete!'))
sdk.color_print('green', string.format('  - Copied %d files', total_other))
sdk.color_print('green', string.format('  - Extracted %d RCF archives', total_rcf))
sdk.color_print('cyan', 'Output directory: ' .. dest_dir)
