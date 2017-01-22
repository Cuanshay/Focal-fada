
display.setStatusBar(display.HiddenStatusBar)

local utf8 = require('utf8_simple')
local widget = require( "widget" )

local W = display.contentWidth
local H = display.contentHeight 
local midW = W*0.5
local midH = H*0.5

local screenDisplay = display.newGroup()
local splashGroup = display.newGroup()
--------- forewards ect..

local click = audio.loadSound('sounds/click.wav')
local delete = audio.loadSound('sounds/delete.mp3') 
local search = audio.loadSound('sounds/search.mp3') 
local nav = audio.loadSound('sounds/nav.mp3') 
local thump = audio.loadSound('sounds/thump.mp3')

local eraseCharacter = {}
local tileTapped = {}
local checkFada = {}
local spawnText = {}
local addToTheWord = {}
local enterEvent = {}
local predictText = {}
local fieldListen = {}
local loadPics = {}
local createKey = {}


local dict = {}
local fada = {}
local out = {}
local textObj = {}
local ln = {}
local scrollY

local del
local enterBtn
local tile = {}
local idx = 0

local predOut = {}
local inc=1
local selected
local listen = 'off'

local splash = display.newImage("images/splash1.png");
splash.x = midW
splash.y = midH
splashGroup:insert(splash)

local splashWord = display.newImage("images/focal.png");
splashWord.x = 0
splashWord.y = -130
splashWord.rotation = -40
splashWord:scale(2,2)
splashGroup:insert(splashWord)


local function removeSplash()
local function cleanSplash()
splashGroup:removeSelf();
splashGroup = nil;
end
	local function transSplash()
	audio.play( thump )
	transition.to(splashGroup,{delay=2500,time=300,x=-350,alpha=0,onComplete=cleanSplash})
	end

transition.to(splashWord,{time=300, xScale=1, yScale=1,x=midW,y=midW/2+20,rotation=-22,transition=easing.inExpo,onComplete=transSplash })

end

local function loadDictionary()

	
	local path = system.pathForFile( "gaeilge.txt", system.ResourceDirectory )
	local file, errStr = io.open( path, "r" )
	if file then
		local ctr = 0
		local rpt = 1
		local check
		for line in file:lines() do	

			local sp = string.find(line, " ")
			local lineA = string.sub(line, 1, sp)
			lineA = string.sub(lineA, 1, -2)
			if(#lineA>=1)then
			fada[lineA] = true
			end
			lineA = (string.gsub(lineA, "Á", 'a') )
			lineA = (string.gsub(lineA, "É", 'e') )
			lineA = (string.gsub(lineA, "Í", 'i') )
			lineA = (string.gsub(lineA, "Ó", 'o') )
			lineA = (string.gsub(lineA, "Ú", 'u') )
			lineA = (string.gsub(lineA, "á", 'a') )
			lineA = (string.gsub(lineA, "é", 'e') )
			lineA = (string.gsub(lineA, "í", 'i') )
			lineA = (string.gsub(lineA, "ó", 'o') )
			lineA = (string.gsub(lineA, "ú", 'u') )
			lineA = lineA:lower()
		
			
			if(#line>2)then -- keep this way
			
				if(check==lineA)then
				lineA = lineA .. ' ' .. rpt
				dict[lineA] = line
				rpt = rpt + 1					
				else
				dict[lineA] = line
				check = lineA
				rpt = 1
				end
				ctr = ctr + 1
			end
			
			
		end
		io.close( file )
		timer.performWithDelay(1500, removeSplash )
		print("Dictionary loaded. Words found: ".. tostring(ctr))
	else

	end
	file = nil
end


local bg
local screen
local textField
local textEntry
local shadowText
local numText
local fadalogo
local fadaText
local scrollView

function loadPics()

	bg = display.newImage("images/cu.png")
	bg.x = midW
	bg.y = midH
	bg.alpha = 1
	screenDisplay:insert(bg)
	
	screen = display.newImageRect("images/screen1.png",300,240)
	screen.x = midW
	screen.y = midW-30
	screenDisplay:insert(screen)
	
	textField = display.newImageRect("images/menu1.png",300,50)
	textField.x = midW
	textField.y = screen.height+48
	textField.id = 'textField'	
	screenDisplay:insert(textField)
	
	textEntry = display.newText( "", 0, 0, "Helvetica", 26 )
	textEntry:setFillColor(181/255,223/255,179/255)
	textEntry.x = midW
	textEntry.y = textField.y
	screenDisplay:insert(textEntry)
	
	shadowText = display.newText( "", 0, 0, "Helvetica", 26 )
	shadowText:setFillColor(1,1,0)
	shadowText.x = midW
	shadowText.y = textField.y	
	shadowText.anchorX = 0
	shadowText.alpha = 0.2
	screenDisplay:insert(shadowText)
	
	numText = display.newText( "", 0, 0, "Helvetica", 20 )
	numText:setFillColor(181/255,223/255,179/255)
	numText.x = textField.x+(textField.width/2)-12
	numText.y = textField.y
	numText.anchorX = 1
	screenDisplay:insert(numText)
	
	fadalogo = display.newImageRect("images/fada1.png",28,11)
	fadalogo.x = textField.x-textField.width/2+26
	fadalogo.y = textField.y+9
	fadalogo.anchorX = 0.5	
	fadalogo.isVisible = false
	screenDisplay:insert(fadalogo)
	
	fadaText = display.newText( "", 0, 0, "Helvetica", 20 )
	fadaText.x = fadalogo.x-2
	fadaText.y = textField.y-8
	fadaText.anchorX = 0.5	
	fadaText:setFillColor(181/255,223/255,179/255)
	screenDisplay:insert(fadaText)
	
	scrollView = widget.newScrollView
{
	left = 24,
	top = 30,
	width = screen.width-30,
	height = screen.height-30,
	bottomPadding = 50,
	hideBackground = true,
	id = "onBottom",
	horizontalScrollDisabled = true,
	verticalScrollDisabled = false
	
}
	scrollView.x = screen.x
	scrollView.y = screen.y
	screenDisplay:insert(scrollView)

	end
	
	
function spawnText( tableIn )
								
								proceed = false
local tableText = tableIn

			if(tableText=='clr')then

	if(#textObj>0)then
		

		
		
				for i = 1,#textObj do
					scrollView:remove(textObj[i])
					display.remove(textObj[i])
					textObj[i] = nil	
				end
					for i = 1,#ln do
					scrollView:remove(ln[i])
					display.remove(ln[i])
					ln[i] = nil	
				end
					for i = 1,#out do
					if(out[i])then
					table.remove(out , #out)
					display.remove(out[i])
					out[i]=nil

					end
				end
	

		 idx = 0


		
		local function onScrollToComplete()

		proceed = true
        end


    scrollView:scrollTo("top",{ time = 500, onComplete = onScrollToComplete })
	end
						---------------------------
elseif(#tableText>=1)then

	
local spacing = 30

	idx = idx + 1

	function string:split( inSplitPattern, outResults )

	   if not outResults then
		  outResults = { }
	   end
	   local theStart = 1
	   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	   while theSplitStart do
		  table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
		  theStart = theSplitEnd + 1
		  theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
	   end
	   table.insert( outResults, string.sub( self, theStart ) )
	   return outResults
	end
	
	
local contents = string.split( tableText, " " )
local def = {'vb','artc','adj','adv','noun','n','nm','nm1','nm2','nm3','nm4','nm5','nf','nf1','nf2','nf3','nf4','nf5','prep', 'pron', 'pref'}


local fillcelt = {0/255, 158/255, 96/255}
local filltitle = {79/255,176/255,73/255}
local filldef = {200/255,55/255,0/255}
local fillcont = {77/255,110/255,238/255}

	for i = 1, #contents do
	out[i] = {}
	out[i].text = contents[i]

	end 
	
	for i = 2, #contents do
	
			out[i].font = 'Arial'
			out[i].fontSize = 26
			out[i].anchorX = 1
			out[i].x = scrollView.width-20
			out[i].fill = fillcont
			
		for j = 1, #def do
			if(out[i].text==def[j])then
			out[i].def=def[j]
			out[i].font = 'Garamond'
			out[i].fontSize = 20
			out[i].anchorX =  0
			out[i].x = scrollView.x-(scrollView.width*0.5)
			out[i].fill = filldef
			end	
		end

	end	

	if(out[2].fill~= filldef)then
	out[2].fill = fillcelt
	end
	
			out[1].font = 'Arial'
			out[1].fontSize = 30
			out[1].anchorX = 0.5
			out[1].x = scrollView.width/2
			out[1].fill = filltitle
		
			
		local celt = {}		
		
		local script = out[1].text
		if(#script>18)then
		script = out[1].text
		end
			celt.text = script
			celt.font = 'Celtic Gaelige'
			celt.fontSize = 24
			celt.anchorX = 0.5
			celt.x = scrollView.width/2
			celt.fill = fillcelt

	for i = 1, #contents do

		local txt = out[i].def or out[i].text
		textObj[idx] = display.newText(txt,0,0,out[i].font,out[i].fontSize)
		textObj[idx].anchorX = out[i].anchorX
		textObj[idx].x = out[i].x
		textObj[idx].y = spacing*idx
		textObj[idx]:setFillColor( unpack(out[i].fill) )
		scrollView:insert(textObj[idx])

			idx = idx + 1 
	end

	
		textObj[idx] = display.newText(celt.text,0,0,celt.font,celt.fontSize)
		textObj[idx].anchorX = celt.anchorX
		textObj[idx].x = celt.x
		textObj[idx].y = (spacing*idx+0)
		textObj[idx]:setFillColor( unpack(celt.fill) )
		scrollView:insert(textObj[idx])


		--	idx = idx + 1 
	
		ln[#ln+1] = display.newLine( scrollView.x-(scrollView.width*0.5),(spacing*idx+15),scrollView.width-25, (spacing*idx+15) )	
		ln[#ln]:setStrokeColor(236/255,255/255,132/255,0.3)--(152/255,171/255,245/255, 0.5)
		ln[#ln].strokeWidth = 1
		scrollView:insert(ln[#ln])
		
		scrollY = (spacing*(idx-#contents)-30)
		

	end
end	

function checkFada(check)
local check = check 
	if(#check>=1)then 
		  local litir = {}
		  local id=1
		  fadaText.text = ''
			local spl = string.find(dict[check], " ")
			local textFada = (dict[check]:sub(1, spl-1) )

		if(#textFada==#check)then
		fadalogo.isVisible = false
		
		else
		
			for ind, ch, bi in utf8.chars(textFada) do
	
				local function addTxt(addIn)
				
				local prev = fadaText.text
				fadaText.text = prev .. ' ' .. addIn or ''
				end

				if(#ch>1)then
					litir[id]=ch
					addTxt(litir[id])
					id=id+1
				end

			end
			
		fadalogo.isVisible = true
		end
	end	
end

function enterEvent(event)

	if(event.phase=='ended')then

	local t = event.target
	audio.play(click)
	spawnText('clr')
		if(t.id=='enter')then

		transition.to(t,{ time=80, xScale=0.8, yScale=0.8,transition=easing.outExpo,	 onComplete=function() 
		transition.to(t,{delay=50, time=80, xScale=1, yScale=1,transition=easing.inExpo,onComplete=function()
			local number = #predOut
			if(number==150)then number = tostring( number .. '+' ) end
			
			if(selected)then
				spawnText(dict[selected])
				checkFada(selected)
				numText.text = ''
				textEntry.text = selected
				textEntry.x = midW
				shadowText.text = ''
				elseif(#predOut>=1)then
					for i = 1, #predOut do
					spawnText(dict[predOut[i]])
					end
			if(predOut[1])then
			textEntry.text = predOut[1]
			textEntry.x = midW
			checkFada(textEntry.text)
			end			

				shadowText.text = ''
				numText.text = '(' .. number .. ')'
				numText.x = textField.x+(textField.width/2)-12

		else
				numText.text = '(' .. number .. ')'
				numText.x = textField.x+(textField.width/2)-12
			end
		selected = false 
			 end })
			 audio.play(search)
			
			fieldListen('off')
			end	})

		end
		return true
	end
end

local function incPred(event)

	if(event.phase=='ended')then

if(not selected and numText.text=='')then 
local number = #predOut
if(number==150)then number = tostring( number .. '+' ) end
	numText.text = '(' .. number .. ')'
	numText.x = textField.x+(textField.width/2)-12
	elseif(not selected)then

	if(predOut[inc])then
	selected=true
	end
	numText.text = ''			

end
	
		if( selected and inc<#predOut)then 
		inc =inc +1
		else
		inc=1
		end

	audio.play(nav)
	
			if(predOut[inc] and selected)then
				shadowText.text = string.sub( predOut[inc] , #textEntry.text+1,#predOut[inc])	textEntry.x = midW-shadowText.width*0.5
				shadowText.x = textEntry.x+textEntry.width*0.5
			--	textEntry.x = midW
			selected = predOut[inc]
			else

			end
			return true
	end
end


function predictText( textIn )

	local addto = textIn

if(#addto>=1)then

  local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
  end
			

local num = 1
for i = 1, #predOut do
table.remove(predOut)
end
	for key,value in spairs(dict) do

		local clip = string.sub(key, 1, #textEntry.text)
		
			if(clip==textEntry.text)then
			
				if(num<=150)then

				predOut[num] = key
				num = num + 1
				else
				num = num + 1
				end
				
			end

	end 
		
				if(predOut[1] and not selected)then
				shadowText.text = string.sub( predOut[1] , #textEntry.text+1,#predOut[1])	textEntry.x = midW-shadowText.width*0.5
				shadowText.x = textEntry.x+textEntry.width*0.5
			--	textEntry.x = midW
				
			else

			end

	end	
end

function fieldListen(txt)

	if(txt=='on' and listen=='off')then
	textField:addEventListener('touch' , incPred )
	listen = 'on'
	elseif(txt=='off' and listen=='on')then
	textField:removeEventListener('touch' , incPred )
	listen = 'off'
	end

end




function addToTheWord(newLetter)

	selected = false

	local newTxt 
	fadalogo.isVisible = false
	fadaText.text = ''
	shadowText.text = ''

	if(#textEntry.text>0)then
	newTxt = textEntry.text .. newLetter
	else
	newTxt = newLetter
	end
	textEntry.text = newTxt
--	textEntry.x = midW
	predictText( textEntry.text )
	if(dict[textEntry.text])then
	spawnText( dict[textEntry.text] )
	checkFada(textEntry.text)
	scrollView:scrollToPosition{ y = -scrollY } 
	end
	if(#textEntry.text>=1)then 
	del:setFillColor(255/255,153/255,159/255)
	numText.text = '' 
	end

end	

local function eraseTimer()

		spawnText('clr')
		fadalogo.isVisible = false
		fadaText.text = ''
		shadowText.text = ''
		audio.play(delete,{onComplete=function() audio.play(delete)  end})		
		for i = 1, #predOut do
		table.remove(predOut)
		end
		del:setFillColor(1,1,1)
		textEntry.text = ''
		numText.text = ''
		
	transition.to(del,{ time=80, xScale=0.8, yScale=0.8,transition=easing.outExpo, onComplete=function() 
transition.to(del,{delay=50, time=80, xScale=1, yScale=1,transition=easing.inExpo})
end	})	
		
end

function eraseCharacter(event)

if(event.phase=='began')then

 wipe = timer.performWithDelay( 600, eraseTimer )

elseif(event.phase=='ended')then
 timer.cancel(wipe) 

	if (#textEntry.text>=1 )then 

		spawnText('clr')
		fadalogo.isVisible = false
		fadaText.text = ''
		shadowText.text = ''

	if (event.target.id=='del')then

local t = event.target

		numText.text = ''
		del:setFillColor(255/255,153/255,159/255)
		local word = textEntry.text
		word = string.sub(word, 1, -2)
		textEntry.text = word
	--	textEntry.x = midW
		
		predictText( textEntry.text )
		fieldListen('on')
		
			if(#textEntry.text<=0)then
			
			del:setFillColor(1,1,1)
			
			end
		
		
			if(dict[textEntry.text])then
			
				spawnText(dict[textEntry.text] )
				checkFada(textEntry.text)

			end			


		audio.play(delete)
transition.to(t,{ time=80, xScale=0.8, yScale=0.8,transition=easing.outExpo, onComplete=function() 
transition.to(t,{delay=50, time=80, xScale=1, yScale=1,transition=easing.inExpo})
end	})

			end
		
		end
		return true
	end
	
end


function tileTapped(event)
	if(event.phase=='ended')then
	local tgt = event.target
			audio.play(click)		
	transition.to(tgt,{ time=80, xScale=0.8, yScale=0.8,transition=easing.outExpo, onComplete=function()
			transition.to(tgt,{delay=50, time=80, xScale=1, yScale=1,transition=easing.inExpo,onComplete=function() addToTheWord(tgt.letter)  end}) 
						 end})
		return true
	end	
end

function createKey()

	local tWidth = 30
	local tHeight = 30
	local colSpace = 2
	local rowSpace = 8
	local numCols = 10
	local numRows = 3
	local keyboard = {'q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m'}

		local xfieldPos = midW - (numCols * tWidth + numCols * colSpace) / 2
		local yfieldPos = textField.y + 40
		local col = 1
		local row = 1
		local indent = 0
			for i = 1, #keyboard do
					local ochair = keyboard[i] 
				if(ochair=='a')then
					row = 2
					colSpace = 4
					indent = 10
					col = 1
					elseif(ochair=='z')then
					row = 3
					colSpace = 5
					indent = 25
					col = 1
				end
				
tile[i] = display.newImageRect("images/" .. ochair .. ".png",tWidth,tHeight)
tile[i].x = xfieldPos + col * (tWidth + colSpace) - tWidth/2 - colSpace+indent
tile[i].y = yfieldPos + row * (tHeight + rowSpace) - tHeight/2 - rowSpace
tile[i].letter = keyboard[i]

	tile[i]:addEventListener("touch", tileTapped)
screenDisplay:insert(tile[i])
				col = col +1
				
			end	
			
			del = display.newImageRect("images/delete.png",50,30)	
			del.x = W-25
			del.y = textField.y+131
			del.id = 'del'
			del:addEventListener("touch", eraseCharacter)
			screenDisplay:insert(del)
			
			enterBtn = display.newImageRect("images/enter1.png",60,30)
			enterBtn.x = midW
			enterBtn.y = del.y+36
			enterBtn.id = 'enter'
			enterBtn:addEventListener("touch", enterEvent)	
			screenDisplay:insert(enterBtn)
end

	loadPics()
	createKey()
	loadDictionary()
	fieldListen('on')

