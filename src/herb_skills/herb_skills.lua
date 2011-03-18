
----------------------------------------------------------------------------
--  init.lua - Herb skills initialization file
--
--  Created: Fri Aug 20 18:25:22 2010 (at Intel Research, Pittsburgh)
--  License: BSD, cf. LICENSE file
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--             2010  Carnegie Mellon University
--             2010  Intel Labs Pittsburgh
----------------------------------------------------------------------------

require("fawkes.modinit")
module(..., fawkes.modinit.register_all)

skillenv = require("skiller.skillenv")
local action_skill = require("skiller.ros.action_skill")
local service_skill = require("skiller.ros.service_skill")
local arm_skill = require("herb_skills.armskill")
require("skiller.skillhsm")

print("Initializing HERB skills")
action_skill.debug = true

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
action_skill.use("herb_skills.pose_goto", "/posegraph/goto", "posegraphapplet/GotoPose")
action_skill.use("herb_skills.pose_fromto", "/posegraph/gofromto", "posegraphapplet/GoFromToPose")

-- Generic arms skills
arm_skill.use("herb_skills.handover", "handover", "newmanipapp/Handover")
arm_skill.use("herb_skills.take_at_tm", "take_at_tm", "newmanipapp/TakeAtTM")
arm_skill.use("herb_skills.go_to_tm", "go_to_tm", "newmanipapp/GoToTM")
arm_skill.use("herb_skills.fthandoff", "fthandoff", "newmanipapp/FTHandOff")
arm_skill.use("herb_skills.fttake", "fttake", "newmanipapp/FTTake")
arm_skill.use("herb_skills.fttare", "fttare", "newmanipapp/FTTare")
arm_skill.use("herb_skills.give", "give", "newmanipapp/Give")
arm_skill.use("herb_skills.goinitial", "goinitial", "newmanipapp/GoInitial")
arm_skill.use("herb_skills.grab", "grab", "newmanipapp/Grab")
arm_skill.use("herb_skills.handoff", "handoff", "newmanipapp/HandOff")
arm_skill.use("herb_skills.noop", "none", "newmanipapp/NoOp")
arm_skill.use("herb_skills.pickup", "pickup", "newmanipapp/Pickup")
arm_skill.use("herb_skills.place_unlocked", "place", "newmanipapp/Place")
arm_skill.use("herb_skills.put_unlocked", "put", "newmanipapp/Put")
arm_skill.use("herb_skills.take", "reachtake", "newmanipapp/ReachTake")
arm_skill.use("herb_skills.weigh", "getobjectweight", "newmanipapp/WeighObject")

-- Generic service skills
service_skill.use("herb_skills.slide_load", "/presenter/load", "presenter/Load")
service_skill.use("herb_skills.slide_next", "/presenter/page/next", "std_srvs/Empty")
service_skill.use("herb_skills.slide_prev", "/presenter/page/prev", "std_srvs/Empty")
service_skill.use("herb_skills.slide_goto", "/presenter/page/goto", "presenter/GotoPage")
service_skill.use("herb_skills.slide_hide", "/presenter/hide", "std_srvs/Empty")
service_skill.use("herb_skills.hold_arm", "/hwctrl/arm/hold", "hwctrl/SideDependent")
service_skill.use("herb_skills.relax_arm", "/hwctrl/arm/relax", "hwctrl/SideDependent")
service_skill.use("herb_skills.open_hand", "/hwctrl/hand/open", "hwctrl/SideDependent")
service_skill.use("herb_skills.reset_hand", "/hwctrl/hand/reset", "hwctrl/SideDependent")
service_skill.use("herb_skills.stop_arms", "/hwctrl/arms/stop", "std_srvs/Empty")
service_skill.use("herb_skills.stop_segway", "/hwctrl/segway/stop", "std_srvs/Empty")
service_skill.use("herb_skills.resume_segway", "/hwctrl/segway/resume", "std_srvs/Empty")

-- Custom skills
skillenv.use_skill("herb_skills.grab_object")
skillenv.use_skill("herb_skills.reset_arms")
skillenv.use_skill("herb_skills.place")
skillenv.use_skill("herb_skills.put")

print_warn("Initialized HERB skills. Skiller can now be used.")
