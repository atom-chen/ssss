
--------------------------------
-- @module FightManager
-- @extend Ref
-- @parent_module sgzj

--------------------------------
-- 
-- @function [parent=#FightManager] removeFightNode 
-- @param self
-- @param #sgzj.FightNode node
-- @return FightManager#FightManager self (return value: sgzj.FightManager)
        
--------------------------------
-- 
-- @function [parent=#FightManager] handleAttack 
-- @param self
-- @param #sgzj.FightNode att
-- @param #sgzj.FightNode target
-- @param #int dtype
-- @param #float damage
-- @param #bool back
-- @return FightManager#FightManager self (return value: sgzj.FightManager)
        
--------------------------------
-- 
-- @function [parent=#FightManager] addFightNode 
-- @param self
-- @param #sgzj.FightNode node
-- @return FightManager#FightManager self (return value: sgzj.FightManager)
        
--------------------------------
-- 
-- @function [parent=#FightManager] handleAOE 
-- @param self
-- @param #sgzj.FightNode att
-- @param #int dtype
-- @param #float damage
-- @param #float range
-- @return FightManager#FightManager self (return value: sgzj.FightManager)
        
--------------------------------
-- 
-- @function [parent=#FightManager] flushDamage 
-- @param self
-- @return FightManager#FightManager self (return value: sgzj.FightManager)
        
--------------------------------
-- 
-- @function [parent=#FightManager] getInstance 
-- @param self
-- @return FightManager#FightManager ret (return value: sgzj.FightManager)
        
return nil
