Gui, Add, CheckBox, x24 y100 w107 h-19 +Checked, Print?
Gui, Font, S12 CDefault, Arial
Gui, Add, Text, x22 y10 w290 h20 , Case Number:
Gui, Add, Text, x22 y40 w290 h20 , Patient Name:
Gui, Add, Text, x22 y70 w290 h20 , Jar Count
Gui, Add, CheckBox, x22 y109 w102 h28 , Print?
Gui, Add, Text, x133 y109 w99 h30 , A/B
Gui, Add, CheckBox, x243 y112 w102 h28 , Split?
Gui, Add, CheckBox, x21 y140 w102 h28 , Print?
Gui, Add, CheckBox, x22 y169 w102 h28 , Print?
Gui, Add, CheckBox, x22 y200 w102 h28 , Print?
Gui, Add, CheckBox, x22 y228 w102 h28 , Print?
Gui, Add, CheckBox, x23 y258 w102 h28 , Print?
Gui, Add, Text, x134 y140 w99 h30 , A/B
Gui, Add, Text, x132 y169 w99 h30 , A/B
Gui, Add, Text, x132 y198 w99 h30 , A/B
Gui, Add, Text, x132 y227 w99 h30 , A/B
Gui, Add, Text, x133 y259 w99 h30 , A/B
Gui, Add, CheckBox, x242 y139 w103 h25 , Split?
Gui, Add, CheckBox, x243 y166 w103 h25 , Split?
Gui, Add, CheckBox, x245 y195 w103 h25 , Split?
Gui, Add, CheckBox, x244 y220 w103 h25 , Split?
Gui, Add, CheckBox, x247 y257 w103 h25 , Split?
Gui, Add, Button, x31 y315 w104 h28 , Send
Gui, Add, Button, x160 y317 w104 h28 , Cancel
; Generated using SmartGUI Creator 4.0
Gui, Show, x127 y87 h379 w529, New GUI Window
Return

GuiClose:
ExitApp