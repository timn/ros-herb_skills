
----------------------------------------------------------------------------
--  put.lua - Herb skill to put with envlock
--
--  Created: Mon Sep 27 19:55:47 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "put"
fsm             = SkillHSM:new{name=name, start="LOCK_ENV"}
depends_skills  = { "lockenv", "releaseenv", "put_unlocked" }
depends_actions = nil
depends_topics  = nil

documentation      = [==[Put object skill with environment lock.

put{side="left|right", object_id="..."}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

-- FINAL and FAILED states are created implicitly by SkillHSM
fsm:define_states{ export_to=_M,
   {"LOCK_ENV",     SkillJumpState, skill=lockenv, final_state="PUT"},
   {"PUT",          SkillJumpState, skill=put_unlocked,
      final_state="RELEASE_ENV", failure_state="FAIL_RELEASE"},
   {"RELEASE_ENV",  SkillJumpState, skill=releaseenv,  final_state="FINAL"},
   {"FAIL_RELEASE", SkillJumpState, skill=releaseenv, final_state="FAILED"},
}
