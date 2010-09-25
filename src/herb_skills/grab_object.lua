
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
fsm             = SkillHSM:new{name=name, start="DETECT_OBJECT"}
depends_skills  = { "lockenv", "releaseenv", "grab", "pickup", "noop", "open_hand" }
depends_actions = nil
depends_topics     = {
   { v="objects",  name="/manipulation/obj_list",   type="manipulationapplet/ObjectActions", latching=true },
}


documentation      = [==[Grab object skill.

grab_object{object_id="..."}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

-- FINAL and FAILED states are created implicitly by SkillHSM
fsm:define_states{ export_to=_M,
   {"DETECT_OBJECT",  JumpState},
   {"LOCK_ENV",       SkillJumpState, skill=lockenv, final_state="VERIFY_OBJECT"},
   {"VERIFY_OBJECT",  JumpState},
   {"DETECT_RETRY",   SkillJumpState, skill=releaseenv,  final_state="DETECT_OBJECT"},
   {"GRAB",           SkillJumpState, skill=grab,   final_state="PICKUP", failure_state="FAIL_RELEASE"},
   {"PICKUP",         SkillJumpState, skill=pickup, final_state="RELEASE_ENV", failure_state="FAIL_RELEASE"},
   {"RELEASE_ENV",    SkillJumpState, skill=releaseenv,  final_state="FINAL"},
   {"FAIL_RELEASE",   SkillJumpState, skill=releaseenv, final_state="FAIL_GOINITIAL"},
   {"FAIL_GOINITIAL", SkillJumpState, skill=releaseenv, final_state="FAILED"},
   --{"GRAB_RETRY",     SkillJumpState, skill=open_hand, final_state="GRAB"},
   --{"PICKUP_RETRY",   SkillJumpState, skill=releaseenv, final_state="PICKUP"},
}

fsm:add_transitions{
   -- Transitions to ensure we only retry once
   {"DETECT_OBJECT", "FAILED", "not vars.object_id", desc="no object_id given", precond_only=true},
   {"DETECT_OBJECT", "LOCK_ENV", "vars.found_object"},
   {"DETECT_OBJECT", "FAILED", timeout=20},
   {"VERIFY_OBJECT", "DETECT_RETRY", timeout=10},
   {"VERIFY_OBJECT", "DETECT_RETRY", "vars.object_disappeared"},
   {"VERIFY_OBJECT", "GRAB", "vars.found_object"},
   --{"GRAB_RETRY", "FAIL_RELEASE", "fsm:traced(self.name)", precond_only=true},
   --{"PICKUP_RETRY", "FAIL_RELEASE", "fsm:traced(self.name)", precond_only=true},
}

function DETECT_OBJECT:init()
   if not self.fsm.vars.original_object_id then
      self.fsm.vars.original_object_id = self.fsm.vars.object_id
   else
      self.fsm.vars.object_id = self.fsm.vars.original_object_id
   end
   self.fsm.vars.found_object = false
end
function VERIFY_OBJECT:init()
   self.fsm.vars.found_object = false
end

function DETECT_OBJECT:loop()
   if #objects.messages > 0 then
      local m = objects.messages[#objects.messages] -- only check most recent
      for i,o in ipairs(m.values.object_id) do
         --printf("Comparing %s / %s / %s", o, m.values.poss_act[i], m.values.side[i])
         if o:match(self.fsm.vars.original_object_id) and m.values.poss_act[i] == "grab" then
            self.fsm.vars.side         = m.values.side[i]
            self.fsm.vars.object_id    = o
            self.fsm.vars.found_object = true
            break
         end
      end
      if not self.fsm.vars.found_object then
	 self.fsm.vars.object_disappeared = true
      end
   end
end
VERIFY_OBJECT.loop = DETECT_OBJECT.loop
