
----------------------------------------------------------------------------
--  init.lua - Herb skills initialization file
--
--  Created: Fri Aug 20 18:25:22 2010 (at Intel Research, Pittsburgh)
--  License: BSD
--  Copyright  2010  Tim Niemueller [www.niemueller.de]
--
----------------------------------------------------------------------------

require("fawkes.modinit")
module(..., fawkes.modinit.register_all);

skillenv = require("skiller.skillenv")
require("skiller.skillhsm")

skillenv.use_skill("herb_skills.say")
