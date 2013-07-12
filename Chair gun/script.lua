//"Da lool gun" by Yarg.
//Fires chairs. My first SWEP.
//Workshop page: http://steamcommunity.com/sharedfiles/filedetails/?id=158673321
//This is version 1.1.1, July 10, 2013

//Code under the GNU GPL License V3- http://www.gnu.org/licenses/gpl.html
//Written by Yarg with help from a tutorial. My profile: http://steamcommunity.com/id/AppleHoller/

//Swep variables
if SERVER then

	//This makes sure clients download the file
	AddCSLuaFile ("shared.lua")

	//How heavy the SWep is
	SWEP.Weight = 7

	//Allow automatic switching to/from this weapon when weapons are picked up
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false

elseif CLIENT then

	SWEP.PrintName = "Da lool gun"

	//Sets the position of the weapon in the switching menu
	//(appears when you use the scroll wheel or keys 1-6 by default)
	SWEP.Slot = 2
	SWEP.SlotPos = 3

	SWEP.DrawAmmo = false

	SWEP.DrawCrosshair = true

	//Ensures a clean looking notification when a chair is undone. How it works:
	//When you create an undo, you specify the ID:
	//		undo.Create("Some_Identity")
	//By creating an associated language, we can make the undo notification look better:
	//		language.Add("Undone_Some_Identity", "Some message...")

	language.Add("Undone_Thrown_SWEP_Entity","Undone Thrown SWEP Entity")
end

SWEP.Author = "Yarg"
SWEP.Contact = "yarg@willsappleholler.com"
SWEP.Purpose = "Shoot chairs!"
SWEP.Instructions = "Hurr durr I dunno"

SWEP.Category = "Gun"

SWEP.Spawnable = true -- Whether regular players can see it
SWEP.AdminSpawnable = true -- Whether Admins/Super Admins can see it

SWEP.ViewModel = "models/weapons/v_Pistol.mdl" -- This is the model used for clients to see in first person.
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl" -- This is the model shown to all other clients and in third-person.


//-1 means no ammo
SWEP.Primary.ClipSize = -1

//Moar ammo junk
SWEP.Primary.DefaultClip = -1

//Is the gun automatic?
SWEP.Primary.Automatic = true
//Sets the ammunition type the gun uses, see below for a list of types.
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

//When the script loads, the sound ''Metal.SawbladeStick'' will be precached,
//and a local variable with the sound name created.
// This will prevent lag when you fire it for the first time

local ShootSound = Sound("Weapon_SMG1.Burst")

function SWEP:Reload()
end

function SWEP:Think()
end


function SWEP:throw_attack (model_file)
	//Get an eye trace. This basically draws an invisible line from
	//the players eye. This SWep makes very little use of the trace, except to
	//calculate the amount of force to apply to the object thrown.
	local tr = self.Owner:GetEyeTrace()

	//Play some noises/effects using the sound we precached earlier
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


//Throw an office chair on primary attack
function SWEP:PrimaryAttack()
	//Call the throw attack function, with the office chair model
	self:throw_attack("models/props/cs_office/Chair_office.mdl")
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.33 )
end

//Throw a wooden chair on secondary attack
function SWEP:SecondaryAttack()
	//Call the throw attack function, this time with the wooden chair model
	self:throw_attack("models/props_c17/FurnitureChair001a.mdl")
end
