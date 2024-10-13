require 'busted.runner'()

describe("labRenderers", function()
    local labRenderers

    local force0 = {
        index = 0,
    }

    local force1 = {
        index = 1,
    }

    local lab0 = {
        type = "lab",
        name = "lab",
        valid = true,
        unit_number = 0,
        force = force0,
    }

    local lab1 = {
        type = "lab",
        name = "lab",
        valid = true,
        unit_number = 1,
        force = force1,
    }

    local nonLab = {
        type = "tool",
        name = "hammer",
        valid = true,
        unit_number = 1,
        force = force0,
    }

    local invalidLab = {
        type = "lab",
        name = "lab",
        valid = false,
        unit_number = 1,
        force = force0,
    }

    local otherLab = {
        type = "lab",
        name = "fancy-lab",
        valid = true,
        unit_number = 1,
        force = force0,
    }

    setup(function()
        _G.game = require("spec.mocks.game")
        _G.game.forces = {force0, force1}
        _G.rendering = require("spec.mocks.rendering")
        _G.script = require("spec.mocks.script")
        _G.serpent = require("serpent")
        labRenderers = require("core.labRenderers")
    end)

    before_each(function()
        labRenderers.linkState({
            labsByForce = {},
            labAnimations = {},
            labScales = {
                ["lab"] = 1,
            },
        })
        rendering.resetMock()
        stub(softErrorReporting, "showModError")
    end)

    after_each(function()
        softErrorReporting.showModError:revert()
    end)

    teardown(function()
        labRenderers = nil
    end)

    it("has the same initial state", function()
        assert.same(labRenderers.state, labRenderers.initialState)
    end)

    describe("setLabScale", function()
        it("adds a new entry", function()
            labRenderers.setLabScale("bogus", 10)
            assert.equal(10, labRenderers.state.labScales["bogus"])
        end)

        it("modifies an existing entry", function()
            labRenderers.setLabScale("bogus", 10)
            labRenderers.setLabScale("bogus", 20)
            assert.equal(20, labRenderers.state.labScales["bogus"])
        end)

        it("removes an existing entry", function()
            labRenderers.setLabScale("bogus", 10)
            assert.equal(10, labRenderers.state.labScales["bogus"])
            labRenderers.setLabScale("bogus", nil)
            assert.is_nil(labRenderers.state.labScales["bogus"])
        end)
    end)

    describe("isCompatibleLab", function()
        it("accepts a regular lab", function()
            assert.is_true(labRenderers.isCompatibleLab(lab0))
        end)

        it("rejects other labs", function()
            assert.is_false(labRenderers.isCompatibleLab(otherLab))
        end)
    end)

    describe("addLab", function()
        it("adds a lab and creates render objects", function()
            labRenderers.addLab(lab0)
            assert.stub(softErrorReporting.showModError).was_not.called()
            assert.truthy(labRenderers.state.labsByForce[lab0.force.index])

            local lab = labRenderers.state.labsByForce[lab0.force.index][lab0.unit_number]
            assert.truthy(labRenderers.state.labsByForce[lab0.force.index][lab0.unit_number])

            local animationId = labRenderers.state.labAnimations[lab0.unit_number]
            assert.truthy(animationId)
            assert.is_true(rendering.is_valid(animationId))
        end)

        it("adds labs in separate forces", function()
            labRenderers.addLab(lab0)
            labRenderers.addLab(lab1)
            assert.truthy(labRenderers.state.labsByForce[lab0.force.index])
            assert.truthy(labRenderers.state.labsByForce[lab1.force.index])
            assert.not_nil(next(labRenderers.state.labsByForce[lab0.force.index]))
            assert.not_nil(next(labRenderers.state.labsByForce[lab1.force.index]))
            assert.not_equal(labRenderers.state.labsByForce[lab0.force.index], labRenderers.state.labsByForce[lab1.force.index])
        end)

        it("won't add a non-lab", function()
            labRenderers.addLab(nonLab)
            assert.is_nil(next(labRenderers.state.labsByForce))
        end)

        it("won't add a lab by any other name", function()
            labRenderers.addLab(otherLab)
            assert.is_nil(next(labRenderers.state.labsByForce))
        end)

        it("errors when attempting to add a nil entity", function()
            labRenderers.addLab(nil)
            assert.stub(softErrorReporting.showModError).was.called_with("errors.unregistered-entity-created")
        end)

        it("errors when attempting to add an invalid lab", function()
            labRenderers.addLab(invalidLab)
            assert.stub(softErrorReporting.showModError).was.called_with("errors.unregistered-entity-created")
        end)

        it("errors instead of adding a lab twice", function()
            labRenderers.addLab(lab0)
            labRenderers.addLab(lab0)
            assert.stub(softErrorReporting.showModError).was.called_with("errors.lab-registered-twice")
        end)
    end)

    describe("removeLab", function()
        it("removes lab and its rendering objects", function()
            labRenderers.addLab(lab0)
            labRenderers.removeLab(lab0.unit_number)
            assert.stub(softErrorReporting.showModError).was_not.called()

            assert.is_nil(next(labRenderers.labsForForce(lab0.force.index)))
            assert.is_nil(next(labRenderers.state.labAnimations))
        end)

        it("errors when an unregistered lab is removed", function()
            labRenderers.removeLab(lab0.unit_number)
            assert.stub(softErrorReporting.showModError).was.called_with("errors.unregistered-lab-deleted")
        end)

        it("errors when an unregistered lab is removed, even if force exists", function()
            labRenderers.addLab(lab0)
            labRenderers.removeLab(lab0.unit_number)
            labRenderers.removeLab(lab0.unit_number)
            assert.stub(softErrorReporting.showModError).was.called_with("errors.unregistered-lab-deleted")
        end)
    end)

    describe("getRenderObjects", function()
        it("gets valid render objects for lab", function()
            labRenderers.addLab(lab0)
            local animationId = labRenderers.getRenderObjects(lab0)
            assert.is_true(rendering.is_valid(animationId))
        end)

        it("errors if animation was destroyed, and creates new animation", function()
            labRenderers.addLab(lab0)
            rendering.destroy(labRenderers.state.labAnimations[lab0.unit_number])
            local animationId = labRenderers.getRenderObjects(lab0)
            assert.stub(softErrorReporting.showModError).was.called_with("errors.render-object-destroyed")
            assert.is_true(rendering.is_valid(animationId))
        end)
    end)
end)