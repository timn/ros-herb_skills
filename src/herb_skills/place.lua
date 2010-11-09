
----------------------------------------------------------------------------
--  place.lua - Herb skill to place with envlock
--
--  Created: Mon Sep 27 19:52:40 2010 (at Intel Research, Pittsburgh)
--  License: BSD, cf. LICENSE file
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--             2010  Carnegie Mellon University
--             2010  Intel Labs Pittsburgh
----------------------------------------------------------------------------

-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "place"
fsm             = SkillHSM:new{name=name, start="LOCK_ENV"}
depends_skills  = { "lockenv", "releaseenv", "place_unlocked" }
depends_actions = nil
depends_topics  = nil

documentation      = [==[Place object skill with environment lock.

place{side="left|right", object_id="..."}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

-- FINAL and FAILED states are created implicitly by SkillHSM
fsm:define_states{ export_to=_M,
   {"LOCK_ENV",       SkillJumpState, skill=lockenv, final_state="PLACE"},
   {"PLACE",          SkillJumpState, skill=place_unlocked,
      final_state="RELEASE_ENV", failure_state="FAIL_RELEASE"},
   {"RELEASE_ENV",    SkillJumpState, skill=releaseenv,  final_state="FINAL"},
   {"FAIL_RELEASE",   SkillJumpState, skill=releaseenv, final_state="FAILED"},
}
