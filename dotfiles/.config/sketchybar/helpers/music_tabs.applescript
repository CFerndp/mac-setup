-- Devuelve las pestañas de música de un navegador Chromium: ventana|pestaña|título|URL
on run argv
	set browserName to item 1 of argv
	set out to ""
	using terms from application "Google Chrome"
		tell application browserName
			set wi to 0
			repeat with w in windows
				set wi to wi + 1
				set ti to 0
				repeat with t in tabs of w
					set ti to ti + 1
					set u to URL of t
					if u contains "music.youtube.com" or u contains "open.spotify.com" or u contains "youtube.com/watch" or u contains "soundcloud.com" then
						set out to out & wi & "|" & ti & "|" & (title of t) & "|" & u & linefeed
					end if
				end repeat
			end repeat
		end tell
	end using terms from
	return out
end run
