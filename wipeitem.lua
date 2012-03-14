--[[ ]]--

local real_function = ContainerFrameItemButton_OnModifiedClick

function ContainerFrameItemButton_OnModifiedClick(self, button)
	if ( button == "LeftButton" ) and ( IsAltKeyDown() ) then
		PickupContainerItem(self:GetParent():GetID(), self:GetID());
		if (CursorHasItem()) then 
			DeleteCursorItem()
		end
	end
	real_function(self, button)
end