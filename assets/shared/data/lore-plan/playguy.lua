function onCreate()
  	setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'ourple_death')
end

flipped = true
flippedIdle = false
defaultY = 0
function onCreatePost()
	defaultY = getProperty('boyfriend.y')
end
function onBeatHit() 
	if curStep <= 448 then 
		if getProperty('healthBar.percent') > 20 then
			flipped = not flipped
			setProperty('iconP1.flipX', flipped)
		end
	
		if curBeat % 1 == 0 and getProperty('boyfriend.animation.curAnim.name') == 'idle' then
			flippedIdle = not flippedIdle
			setProperty('boyfriend.flipX', flippedIdle)
			setProperty('boyfriend.y', getProperty('boyfriend.y') + 20)
			doTweenY('raise', 'boyfriend', getProperty('boyfriend.y') - 20, 0.15, 'cubeOut')
		end
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if curStep <= 448 then 
		if not getPropertyFromGroup('notes', id, 'gfNote') then
			cancelTween('raise')
			setProperty('boyfriend.y', defaultY)
			setProperty('boyfriend.flipX', true)
		end
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
	if curStep <= 448 then 
		if not getPropertyFromGroup('notes', id, 'gfNote') then
			cancelTween('raise')
			setProperty('boyfriend.y', defaultY)
			setProperty('boyfriend.flipX', true)
		end
	end
end

function onStepHit() 
	if curStep <= 448 then 
		if getProperty('healthBar.percent') < 20 and curStep % 2 == 0 then
			flipped = not flipped
			setProperty('iconP1.flipX', flipped)
		end
	end
end

function onUpdate(e)
	if curStep <= 448 then 
		local angleOfs = math.random(-5, 5)
		if getProperty('healthBar.percent') < 20 then
			setProperty('iconP1.angle', angleOfs)
		else
			setProperty('iconP1.angle', 0)
		end
	end
end
