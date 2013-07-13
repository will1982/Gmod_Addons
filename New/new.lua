//It's Yarg, making crude Gmod addons
//This is version 0.0.0-July 12, 2013
//Code will be pushed to my Github-https://github.com/will1982/Gmod_Addons
//Based off my Lool gun, which was based off a tutorial
//Copyright (C) Yarg/Will1982 2013. All rights reserved
//Badly commented.

//Swep vars
if SERVER then

AddCSLuaFile ("new.lua")

SWEP.Weight = 7

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = false

elseif CLIENT then

SWEP.Printname = "New melon launcher"

SWEP.Slot = 3
SWEP.Slotpos = 2

SWEP.Drawammo = false
SWEP.Drawcrosshair = true

language.Add("Undone_Thrown_SWEP_Entity","Undone Thrown SWEP Entity")
end

SWEP.Author = "Yarg"
SWEP.Contact = "yarg@willsappleholler.com"
SWEP.Purpose = "Indev"
SWEP.Instructions = "Indev"

SWEP.Category = "Yarg's Sweps"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/v_Pistol.mdl" --1st person
SWEP.WorldModel = "	models/weapons/w_smg1.mdl " --Everyone else

SWEP.Primary.Clipsize = -1
SWEP.Primary.DefaultClip = -1

SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

local ShootSound = Sound("Weapon_SMG1.Burst")

function SWEP:Reload()
end

function SWEP:Think()
end

function SWEP:throw_attack (model_file)
local tr = self.Owner:GetEyeTrace()

self:EmitSound(ShootSound)
self.BaseClass.ShootEffects(self)

if (!SERVER) then return end

ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
ent:SetAngles(self.Owner:EyeAngles())
ent:Spawn()

local phys = ent:GetPhysicsObject()

if !(phys && IsValid(phys)) then ent:Remove() return end

phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * math.pow(tr.HitPos:Length(), 3))

cleanup.Add(self.Owner, "props", ent)

undo.Create ("Thrown_SWEP_Entity")
undo.AddEntity (ent)
undo.SetPlayer (self.Owner)
undo.Finish()
end

function SWEP:PrimaryAttack()
function SWEP:ShootBullet( damage, num_bullets, aimcone )
 
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()	// Source
	bullet.Dir 		= self.Owner:GetAimVector()	// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 5	// Show a tracer on every x bullets 
        bullet.TracerName = "Tracer" // what Tracer Effect should be used
	bullet.Force	= 3	// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"
 
	self.Owner:FireBullets( bullet )
 
	self:ShootEffects()
 
end
end

function SWEP:SecondaryAttack()
 
	if ( !self:CanPrimaryAttack() ) then return end
 
	local eyetrace = self.Owner:GetEyeTrace();
	
	self:EmitSound ( self.Shootsound )
 
	self.BaseClass.ShootEffects (self);
 
	local explode = ents.Create( "env_explosion" )
	explode:SetPos( eyetrace.HitPos )
	explode:SetOwner( self.Owner ) -- this sets you as the person who made the explosion
	explode:Spawn() --this actually spawns the explosion
	explode:SetKeyValue( "iMagnitude", "220" ) -- the magnitude
	explode:Fire( "Explode", 0, 0 )
	explode:EmitSound( "weapon_AWP.Single", 400, 400 ) -- the sound for the explosion, and how far away it can be heard
 
	self:SetNextPrimaryFire( CurTime() + 0.15 )
	self:SetNextSecondaryFire( CurTime() + 0.20 )
 
end

