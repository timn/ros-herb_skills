
----------------------------------------------------------------------------
--  grab_object.lua - Herb skill to grab and pickup an object
--
--  Created: Thu Sep  2 16:50:05 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "grab_object"
fsm             = SkillHSM:new{name=name, start="LOCK_ENV"}
depends_skills  = { "lockenv", "releaseenv", "grab", "pickup", "noop", "open_hand" }
depends_actions = nil

documentation      = [==[Grab object skill.

grab_object{object_id="..."}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

-- FINAL and FAILED states are created implicitly by SkillHSM
fsm:define_states{ export_to=_M,
   {"LOCK_ENV",     SkillJumpState, skill=lockenv, final_state="GRAB"},
   {"GRAB",         SkillJumpState, skill=grab,   final_state="PICKUP", failure_state="FAIL_RELEASE"},
   {"PICKUP",       SkillJumpState, skill=pickup, final_state="RELEASE_ENV", failure_state="FAIL_RELEASE"},
   {"RELEASE_ENV",  SkillJumpState, skill=releaseenv,  final_state="FINAL"},
   {"FAIL_RELEASE", SkillJumpState, skill=releaseenv, final_state="FAIL_GOINITIAL"},
   {"FAIL_GOINITIAL", SkillJumpState, skill=releaseenv, final_state="FAILED"},
   {"GRAB_RETRY",   SkillJumpState, skill=open_hand, final_state="GRAB"},
   {"PICKUP_RETRY", SkillJumpState, skill=releaseenv, final_state="PICKUP"},
}

fsm:add_transitions{
   -- Transitions to ensure we only retry once
   {"GRAB_RETRY", "FAIL_RELEASE", "fsm:traced(self.name)", precond_only=true},
   {"PICKUP_RETRY", "FAIL_RELEASE", "fsm:traced(self.name)", precond_only=true},
}
