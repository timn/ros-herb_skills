
----------------------------------------------------------------------------
--  init.lua - Herb skills initialization file
--
--  Created: Fri Aug 20 18:25:22 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------


-- *************************************************************************
-- NOTE: This skill does only exist for your reference, it is _not_ actually
-- used, as for simple actions skiller.ros.action_module.create() creates
-- the module on the fly!
-- *************************************************************************
error("This implementation should not be used")


-- Initialize module
module(..., skillenv.module_init)

-- Crucial skill information
name            = "say"
fsm             = SkillHSM:new{name=name, start="SAY"}
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
skillenv.skill_module(_M)

fsm:define_states{ export_to=_M,
   {"SAY", ActionJumpState, action_client=talker}
}
