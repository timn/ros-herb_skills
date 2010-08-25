
----------------------------------------------------------------------------
--  init.lua - Herb skills initialization file
--
--  Created: Fri Aug 20 18:25:22 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "say"
fsm             = SkillHSM:new{name=name, start="WAIT_SERVER"}
depends_skills  = nil
depends_actions = {
   {v = "talker", name = "/talker", type="talkerapplet/Say" }
}

documentation      = [==[Speech synthesis skill.
Say some string via a speech synthesis device.
and disable the servos by using the following form:

say{text="...", wait=true/false/nil}
]==]

-- Initialize as skill module
skillenv.skill_module(...)

function action_trans(from, to, state_to)
   local state_to = state_to or to
   return {from, state_to, "vars.goal and vars.goal.state == vars.goal." .. to, desc="["..to.."]"}
end

-- States
fsm:add_transitions{
   --closure={talker=talker},
   {"WAIT_SERVER", "WAIT_GOAL_ACK", "vars.acl:has_server()", timeout={10, "FAILED"}},
   action_trans("WAIT_GOAL_ACK", "PENDING"),
   action_trans("WAIT_GOAL_ACK", "ACTIVE"),
   action_trans("WAIT_GOAL_ACK", "WAIT_CANCEL_ACK"),
   action_trans("WAIT_GOAL_ACK", "REJECTED", "FAILED"),
   action_trans("WAIT_GOAL_ACK", "RECALLING"),
   action_trans("WAIT_GOAL_ACK", "PREEMPTING"),
   action_trans("WAIT_GOAL_ACK", "WAIT_RESULT"),
   action_trans("WAIT_GOAL_ACK", "SUCCEEDED", "FINAL"),
   action_trans("PENDING", "ACTIVE"),
   action_trans("PENDING", "RECALLING"),
   action_trans("PENDING", "PREEMPTING"),
   action_trans("PENDING", "REJECTED", "FAILED"),
   action_trans("PENDING", "WAIT_CANCEL_ACK"),
   action_trans("PENDING", "WAIT_RESULT"),
   action_trans("PENDING", "SUCCEEDED", "FINAL"),
   action_trans("ACTIVE", "WAIT_CANCEL_ACK"),
   action_trans("ACTIVE", "PREEMPTING"),
   action_trans("ACTIVE", "RECALLING"),
   action_trans("ACTIVE", "WAIT_RESULT"),
   action_trans("ACTIVE", "SUCCEEDED", "FINAL"),
   action_trans("ACTIVE", "ABORTED", "FAILED"),
   action_trans("WAIT_CANCEL_ACK", "RECALLING"),
   action_trans("WAIT_CANCEL_ACK", "PREEMPTING"),
   action_trans("WAIT_CANCEL_ACK", "RECALLED", "FAILED"),
   action_trans("WAIT_CANCEL_ACK", "PREEMPTED", "FAILED"),
   action_trans("RECALLING", "PREEMPTING"),
   action_trans("RECALLING", "RECALLED", "FAILED"),
   action_trans("PREEMPTING", "PREEMPTED", "FAILED"),
   action_trans("PREEMPTING", "ABORTED", "FAILED"),
   action_trans("WAIT_RESULT", "SUCCEEDED", "FINAL"),

   --[[
   {"WAIT_GOAL_ACK", "PENDING", "vars.goal and vars.goal.state == vars.goal.PENDING"},
   {"WAIT_GOAL_ACK", "ACTIVE", "vars.goal and vars.goal.state == vars.goal.ACTIVE"},
   {"WAIT_GOAL_ACK", "WAIT_CANCEL_ACK", "vars.goal and vars.goal.state == vars.goal.WAIT_CANCEL_ACK"},
   {"PENDING", "ACTIVE", "vars.goal and vars.goal.state == vars.goal.ACTIVE"},
   {"PENDING", "RECALLING", "vars.goal and vars.goal.state == vars.goal.RECALLING"},
   {"PENDING", "WAIT_CANCEL_ACK", "vars.goal and vars.goal.state == vars.goal.WAIT_CANCEL_ACK"},
   {"PENDING", "WAIT_RESULT", "vars.goal and vars.goal.state == vars.goal.WAIT_RESULT"},
   {"ACTIVE", cond = "vars.goal and vars.goal.state == vars.goal.ACTIVE"},
   {"RECALLING", cond = "vars.goal and vars.goal.state == vars.goal.RECALLING"},
   {"PREEMPTING", cond = "vars.goal and vars.goal.state == vars.goal.PREEMPTING"},
   {"WAIT_RESULT", cond = "vars.goal and vars.goal.state == vars.goal.WAIT_RESULT"},
   {"ABORTED", cond = "vars.goal and vars.goal.state == vars.goal.ABORTED"},
   {"PREEMPTED", cond = "vars.goal and vars.goal.state == vars.goal.PREEMPTED"},
   {"RECALLED", cond = "vars.goal and vars.goal.state == vars.goal.RECALLED"},
   {"REJECTED", cond = "vars.goal and vars.goal.state == vars.goal.REJECTED"},
   {"SUCCEEDED", cond = "vars.goal and vars.goal.state == vars.goal.SUCCEEDED"},
   {"SUCCEEDED", "FINAL", true, precond=true},
   {"REJECTED", "FAILED", true, precond=true},
   {"RECALLED", "FAILED", true, precond=true},
   {"PREEMPTED", "FAILED", true, precond=true},
   {"ABORTED", "FAILED", true, precond=true}
   --]]
}


function WAIT_SERVER:init()
   self.fsm.vars.acl = actionlib.action_client("/talker", "talkerapplet/Say")
end

function WAIT_GOAL_ACK:init()
   local vars = self.fsm.vars
   local goal = vars.acl.actspec.goal_spec:instantiate()
   goal.values.text = vars.text or vars[1]
   vars.goal = vars.acl:send_goal(goal)
end
