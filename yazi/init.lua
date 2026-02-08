-- 1. 初始化全边框插件 (让界面拥有现代感的完整边框)
require("full-border"):setup {
    type = ui.Border.ROUNDED,
}

-- 2. 自定义状态栏：在右侧显示文件的用户/组权限
function Status:owner()
	local h = cx.active.current.hovered
	if h == nil or ya.target_family() ~= "unix" then
		return ui.Line {}
	end

	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		ui.Span(":"),
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		ui.Span(" "),
	}
end

-- 3. 将自定义组件插入状态栏渲染序列
Status:children_add(Status.owner, 500, Status.RIGHT)
