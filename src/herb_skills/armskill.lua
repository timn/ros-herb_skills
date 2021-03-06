
------------------------------------------------------------------------
--  armskill.lua - Create skill module automatically for arm actions
--
--  Created: Wed Sep 01 16:30:45 2010
--  License: BSD, cf. LICENSE file
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--             2010  Carnegie Mellon University
--             2010  Intel Labs Pittsburgh
------------------------------------------------------------------------

require("fawkes.modinit")

--- Skill module auto-generator for ROS simple actions.
-- This module can automatically generate skill modules for simple ROS
-- actions which do not need special treatment.
-- @author Tim Niemueller
module(..., fawkes.modinit.module_init)

local skillenv = require("skiller.skillenv")
require("actionlib")
require("skiller.ros.action_jumpstate")
require("skiller.ros.multi_action_jumpstate")
require("skiller.skillhsm")
require("skiller.ros.action_skill")
--require("herb_skills.utils.armctrl")
require("fawkes.fsm.jumpstate")
local ActionJumpState = skiller.ros.action_jumpstate.ActionJumpState
local MultiActionJumpState = skiller.ros.multi_action_jumpstate.MultiActionJumpState
local JumpState = assert(fawkes.fsm.jumpstate.JumpState, "JumpState not specified!?")
local SkillHSM = skiller.skillhsm.SkillHSM

debug = skiller.ros.action_skill.debug

local reserved= { left = false, right = false }

local function is_free(side)
   --printf("Checking reserved[%s] = %s", side, tostring(reserved[side]))
   return not reserved[side]
end

local function reserve(side)
   print_debug("Reserving %s", side)
   assert(not reserved[side], "Arm already reserved")
   reserved[side] = true
end

local function free(side)
   print_debug("Freeing %s", side)
   reserved[side] = false
end

local function can_start()
   return reserved.left and reserved.right
end

function opposite_side(side)
   if side == "left" then return "right" else return "left" end
end

function use(module_name, action_name, action_type)
   local M = {}
   local skill_name       = module_name:match(".([%w%d_]+)$")
   local action_var_base  = skill_name
   local action_spec      = actionlib.get_actionspec(action_type)
   local state_base       = skill_name:upper()

   local action_name_left  = "/manipulation/left_arm/" .. action_name
   local action_name_right = "/manipulation/right_arm/" .. action_name
   local action_var_left   = action_var_base.."_left"
   local action_var_right  = action_var_base.."_right"
   local state_left        = state_base .. "_LEFT"
   local state_right       = state_base .. "_RIGHT"

   skillenv.module_init(M)
   M.name = skill_name
   M.fsm  = SkillHSM:new{name=M.name, start="WAIT_GOALS", debug=debug}
   M.depends_actions = {
      {v=action_var_left,  name=action_name_left,  type=action_type},
      {v=action_var_right, name=action_name_right, type=action_type},
      {v="noop_left",  name="/manipulation/left_arm/none",  type="manipapp_msgs/NonObjectSpecific"},
      {v="noop_right", name="/manipulation/right_arm/none", type="manipapp_msgs/NonObjectSpecific"}
   }
   M.depends_topics = {
      {v="objects", name="/manipulation/obj_list", type="manipapp_msgs/ObjectActions", latching=true}
   }
   M.documentation = "Autogenerated skill for the " .. action_name .. " ("
      .. action_type .. ") arm action.\nThe skill provides the following "
      .. "parameters which you must\npass as named arguments to the skill "
      .. "call.\n\n"
      .. "side=left/right\n"
      .. skiller.ros.action_skill.param_doc(action_spec.goal_spec.fields)

   skillenv.skill_module(M)

   M.fsm:define_states{ export_to=M,
      closure={is_free=is_free, can_start=can_start},
      {"WAIT_GOALS", JumpState},
      {"ASSUME_NOOP", JumpState},
      {state_left  .. "_NOOP", MultiActionJumpState, action_clients={M[action_var_left], M["noop_right"]}},
      {state_right .. "_NOOP", MultiActionJumpState, action_clients={M[action_var_right], M["noop_left"]}},
      {state_left,  ActionJumpState, action_client=M[action_var_left]},
      {state_right, ActionJumpState, action_client=M[action_var_right]}
   }

   M.fsm:add_transitions{
      {"WAIT_GOALS", "FAILED", "vars.side ~= \"left\" and vars.side ~= \"right\"", precond_only=true},
       --timeout={5, "FAILED", error="No second goal"},
       --precond_only=true, dotattr={labelrotate=-90}},
      {"WAIT_GOALS", "ASSUME_NOOP", timeout=1},
      {"WAIT_GOALS", "FAILED", "not is_free(vars.side)", precond_only=true},
       --precond_only=true, dotattr={labelrotate=-90}},
      {"WAIT_GOALS", state_left,  "can_start() and vars.side == \"left\""},
      {"WAIT_GOALS", state_right, "can_start() and vars.side == \"right\""},
      {"ASSUME_NOOP", state_left.."_NOOP",  "vars.side == \"left\""},
      {"ASSUME_NOOP", state_right.."_NOOP", "vars.side == \"right\""},
      {state_left.."_NOOP",  "FAILED",  "not is_free(\"right\")", precond_only=true},
      {state_right.."_NOOP", "FAILED",  "not is_free(\"left\")",  precond_only=true},
   }


   M.WAIT_GOALS.init =
      function (self)
	 reserve(self.fsm.vars.side)
	 M.determine_object(self)
      end

   M.determine_object =
      function (state)
	 if not state.fsm.vars.object_id then return end

	 if #M.objects.messages > 0 then
	    local m = M.objects.messages[#M.objects.messages] -- only check most recent
	    for i,o in ipairs(m.values.object_id) do
	       if o:match(state.fsm.vars.object_id) then
		  state.fsm.vars.object_id = o
		  break
	       end
	    end
	 end
      end

   M[state_left].init  = M.determine_object
   M[state_right].init = M.determine_object

   M[state_left.."_NOOP"].init =
      function (self)
	 M.determine_object(self)
	 self.fsm.vars.assume_noop = true
	 reserve("right")
	 self.fsm.vars[self.name .. ":" .. M[action_var_left].name] = self.fsm.vars
	 self.fsm.vars[self.name .. ":" .. M["noop_right"].name] = {side = "right"}
      end

   M[state_right.."_NOOP"].init =
      function (self)
	 M.determine_object(self)
	 self.fsm.vars.assume_noop = true
	 reserve("left")
	 self.fsm.vars[self.name .. ":" .. M[action_var_right].name] = self.fsm.vars
	 self.fsm.vars[self.name .. ":" .. M["noop_left"].name] = {side = "left"}
      end

   M.reset =
      function ()
	 if M.fsm.vars.side then
	    free(M.fsm.vars.side)
	    if M.fsm.vars.assume_noop then
	       free(opposite_side(M.fsm.vars.side))
	    end
	 end
	 M.fsm:reset()
      end

   _G[module_name] = M
   package.loaded[module_name] = M

   skillenv.use_skill(module_name)

   return M
end
