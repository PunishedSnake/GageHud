if not mod_collection then
	return
end

function HUDAssaultCorner:init(hud, full_hud)
	self._hud_panel = hud.panel
	self._full_hud_panel = full_hud.panel
	self._casing_color = Color.white
	if self._hud_panel:child("assault_panel") then
		self._hud_panel:remove(self._hud_panel:child("assault_panel"))
	end

	local size = 200
	local assault_panel = self._hud_panel:panel({
		visible = false,
		name = "assault_panel",
		w = 270,
		h = 100
	})
	assault_panel:set_center(self._hud_panel:center())
	assault_panel:set_top(0)
	self._assault_color = Color(1, 1, 1, 0)

	local icon_assaultbox = assault_panel:bitmap({
		halign = "right",
		valign = "top",
		color = Color.yellow,
		name = "icon_assaultbox",
		blend_mode = "add",
		visible = true,
		layer = 0,
		texture = "guis/textures/pd2/hud_icon_assaultbox",
		w = 24,
		h = 24
	})
	icon_assaultbox:set_right(icon_assaultbox:parent():w())
	self._bg_box = HUDBGBox_create(assault_panel, {
		w = 242,
		h = 38,
	}, {
		color = self._assault_color,
		blend_mode = "add"
	})
	self._bg_box:set_right(icon_assaultbox:left() - 3)
	local yellow_tape = assault_panel:rect({
		visible = false,
		name = "yellow_tape",
		h = tweak_data.hud.location_font_size * 1.5,
		w = size * 3,
		color = Color(1, 0.8, 0),
		layer = 1
	})
	yellow_tape:set_center(10, 10)
	yellow_tape:set_rotation(30)
	yellow_tape:set_blend_mode("add")
	assault_panel:panel({
		name = "text_panel",
		layer = 1,
		w = yellow_tape:w()
	}):set_center(yellow_tape:center())
	if self._hud_panel:child("point_of_no_return_panel") then
		self._hud_panel:remove(self._hud_panel:child("point_of_no_return_panel"))
	end

	--TODO: Fix text alignment
	local size = 300
	local point_of_no_return_panel = self._hud_panel:panel({
		visible = false,
		name = "point_of_no_return_panel",
		w = size,
		h = 40
	})
	point_of_no_return_panel:set_center(self._hud_panel:center())
	point_of_no_return_panel:set_top(0)
	self._noreturn_color = Color(1, 1, 0, 0)
	local icon_noreturnbox = point_of_no_return_panel:bitmap({
		halign = "right",
		valign = "top",
		color = self._noreturn_color,
		name = "icon_noreturnbox",
		blend_mode = "add",
		visible = true,
		layer = 0,
		texture = "guis/textures/pd2/hud_icon_noreturnbox",
		w = 24,
		h = 24
	})
	icon_noreturnbox:set_right(icon_noreturnbox:parent():w())
	self._noreturn_bg_box = HUDBGBox_create(point_of_no_return_panel, {
		w = 242,
		h = 38,
	}, {
		color = self._noreturn_color,
		blend_mode = "add"
	})
	self._noreturn_bg_box:set_right(icon_noreturnbox:left() - 3)
	local w = point_of_no_return_panel:w()
	local size = 200 - tweak_data.hud.location_font_size
	local point_of_no_return_text = self._noreturn_bg_box:text({
		name = "point_of_no_return_text",
		text = "",
		blend_mode = "add",
		layer = 1,
		valign = "center",
		align = "right",
		vertical = "center",
		color = self._noreturn_color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})
	point_of_no_return_text:set_text(utf8.to_upper(managers.localization:text("hud_assault_point_no_return_in", {time = ""})))
	point_of_no_return_text:set_size(self._noreturn_bg_box:w(), self._noreturn_bg_box:h())
	local point_of_no_return_timer = self._noreturn_bg_box:text({
		name = "point_of_no_return_timer",
		text = "",
		blend_mode = "add",
		layer = 1,
		valign = "center",
		align = "center",
		vertical = "center",
		color = self._noreturn_color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})
	local _, _, w, h = point_of_no_return_timer:text_rect()
	point_of_no_return_timer:set_size(46, self._noreturn_bg_box:h())
	point_of_no_return_timer:set_right(point_of_no_return_timer:parent():w())
	point_of_no_return_text:set_right(math.round(point_of_no_return_timer:left()))
end

function HUDAssaultCorner:sync_start_assault(data)
	if self._point_of_no_return then
		return
	end

	if managers.job:current_difficulty_stars() > 0 then
		local ids_risk = Idstring("risk")
		self:_start_assault({
			"hud_assault_assault",
			"hud_assault_end_line",
			ids_risk,
			"hud_assault_end_line",
			"hud_assault_assault",
			"hud_assault_end_line",
			ids_risk,
			"hud_assault_end_line"
		})
	else
		self:_start_assault({
			"hud_assault_assault",
			"hud_assault_end_line",
			"hud_assault_assault",
			"hud_assault_end_line",
			"hud_assault_assault",
			"hud_assault_end_line"
		})
	end
end

function HUDAssaultCorner:show_point_of_no_return_timer()
	local delay_time = self._assault and 1.2 or 0
	self:_end_assault()
	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
	point_of_no_return_panel:stop()
	point_of_no_return_panel:animate(callback(self, self, "_animate_show_noreturn"), delay_time)
	self._point_of_no_return = true
end

function HUDAssaultCorner:hide_point_of_no_return_timer()
	self._noreturn_bg_box:stop()
	self._hud_panel:child("point_of_no_return_panel"):set_visible(false)
	self._point_of_no_return = false
end

function HUDAssaultCorner:set_control_info(...) end
function HUDAssaultCorner:show_casing(...) end
function HUDAssaultCorner:hide_casing(...) end

local orig_init = HUDAssaultCorner.init
function HUDAssaultCorner:init(hud, full_hud)
	orig_init(self, hud, full_hud)
	self._hud_panel = hud.panel
	self._full_hud_panel = full_hud.panel
	if self._hud_panel:child("hostages_panel") then
		self:_hide_hostages()
	end
end

function HUDAssaultCorner:_show_hostages()
	if not self._casing_panel then
	end
end
