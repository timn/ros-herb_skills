
----------------------------------------------------------------------------
--  init.lua - Herb skills initialization file
--
--  Created: Fri Aug 20 18:25:22 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

require("fawkes.modinit")
module(..., fawkes.modinit.register_all);

skillenv = require("skiller.skillenv")
local action_skill = require("skiller.ros.action_skill")
require("skiller.skillhsm")

--skillenv.use_skill("herb_skills.say")
print("Initializing HERB skills")
action_skill.debug = true
action_skill.use("herb_skills.say", "/talker", "talkerapplet/Say")
action_skill.use("herb_skills.stop_arms", "/hwctrl/arms/stop", "pr_msgs/Signal")
action_skill.use("herb_skills.stop_segway", "/hwctrl/segway/stop", "pr_msgs/Signal")
action_skill.use("herb_skills.resume_segway", "/hwctrl/segway/resume", "pr_msgs/Signal")
action_skill.use("herb_skills.rotate_global", "/rails/rotate/global", "RobotOnRails/Rotate")
action_skill.use("herb_skills.rotate_relative", "/rails/rotate/relative", "RobotOnRails/Rotate")
action_skill.use("herb_skills.drive_forward", "/rails/drive/forward", "RobotOnRails/Drive")
action_skill.use("herb_skills.goto", "/rails/goto", "RobotOnRails/Goto")
action_skill.use("herb_skills.stop_rails", "/rails/stop", "pr_msgs/Signal")

