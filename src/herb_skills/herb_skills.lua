
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
local service_skill = require("skiller.ros.service_skill")
local arm_skill = require("herb_skills.armskill")
require("skiller.skillhsm")

print("Initializing HERB skills")
--action_skill.debug = true

-- Generic action skills
action_skill.use("herb_skills.say", "/talker", "talkerapplet/Say")
--action_skill.use("herb_skills.stop_arms", "/hwctrl/arms/stop", "pr_msgs/Signal")
--action_skill.use("herb_skills.stop_segway", "/hwctrl/segway/stop", "pr_msgs/Signal")
--action_skill.use("herb_skills.resume_segway", "/hwctrl/segway/resume", "pr_msgs/Signal")
action_skill.use("herb_skills.turn_global", "/rails/rotate/global", "RobotOnRails/Rotate")
action_skill.use("herb_skills.turn", "/rails/rotate/relative", "RobotOnRails/Rotate")
action_skill.use("herb_skills.drive_forward", "/rails/drive/forward", "RobotOnRails/Drive")
action_skill.use("herb_skills.goto", "/rails/goto", "RobotOnRails/Goto")
action_skill.use("herb_skills.stop_rails", "/rails/stop", "pr_msgs/Signal")
action_skill.use("herb_skills.lockenv", "/manipulation/env/lock", "pr_msgs/Signal")
action_skill.use("herb_skills.releaseenv", "/manipulation/env/release", "pr_msgs/Signal")

-- Generic arms skills
arm_skill.use("herb_skills.grab", "grab", "manipulationapplet/Grab")
arm_skill.use("herb_skills.noop", "none", "manipulationapplet/NoOp")
arm_skill.use("herb_skills.pickup", "pickup", "manipulationapplet/Pickup")
arm_skill.use("herb_skills.put", "put", "manipulationapplet/Put")
arm_skill.use("herb_skills.handoff", "handoff", "manipulationapplet/HandOff")
arm_skill.use("herb_skills.take", "take", "manipulationapplet/Take")
arm_skill.use("herb_skills.goinitial", "goinitial", "manipulationapplet/GoInitial")
arm_skill.use("herb_skills.weigh", "getobjectweight", "manipulationapplet/WeighObject")

-- Generic service skills
service_skill.use("herb_skills.slide_load", "/rospresenter/load", "rospresenter/Load")
service_skill.use("herb_skills.slide_next", "/rospresenter/page/next", "std_srvs/Empty")
service_skill.use("herb_skills.slide_prev", "/rospresenter/page/prev", "std_srvs/Empty")
service_skill.use("herb_skills.slide_goto", "/rospresenter/page/goto", "rospresenter/GotoPage")
service_skill.use("herb_skills.slide_hide", "/rospresenter/hide", "std_srvs/Empty")
service_skill.use("herb_skills.hold_arm", "/hwctrl/arm/hold", "hwctrl/SideDependent")
service_skill.use("herb_skills.relax_arm", "/hwctrl/arm/relax", "hwctrl/SideDependent")
service_skill.use("herb_skills.open_hand", "/hwctrl/hand/open", "hwctrl/SideDependent")
service_skill.use("herb_skills.reset_hand", "/hwctrl/hand/reset", "hwctrl/SideDependent")
service_skill.use("herb_skills.stop_arms", "/hwctrl/arms/stop", "pr_msgs/Signal")
service_skill.use("herb_skills.stop_segway", "/hwctrl/segway/stop", "pr_srvs/Empty")
service_skill.use("herb_skills.resume_segway", "/hwctrl/segway/resume", "pr_srvs/Empty")

-- Custom skills
skillenv.use_skill("herb_skills.grab_object")
skillenv.use_skill("herb_skills.reset_arms")
