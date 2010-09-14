
----------------------------------------------------------------------------
--  reset_arms.lua - Herb skill to reset both arms
--
--  Created: Thu Sep  2 18:09:42 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "reset_arms"
fsm             = SkillHSM:new{name=name, start="GOINITIAL_LEFT"}
depends_skills  = { "goinitial", "noop" }
depends_actions = nil

documentation      = [==[Reset both arms.

Will call GoInitial on both arms one after another.

reset_arms()
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

-- FINAL and FAILED states are created implicitly by SkillHSM
fsm:define_states{ export_to=_M,
   {"GOINITIAL_LEFT",  SkillJumpState, final_state="GOINITIAL_RIGHT", skills={{goinitial, {side="left"}}}},
   {"GOINITIAL_RIGHT", SkillJumpState, final_state="FINAL", skills={{goinitial, {side="right"}}}}
}
