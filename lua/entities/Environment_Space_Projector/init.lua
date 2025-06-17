AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")





function ENT:Initialize()
    self:SetModel("models/maxofs2d/thruster_projector.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(true)
    local phys = self:GetPhysicsObject()
    if (!IsValid(phys)) then
        phys:Wake()
    end


self.next_emit_time = 5
self.random_angle = nil
self.projector_is_off = true
end   


function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() then
        if CurTime() > self.next_emit_time then
            if self.projector_is_off then
                self.random_angle = Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360))
                self:play_emit_sound(activator)
                self:play_projector_humming_sound(activator)
                self:create_projection_beam(activator)
                self:create_celestial_bodies(activator)
                self:freeze_projector_in_place(activator)
                self.next_emit_time = CurTime() + 1
                self.projector_is_off = false
            else 
                self:remove_celestial_bodies(activator)
                self:turn_projector_sound_off(activator)
                self:stop_projector_humming_sound(activator)
                self:unfreeze_projector(activator)
                self:get_current_pos(activator)
                self.next_emit_time = CurTime() + 1
                self.projector_is_off = true     
            end
        end
    end
end


function ENT:freeze_projector_in_place()
    if IsValid(self) then
        self:SetMoveType(MOVETYPE_NONE)
    end 
end

function ENT:unfreeze_projector()
    if IsValid(self) then
        self:SetMoveType(MOVETYPE_VPHYSICS)
    end 
end

function ENT:get_current_pos()
    if IsValid(self) then
        self:SetPos(self:GetPos())
    end 
end

celestial_bodies = {}

function ENT:remove_celestial_bodies()
    for _, body in ipairs(celestial_bodies) do
        if IsValid(body) then
            body:Remove()
        end
    end
    celestial_bodies = {}
end


function ENT:create_celestial_bodies()
    if IsValid(self) then
        self:create_stars()
        self:create_nebulas()
        self:create_suns()
    end
end

function ENT:play_projector_humming_sound()
    local volume = 75
    local sound_distance = 100
    local sound_pitch = 1
    
    self:EmitSound("ambient/machines/combine_shield_loop3.wav", volume, sound_distance, sound_pitch, CHAN_AUTO) 

    if IsValid(self) then
        self:CallOnRemove("stop_humming", function()
            self:StopSound("ambient/machines/combine_shield_loop3.wav")   
        end)
    end
end

function ENT:stop_projector_humming_sound()
    if IsValid(self) then
        self:StopSound("ambient/machines/combine_shield_loop3.wav") 
        self:RemoveCallOnRemove("stop_humming")
    end
end

function ENT:turn_projector_sound_off()
    local volume = 75
    local sound_distance = 100
    local sound_pitch = 1
    
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:EmitSound("/buttons/button8.wav", volume, sound_distance, sound_pitch, CHAN_AUTO)
        end 
    end)
end

function ENT:play_emit_sound()
    local volume = 75
    local sound_distance = 100
    local sound_pitch = 1
    
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:EmitSound("/buttons/button9.wav", volume, sound_distance, sound_pitch, CHAN_AUTO) 
        end
    end)
end


function ENT:create_projection_beam(parent)
    if IsValid(parent) then
        local projector_beam_ent = ents.Create("prop_dynamic")
    
        local center_offset = parent:LocalToWorld(parent:OBBCenter())

        table.insert(celestial_bodies, projector_beam_ent)

        projector_beam_ent:SetPos(center_offset)
    
        projector_beam_ent:SetPos(center_offset + parent:GetUp() * 102.0)

        projector_beam_ent:SetPos(self:GetPos() + Vector(0, 0, 102.0))

        projector_beam_ent:SetModel("models/hunter/misc/cone2x2.mdl")
        projector_beam_ent:Spawn()

        self:Initialize_physics(projector_beam_ent)  
        self:set_collision(projector_beam_ent)
        self:set_projector_beam_angle(projector_beam_ent)
        self:set_projector_beam_color(projector_beam_ent)
        self:set_beam_texture(projector_beam_ent) 
        projector_beam_ent:SetParent(self)
    end         
end


function ENT:set_beam_texture(beam_texture)
    if IsValid(beam_texture) then
        beam_texture:SetMaterial("models/props_combine/portalball001_sheet")
    end 
end

function ENT:set_projector_beam_angle(beam_angle)
    if IsValid(beam_angle) then
        beam_angle:SetAngles(Angle(180, 0, 0))
    end
end

function ENT:set_projector_beam_color(beam_color)
    if IsValid(beam_color) then
        beam_color:SetColor(Color(25, 0, 255))
    end
end



function ENT:create_stars()
   if IsValid(self) then
    local stars_count = math.random(100, 300)
    
        for i = 1, stars_count do
            local stars_ent = ents.Create("env_sprite")

            if IsValid(stars_ent) then

                table.insert(celestial_bodies, stars_ent)

                stars_ent:SetKeyValue("model", "materials/sprites/light_flare01.vmt")
                stars_ent:SetKeyValue("InitialState", "1")
                stars_ent:SetKeyValue("WindAngle", "0 0 0")
                stars_ent:SetKeyValue("WindSpeed", "0")

                self:set_random_sun_color(stars_ent)
                stars_ent:SetKeyValue("renderamt", "255")
                stars_ent:SetKeyValue("rendermode", "5")
                stars_ent:SetKeyValue("renderfx", "14")
                stars_ent:SetKeyValue("Scale", tostring(math.random(0.130, 0.140)))
                stars_ent:SetKeyValue("spawnflags", "1")
                stars_ent:SetKeyValue("SpawnRate", "10")
                stars_ent:SetKeyValue("Speed", "5")
                stars_ent:SetKeyValue("StartSize", "2")
                stars_ent:SetKeyValue("EndSize", "1")
                stars_ent:SetKeyValue("roll", "10")
                stars_ent:SetKeyValue("JetLength", "100")
                stars_ent:SetKeyValue("twist", "5")

                self:set_random_pos(stars_ent)

                stars_ent:Spawn()
                stars_ent:Activate()
                
                stars_ent:SetParent(self)

            end
        end
    end
end


function ENT:create_nebulas()
    if IsValid(self) then
        local nebula_count = math.random(1, 20)

        for i = 1, nebula_count do

            local nebula_ent = ents.Create("env_sprite")
            
            if IsValid(nebula_ent) then

                table.insert(celestial_bodies, nebula_ent)

                self:set_random_nebula(nebula_ent)
                nebula_ent:SetKeyValue("InitialState", "1")
                nebula_ent:SetKeyValue("WindAngle", "0 0 0")
                nebula_ent:SetKeyValue("WindSpeed", "0")

                self:set_random_colorful_RGB_color(nebula_ent)
                nebula_ent:SetKeyValue("renderamt", "255")
                nebula_ent:SetKeyValue("rendermode", "5")
                nebula_ent:SetKeyValue("renderfx", "14")
                nebula_ent:SetKeyValue("Scale", tostring(math.random(1, 30)))
                nebula_ent:SetKeyValue("spawnflags", "1")
                nebula_ent:SetKeyValue("SpawnRate", "10")
                nebula_ent:SetKeyValue("Speed", "5")
                nebula_ent:SetKeyValue("StartSize", "2")
                nebula_ent:SetKeyValue("EndSize", "1")
                nebula_ent:SetKeyValue("roll", "10")
                nebula_ent:SetKeyValue("JetLength", "100")
                nebula_ent:SetKeyValue("twist", "5")

                self:set_random_pos(nebula_ent)

                nebula_ent:Spawn()
                nebula_ent:Activate()

                nebula_ent:SetParent(self)

            end
        end
    end
end


function ENT:set_random_nebula(nebula)
    local nebulas = {
        "sprites/muzzleflash1.vmt",
        "sprites/muzzleflash2.vmt",
        "sprites/muzzleflash3.vmt",
        "sprites/muzzleflash4.vmt"
    }

    local random_nebula = table.Random(nebulas)
    
    if IsValid(nebula) then
        nebula:SetKeyValue("model", random_nebula)
    end
end

function ENT:create_suns()
    if IsValid(self) then
        local sun_count = math.random(10, 50)

        for i = 1, sun_count do
            local sun_ent = ents.Create("prop_dynamic")

            local sun_light_ent = ents.Create("light_dynamic")

            local planet_radius = math.random(10, 1000)

            table.insert(celestial_bodies, sun_ent)

            sun_light_ent:SetKeyValue("Brightness", tostring(math.random(5, 8)))
            sun_light_ent:SetKeyValue("distance", tostring(math.random(1200, 1500)))
            sun_light_ent:SetKeyValue("spawnflags", "1")

            sun_light_ent:Spawn()
            sun_light_ent:SetParent(sun_ent)
            sun_light_ent:Activate()

            sun_ent:SetModel("models/XQM/Rails/gumball_1.mdl")
            sun_ent:Spawn()

            local angle = math.random(0, 360)

            local x_offset = planet_radius * math.cos(math.rad(angle))
            local y_offset = planet_radius * math.sin(math.rad(angle))

            sun_ent:SetPos(self:GetPos() + Vector(x_offset, y_offset, 0))

            self:Initialize_physics(sun_ent)
            self:set_collision(sun_ent)
            self:set_random_pos(sun_ent)
            self:set_random_sizes(sun_ent)
            self:give_random_rotation(sun_ent)
            self:set_random_sun_texture(sun_ent)
            self:set_random_sun_color(sun_ent)

            self:create_planets(sun_ent)
            self:create_earth(sun_ent)
            
            self:create_asteroid_belts(sun_ent)

            self:create_sun_flares(sun_ent)

            sun_ent:SetParent(self)
        end 
    end 
end

function ENT:set_random_sun_texture(sun_texture)
    local sun_textures = {
        "entities/sun",
        "entities/sun_2",
        "entities/sun_dying",
        "entities/sun_noise",
        "entities/sun_swirly"
    }

    local random_sun_texture = table.Random(sun_textures)

    if IsValid(sun_texture) then
        sun_texture:SetMaterial(random_sun_texture)
    end
end

function ENT:set_random_sun_color(sun_color)
    local sun_colors = {
        red = Color(179, 34, 34),
        orange = Color(255, 115, 0),
        yellow = Color(255, 230, 0),
        white = Color(255, 255, 255),
        bright_blue = Color(0, 150, 255)
    }

    local random_sun_color = table.Random(sun_colors)

    if IsValid(sun_color) then
        sun_color:SetColor(random_sun_color) 
    end
end

function ENT:create_sun_flares(sun)
    if IsValid(sun) then
        local sun_flare_ent = ents.Create("env_sprite")

        if IsValid(sun_flare_ent) then

            table.insert(celestial_bodies, sun_flare_ent)

    
            self:set_random_star_flare(sun_flare_ent)
            sun_flare_ent:SetKeyValue("InitialState", "1")
            sun_flare_ent:SetKeyValue("WindAngle", "0 0 0")
            sun_flare_ent:SetKeyValue("WindSpeed", "0")

            self:set_random_sun_color(sun_flare_ent)
            sun_flare_ent:SetKeyValue("renderamt", math.random(155, 355))
            sun_flare_ent:SetKeyValue("rendermode", "5")
            sun_flare_ent:SetKeyValue("renderfx", "14")

            sun_flare_ent:SetKeyValue("Scale", tostring(math.random(3, 8)))
            sun_flare_ent:SetKeyValue("spawnflags", "1")
            sun_flare_ent:SetKeyValue("SpawnRate", "10")
            sun_flare_ent:SetKeyValue("Speed", "5")
            sun_flare_ent:SetKeyValue("StartSize", "20")
            sun_flare_ent:SetKeyValue("EndSize", "4")
            sun_flare_ent:SetKeyValue("roll", "10")
            sun_flare_ent:SetKeyValue("JetLength", "100")
            sun_flare_ent:SetKeyValue("twist", "5")
            

            sun_flare_ent:SetPos(sun:GetPos() + sun:OBBCenter())

            sun_flare_ent:SetParent(sun)
            sun_flare_ent:Spawn()
            sun_flare_ent:Activate()

            self:Initialize_physics(sun_flare_ent)
            self:set_collision(sun_flare_ent)

            sun_flare_ent:SetParent(self)
        end 
    end      
end

function ENT:set_random_star_flare(sun_flare)
    local star_flares = {
        "sprites/blueflare1.vmt",
        "sprites/light_glow02_add.vmt",
        "sprites/flare1.vmt",
        "sprites/light_flare01.vmt",
        "sprites/halo01.vmt",
        "sprites/redglow1.vmt",
        "sprites/glow01.vmt",
        "sprites/glow02.vmt"
    }

    random_star_flare = table.Random(star_flares)

    if IsValid(sun_flare) then
        sun_flare:SetKeyValue("model", random_star_flare)
    end
end

function ENT:create_asteroid_belts(sun)
    if IsValid(sun) then
        if math.random(0, 15) == 1 then
            local asteroid_belt_count = math.random(1, 5)
    
            for i = 1, asteroid_belt_count do
                local asteroid_belt_ent = ents.Create("prop_dynamic")
    
                asteroid_belt_ent:SetModel("models/entities/asteroid_belt.mdl")
                asteroid_belt_ent:Spawn()
                asteroid_belt_ent:Activate()
    
                table.insert(celestial_bodies, asteroid_belt_ent)
    
                self:Initialize_physics(asteroid_belt_ent)
                self:set_collision(asteroid_belt_ent)
                self:set_random_sizes_for_asteroid_belts(asteroid_belt_ent)
                self:set_asteroid_belt_texture(asteroid_belt_ent)
                
                asteroid_belt_ent:SetAngles(self.random_angle)
                
                asteroid_belt_ent:SetParent(sun)
    
                asteroid_belt_ent:SetPos(sun:GetPos() + Vector(0, 0, 0))
            end
        end
    end
end

function ENT:set_asteroid_belt_texture(asteroid_belt_texture)
    if IsValid(asteroid_belt_texture) then
        asteroid_belt_texture:SetMaterial("entities/rock_planet_crators")  
    end
end

function ENT:create_planet_ring(planet)
    if IsValid(planet) then
        local ring_count = math.random(1, 2)

        if math.random(0, 15) == 1 then
                
            for i = 1, ring_count do
                local ring_ent = ents.Create("prop_dynamic")

                self:set_random_ring_model(ring_ent)
                ring_ent:Spawn()
                ring_ent:Activate()

                table.insert(celestial_bodies, ring_ent)
                
                self:Initialize_physics(ring_ent)
                self:set_collision(ring_ent)
                self:give_random_rotation(ring_ent)
                self:set_random_ring_texture(ring_ent)
                self:set_random_ring_size(ring_ent)
                self:give_random_RGB_color(ring_ent)
                self:set_transparency(ring_ent)

                ring_ent:SetAngles(self.random_angle)
                ring_ent:SetParent(planet)

                ring_ent:SetPos(planet:GetPos() + Vector(0, 0, 0))
            end
        end 
    end 
end

function ENT:set_random_ring_model(ring)
    local rings = {
        "models/entities/planet_ring.mdl",
        "models/entities/planet_ring2.mdl",
        "models/entities/planet_ring3.mdl",
        "models/entities/planet_ring4.mdl"
    }

    local random_ring = table.Random(rings)

    if IsValid(ring) then
        ring:SetModel(random_ring)
    end
    
end

function ENT:set_transparency(transparency)
    if IsValid(transparency) then
        transparency:SetRenderMode(RENDERMODE_TRANSCOLOR)
        transparency:SetMaterial("models/entities/planet_ring.mdl")
    end
end

function ENT:set_random_ring_size(ring_size)
    local ring_sizes = math.random(3, 20)
    if IsValid(ring_size) then
        ring_size:SetModelScale(ring_sizes)
    end
end

function ENT:set_random_ring_texture(ring_texture)
    local ring_textures = {
        "entities/ring",
        "entities/ring2",
        "entities/ring3",
        "entities/ring4"    
    }

    local random_ring_texture = table.Random(ring_textures)

    if IsValid(ring_texture) then
        ring_texture:SetMaterial(random_ring_texture)
    end
end

function ENT:create_earth(sun)
    if IsValid(sun) then
        if math.random(0, 300) == 1 then
            local earth_ent = ents.Create("prop_dynamic")
    
            table.insert(celestial_bodies, earth_ent)
    
            earth_ent:SetModel("models/XQM/Rails/gumball_1.mdl")
            earth_ent:SetMaterial("entities/earth")
            earth_ent:Spawn()
            earth_ent:Activate()
    
            earth_ent:SetPos(sun:GetPos() + Vector(math.random(-100, 1000), math.random(-100, 1000), math.random(-100, 1000)))
            earth_ent:SetParent(sun)
            earth_ent:SetAngles(sun:GetAngles() + Angle(0, 0, 0))
            earth_ent:SetModelScale(1)
    
            self:Initialize_physics(earth_ent)
            self:set_collision(earth_ent)
            
            self:create_earths_moon(earth_ent)
        end
    end 
end

function ENT:create_earths_moon(sun)
    
    if IsValid(sun) then
        local moon_ent = ents.Create("prop_dynamic")

        table.insert(celestial_bodies, moon_ent)

        moon_ent:SetModel("models/XQM/Rails/gumball_1.mdl")
        moon_ent:SetMaterial("entities/earth_moon")
        moon_ent:Spawn()
        moon_ent:Activate()

        moon_ent:SetPos(sun:GetPos() + Vector(math.random(10, 100), math.random(10, 100), math.random(10, 100)))
        moon_ent:SetParent(sun)
        moon_ent:SetAngles(sun:GetAngles() + Angle(0, 0, 0))
        moon_ent:SetModelScale(0.5)

        self:Initialize_physics(moon_ent)
        self:set_collision(moon_ent)
    end
end


function ENT:create_planets(sun)
    if IsValid(sun) then
        local planet_count = math.random(0, 5)

        for i = 1, planet_count do
            local planet_ent = ents.Create("prop_dynamic")

            table.insert(celestial_bodies, planet_ent)

            planet_ent:SetModel("models/XQM/Rails/gumball_1.mdl")

            local planetPos = Vector(math.random(0, 2000) - 1000, math.random(0, 2000) - 1000, 0)
            planetPos:Rotate(sun:GetAngles())
            planet_ent:SetPos(sun:GetPos() + planetPos)

            planet_ent:SetParent(sun)

            planet_ent:Spawn()
            planet_ent:Activate()

            planet_ent:SetParent(self)
            planet_ent:SetAngles(self.random_angle)
            
            self:Initialize_physics(planet_ent)
            self:set_collision(planet_ent)
            self:set_random_sizes(planet_ent)
            self:give_random_rotation(planet_ent)
            self:set_random_planet_texture(planet_ent)
            self:give_random_RGB_color(planet_ent)
            
            
            self:create_planet_ring(planet_ent)
            self:create_moons(planet_ent)
        end
    end 
end


function ENT:set_random_planet_texture(planet)
    local planet_textures = {
        "entities/rock_planet_crators",
        "entities/rock_planet1",
        "entities/icey_planet",
        "entities/rock_planet_crators_2",
        "entities/rock_planet_3",
        "entities/rock_planet_4",

        "entities/lava_planet",
        "entities/dark_lava_planet",

        "entities/earth-like_planet",
        "entities/earth-like_planet_2",
        "entities/earth_like_planet3",
        "entities/earth_like_planet4",
        "entities/earth_like_planet5",
        "entities/earth_like_planet6",

        "entities/gas_giant_1",
        "entities/gas_giant_2",
        "entities/gas_giant_3",
        "entities/gas_giant_4",
        "entities/gas_giant_5",
        "entities/gas_giant_6",
        "entities/gas_giant_7",
        "entities/gas_giant_8",
        "entities/gas_giant_9"
    }
    
    local random_texture = table.Random(planet_textures)
    
    if IsValid(planet) then
        planet:SetMaterial(random_texture)
    end
end

function ENT:create_moons(planet)
    if IsValid(planet) then
        local moon_count = math.random(1, 5)

        if math.random(0, 8) == 1 then
            for i = 1, moon_count do
                local moon_ent = ents.Create("prop_dynamic")

                moon_ent:SetModel("models/XQM/Rails/gumball_1.mdl")
                moon_ent:Spawn()
                moon_ent:Activate()
                
                table.insert(celestial_bodies, moon_ent)

                moon_ent:SetPos(planet:GetPos() + Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)))
                moon_ent:SetParent(planet)
                moon_ent:SetAngles(planet:GetAngles() + Angle(0, 0, 0))
                moon_ent:SetAngles(self.random_angle)

                self:Initialize_physics(moon_ent)
                self:set_collision(moon_ent)
                self:give_random_rotation(moon_ent)
                self:set_random_moon_sizes(moon_ent)
                self:set_random_moon_texture(moon_ent)
                self:give_random_RGB_color(moon_ent)
            end
        end
    end
end

function ENT:set_random_moon_texture(moon_texture)
    local moon_textures = {
        "entities/rock_planet_crators",
        "entities/rock_planet1",
        "entities/rock_planet_crators_2",
        "entities/rock_planet_3",
        "entities/rock_planet_4"
    }

    local random_moon_texture = table.Random(moon_textures)

    if IsValid(moon_texture) then
        moon_texture:SetMaterial(random_moon_texture)
    end
end

function ENT:set_random_moon_sizes(moon_size)
    local moon_sizes = math.random(0.080, 0.1)
    if IsValid(moon_size) then
        moon_size:SetModelScale(moon_sizes)
    end
end

function ENT:Initialize_physics(physics)
    if IsValid(physics) then
        physics:PhysicsInit(SOLID_NONE)
        physics:SetMoveType(MOVETYPE_NONE) 
    end  
end

function ENT:set_collision(collision)
    if IsValid(collision) then
        collision:SetCollisionGroup(COLLISION_GROUP_NONE)
        collision:SetSolid(SOLID_NONE)
    end
end


function ENT:give_random_RGB_color(random_color)
    local random_colors
    
    if math.random(0, 15) == 1 then
        random_colors = Color(
            math.random(0, 255),
            math.random(0, 255),
            math.random(0, 255),
            math.random(40, 255)
        )
    else 
        random_colors = Color(
            math.random(80, 160),
            math.random(60, 140),
            math.random(40, 100),
            math.random(40, 255)
        )
    end   

    if IsValid(random_color) then
        random_color:SetColor(random_colors)
    end
end

function ENT:set_random_colorful_RGB_color(nebula_color)
    local random_colors = Color(
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255),
        math.random(40, 255)
    )
    if IsValid(nebula_color) then
        nebula_color:SetColor(random_colors)
    end
end

function ENT:give_random_rotation(rotation)

    local random_rotations = Angle(
        math.random(0, 360),
        math.random(0, 360),
        math.random(0, 360)
    )
    if IsValid(rotation) then
        rotation:SetAngles(random_rotations)
    end
end

function ENT:set_random_pos(pos)

    local random_pos = Vector(
        math.random(-9192, 9192),
        math.random(-9192, 9192),
        math.random(0, 5024)
    )
    random_pos = random_pos + self:GetPos()
    if IsValid(pos) then
        pos:SetPos(random_pos)
    end
end

function ENT:set_random_sizes_for_asteroid_belts(belt_size)
    belt_sizes = math.random(0.3, 200)
    if IsValid(belt_size) then
        belt_size:SetModelScale(belt_sizes)
    end 
end

function ENT:set_random_sizes(size)
    local sizes = math.random(0.3, 1)
    if IsValid(size) then
        size:SetModelScale(sizes)
    end
end

