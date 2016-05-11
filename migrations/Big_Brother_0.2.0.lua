for _, force in pairs(game.forces) do
    force.recipes['big_brother-surveillance-center'].enabled = force.technologies["surveillance"].researched 
end
