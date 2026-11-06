pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
ship={}
bullets={}
rocks={}
stars={}

score=0
highscore=0
hp=3
ticks=0
gameover=false

bullet_colors={8,9,10,11,12,13}
bullet_color=1

function _init()
 cartdata("gravity-rocks-jason")
 highscore=dget(0)
 restart_game()
end

function restart_game()
 ship={
  x=64,
  y=110
 }

 bullets={}
 rocks={}
 stars={}

 score=0
 hp=3
 ticks=0
 gameover=false
 bullet_color=1

 for i=1,30 do
  add(stars,{
   x=rnd(128),
   y=rnd(128),
   spd=1+rnd(2)
  })
 end
end

function _update()
 if gameover then
  if btnp(5) then
   restart_game()
  end
  return
 end

 ticks+=1

 if btn(0) then ship.x-=5 end
 if btn(1) then ship.x+=5 end
 if btn(2) then ship.y-=5 end
 if btn(3) then ship.y+=5 end

 ship.x=max(8,ship.x)
 ship.x=min(120,ship.x)

 ship.y=max(70,ship.y)
 ship.y=min(118,ship.y)

 if btn(5)
 and ticks%4==0 then

  add(bullets,{
   x=ship.x,
   y=ship.y-8,
   c=bullet_colors[bullet_color]
  })

  bullet_color+=1

  if bullet_color>#bullet_colors then
   bullet_color=1
  end
 end

 for b in all(bullets) do
  b.y-=8

  if b.y<0 then
   del(bullets,b)
  end
 end

 if ticks%19==0 then
  local roll=rnd(1)

  local size=4
  local rockhp=1
  local speed=1+rnd(2)

  if roll>0.55 then
   size=6
   rockhp=2
   speed=1+rnd(1.5)
  end

  if roll>0.85 then
   size=9
   rockhp=3
   speed=0.8+rnd(1)
  end

  add(rocks,{
   x=10+rnd(108),
   y=-12,
   r=size,
   hp=rockhp,
   maxhp=rockhp,
   spd=speed,
   kind=flr(rnd(3))+1
  })
 end

 for r in all(rocks) do
  r.y+=r.spd

  if r.y>140 then
   del(rocks,r)
   hp-=1

   if hp<=0 then
    end_game()
   end
  end
 end

 for b in all(bullets) do
  for r in all(rocks) do
   if abs(b.x-r.x)<r.r+2
   and abs(b.y-r.y)<r.r+2 then

    del(bullets,b)
    r.hp-=1

    if r.hp<=0 then
     score+=r.maxhp*10
     del(rocks,r)

     if score>highscore then
      highscore=score
      dset(0,highscore)
     end
    end

    break
   end
  end
 end

 for r in all(rocks) do
  if abs(ship.x-r.x)<r.r+5
  and abs(ship.y-r.y)<r.r+5 then

   del(rocks,r)
   hp-=1

   if hp<=0 then
    end_game()
   end
  end
 end

 for s in all(stars) do
  s.y+=s.spd

  if s.y>127 then
   s.y=0
   s.x=rnd(128)
  end
 end
end

function end_game()
 gameover=true

 if score>highscore then
  highscore=score
  dset(0,highscore)
 end
end

function _draw()
 cls(0)

 for s in all(stars) do
  pset(s.x,s.y,6)
 end

 for b in all(bullets) do
  line(
   b.x,
   b.y-3,
   b.x,
   b.y+2,
   b.c
  )
 end

 for r in all(rocks) do
  draw_rock(r)
 end

 draw_ship()

 print(
  "score:"..score,
  2,
  2,
  7
 )

 print(
  "hi:"..highscore,
  2,
  9,
  10
 )

 print(
  "hp:"..hp,
  100,
  2,
  8
 )

 if gameover then
  rectfill(
   25,
   45,
   103,
   86,
   0
  )

  rect(
   25,
   45,
   103,
   86,
   7
  )

  print(
   "game over",
   46,
   51,
   8
  )

  print(
   "score:"..score,
   43,
   61,
   7
  )

  print(
   "high:"..highscore,
   43,
   69,
   10
  )

  print(
   "press v",
   48,
   78,
   6
  )
 end
end

function draw_rock(r)
 local x=r.x
 local y=r.y
 local s=r.r

 circfill(
  x,
  y,
  s,
  5
 )

 circ(
  x,
  y,
  s,
  6
 )

 pset(
  x-s,
  y-1,
  5
 )

 pset(
  x+s,
  y+1,
  5
 )

 pset(
  x-2,
  y-s,
  5
 )

 pset(
  x+2,
  y+s,
  5
 )

 if r.kind==1 then
  circfill(
   x-2,
   y-1,
   1,
   1
  )

  pset(
   x+2,
   y+2,
   6
  )
 end

 if r.kind==2 then
  circfill(
   x+2,
   y-2,
   1,
   1
  )

  pset(
   x-2,
   y+2,
   6
  )
 end

 if r.kind==3 then
  pset(
   x-2,
   y-2,
   1
  )

  circfill(
   x+1,
   y+2,
   1,
   1
  )
 end

 if s>=6 then
  pset(
   x-3,
   y+1,
   6
  )

  pset(
   x+3,
   y-1,
   1
  )
 end

 if s>=9 then
  circfill(
   x-3,
   y-3,
   1,
   1
  )

  pset(
   x+4,
   y+2,
   6
  )
 end

 if r.hp<r.maxhp then
  line(
   x,
   y-1,
   x+2,
   y+2,
   0
  )
 end

 if r.hp<r.maxhp-1 then
  line(
   x+2,
   y+2,
   x-1,
   y+4,
   0
  )
 end
end

function draw_ship()
 line(
  ship.x,
  ship.y-8,
  ship.x-6,
  ship.y+6,
  12
 )

 line(
  ship.x,
  ship.y-8,
  ship.x+6,
  ship.y+6,
  12
 )

 line(
  ship.x-6,
  ship.y+6,
  ship.x+6,
  ship.y+6,
  12
 )

 line(
  ship.x,
  ship.y-5,
  ship.x,
  ship.y+5,
  12
 )

 circfill(
  ship.x,
  ship.y-2,
  1,
  6
 )

 line(
  ship.x-3,
  ship.y+1,
  ship.x-9,
  ship.y+6,
  7
 )

 line(
  ship.x+3,
  ship.y+1,
  ship.x+9,
  ship.y+6,
  7
 )

 pset(
  ship.x-2,
  ship.y+7,
  9
 )

 pset(
  ship.x+2,
  ship.y+7,
  9
 )
end

