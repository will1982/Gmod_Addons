//It's Yarg, making crude Gmod addons
//This is version 0.1.0-July 12, 2013
//Code will be pushed to my Github-https://github.com/will1982/Gmod_Addons
//Based off my Lool gun, which was based off a tutorial
//Copyright (C) Yarg/Will1982 2013. Under the GNU GPL V3
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

function SWEP:ShootBullet( damage, num_bullets, aimcone )

	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()	// Source
	bullet.Dir 		= self.Owner:GetAimVector()	// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 5	// Show a tracer on every x bullets
        bullet.TracerName = "Tracer" // what Tracer Effect should be used
	bullet.Force	= 1	// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "Pistol"

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end


function SWEP:throw_attack (model_file)
	local tr = self.Owner:GetEyeTrace()

	self:EmitSound(ShootSound)
	self.BaseClass.ShootEffects(self)

	//We now exit if this function is not running serverside
	if (!SERVER) then return end

	//The next task is to create a physics prop based on the supplied model
	local ent = ents.Create("prop_physics")
	ent:SetModel(model_file)

	//Set the initial position and angles of the object. This might need some fine tuning;
	//but it seems to work for the models I have tried.
	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
	ent:SetAngles(self.Owner:EyeAngles())
	ent:Spawn()

	//Now we need to get the physics object for our entity so we can apply a force to it
	local phys = ent:GetPhysicsObject()

	//Check if the physics object is valid. If not, remove the entity and stop the function
	if !(phys && IsValid(phys)) then ent:Remove() return end

	//Time to apply the force. My method for doing this was almost entirely empirical
	//and it seems to work fairly intuitively with chairs.
	phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  math.pow(tr.HitPos:Length(), 3))

	//Now for the important part of adding the spawned objects to the undo and cleanup lists.
	cleanup.Add(self.Owner, "props", ent)

	undo.Create ("Thrown_SWEP_Entity")
		undo.AddEntity (ent)
		undo.SetPlayer (self.Owner)
	undo.Finish()
end


function SWEP:PrimaryAttack()
	self:ShootBullet()
end

function SWEP:SecondaryAttack()
	self:throw_attack("models/props_c17/FurnitureChair001a.mdl")
end
