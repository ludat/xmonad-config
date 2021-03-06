-- Imports {{{
import XMonad

import XMonad.Actions.CycleWS (toggleWS, WSType(AnyWS))
import XMonad.Actions.DynamicWorkspaces
    ( addWorkspace, addWorkspacePrompt, removeWorkspace, selectWorkspace,
    withWorkspace, renameWorkspace)
import XMonad.Actions.DynamicWorkspaceOrder as DO

import XMonad.Hooks.DynamicLog
    ( dynamicLogWithPP, ppOutput, ppHiddenNoWindows, ppSort)
import XMonad.Hooks.ManageDocks
    ( manageDocks, docksEventHook, avoidStruts, ToggleStruts(ToggleStruts))
import XMonad.Hooks.Minimize (minimizeEventHook)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhDesktopsEventHook)

import XMonad.Prompt
    (XPPosition(Top), Direction1D(Next,Prev), XPConfig(position),
    searchPredicate)
import XMonad.Prompt.Window (windowPromptGoto, windowPromptBring)
import XMonad.Prompt.AppendFile (appendFilePrompt)
import XMonad.Prompt.Shell (shellPrompt)

import XMonad.Util.Run (hPutStrLn, spawnPipe)
import XMonad.Util.EZConfig (mkKeymap)

import XMonad.Layout.SimpleFloat (simpleFloat)
import XMonad.Layout.Minimize
    (minimize, minimizeWindow, MinimizeMsg(RestoreNextMinimizedWin))
import XMonad.Layout.Maximize (maximize, maximizeRestore)
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.Accordion (Accordion(Accordion))
import XMonad.Layout.ThreeColumns (ThreeCol(ThreeColMid))
import XMonad.Layout.BoringWindows (boringWindows, focusUp, focusDown)
import XMonad.Layout.NoBorders (smartBorders)

import System.Exit
import XMonad.Hooks.SetWMName (setWMName)

import qualified XMonad.StackSet    as W
import qualified Data.Map           as M
import qualified Data.List          as L
-- }}}
-- Common defaults {{{
-- The preferred terminal program, which is used in a binding below and by
home :: String
home = "/home/ludat/"
-- certain contrib modules.
myTerminal :: String
myTerminal = "urxvtc"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
myModMask :: KeyMask
myModMask = mod4Mask

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor :: String
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor :: String
myFocusedBorderColor = "#ff0000"
-- }}}
-- Workspaces {{{
-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.

-- A tagging example:

-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
myWorkspaces :: [String]
myWorkspaces = ["term"]
-- }}}
-- Key bindings. Add, modify or remove key bindings here. {{{
myXPConfig :: XPConfig
myXPConfig = def {
                    position = Top
                    , searchPredicate = L.isInfixOf
                }

        -- , ( "M-m"   , windows W.focusMaster)
        -- , ( "M-n"   , refresh)
        -- , ( "M-S-m" , withWorkspace myXPConfig (windows . copy))
        -- , ( "M-p"   , spawn "dmenu_run")

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@XConfig {XMonad.modMask = modm} = mkKeymap conf
        [( "M-S-<Return>"    , spawn $ XMonad.terminal conf)
        , ( "M-p"             , shellPrompt myXPConfig)
        , ( "M-c"             , kill)
        , ( "M-<Space>"       , sendMessage NextLayout)
        , ( "M-S-<Space>"     , setLayout $ XMonad.layoutHook conf)
        -- , ( "M-<Tab>"         , rotOpposite)
        , ( "M-<Up>"          , focusUp)
        , ( "M-<Down>"        , focusDown)
        , ( "M-<Tab>"         , focusDown)
        , ( "M-S-<Tab>"       , focusUp)
        , ( "M-<Return>"      , windows W.swapMaster)
        , ( "M-S-j"           , windows W.swapDown)
        , ( "M-S-k"           , windows W.swapUp)
        , ( "M-S-h"           , sendMessage Shrink)
        , ( "M-S-l"           , sendMessage Expand)
        , ( "M-t"             , withFocused $ windows . W.sink)
        , ( "M-,"             , sendMessage $ IncMasterN 1)
        , ( "M-."             , sendMessage $ IncMasterN (-1))
        , ( "M-b"             , sendMessage ToggleStruts)

        , ( "M-<Right>"       , DO.moveTo Next AnyWS)
        , ( "M-<Left>"        , DO.moveTo Prev AnyWS)
        , ( "M-S-<Right>"     , DO.shiftTo Next AnyWS >> DO.moveTo Next AnyWS)
        , ( "M-S-<Right>"     , DO.shiftTo Prev AnyWS >> DO.moveTo Prev AnyWS)
        , ( "M-M1-<Right>"    , DO.swapWith Next AnyWS)
        , ( "M-M1-<Left>"     , DO.swapWith Prev AnyWS)

        , ( "M-z"             , toggleWS)
        , ( "M-S-g"           , windowPromptGoto  myXPConfig)
        , ( "M-S-b"           , windowPromptBring myXPConfig)

        , ( "M-s"             , withFocused minimizeWindow)
        , ( "M-S-s"           , sendMessage RestoreNextMinimizedWin)
        , ( "M-r"             , withFocused (sendMessage . maximizeRestore))

        , ( "M-<Esc>"         , restart "xmonad" True)
        , ( "M-S-<Esc>"       , io exitSuccess)

        , ( "M-C-n"           , appendFilePrompt myXPConfig $ home ++ "NOTES")

        , ( "M-S-<Backspace>" , removeWorkspace)
        , ( "M-S-v"           , selectWorkspace myXPConfig)
        , ( "M-m"             , withWorkspace myXPConfig (windows . W.shift))
        , ( "M-C-r"           , renameWorkspace myXPConfig)
        , ( "M-n"             , addWorkspacePrompt myXPConfig)

        , ( "M-C-l"           , spawn "xscreensaver-command -lock")

        , ( "M-<XF86AudioRaiseVolume>"    , spawn "pactl set-sink-volume 0 +5%")
        , ( "M-<XF86AudioLowerVolume>"    , spawn "pactl set-sink-volume 0 -5%")
        , ( "M-<XF86AudioMute>"           , spawn "pactl set-sink-mute 0 toggle")
        , ( "M-S-<XF86AudioRaiseVolume>"  , spawn "pactl set-sink-volume 0 +1%")
        , ( "M-S-<XF86AudioLowerVolume>"  , spawn "pactl set-sink-volume 0 -1%")
        , ( "M-S-<XF86AudioMute>"         , spawn "pactl set-sink-volume 0 100%")

        , ( "M-<XF86AudioPlay>"  , spawn "mpc toggle")
        , ( "M-<XF86AudioStop>"  , spawn "mpc stop")
        , ( "M-<XF86AudioNext>"  , spawn "mpc next")
        , ( "M-<XF86AudioPrev>"  , spawn "mpc prev")
        , ( "M-<XF86Calculator>" , spawn "qalculate")

        , ( "<XF86TouchpadToggle>"    , spawn "xinput --disable 'ETPS/2 Elantech Touchpad'")
        , ( "S-<XF86TouchpadToggle>"  , spawn "xinput --enable  'ETPS/2 Elantech Touchpad'")
    ] `M.union` M.fromList (
    zip (zip (repeat modm) [xK_1..xK_9]) (map (DO.withNthWorkspace W.greedyView) [0..])
    ++
    zip (zip (repeat (modm .|. shiftMask)) [xK_1..xK_9]) (map (DO.withNthWorkspace W.shift) [0..]))
-- }}}
-- Mouse bindings: default actions bound to mouse events {{{
myMouseBindings :: XConfig t -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings XConfig {XMonad.modMask = modm} = M.fromList
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster)
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    -- mod-button3, Set the window to floating mode and re size by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster)
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]
-- }}}
-- Layouts: {{{

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.

-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.

myLayout = avoidStruts (
            renamed [Replace "Full"]     ( smartBorders . maximize . minimize . boringWindows $ Full )
        ||| renamed [Replace "Mirror"]   ( smartBorders . maximize . minimize . boringWindows $ Mirror tiled )
        ||| renamed [Replace "Tiled"]    ( smartBorders . maximize . minimize . boringWindows $ tiled )
        ||| renamed [Replace "Acordion"] ( smartBorders . maximize . minimize . boringWindows $ Accordion )
        ||| renamed [Replace "Columns"]  ( smartBorders . maximize . minimize . boringWindows $ ThreeColMid 1 0.03 0.5 )
        ||| renamed [Replace "Simple"]   ( smartBorders . maximize . minimize . boringWindows $  simpleFloat )
        -- ||| renamed [Replace "Mirror"] ( common $ Mirror tiled )
        -- ||| renamed [Replace "Tiled"] ( common tiled )
        -- ||| renamed [Replace "Acordion"] ( common Accordion )
        -- ||| renamed [Replace "Columns"] ( common $ ThreeColMid 1 0.03 0.5 )
        -- ||| renamed [Replace "Simple"] ( common simpleFloat )
    )
    where
        -- Stuff common for all layout
        -- TODO find out how the fuck I can do this
        -- common l = maximize ( minimize ( boringWindows l ) )
        -- default tiling algorithm partitions the screen into two panes
        tiled   = Tall 1 0.03 0.5

-- }}}
-- Window rules: {{{

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.

myManageHook = composeAll
    [ resource                 =? "desktop_window"        --> doIgnore
    , resource                 =? "kdesktop"              --> doIgnore
    , className                =? "Screenkey"             --> doIgnore
    , className                =? "Google-chrome-stable"  --> liftX (addWorkspace "www")  >> doShift "www"
    , className                =? "Chromium"              --> liftX (addWorkspace "www")  >> doShift "www"
    , className                =? "Firefox"               --> liftX (addWorkspace "www")  >> doShift "www"
    -- , className                =? "luakit"                --> liftX (addWorkspace "www")  >> doShift "www"
    , className                =? "URxvt"                 --> liftX (addWorkspace "term") >> doShift "term"
    , className                =? "telegram"              --> liftX (addWorkspace "im")  >> doShift "im"
    , className                =? "Pidgin"                --> liftX (addWorkspace "im")  >> doShift "im"
    , className                =? "Qalculate"             --> doFloat
    , stringProperty "WM_NAME" =? "Event Tester"          --> doFloat
    , manageDocks]
-- }}}
-- Event handling {{{

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
-- combine event hooks use mappend or mconcat from Data.Monoid.

myEventHook = docksEventHook <+> ewmhDesktopsEventHook <+> minimizeEventHook
-- }}}
-- Status bars and logging {{{

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.

myLogHook h = dynamicLogWithPP $ def {
            ppOutput = hPutStrLn h
            , ppHiddenNoWindows = id
            , ppSort = DO.getSortByOrder
        }
-- }}}
-- Startup hook {{{

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.

-- By default, do nothing.
myStartupHook :: X ()
myStartupHook = setWMName "LG3D"
-- }}}
-- Actually start xmonad {{{
main :: IO ()
main = do
        -- home <- getHomeDirectory
        dzenPipe <- spawnPipe "dzen2 -ta l -bg '#161616' -fn 'Terminus:size=8' -w 600 -e '' -dock"
        xmonad $ ewmh def
            { terminal           = myTerminal
            , focusFollowsMouse  = myFocusFollowsMouse
            , clickJustFocuses   = myClickJustFocuses
            , borderWidth        = myBorderWidth
            , modMask            = myModMask
            , workspaces         = myWorkspaces
            , normalBorderColor  = myNormalBorderColor
            , focusedBorderColor = myFocusedBorderColor

            , keys               = myKeys
            , mouseBindings      = myMouseBindings

            , layoutHook         = myLayout
            , manageHook         = myManageHook
            , handleEventHook    = myEventHook
            , logHook            = myLogHook dzenPipe
            , startupHook        = myStartupHook
            }
-- }}}
