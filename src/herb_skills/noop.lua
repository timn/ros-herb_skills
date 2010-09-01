
----------------------------------------------------------------------------
--  noop.lua - Herb noop skill
--
--  Created: Wed Sep 01 16:07:59 2010 (at Intel Research, Pittsburgh)
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
name            = "noop"
fsm             = SkillHSM:new{name=name, start="WAIT_GOALS"}
depends_skills  = nil
depends_actions = {
   {v = "noop_left",  name = "/manipulation/left_arm/none", type="manipulationapplet/NoOp" },
   {v = "noop_right",  name = "/manipulation/right_arm/none", type="manipulationapplet/NoOp" }
}

documentation      = [==[Do nothing with an arm.
noop{side="left"/"right"}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

require("herb_skills.utils.armctrl")

fsm:define_states{
   export_to=_M,
   closure={armctrl=herb_skills.utils.armctrl},
   {"WAIT_GOALS", JumpState},
   {"NOOP_LEFT",  ActionJumpState, action_client=noop_left},
   {"NOOP_RIGHT", ActionJumpState, action_client=noop_right}
}

fsm:add_transitions{
   {"WAIT_GOALS", "FAILED", "vars.side ~= \"left\" and vars.side ~= \"right\"", precond_only=true},
   {"WAIT_GOALS", "FAILED", "not armctrl.is_free(vars.side)", precond_only=true},
   {"WAIT_GOALS", "NOOP_LEFT",  "armctrl.can_start() and vars.side == \"left\""},
   {"WAIT_GOALS", "NOOP_RIGHT", "armctrl.can_start() and vars.side == \"right\""},
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
