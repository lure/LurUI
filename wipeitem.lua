--[[
 Alt + leftclick purges item under cursor
 Execution tainted by lurui while reading ContainerFrameItemButton_OnModifiedClick - ContainerFrame1Item15:OnClick()
]]--
hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function (self, button)
	if ( button == "LeftButton" ) and ( IsAltKeyDown() ) then
		PickupContainerItem(self:GetParent():GetID(), self:GetID());
		if (CursorHasItem()) then 
			DeleteCursorItem()
		end
	end
end)