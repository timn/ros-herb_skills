
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
depends_skills  = { "lockenv", "releaseenv", "grab", "pickup", "noop" }
depends_actions = nil

documentation      = [==[Grab object skill.

grab_object{object_id="..."}
]==]

-- Initialize as skill module
skillenv.skill_module(_M)

-- FINAL and FAILED states are created implicitly by SkillHSM
fsm:define_states{ export_to=_M,
   {"LOCK_ENV",    SkillJumpState, skill=lockenv,             final_state="GRAB",
    failtrans_dotattr={labelrotate=-90}, fintrans_dotattr={labeloffsetx=20}},
   {"GRAB",        SkillJumpState, skills={{grab}, {noop}},   final_state="PICKUP",
    failtrans_dotattr={labelrotate=-90, labeloffsety=40, labeloffsetx=-5}, fintrans_dotattr={labeloffsetx=20, labeloffsety=-5}},
   {"PICKUP",      SkillJumpState, skills={{pickup}, {noop}}, final_state="RELEASE_ENV",
    failtrans_dotattr={labelrotate=-72, labeloffsety=60}, fintrans_dotattr={labeloffsetx=0, labeloffsety=-10}},
   {"RELEASE_ENV", SkillJumpState, skill=releaseenv,          final_state="FINAL",
    failtrans_dotattr={labelrotate=-22, labeloffsetx=-75, labeloffsety=13}, fintrans_dotattr={labelrotate=-22, labeloffsetx=-125, labeloffsety=55}},

}

function opposite_side(side)
   if side == "left" then return "right" else return "left" end
end

function GRAB:init()
   self.skills[1].args = { side=self.fsm.vars.side,
			   object_id = self.fsm.vars.object_id}
   self.skills[2].args = { side=opposite_side(self.fsm.vars.side) }
end

function PICKUP:init()
   self.skills[1].args = { side=self.fsm.vars.side,
			   object_id = self.fsm.vars.object_id}
   self.skills[2].args = { side=opposite_side(self.fsm.vars.side) }
end
