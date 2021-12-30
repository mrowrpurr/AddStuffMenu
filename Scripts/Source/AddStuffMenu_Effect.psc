scriptName AddStuffMenu_Effect extends ActiveMagicEffect

AddStuffMenu property _AddStuffMenu auto

event OnEffectStart(Actor target, Actor caster)
    _AddStuffMenu.Search()
endEvent
