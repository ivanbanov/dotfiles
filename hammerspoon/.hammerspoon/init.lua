-- Ghostty
hs.hotkey.bind({ 'command' }, 'escape', function()
  -- local BUNDLE_ID = 'net.kovidgoyal.kitty'
  local BUNDLE_ID = 'com.mitchellh.ghostty'
  local app = hs.application.get(BUNDLE_ID)
  if app ~= nil and app:isFrontmost() then
    app:hide()
    return
  end

  hs.application.launchOrFocusByBundleID(BUNDLE_ID)
end)

-- Raycast
hs.hotkey.bind({ 'alt' }, 'space', function()
  local BUNDLE_ID = 'com.raycast.macos'
  local app = hs.application.get(BUNDLE_ID)
  if app ~= nil and app:isFrontmost() then
    app:hide()
    return
  end

  hs.application.launchOrFocusByBundleID(BUNDLE_ID)
end)

-- Google Gemini
-- hs.hotkey.bind({"alt"}, "space", function()
--   local HOME = os.getenv("HOME")
--   local GEMINI = HOME .. "/Applications/Chrome Apps.localized/Google Gemini.app"
--   local GEMINI_URL = "https://gemini.google.com"
--
--   local front = hs.application.frontmostApplication()
--
--   if front and front:path() == GEMINI and front:isFrontmost() then
--     front:hide()
--     return
--   end
--
--   local launched = hs.application.launchOrFocus(GEMINI)
-- end)
