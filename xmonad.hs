-- Imports {{{
import XMonad

import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.DynamicWorkspaceOrder as DO

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.Minimize
import XMonad.Hooks.EwmhDesktops

import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.AppendFile
import XMonad.Prompt.Shell

import XMonad.Util.Run

import XMonad.Layout.SimpleFloat
import XMonad.Layout.Minimize
import XMonad.Layout.Maximize
import XMonad.Layout.Renamed
import XMonad.Layout.Accordion
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Drawer

import System.Exit
import System.Directory
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet    as W
import qualified Data.Map           as M
import qualified Data.List          as L
-- }}}
-- Common defaults {{{
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
myTerminal :: [Char]
myTerminal = "urxvtc"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth :: Dimension
myBorderWidth = 0

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
myModMask :: KeyMask
myModMask = mod4Mask

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor :: [Char]
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor :: [Char]
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
altMask :: KeyMask
altMask = mod1Mask -- mod1Mask just isn't verbose enough
xF86XK_TouchpadToggle :: KeySym
xF86XK_TouchpadToggle = 269025193
myXPConfig :: XPConfig
myXPConfig = defaultXPConfig {
                    position = Top
                    , searchPredicate = L.isInfixOf
                }
        -- , ((modm                 , xK_m        ) , windows W.focusMaster)
        -- , ((modm                 , xK_n        ) , refresh)
        -- , ((modm .|. shiftMask   , xK_m        ) , withWorkspace myXPConfig (windows . copy))
        -- , ((modm                 , xK_p        ) , spawn "dmenu_run")

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    [     ((modm .|. shiftMask   , xK_Return)               , spawn $ XMonad.terminal conf)
        , ((modm                 , xK_p)                    , shellPrompt myXPConfig)
        , ((modm                 , xK_c)                    , kill)
        , ((modm                 , xK_space)                , sendMessage NextLayout)
        , ((modm .|. shiftMask   , xK_space)                , setLayout $ XMonad.layoutHook conf)
        , ((modm                 , xK_Tab)                  , windows W.focusDown)
        , ((modm .|. shiftMask   , xK_Tab)                  , windows W.focusUp)
        , ((modm                 , xK_Return)               , windows W.swapMaster)
        , ((modm .|. shiftMask   , xK_j)                    , windows W.swapDown)
        , ((modm .|. shiftMask   , xK_k)                    , windows W.swapUp)
        , ((modm                 , xK_h)                    , sendMessage Shrink)
        , ((modm                 , xK_l)                    , sendMessage Expand)
        , ((modm                 , xK_t)                    , withFocused $ windows . W.sink)
        , ((modm                 , xK_comma)                , sendMessage $ IncMasterN 1)
        , ((modm                 , xK_period)               , sendMessage $ IncMasterN (-1))
        , ((modm                 , xK_b)                    , sendMessage ToggleStruts)

        , ((modm                 , xK_Right)                , DO.moveTo Next AnyWS)
        , ((modm                 , xK_Left)                 , DO.moveTo Prev AnyWS)
        , ((modm .|. shiftMask   , xK_Right)                , DO.shiftTo Next AnyWS)
        , ((modm .|. shiftMask   , xK_Left)                 , DO.shiftTo Prev AnyWS)
        , ((modm .|. altMask     , xK_Right)                , DO.swapWith Next AnyWS)
        , ((modm .|. altMask     , xK_Left)                 , DO.swapWith Prev AnyWS)

        , ((modm                 , xK_z)                    , toggleWS)
        , ((modm .|. shiftMask   , xK_g)                    , windowPromptGoto  myXPConfig)
        , ((modm .|. shiftMask   , xK_b)                    , windowPromptBring myXPConfig)

        , ((modm                 , xK_s)                    , withFocused minimizeWindow)
        , ((modm .|. shiftMask   , xK_s)                    , sendMessage RestoreNextMinimizedWin)
        , ((modm                 , xK_r)                    , withFocused (sendMessage . maximizeRestore))

        , ((modm                 , xK_Escape)               , restart "xmonad" True)
        , ((modm .|. shiftMask   , xK_Escape)               , io (exitWith ExitSuccess))

        , ((modm .|. controlMask , xK_n)                    , appendFilePrompt myXPConfig "/home/lucas/NOTES")

        , ((modm .|. shiftMask   , xK_BackSpace)            , removeWorkspace)
        , ((modm .|. shiftMask   , xK_v)                    , selectWorkspace myXPConfig)
        , ((modm                 , xK_m)                    , withWorkspace myXPConfig (windows . W.shift))
        , ((modm .|. controlMask , xK_r)                    , renameWorkspace myXPConfig)
        , ((modm                 , xK_n)                    , addWorkspacePrompt myXPConfig)

        , ((modm .|. controlMask , xK_l)                    , spawn "xscreensaver-command -lock")

        , ((modm                 , xF86XK_AudioRaiseVolume) , spawn "pactl set-sink-volume 0 +5%")
        , ((modm                 , xF86XK_AudioLowerVolume) , spawn "pactl set-sink-volume 0 -5%")
        , ((modm                 , xF86XK_AudioMute)        , spawn "pactl set-sink-mute 0 toggle")
        , ((modm .|. shiftMask   , xF86XK_AudioRaiseVolume) , spawn "pactl set-sink-volume 0 +1%")
        , ((modm .|. shiftMask   , xF86XK_AudioLowerVolume) , spawn "pactl set-sink-volume 0 -1%")
        , ((modm .|. shiftMask   , xF86XK_AudioMute)        , spawn "pactl set-sink-volume 0 100%")

        , ((modm                 , xF86XK_AudioPlay)        , spawn "mpc toggle")
        , ((modm                 , xF86XK_AudioStop)        , spawn "mpc stop")
        , ((modm                 , xF86XK_AudioNext)        , spawn "mpc next")
        , ((modm                 , xF86XK_AudioPrev)        , spawn "mpc prev")
        , ((modm                 , xF86XK_Calculator)       , spawn "qalculate")

        , ((0                    , xF86XK_TouchpadToggle)   , spawn "xinput --disable 'ETPS/2 Elantech Touchpad'")
        , ((shiftMask            , xF86XK_TouchpadToggle)   , spawn "xinput --enable  'ETPS/2 Elantech Touchpad'")
    ]
    ++
    zip (zip (repeat (modm)) [xK_1..xK_9]) (map (DO.withNthWorkspace W.greedyView) [0..])
    ++
    zip (zip (repeat (modm .|. shiftMask)) [xK_1..xK_9]) (map (DO.withNthWorkspace W.shift) [0..])

-- }}}
-- Mouse bindings: default actions bound to mouse events {{{
myMouseBindings :: XConfig t -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))
    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))
    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
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
            renamed [Replace "Full"] ( maximize . minimize $ Full )
        ||| renamed [Replace "Mirror"] ( maximize . minimize $ Mirror tiled )
        ||| renamed [Replace "Tiled"] ( maximize . minimize $ tiled )
        ||| renamed [Replace "Acordion"] ( maximize . minimize $ Accordion )
        ||| renamed [Replace "Columns"] ( maximize . minimize $ ThreeColMid 1 0.03 0.5 )
        ||| renamed [Replace "Simple"] ( maximize . minimize $  simpleFloat )
        ||| renamed [Replace "Drawer"] ( maximize . minimize $ (drawer `onTop` (Tall 1 0.03 0.5)))
        -- ||| renamed [Replace "Mirror"] ( common $ Mirror tiled )
        -- ||| renamed [Replace "Tiled"] ( common tiled )
        -- ||| renamed [Replace "Acordion"] ( common Accordion )
        -- ||| renamed [Replace "Columns"] ( common $ ThreeColMid 1 0.03 0.5 )
        -- ||| renamed [Replace "Simple"] ( common simpleFloat )
        -- ||| renamed [Replace "Drawer"] ( common (drawer `onTop` (Tall 1 0.03 0.5)))
    )
    where
        drawer = simpleDrawer 0.01 0.3 (ClassName "Rhythmbox" `Or` ClassName "Sonata")
        -- Stuff common for all layout
        -- TODO should eventually remember haskell and replace this with and fmap or something
        -- common l = maximize ( minimize ( l ) )
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
    , className                =? "luakit"                --> liftX (addWorkspace "www")  >> doShift "www"
    , className                =? "URxvt"                 --> liftX (addWorkspace "term") >> doShift "term"
    , className                =? "Telegram"              --> liftX (addWorkspace "im")  >> doShift "im"
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

myLogHook h = dynamicLogWithPP $ defaultPP {
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
myStartupHook = return ()
-- }}}
-- Actually start xmonad {{{
main :: IO ()
main = do 
        -- home <- getHomeDirectory
        dzenPipe <- spawnPipe "dzen2 -ta l -bg '#161616' -fn 'Terminus:size=8' -w 600 -e '' -dock"
        xmonad $ ewmh defaultConfig 
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
