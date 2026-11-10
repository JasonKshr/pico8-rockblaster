
function _init()
    level=1
    level_clear=false
    game_over_sound=false

    player={
        x=60,
        y=100,
        speed=2,
        health=3,
        invincible=0
    }

    alien={
        x=48,
        y=3,
        speed=2,
        direction=1,
        health=100,
        max_health=100
    }

    rock_spawn_interval=40
    rock_speed_bonus=0

    plasma_spawn_interval=30
    plasma_speed=2

    bullets={}
    stars={}
    explosions={}
    plasma={}
    rocks={}

    plasma_timer=0
    rock_timer=0
    shoot_timer=3

    rainbow={7,8,9,10,11,12,14}
    color_index=1
    current_color=rainbow[color_index]

    super_charge=0
    super_max=50
    super_timer=0
    super_duration=30
    super_width=20
    super_damage=100
    super_dealt=0

    for i=1,40 do
        add(stars,{
            x=rnd(128),
            y=rnd(128),
            speed=0.5+rnd(1.5)
        })
    end
end

function collision(ax,ay,aw,ah,bx,by,bw,bh)
    return ax<bx+bw
       and ax+aw>bx
       and ay<by+bh
       and ay+ah>by
end

function rock_hitbox(r)
    if r.size==1 then
        return r.x+1,r.y+1,7,7
    elseif r.size==2 then
        return r.x+2,r.y+2,13,13
    else
        return r.x+1,r.y+1,30,30
    end
end

function explosion(x,y)
    add(explosions,{
        x=x,
        y=y,
        life=8
    })
end

function add_charge(amount)
    if super_timer==0 then
        super_charge=min(
            super_max,
            super_charge+amount
        )
    end
end

function spawn_rock()
    local size=flr(rnd(3))+1
    local width=8
    local sprite=64
    local hp=1

    if size==2 then
        width=16
        sprite=65
        hp=5
    elseif size==3 then
        width=32
        sprite=68
        hp=10
    end

    add(rocks,{
        x=rnd(129-width),
        y=-width,
        size=size,
        width=width,
        sprite=sprite,
        speed=0.5+rnd(1.5)+rock_speed_bonus,
        health=hp
    })
end

function next_level()
    level=level+1
    level_clear=false

    rock_spawn_interval=max(
        15,40-(level-1)*3
    )
    rock_speed_bonus=(level-1)*0.2

    plasma_spawn_interval=max(
        10,30-(level-1)*2
    )
    plasma_speed=2+(level-1)*0.2

    alien.max_health=100+(level-1)*20
    alien.health=alien.max_health
    alien.speed=2+(level-1)*0.2

    alien.x=48
    alien.y=3
    alien.direction=1

    bullets={}
    plasma={}
    rocks={}
    explosions={}

    rock_timer=0
    plasma_timer=0
    shoot_timer=3
    super_timer=0
    super_dealt=0

    player.invincible=30
end

function start_super()
    if super_charge>=super_max
    and super_timer==0 then
        super_charge=0
        super_timer=super_duration
        super_dealt=0
        sfx(3)
    end
end

function update_super()
    if super_timer<=0 then
        return
    end

    local beam_x=player.x+8-super_width/2
    local beam_h=player.y+8

    -- destroy asteroids in beam
    for r in all(rocks) do
        local rx,ry,rw,rh=rock_hitbox(r)

        if collision(
            beam_x,0,
            super_width,beam_h,
            rx,ry,rw,rh
        ) then
            explosion(
                rx+rw/2,
                ry+rh/2
            )
            del(rocks,r)
        end
    end

    -- damage alien
    if alien.health>0
    and super_dealt<super_damage
    and collision(
        beam_x,0,
        super_width,beam_h,
        alien.x+2,alien.y+1,29,26
    ) then
        local damage=min(
            super_damage-super_dealt,
            super_damage/super_duration,
            alien.health
        )

        alien.health=max(
            0,alien.health-damage
        )

        super_dealt=super_dealt+damage

        if alien.health<=0 then
            level_clear=true
        end
    end

    super_timer=super_timer-1
end

function _update()
    -- rainbow cycle
    color_index=color_index+1

    if color_index>#rainbow then
        color_index=1
    end

    current_color=rainbow[color_index]

    -- game over
    if player.health<=0 then
        if not game_over_sound then
            sfx(2)
            game_over_sound=true
        end

        if btnp(5) then
            sfx(-1)
            _init()
        end

        return
    end

    -- level clear
    if level_clear then
        if btnp(5) then
            next_level()
        end

        return
    end

    -- player movement
    if btn(0) then
        player.x=player.x-player.speed
    end

    if btn(1) then
        player.x=player.x+player.speed
    end

    if btn(2) then
        player.y=player.y-player.speed/2
    end

    if btn(3) then
        player.y=player.y+player.speed/2
    end

    player.x=mid(0,player.x,112)
    player.y=mid(0,player.y,112)

    -- activate super with x
    if btnp(5) then
        start_super()
    end

    -- shoot every 3 frames
    shoot_timer=shoot_timer+1

    if btn(4) and shoot_timer>=3 then
        add(bullets,{
            x=player.x+4,
            y=player.y,
            color=current_color
        })

        add(bullets,{
            x=player.x+12,
            y=player.y,
            color=current_color
        })

        shoot_timer=0
    end

    -- player bullets
    for b in all(bullets) do
        b.y=b.y-5

        if b.y<-3 then
            del(bullets,b)
        else
            local hit=false

            -- bullet-rock collision
            for r in all(rocks) do
                local rx,ry,rw,rh=rock_hitbox(r)

                if collision(
                    b.x,b.y,1,4,
                    rx,ry,rw,rh
                ) then
                    r.health=r.health-1
                    add_charge(1)
                    explosion(b.x,b.y)
                    sfx(0)
                    del(bullets,b)
                    hit=true

                    if r.health<=0 then
                        del(rocks,r)
                    end

                    break
                end
            end

            -- bullet-alien collision
            if not hit
            and alien.health>0
            and collision(
                b.x,b.y,1,4,
                alien.x+2,alien.y+1,29,26
            ) then
                alien.health=max(
                    0,alien.health-1
                )

                add_charge(1)
                explosion(b.x,b.y)
                sfx(0)
                del(bullets,b)

                if alien.health<=0 then
                    level_clear=true
                end
            end
        end
    end

    -- scrolling stars
    for s in all(stars) do
        s.y=s.y+s.speed

        if s.y>127 then
            s.y=0
            s.x=rnd(128)
        end
    end

    -- alien movement
    if alien.health>0 then
        alien.x=alien.x+
            alien.speed*alien.direction

        if rnd(1)<0.02 then
            alien.direction=-alien.direction
        end

        if alien.x<=0 then
            alien.x=0
            alien.direction=1
        end

        if alien.x>=96 then
            alien.x=96
            alien.direction=-1
        end

        plasma_timer=plasma_timer+1

        if plasma_timer>=plasma_spawn_interval then
            add(plasma,{
                x=alien.x+16,
                y=alien.y+32
            })
            plasma_timer=0
        end
    end

    -- spawn rocks
    rock_timer=rock_timer+1

    if rock_timer>=rock_spawn_interval then
        spawn_rock()
        rock_timer=0
    end

    -- move rocks
    for r in all(rocks) do
        r.y=r.y+r.speed

        if r.y>128 then
            del(rocks,r)
        else
            local rx,ry,rw,rh=rock_hitbox(r)

            if player.invincible==0
            and collision(
                player.x+4,player.y+7,9,9,
                rx,ry,rw,rh
            ) then
                player.health=player.health-1
                player.invincible=30
                sfx(1)

                explosion(
                    rx+rw/2,
                    ry+rh/2
                )

                del(rocks,r)
            end
        end
    end

    -- alien plasma
    for p in all(plasma) do
        p.y=p.y+plasma_speed

        if p.y>132 then
            del(plasma,p)
        elseif player.health>0
        and player.invincible==0
        and collision(
            p.x-4,p.y-4,9,9,
            player.x+4,player.y+7,9,9
        ) then
            player.health=player.health-1
            player.invincible=30
            sfx(1)
            del(plasma,p)
        end
    end

    -- supercharge beam
    if player.health>0 then
        update_super()
    end

    -- explosions
    for e in all(explosions) do
        e.life=e.life-1

        if e.life<=0 then
            del(explosions,e)
        end
    end

    -- invincibility timer
    if player.invincible>0 then
        player.invincible=player.invincible-1
    end
end

function _draw()
    cls()

    -- stars
    for s in all(stars) do
        pset(s.x,s.y,6)
    end

    -- alien
    if alien.health>0 then
        spr(128,alien.x,alien.y,4,4)
    end

    -- asteroid sprites
    for r in all(rocks) do
        if r.size==1 then
            spr(r.sprite,r.x,r.y)
        elseif r.size==2 then
            spr(r.sprite,r.x,r.y,2,2)
        else
            spr(r.sprite,r.x,r.y,4,4)
        end
    end

    -- player
    if player.health>0 then
        if player.invincible==0
        or flr(player.invincible/3)%2==0 then
            spr(192,player.x,player.y,2,2)
        end
    end

    -- rainbow bullets
    for b in all(bullets) do
        rectfill(
            b.x,b.y,
            b.x,b.y+3,
            b.color
        )
    end

    -- alien plasma
    for p in all(plasma) do
        circfill(p.x,p.y,4,3)
        circfill(p.x,p.y,3,11)
        circfill(p.x,p.y,1,10)
    end

    -- rainbow explosions
    for e in all(explosions) do
        local radius=(8-e.life)/2

        circ(
            e.x,e.y,
            radius,current_color
        )

        circfill(e.x,e.y,1,7)
    end

    -- unstable plasma beam
    if super_timer>0
    and player.health>0
    and not level_clear then
        local cx=player.x+8
        local beam_bottom=player.y+8

        -- flickering outer glow
        for y=0,beam_bottom,4 do
            local wobble=rnd(7)-3

            rectfill(
                cx-10+wobble,y,
                cx+9+wobble,y+3,
                current_color
            )
        end

        -- jagged energy edges
        for y=0,beam_bottom,6 do
            local left=cx-10-rnd(5)
            local right=cx+9+rnd(5)

            line(left,y,cx-7,y+6,12)
            line(right,y,cx+6,y+6,10)
        end

        -- flickering inner beam
        for y=0,beam_bottom,3 do
            local wobble=rnd(3)-1

            rectfill(
                cx-4+wobble,y,
                cx+3+wobble,y+2,
                7
            )
        end

        -- white-hot center
        line(cx,0,cx,beam_bottom,7)

        -- energy sparks
        for i=1,12 do
            local px=cx-14+rnd(28)
            local py=rnd(beam_bottom)

            pset(px,py,current_color)
        end
    end

    -- alien health bar
    if alien.health>0 then
        rectfill(2,2,41,5,5)

        rectfill(
            2,2,
            2+alien.health/
            alien.max_health*40-1,
            5,11
        )
    end

    -- hud
    print("lvl:"..level,48,2,7)
    print("hp:"..player.health,103,2,7)

    -- supercharge meter
    rectfill(2,119,81,123,5)

    if super_charge>0 then
        rectfill(
            2,119,
            2+super_charge/
            super_max*80-1,
            123,10
        )
    end

    if super_charge>=super_max then
        print("super ready! x",2,111,10)
    end

    -- popup messages
    if player.health<=0 then
        rectfill(20,48,108,80,0)
        rect(20,48,108,80,8)

        print("game over",46,53,8)
        print("level "..level,47,62,7)
        print("x to restart",37,72,7)

    elseif level_clear then
        rectfill(20,48,108,80,0)
        rect(20,48,108,80,11)

        print("level "..level.." clear!",30,53,11)
        print("x to continue",34,68,7)
    end
end
