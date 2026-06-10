
local PLUGIN = PLUGIN

ENT.Type = "anim"
ENT.Author = "Fruity"
ENT.PrintName = "Новостной Принтер"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.bNoPersist = true

ENT.Displays = {
	[1] = {"ОЖИДАНИЕ", Color( 255, 255, 180 ), true},
	[2] = {"ПРОВЕРКА", Color(0, 255, 0)},
	[3] = {"НЕТ БУМАГИ/ЧЕРНИЛ", Color(255, 0, 0)},
	[4] = {"НЕТ БУМАГИ", Color(255, 0, 0)},
	[5] = {"НЕТ ЧЕРНИЛ", Color(255, 0, 0)},
	[6] = {"ПЕРЕЗАГРУЗКА", Color(255, 200, 0)},
	[7] = {"В ПРОЦЕССЕ", Color(255, 255, 180), true},
	[8] = {"ИДЕТ ПЕЧАТЬ", Color( 0, 255, 0 ), true},
	[9] = {"НЕТ РАЗРЕШЕНИЯ", Color(255, 0, 0)},
	[10] = {"КАРТА НЕ ТРЕБУЕТСЯ", Color(0, 255, 0)},
	[11] = {"БУМАГА ИСЧЕРПАНА", Color(0, 255, 0)},
	[12] = {"ЧЕРНИЛА ИСЧЕРПАНЫ", Color(0, 255, 0)},
	[13] = {"НЕДЕЙСТВ. КАРТА", Color(255, 0, 0)}
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Display")
	self:NetworkVar("Float", 0, "Ink")
	self:NetworkVar("Float", 1, "Paper")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/willardnetworks/plotter.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:DrawShadow(false)
		self:SetUseType(SIMPLE_USE)
		self:SetDisplay(1)
		self:SetSkin(1)

		local physics = self:GetPhysicsObject()
		physics:EnableMotion(false)
		physics:Wake()

		self.canUse = true
		self.paper = self.paper or 0
		self.ink = self.ink or 0
		self:SetInk(self.ink)
		self:SetPaper(self.paper)
		self.canTouch = true
	end

	function ENT:CheckCID(client)
		local character = client:GetCharacter()
		local inventory = character:GetInventory()

		if self.registeredCID and self.registeredCID != "00000" then
			if self.registeredCID != "00000" then
				for _, v in pairs(inventory:GetItems()) do
					if v.uniqueID == "id_card" then
						if v:GetData("cid") == self.registeredCID then
							return true
						else
							return false
						end
					end
				end
			else
				self:SetDisplay(10)
				return true
			end
		else
			self:SetDisplay(10)
			return true
		end

		self:SetDisplay(13)

		timer.Simple(2, function()
			self.canUse = true
			self:SetDisplay(1)
		end)

		return false
	end

	function ENT:CheckForPaperInk()
		if (self.paper <= 0 or self.ink <= 0) then
			if (self.paper <= 0 and self.ink <= 0) then
				self:SetDisplay(3)
				self:EmitSound("buttons/button10.wav")
				timer.Simple(2, function()
					self:SetDisplay(1)
					self.canUse = true
				end)

				return false
			end

			if self.paper <= 0 then
				self:SetDisplay(4)
				self:EmitSound("buttons/button10.wav")
			end

			if self.ink <= 0 then
				self:SetDisplay(5)
				self:EmitSound("buttons/button10.wav")
			end

			timer.Simple(2, function()
				self:SetDisplay(1)
				self.canUse = true
			end)

			return false
		end

		return true
	end

	function ENT:Touch(touchingEnt)
		if self.canTouch then
			if touchingEnt:GetClass() == "ix_item" then
				self.canTouch = false
				local itemID = touchingEnt.ixItemID
				local itemTable = ix.item.instances[itemID]
				if itemTable.uniqueID == "paper" or itemTable.uniqueID == "black_ink" then
					if itemTable.uniqueID == "paper" then
						if self.paper == 5 then
							self:SetDisplay(11)
							self:EmitSound("buttons/button10.wav")
							timer.Simple(1, function()
								self:SetDisplay(1)
								self.canTouch = true
							end)

							return false
						end

						self:EmitSound("buttons/button14.wav")
						self.paper = math.Clamp(self.paper + 1, 0, 5)
						self:SetPaper(self.paper)
						touchingEnt:Remove()
					end

					if itemTable.uniqueID == "black_ink" then
						if self.ink == 5 then
							self:SetDisplay(12)
							self:EmitSound("buttons/button10.wav")
							timer.Simple(1, function()
								self:SetDisplay(1)
								self.canTouch = true
							end)

							return false
						end

						self:EmitSound("buttons/button14.wav")
						self.ink = math.Clamp(self.ink + 1, 0, 5)
						self:SetInk(self.ink)
						touchingEnt:Remove()
					end
				end

				timer.Simple(1, function()
					self.canTouch = true
				end)
			end
		end
	end

	function ENT:Use(client)
		if self.canUse then
			self:SetDisplay(2)
			self:EmitSound("ambient/materials/metal_stress3.wav")
			self.canUse = false
			timer.Simple(2, function()
				if self:CheckCID(client) then
					timer.Simple(2, function()
						if self:CheckForPaperInk() then
							netstream.Start(client, "OpenNewspaperEditor", true, false, self)
							self:EmitSound("buttons/button4.wav")
							self:SetDisplay(7)
							self.canUse = false

							local uniqueID = "NewspaperCheckForPlayer"..self:EntIndex()
							timer.Create(uniqueID, 10, 0, function()
								if (!IsValid(self)) then
									timer.Remove(uniqueID)
									return
								end

								if !client or !client:GetCharacter() then
									if IsValid(self) then
										self.canUse = true
										self:SetDisplay(1)

										timer.Remove(uniqueID)
									end
								end
							end)
						end
					end)
				end
			end)
		end
	end

	function ENT:Close()
		self.canUse = true
		self:SetDisplay(1)
	end

	function ENT:PrintNewspaper(client, pictureEntryVisible, columnTextVisible, savedText, pictureURL)
		local character = client:GetCharacter()
		local randomID = math.random(0, 90000)

		if character:GetGenericdata().permits == false then
			self:SetDisplay(9)
			client:NotifyLocalized("У вас нет коммерческой лицензии!")
			self:EmitSound("buttons/button10.wav")

			timer.Simple(2, function()
				self:SetDisplay(1)
				self.canUse = true
			end)
		else
			if ix.data.Get("newspaper_"..randomID) then
				randomID = math.random(0, 90000)
			end

			if pictureEntryVisible then
				savedText["columnTextEntry"] = nil
			end

			if columnTextVisible then
				savedText["pictureEntry"] = nil
			end

			if pictureURL != "temp" then
				savedText[1].pictureURL = pictureURL
			end

			ix.data.Set("newspaper_"..randomID, savedText)
			netstream.Start(client, "SetNewspaperContent", randomID, savedText)

			self:SetDisplay(8)
			self:EmitSound("ambient/machines/combine_terminal_idle3.wav")
			self:SetSkin(0)
			self:ResetSequence( 1 )

			timer.Simple(5, function()
				local entity = ents.Create("ix_shipment")
				entity:Spawn()
				entity:SetPos(client:GetItemDropPos(entity))
				entity:SetItems({["newspaper"] = self.paper})
				entity:SetNetVar("owner", character:GetID())
				entity.itemData = "newspaper_"..randomID

				self:SetSkin(1)
				self:SetDisplay(1)
				self:ResetSequence( 0 )
				self:EmitSound("buttons/button6.wav")

				local shipments = character:GetVar("charEnts") or {}
				table.insert(shipments, entity)
				character:SetVar("charEnts", shipments, true)

				hook.Run("CreateShipment", client, entity)

				self.ink = math.Clamp(self.ink - 1, 0, 5)
				self.paper = 0
				self:SetInk(self.ink)
				self:SetPaper(self.paper)
				self.canUse = true
			end)
		end
	end

	ENT.AutomaticFrameAdvance = true -- Must be set on client
else
	netstream.Hook("SetNewspaperContent", function(randomID, savedText)
		ix.data.Set("newspaper_"..randomID, savedText, false, true)
	end)

	netstream.Hook("SetNewspaperContentWithIDCL", function(id, content)
		ix.data.Set(id, content, false, true)
	end)

	netstream.Hook("OpenNewspaperEditor", function(canEdit, activeNewspaper, entity)
		local editor = vgui.Create("NewspaperEditor")
		editor:CreateFunctionsPanel(canEdit, entity)
		editor:CreateInnerContent(entity, activeNewspaper)
	end)

	function ENT:Draw()
		self:DrawModel()

		local ang = self:GetAngles()
		local pos = self:GetPos() + ang:Up() * 41.7 + ang:Right() * 9.56 + ang:Forward() * 8.6
		ang:RotateAroundAxis(ang:Right(), 90)
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		local width, height = 176, 66

		local display = self.Displays[self:GetDisplay()] or self.Displays[6]

		cam.Start3D2D( pos, ang, 0.1 )
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetDrawColor( Color( 16, 16, 16, 240 ) )
			surface.DrawRect( 0, 0, width, height )

			surface.SetDrawColor( Color( 255, 255, 255, 16 ) )
			surface.DrawRect( 10, height / 2 + math.sin( CurTime() * 4 ) * height / 2.5, width - 22, 1 )

			local alpha = 191 + 64 * math.sin( CurTime() * 4 )
			local color = ColorAlpha(display[2], alpha)

			draw.SimpleText( "НОВОСТНОЙ ПРИНТЕР", "MenuFont", width / 2, 10, Color( 255, 255, 255, alpha ), TEXT_ALIGN_CENTER )
			draw.SimpleText( display[1], "MenuFont", width / 2, height - 16, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()

		local paper = self:GetPaper() or 0
		local ink = self:GetInk() or 0

		pos = pos + ang:Up() * -1.95
		cam.Start3D2D( pos, ang, 0.1 )
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetDrawColor( Color(255, 255, 255, 255) )
			surface.DrawRect( -6, 97, 35 / 2, 12 )

			draw.SimpleText( paper, "MenuFont", 3, 93, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER )

			surface.SetDrawColor( Color(0, 0, 0, 255) )
			surface.DrawRect( -6 + (35 / 2), 97, 35 / 2, 12 )

			draw.SimpleText( ink, "MenuFont", 20, 93, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
	end
end