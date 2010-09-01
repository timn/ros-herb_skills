
----------------------------------------------------------------------------
--  grab.lua - Herb grab skill
--
--  Created: Wed Sep 01 11:56:17 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

-- *************************************************************************
-- NOTE: This skill does only exist for your reference, it is _not_ actually
-- used, as for simple actions herb_skills.armskill.use() creates the module
-- on the fly!
-- *************************************************************************
error("This implementation should not be used")


-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "grab"
fsm             = SkillHSM:new{name=name, start="WAIT_GOALS"}
depends_skills  = nil
depends_actions = {
   {v = "grab_left",  name = "/manipulation/left_arm/grab", type="manipulationapplet/Grab" },
   {v = "grab_right",  name = "/manipulation/right_arm/grab", type="manipulationapplet/Grab" }
}

documentation      = [==[Grab object skill.
Grab an object.

say{side="left"/"right", object_id="..."}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

require("herb_skills.utils.armctrl")

fsm:define_states{
   export_to=_M,
   closure={armctrl=herb_skills.utils.armctrl},
   {"WAIT_GOALS", JumpState},
   {"GRAB_LEFT",  ActionJumpState, action_client=grab_left},
   {"GRAB_RIGHT", ActionJumpState, action_client=grab_right}
}

fsm:add_transitions{
   {"WAIT_GOALS", "FAILED", "vars.side ~= \"left\" and vars.side ~= \"right\"", precond_only=true},
   {"WAIT_GOALS", "FAILED", "not armctrl.is_free(vars.side)", precond_only=true},
   {"WAIT_GOALS", "GRAB_LEFT",  "armctrl.can_start() and vars.side == \"left\""},
   {"WAIT_GOALS", "GRAB_RIGHT", "armctrl.can_start() and vars.side == \"right\""},
}


function WAIT_GOALS:init()
   herb_skills.utils.armctrl.reserve(self.fsm.vars.side)
end

function reset()
   if fsm.vars.side then
      herb_skills.utils.armctrl.free(fsm.vars.side)
   end
   fsm:reset()
end
