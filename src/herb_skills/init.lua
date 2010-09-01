
----------------------------------------------------------------------------
--  init.lua - Herb skills initialization file
--
--  Created: Fri Aug 20 18:25:22 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

require("fawkes.modinit")
module(..., fawkes.modinit.register_all)

skillenv = require("skiller.skillenv")
local action_skill = require("skiller.ros.action_skill")
local arm_skill = require("herb_skills.armskill")
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
arm_skill.use("herb_skills.grab", "grab", "manipulationapplet/Grab")
arm_skill.use("herb_skills.noop", "none", "manipulationapplet/NoOp")
arm_skill.use("herb_skills.pickup", "pickup", "manipulationapplet/Pickup")
arm_skill.use("herb_skills.put", "put", "manipulationapplet/Put")
arm_skill.use("herb_skills.handoff", "handoff", "manipulationapplet/HandOff")
arm_skill.use("herb_skills.goinitial", "goinitial", "manipulationapplet/GoInitial")
