-- Trae al frente una pestaña: navegador, ventana, pestaña
on run argv
	set browserName to item 1 of argv
	set wi to (item 2 of argv) as integer
	set ti to (item 3 of argv) as integer
	using terms from application "Google Chrome"
		tell application browserName
			set active tab index of window wi to ti
			set index of window wi to 1
			activate
		end tell
	end using terms from
end run
